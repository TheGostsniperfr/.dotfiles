{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.cifs-utils
  ];

  sops.secrets.nas_credentials = { };

  fileSystems."/media/raid5_proxmox" = {
    device = "//192.168.1.49/raid5_proxmox";
    fsType = "cifs";
    options = [ 
      "credentials=${config.sops.secrets.nas_credentials.path}"
      "rw"
      "uid=brian"
      "gid=users"
      "file_mode=0770"
      "dir_mode=0770"

      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
    ];
  };
}
