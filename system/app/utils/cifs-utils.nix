{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.cifs-utils
    pkgs.sshfs
    pkgs.direnv
  ];

  systemd.services.afsMount = {
    description = "Mount AFS using SSHFS";
    after = [ "network.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.sshfs}/bin/sshfs -o reconnect brian.perret@ssh.cri.epita.fr:/afs/cri.epita.fr/user/x/xa/brian.perret/u/ /media/afs";
      ExecStop = "/bin/umount /media/afs";
      Restart = "on-failure";
    };

    wantedBy = [ "multi-user.target" ];
  };

  fileSystems."/media/nas" = {
    device = "//192.168.1.25/partage";
    fsType = "cifs";
    options = [ "username=it-connect" "password=ackmce" ];
  };
}
