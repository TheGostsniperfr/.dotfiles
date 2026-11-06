{ userSettings, ... }:

{
  sops.secrets.arffornia_tf_backend = {
    owner = userSettings.username;
    mode = "0400";
  };

  systemd.tmpfiles.rules = [
    "L+ /home/${userSettings.username}/.config/arffornia/tf-backend.env - - - - /run/secrets/arffornia_tf_backend"
  ];
}
