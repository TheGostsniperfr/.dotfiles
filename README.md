# My personal NixOS Config 

From a new NixOS user, hoping for a good configuration 😊.

## Installation : 

### Single command installation : 
```bash
nix-shell -p git --command "nix run --experimental-features 'nix-command flakes' github:TheGostsniperfr/.dotfiles"
```

### Custom installation 
If you prefer to edit the configuration before installation or install it in a different directory, follow these steps:

1. Clone the repository : 
    ```bash
    git clone https://github.com/TheGostsniperfr/.dotfiles ~/.dotfiles
    ```
2. Run the installation script :
    ```bash
    bash ~/.dotfiles/install.sh
    ```

I recommend reading the `install.sh` and `flake.nix` files to edit any variables you want to change, such as the username 😉.

If you want to modify the installation directory, replace `~/.dotfiles` with your new location.
