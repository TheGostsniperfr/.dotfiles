{ ... }:

{
  services.k3s = {
    enable = true;
    role = "server";

    # Options Doc: https://docs.k3s.io/cli/server
    extraFlags = toString [
      "--service-cidr=10.43.0.0/16,2a10:3781:25ac:3::/112"
      "--cluster-cidr=10.42.0.0/16,2a10:3781:25ac:2::/64"
      "--write-kubeconfig-mode=0644"
    ];
  };

  networking.firewall.allowedTCPPorts = [
    6443  # k3s API server
    2379  # etcd clients (HA embedded etcd)
    2380  # etcd peers (HA embedded etcd)
    10250 # Kubelet metrics
  ];

  networking.firewall.allowedUDPPorts = [
    8472 # flannel inter-node networking
  ];
}
