{
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
          poetry-with-plugin = pkgs.${system}.poetry.withPlugins (
            ps: with ps; [
              pkgs.${system}.python311Packages.poetry-dynamic-versioning
            ]
          );
        in
        {
          poetry = poetry-with-plugin;
          default = poetry-with-plugin;
        }
      );
    };
}
