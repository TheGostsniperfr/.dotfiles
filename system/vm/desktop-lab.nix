{
  lib,
  inputs,
  userSettings,
  ...
}:

# Only evaluated by `nixos-rebuild build-vm`; the real host is untouched.
# Driven by scripts/desktop-lab.sh, which adds QMP/VNC options via QEMU_OPTS.
{
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 6144;
      cores = 6;
      diskSize = 20480;
      resolution = {
        x = 1920;
        y = 1080;
      };
      # No NVIDIA in the guest: KWin composites with llvmpipe, which still
      # renders blur and rounded corners, just slower.
      qemu.options = [
        "-vga none"
        "-device virtio-vga,xres=1920,yres=1080"
      ];
      forwardPorts = [
        {
          from = "host";
          host.address = "127.0.0.1";
          host.port = 2222;
          guest.port = 22;
        }
      ];
    };

    services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];
    hardware.nvidia-container-toolkit.enable = lib.mkForce false;

    services.displayManager.autoLogin = {
      enable = true;
      user = userSettings.username;
    };
    services.displayManager.defaultSession = "plasma";

    users.users.${userSettings.username} = {
      initialPassword = "lab";
      openssh.authorizedKeys.keyFiles = [ ./desktop-lab.pub ];
    };
    services.openssh.enable = true;
    # Some activation steps read from ~/.dotfiles; give them the flake source
    # read-only instead of sharing the real checkout.
    systemd.tmpfiles.rules = [
      "L+ /home/${userSettings.username}/.dotfiles - - - - ${inputs.self}"
    ];
    security.sudo.wheelNeedsPassword = false;

    # A real API server so the launcher's kube commands can be exercised.
    services.k3s = {
      enable = true;
      extraFlags = [
        "--write-kubeconfig-mode=644"
        "--disable=traefik"
      ];
    };

    home-manager.users.${userSettings.username} = {
      # Example infras with fake URLs, VM only.
      infra.infras = lib.mkForce {
        lab-vm = {
          title = "Lab VM";
          env = "lab";
          kube = "default";
          links = {
            grafana = "https://grafana.lab.example";
            argocd = "https://argocd.lab.example";
            alertmanager = "https://alertmanager.lab.example";
          };
        };
        talos-prod = {
          title = "Talos prod";
          env = "prod";
          kube = "oidc@talos-prod";
          links = {
            grafana = "https://grafana.prod.example";
            argocd = "https://argocd.prod.example";
            vault = "https://vault.prod.example";
            ceph = "https://grafana.prod.example/d/ceph";
          };
        };
        ubsi-staging = {
          title = "UBSI staging";
          env = "staging";
          kube = "admin@ubsi-staging";
          links.grafana = "https://grafana.staging.example";
        };
      };

      # A blanked or locked screen makes every screenshot useless.
      programs.plasma = {
        kscreenlocker.autoLock = false;
        kscreenlocker.lockOnResume = false;
        # Night Color would tint every screenshot taken after sunset.
        configFile.kwinrc.NightColor.Active = lib.mkForce false;
        powerdevil.AC = {
          autoSuspend.action = "nothing";
          dimDisplay.enable = false;
          turnOffDisplay.idleTimeout = "never";
        };
      };
    };
  };
}
