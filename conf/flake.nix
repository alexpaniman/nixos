{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nix-alien.url = "github:thiagokokada/nix-alien";

    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, nix-alien, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
    
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit system;
            inherit self;
          };
          modules = [ 
            ./configuration.nix
            # inputs.home-manager.nixosModules.default
          ];
        };
      };

    };
}
