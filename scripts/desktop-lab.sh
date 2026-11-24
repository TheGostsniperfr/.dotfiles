#!/usr/bin/env bash
# Disposable QEMU copy of a host config for testing desktop changes.
# Usage: desktop-lab.sh {build|up|down|ssh [cmd]|run <cmd>|shot <name>|wait|reset|status}
set -euo pipefail

host="${LAB_HOST:-workstation}"
flake="${LAB_FLAKE:-$HOME/.dotfiles}"
state="${LAB_STATE:-$HOME/.cache/desktop-lab}"
shots="$state/shots"
qmp="$state/qmp.sock"
key="$state/id_ed25519"
ssh_opts=(-i "$key" -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=3)

mkdir -p "$state" "$shots"

qmp_cmd() {
  printf '{"execute":"qmp_capabilities"}\n%s\n' "$1" | socat - "UNIX-CONNECT:$qmp" | tail -n +2
}

is_up() { [ -S "$qmp" ] && qmp_cmd '{"execute":"query-status"}' >/dev/null 2>&1; }

case "${1:-}" in
  build)
    nix build "$flake#nixosConfigurations.$host.config.system.build.vm" --out-link "$state/result"
    ;;
  up)
    is_up && { echo "already running"; exit 0; }
    rm -f "$qmp"
    export NIX_DISK_IMAGE="$state/$host.qcow2"
    export QEMU_OPTS="-display none -vnc 127.0.0.1:5 -qmp unix:$qmp,server,nowait"
    nohup "$state/result/bin/run-$host-vm" >"$state/qemu.log" 2>&1 &
    echo $! >"$state/qemu.pid"
    echo "started (VNC on 127.0.0.1:5905, log $state/qemu.log)"
    ;;
  down)
    is_up && qmp_cmd '{"execute":"quit"}' >/dev/null 2>&1 || true
    # QEMU keeps the VNC and SSH ports until it has fully exited
    pid="$(cat "$state/qemu.pid" 2>/dev/null || true)"
    if [ -n "$pid" ]; then
      for _ in $(seq 1 30); do
        kill -0 "$pid" 2>/dev/null || break
        sleep 1
      done
      kill "$pid" 2>/dev/null || true
    fi
    rm -f "$qmp" "$state/qemu.pid"
    ;;
  wait)
    for _ in $(seq 1 180); do
      if ssh "${ssh_opts[@]}" "$USER@127.0.0.1" 'pgrep -f bin/plasmashell' >/dev/null 2>&1; then
        echo "plasma is up"; exit 0
      fi
      sleep 2
    done
    echo "timed out waiting for plasmashell" >&2; exit 1
    ;;
  ssh)
    shift
    exec ssh "${ssh_opts[@]}" "$USER@127.0.0.1" "$@"
    ;;
  run)
    shift
    # same environment as the Plasma session, like a command run from a shortcut
    exec ssh "${ssh_opts[@]}" "$USER@127.0.0.1" \
      "while IFS= read -r -d '' kv; do case \"\$kv\" in DISPLAY=*|XAUTHORITY=*|WAYLAND_DISPLAY=*|DBUS_SESSION_BUS_ADDRESS=*|XDG_*|KDE_*|QT_*|PATH=*) export \"\$kv\";; esac; done < /proc/\$(pgrep -of bin/plasmashell)/environ; $*"
    ;;
  shot)
    name="${2:?shot name required}"
    out="$shots/$name.png"
    # wake the output in case it blanked
    qmp_cmd '{"execute":"send-key","arguments":{"keys":[{"type":"qcode","data":"shift"}]}}' >/dev/null
    sleep 1
    qmp_cmd "{\"execute\":\"screendump\",\"arguments\":{\"filename\":\"$out\",\"format\":\"png\"}}" >/dev/null
    echo "$out"
    ;;
  reset)
    "$0" down
    rm -f "$state/$host.qcow2"
    ;;
  status)
    is_up && echo up || echo down
    ;;
  *)
    sed -n 3p "$0" >&2; exit 2
    ;;
esac
