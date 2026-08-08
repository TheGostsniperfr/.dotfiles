rec {
  initMaster = "forge-k3s-lab-node-1";

  nodes = {
    # --- MASTERS ---
    "forge-k3s-lab-node-1" = { ip = "192.168.1.10"; interface = "eno1"; role = "server"; };
    "forge-k3s-lab-node-2" = { ip = "192.168.1.11"; interface = "eno1"; role = "server"; };
    "forge-k3s-lab-node-3" = { ip = "192.168.1.12"; interface = "eno1"; role = "server"; };
    
    # --- WORKERS (Exemple pour le futur) ---
    # "forge-k3s-lab-worker-1" = { ip = "192.168.1.20"; interface = "eno1"; role = "agent"; };
  };
}