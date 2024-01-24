{
  # See https://www.jetpack.io/blog/using-nix-flakes-with-devbox/ for more details
  # on using flakes with Devbox
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (system:
        let
          # use withPlugins to modify the Poetry Package
          poetry-with-plugin = pkgs.${system}.poetry.withPlugins (
            ps: with ps; [
              pkgs.${system}.python311Packages.poetry-dynamic-versioning
            ]
          );
        in
        {
          # Export the package so it can be installed by Devbox
          poetry = poetry-with-plugin;
          # For extra convenience, make it the default
          default = poetry-with-plugin;
        }
      );
    };
}
