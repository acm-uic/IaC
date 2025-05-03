{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          # Per-system attributes can be defined here. The self' and inputs'
          # module parameters provide easy access to attributes of the same
          # system.

          # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
          packages.default = pkgs.hello;
          devShells.default =
            let
              PROJECT_ROOT = builtins.toString ./.;
              pkgs2 = import inputs.nixpkgs {
                inherit system;
                config.allowUnfree= true;
              };
            in
            pkgs2.mkShell {
              name = "ACM IaC";
              packages = with pkgs2; [
                opentofu
                ansible
                sshpass
                vault
                libdnf
                libdnf.py
                munge
                python3Packages.hvac
              ];
              KUBECONFIG = "${PROJECT_ROOT}/k8s-kubeconfig";
              VAULT_ADDR="https://vault.acmuic.org";
            };
        };
      flake = { };
    };
}
