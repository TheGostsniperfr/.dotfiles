{ lib, ... }:

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

      "workstation" = {
        Hostname = "thegostserveur.ddns.net";
        User = "brian";
        Port = 2244;
        IdentityFile = "~/.ssh/id_ed25519";
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
        ];
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

      # ── Forge Lab 2026 ─────────────────────────────────────────────────────
      "pve1" = {
        Hostname = "pve1";
        User = "root";
        IdentityFile = "~/.ssh/id_ed25519";
        LocalForward = [ "6443 10.201.4.127:6443" ];
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
