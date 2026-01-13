{
  description = "NixOS Live Boot ISO with GNOME and Development Tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = { self, nixpkgs, stylix, llm-agents }: {
    nixosConfigurations.live-iso = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inputs = { inherit nixpkgs stylix llm-agents; }; };
      modules = [
        ({ modulesPath, ... }: {
          imports = [
            (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
            ./iso-configuration.nix
          ];
        })
        stylix.nixosModules.stylix
      ];
    };
  };
}
