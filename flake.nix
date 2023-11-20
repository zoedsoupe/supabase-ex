{
  description = "A complete Supabase SDK for Elixir alchemists";

  outputs = {nixpkgs, ...}: let
    for-all-systems = function:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ] (system:
        function rec {
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (pkgs.beam.interpreters) erlang_26;
          inherit (pkgs.beam) packagesWith;
          beam-pkgs = packagesWith erlang_26;
          deps = import ./nix/deps.nix {
            inherit (pkgs) lib;
            beamPackages = beam-pkgs;
          };
        });
  in {
    packages = for-all-systems ({
      beam-pkgs,
      deps,
      ...
    }: rec {
      default = supabase-potion;
      supabase-potion = beam-pkgs.buildMix {
        name = "supabase-potion";
        version = "v0.2.3";
        src = ./apps/supabase_potion;
        beamDeps = with deps; [ecto jason finch];
      };
      supabase-storage = beam-pkgs.buildMix {
        name = "supabase-storage";
        version = "v0.2.0";
        src = ./apps/supabase_storage;
        beamDeps = with deps; [ecto supabase-potion];
      };
      supabase-auth = beam-pkgs.buildMix {
        name = "supabase-auth";
        version = "v0.1.0";
        src = ./apps/supabase_auth;
        beamDeps = with deps; [ecto plug supabase-potion];
      };
      supabase-postgrest = beam-pkgs.buildMix {
        name = "supabase-postgrest";
        version = "v0.1.0";
        src = ./apps/supabase_postgrest;
        beamDeps = with deps; [ecto supabase-potion];
      };
    });

    devShells = for-all-systems ({
      pkgs,
      beam-pkgs,
      ...
    }: rec {
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
    });
  };
}
