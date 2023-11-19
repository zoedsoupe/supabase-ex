{
  description = "A complete Supabase SDK for Elixir alchemists";

  outputs = {nixpkgs, ...}: let
    system = "aarch64-darwin";
    pkgs = import nixpkgs {inherit system;};
    inherit (pkgs.beam.interpreters) erlang_26;
    inherit (pkgs.beam) packagesWith;
    beam-pkgs = packagesWith erlang_26;
    deps = import ./nix/deps.nix {
      inherit (pkgs) lib;
      beamPackages = beam-pkgs;
    };
  in {
    packages."${system}".supabase-potion = beam-pkgs.buildMix {
      name = "supabase-potion";
      version = "v0.2.3";
      src = ./.;
      beamDeps = with deps; [ecto jason finch];
    };

    devShells."${system}" = rec {
      default = supabase-potion;
      supabase-potion = pkgs.mkShell {
        name = "supabase-potion";
        shellHook = "mkdir -p $PWD/.nix-mix";
        packages = with pkgs;
          [beam-pkgs.elixir_1_15 mix2nix]
          ++ lib.optional stdenv.isDarwin [
            darwin.apple_sdk.frameworks.CoreServices
            darwin.apple_sdk.frameworks.CoreFoundation
          ];
      };
    };
  };
}
