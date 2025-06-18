{
  description = "nixos-wsl";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-wsl = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nixos-wsl";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      home-manager,
      flake-utils,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      systems = [ system ];
      forAllSystems =
        function: nixpkgs.lib.genAttrs systems (system: function nixpkgs.legacyPackages.${system});
    in
    {
      nixosModules.default = {
        imports = [
          inputs.nixos-wsl.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          ./modules
          (
            {
              config,
              lib,
              pkgs,
              ...
            }:
            {
              wsl.enable = true;
              wsl.version.rev = nixpkgs.lib.mkIf (self ? rev) (nixpkgs.lib.mkForce self.rev);
              nixpkgs.flake.source = nixpkgs.lib.mkForce null;
              systemd.tmpfiles.rules =
                let
                  channels = pkgs.runCommand "default-channels" { } ''
                    mkdir -p $out
                    ln -s ${pkgs.path} $out/nixos
                    ln -s ${./.} $out/nixos-wsl
                  '';
                in
                [
                  "L /nix/var/nix/profiles/per-user/root/channels-1-link - - - - ${channels}"
                  "L /nix/var/nix/profiles/per-user/root/channels - - - - channels-1-link"
                ];
              system.stateVersion = config.system.nixos.release;
            }
          )
        ];
      };
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
          inherit system;
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [
            self.nixosModules.default
          ];
        };
      };
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.nil
            pkgs.nixfmt-rfc-style
          ];
        };
      });
    };
}
