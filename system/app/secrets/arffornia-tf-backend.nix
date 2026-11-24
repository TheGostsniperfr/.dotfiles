{ userSettings, ... }:

{
  sops.secrets.arffornia_tf_backend = {
    owner = userSettings.username;
    mode = "0400";
  };

  # tmpfiles creates missing parents as root, which on a fresh home leaves
  # ~/.config root-owned and breaks home-manager activation.
  systemd.tmpfiles.rules = [
    "d /home/${userSettings.username}/.config 0755 ${userSettings.username} users - -"
    "d /home/${userSettings.username}/.config/arffornia 0700 ${userSettings.username} users - -"
    "L+ /home/${userSettings.username}/.config/arffornia/tf-backend.env - - - - /run/secrets/arffornia_tf_backend"
  ];
}
