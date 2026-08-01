{ pkgs, config, lib, inputs, ... }: {

  # Display Drivers: Use strictly "nvidia".
  # Do NOT place "modesetting" before "nvidia", as it forces Xwayland and Lutris 
  # to load Proxmox's virtual display driver (bochs-drm) before your RTX 5080,
  # causing Lutris to crash with incorrect PRIME Offload settings.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    # Enables NVIDIA GPU passthrough support for Docker / Podman containers
    nvidia-container-toolkit.enable = true;

    # Graphics & Vulkan Subsystem
    graphics = {
      enable = true;
      # Crucial for 32-bit Steam games, Wine/Proton runners, and 32-bit Java libraries
      enable32Bit = true;
    };

    nvidia = {
      # DRM Modesetting is required for Wayland compositors (KDE Plasma 6, Hyprland, etc.)
      modesetting.enable = true;

      # Disable power management inside the VM.
      # EXPERIMENTAL power-saving features can cause hypervisor VRAM crashes,
      # graphical corruption, or black screens after waking up.
      powerManagement.enable = false;
      powerManagement.finegrained = false;

      # Use NVIDIA's open-source kernel module.
      # This is the recommended default by NVIDIA for modern architectures (RTX 4000/5000 series).
      open = true;

      # Enables the nvidia-settings GUI utility
      nvidiaSettings = true;

      # Driver package selection (Beta driver branch is recommended for cutting-edge GPUs like RTX 5080)
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };

  # Register the nvidia runtime with Docker so `runtime: nvidia` works in docker-compose.
  # `hardware.nvidia-container-toolkit.enable` only sets up CDI specs, not the runtime shim.
  virtualisation.docker.daemon.settings = {
    runtimes.nvidia = {
      path = "${pkgs.nvidia-container-toolkit.tools}/bin/nvidia-container-runtime";
      runtimeArgs = [];
    };
  };

  # System-wide packages required for gaming runners (Lutris, Wine, Proton)
  environment.systemPackages = with pkgs; [
    vulkan-tools   # Provides 'vulkaninfo' (fixes the Lutris missing /usr/bin/vulkaninfo error)
    vulkan-loader  # Ensures Vulkan ICD drivers are properly discoverable by games
  ];
}