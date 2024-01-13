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
        });
  in {
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
          [beam-pkgs.elixir_1_15 mix2nix earthly]
          ++ lib.optional stdenv.isDarwin [
            darwin.apple_sdk.frameworks.CoreServices
            darwin.apple_sdk.frameworks.CoreFoundation
          ];
      };
    });
  };
}
