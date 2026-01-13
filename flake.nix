{
  description = "NixOS Live Boot ISO with GNOME and Development Tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = { self, nixpkgs, llm-agents }: {
    nixosConfigurations.live-iso = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inputs = { inherit nixpkgs llm-agents; }; };
      modules = [
        ({ modulesPath, ... }: {
          imports = [
            (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
            ./iso-configuration.nix
          ];
        })
      ];
    };
  };
}
