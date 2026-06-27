{ pkgs, lib, ... }:

let
  sync-konsole = pkgs.writeShellScriptBin "sync-konsole" ''
    echo "🔄 Syncing Konsole configuration to dotfiles..."

    DOT_DIR="$HOME/.dotfiles/user/app/konsole"

    cp -f "$HOME/.config/konsolerc" "$DOT_DIR/konsolerc" 2>/dev/null || true
    cp -f "$HOME/.local/share/konsole/Brian.profile" "$DOT_DIR/Brian.profile" 2>/dev/null || true
    cp -f "$HOME/.local/share/konsole/WhiteOnBlack.colorscheme" "$DOT_DIR/WhiteOnBlack.colorscheme" 2>/dev/null || true
    
    sync_xml() {
      FILE=$1
      F5="$HOME/.local/share/kxmlgui5/konsole/$FILE"
      F6="$HOME/.local/share/kxmlgui6/konsole/$FILE"
      DEST="$DOT_DIR/$FILE"

      if [ -f "$F6" ] && [ -f "$F5" ]; then
        if [ "$F6" -nt "$F5" ]; then
          cp -f "$F6" "$DEST"
        else
          cp -f "$F5" "$DEST"
        fi
      elif [ -f "$F6" ]; then
        cp -f "$F6" "$DEST"
      elif [ -f "$F5" ]; then
        cp -f "$F5" "$DEST"
      fi
    }

    sync_xml "konsoleui.rc"
    sync_xml "sessionui.rc"

    # 🧹 --- FIX KDE BUG --- 🧹
    # Remove the duplicate Ctrl+Shift+C assigned by Konsole GUI to edit_copy_contextmenu
    if [ -f "$DOT_DIR/sessionui.rc" ]; then
      ${pkgs.gnused}/bin/sed -i 's/<Action name="edit_copy_contextmenu" shortcut=".*"\/>/<Action name="edit_copy_contextmenu" shortcut=""\/>/g' "$DOT_DIR/sessionui.rc"
      echo "🧹 Cleaned up KDE duplicate shortcut bug."
    fi

    echo "✅ Sync complete. Run git add/commit in your dotfiles."
  '';
in
{
  home.packages = [
    pkgs.kdePackages.konsole
    sync-konsole
  ];

  home.activation.setupKonsole = lib.hm.dag.entryAfter ["writeBoundary"] ''
    KONSOLE_DIR="$HOME/.local/share/konsole"
    KXML5_DIR="$HOME/.local/share/kxmlgui5/konsole"
    KXML6_DIR="$HOME/.local/share/kxmlgui6/konsole"

    mkdir -p "$HOME/.config" "$KONSOLE_DIR" "$KXML5_DIR" "$KXML6_DIR"

    rm -f "$HOME/.config/konsolerc"
    rm -f "$KONSOLE_DIR/Brian.profile"
    rm -f "$KONSOLE_DIR/WhiteOnBlack.colorscheme"
    rm -f "$KXML5_DIR/konsoleui.rc"
    rm -f "$KXML5_DIR/sessionui.rc"
    rm -f "$KXML6_DIR/konsoleui.rc"
    rm -f "$KXML6_DIR/sessionui.rc"

    cp -f "${./konsolerc}" "$HOME/.config/konsolerc"
    cp -f "${./Brian.profile}" "$KONSOLE_DIR/Brian.profile"
    cp -f "${./WhiteOnBlack.colorscheme}" "$KONSOLE_DIR/WhiteOnBlack.colorscheme"

    cp -f "${./konsoleui.rc}" "$KXML5_DIR/konsoleui.rc"
    cp -f "${./sessionui.rc}" "$KXML5_DIR/sessionui.rc"

    cp -f "${./konsoleui.rc}" "$KXML6_DIR/konsoleui.rc"
    cp -f "${./sessionui.rc}" "$KXML6_DIR/sessionui.rc"

    chmod u+w "$HOME/.config/konsolerc"
    chmod u+w "$KONSOLE_DIR/Brian.profile"
    chmod u+w "$KONSOLE_DIR/WhiteOnBlack.colorscheme"
    chmod u+w "$KXML5_DIR/konsoleui.rc"
    chmod u+w "$KXML5_DIR/sessionui.rc"
    chmod u+w "$KXML6_DIR/konsoleui.rc"
    chmod u+w "$KXML6_DIR/sessionui.rc"
  '';
}