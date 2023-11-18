{
  description = "A complete Supabase SDK for Elixir alchemists";

  outputs = {nixpkgs, ...}: let
    system = "aarch64-darwin";
    pkgs = import nixpkgs {inherit system;};
  in {
    packages."${system}".supabase-potion = null;

    devShells."${system}" = rec {
      default = supabase-potion;
      supabase-potion = pkgs.mkShell {
        name = "supabase-potion";
        shellHook = "mkdir -p $PWD/.nix-mix";
        packages = with pkgs;
          [beam.packages.erlangR26.elixir_1_15]
          ++ lib.optional stdenv.isDarwin [
            darwin.apple_sdk.frameworks.CoreServices
            darwin.apple_sdk.frameworks.CoreFoundation
          ];
      };
    };
  };
}
