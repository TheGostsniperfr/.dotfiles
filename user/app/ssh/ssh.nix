{ lib, ... }:

let
  gpgAgent = "/run/user/1000/gnupg/S.gpg-agent.ssh";
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*".AddKeysToAgent = "yes";

      # ── Perso ──────────────────────────────────────────────────────────────
      "home-server-lab" = {
        Hostname = "192.168.1.52";
        User = "brian";
        ForwardAgent = "yes";
      };

      "farmlab" = {
        Hostname = "10.69.16.19";
        User = "pi";
        IdentityFile = "~/.ssh/id_ed25519";
      };

      "workstation" = {
        Hostname = "thegostserveur.ddns.net";
        User = "brian";
        Port = 2244;
        IdentityFile = "~/.ssh/id_ed25519";
        ControlMaster = "auto";
        ControlPath = "~/.ssh/cm-%r@%h:%p";
        ControlPersist = "4h";
        ForwardAgent = "yes";
      };

      "proxmox-homelab" = {
        Hostname = "192.168.1.49";
        User = "root";
      };

      "arffornia-k8s-master-node" = {
        Hostname = "192.168.1.73";
        User = "master-node";
      };

      "arffornia-k8s-worker-01" = {
        Hostname = "192.168.1.168";
        User = "worker-01";
      };

      "arffornia-k8s-worker-02" = {
        Hostname = "192.168.1.142";
        User = "worker-02";
      };

      "arffornia-k8s-worker-03" = {
        Hostname = "192.168.1.127";
        User = "worker-03";
      };

      # ── K3S / Kubernetes ───────────────────────────────────────────────────
      "k3s-master-epimac" = {
        Hostname = "master-k8s-01.k8s.srv.epimac.org";
        User = "root";
        IdentityFile = "~/.ssh/id_ed25519_wsl";
        LocalForward = [ "6443 localhost:6443" ];
      };

      "k8s" = {
        Hostname = "thegostserveur.ddns.net";
        User = "master-node";
        Port = 2222;
        LocalForward = [ "6443 localhost:6443" ];
      };

      "test-k8s-master-node" = {
        Hostname = "thegostserveur.ddns.net";
        User = "test-k8s-master-node";
        Port = 4343;
        IdentityFile = "~/.ssh/id_ed25519";
        LocalForward = [
          "6443 localhost:6443"
          "8443 192.168.1.100:443"
        ];
      };

      # ── Epimac ─────────────────────────────────────────────────────────────
      "epimac" = {
        Hostname = "116.203.79.116";
        Port = 2484;
        User = "epimac";
        IdentityFile = "~/.ssh/id_ed25519_wsl";
      };

      # ── EPITA Forge — specific hosts BEFORE wildcards ──────────────────────
      "gitlab.cri.epita.fr" = lib.hm.dag.entryBefore [ "*.cri.epita.fr" ] {
        ProxyJump = "none";
      };

      "ssh.cri.epita.fr" = lib.hm.dag.entryBefore [ "*.cri.epita.fr" ] {
        ProxyJump = "none";
      };

      "git.forge.epita.fr" = lib.hm.dag.entryBefore [ "*.forge.epita.fr" ] {
        ProxyJump = "none";
      };

      "*.3ie.openstack.epita.fr" = {
        User = "root";
        ProxyJump = "3ie-bastion";
      };

      "*.cri.epita.fr" = {
        User = "root";
        ProxyJump = "fw-cri";
      };

      "*.cri.openstack.epita.fr" = {
        User = "root";
        ProxyJump = "os-bastion";
      };

      "*.cri_playground.openstack.epita.fr" = {
        User = "root";
        ProxyJump = "play-bastion";
      };

      "*.forge.epita.fr" = {
        User = "root";
        ProxyJump = "fw-cri";
      };

      "*.lre.openstack.epita.fr" = {
        User = "root";
        ProxyJump = "lre-bastion";
      };

      # ── EPITA Bastions ─────────────────────────────────────────────────────
      "3ie-bastion" = {
        User = "root";
        Hostname = "bastion.iaas.3ie.epita.fr";
      };

      "fw-cri" = {
        User = "root";
        Hostname = "91.243.117.1";
      };

      "lre-bastion" = {
        User = "root";
        Hostname = "admin-svc.lre.iaas.epita.fr";
      };

      "os-bastion" = {
        Port = 2222;
        User = "root";
        Hostname = "bastion.iaas.cri.epita.fr";
      };

      "play-bastion" = {
        User = "root";
        Hostname = "bastion.cri-playground.iaas.epita.fr";
      };

      # ── CRI Switches (legacy crypto) ───────────────────────────────────────
      "sw-core-cri" = {
        User = "manager";
        Hostname = "192.168.200.240";
        HostKeyAlgorithms = "+ssh-rsa";
        KexAlgorithms = "diffie-hellman-group14-sha1";
      };

      "sw-mgmt-cri" = {
        User = "manager";
        Hostname = "192.168.200.241";
        HostKeyAlgorithms = "+ssh-rsa";
        KexAlgorithms = "diffie-hellman-group1-sha1";
      };

      "sw-rack-d-cri" = {
        User = "admin";
        Hostname = "192.168.200.74";
        HostKeyAlgorithms = "+ssh-rsa";
      };

      # ── PAE NUCs Cluster ───────────────────────────────────────────────────
      "pae-node-1" = {
        Hostname = "10.0.0.1";
        User = "pae-node-1";
        IdentityFile = "~/.ssh/id_ed25519_ansible";
        LocalForward = [
          "8080 192.168.1.210:80"    # Horizon
          "5000 192.168.1.210:5000"  # Keystone
          "8774 192.168.1.210:8774"  # Nova API
          "9696 192.168.1.210:9696"  # Neutron API
          "9292 192.168.1.210:9292"  # Glance API
          "9876 192.168.1.210:9876"  # Octavia
          "6443 192.168.1.212:6443"  # KubeAPI
          "6444 192.168.1.217:6443"  # K3s lab API Server
        ];
        # CNP cnp.sh and EKS/GKE kubeconfigs reach the cloud APIs through it (CNP-166)
        DynamicForward = "1080";
      };

      "pae-node-2" = {
        Hostname = "10.0.0.2";
        User = "pae-node-2";
        IdentityFile = "~/.ssh/id_ed25519";
      };

      "pae-node-3" = {
        Hostname = "10.0.0.3";
        User = "pae-node-3";
        IdentityFile = "~/.ssh/id_ed25519";
      };

      "jumpserver" = {
        Hostname = "192.168.1.125";
        User = "jumpserver";
        IdentityFile = "~/.ssh/id_ed25519";
        ProxyJump = "pae-node-1";
      };

      "server" = {
        Hostname = "192.168.1.93";
        User = "server";
        IdentityFile = "~/.ssh/id_ed25519";
        ProxyJump = "pae-node-1";
      };

      "node-0" = {
        Hostname = "192.168.1.199";
        User = "node-0";
        IdentityFile = "~/.ssh/id_ed25519";
        ProxyJump = "pae-node-1";
      };

      "node-1" = {
        Hostname = "192.168.1.48";
        User = "node-1";
        IdentityFile = "~/.ssh/id_ed25519";
        ProxyJump = "pae-node-1";
      };

      # ── Atelier ────────────────────────────────────────────────────────────
      "at-pi-01" = {
        Hostname = "192.168.1.2";
        User = "root";
        IdentityAgent = gpgAgent;
      };

      "*.le-maker.fr" = {
        User = "root";
        IdentityAgent = gpgAgent;
      };

      "ctl-01.le-maker.fr" = {
        Hostname = "192.168.253.10";
      };
      "cpt-02.le-maker.fr" = {
        Hostname = "192.168.253.101";
      };
      "cpt-03.le-maker.fr" = {
        Hostname = "192.168.253.102";
      };
      "sto-01.le-maker.fr" = {
        Hostname = "192.168.253.200";
      };
      "sto-02.le-maker.fr" = {
        Hostname = "192.168.253.201";
      };

      "at-admin-bastion" = {
        Hostname = "ext.bastion.admin.cloud.atelier-maker.fr";
        User = "alpine";
        IdentityAgent = gpgAgent;
      };

      "*.admin.cloud.atelier-maker.fr" = {
        User = "root";
        IdentityAgent = gpgAgent;
        ProxyJump = "at-admin-bastion";
      };

      "at-playground-bastion" = {
        Hostname = "ext.bastion.atelier_playground.cloud.atelier-maker.fr";
        User = "alpine";
        IdentityAgent = gpgAgent;
      };

      "*.atelier_playground.cloud.atelier-maker.fr" = {
        User = "root";
        IdentityAgent = gpgAgent;
        ProxyJump = "at-playground-bastion";
      };

      # ── Forge Lab 2026 ─────────────────────────────────────────────────────
      "pve1" = {
        Hostname = "pve1";
        User = "root";
        IdentityFile = "~/.ssh/id_ed25519";
        LocalForward = [ "6443 10.201.4.212:6443" ];
      };

      "pve2" = {
        Hostname = "10.201.4.201";
        User = "root";
        IdentityFile = "~/.ssh/id_ed25519";
        ProxyJump = "pve1";
      };

      "pve3" = {
        Hostname = "10.201.4.202";
        User = "root";
        IdentityFile = "~/.ssh/id_ed25519";
        ProxyJump = "pve1";
      };
    };
  };
}
