{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
         let
          overlays = [
          ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
          gems = pkgs.bundlerEnv {
            name = "jwillikers-blog";
            gemdir = ./.;
            extraConfigPaths = [ "${./.}/.ruby-version" ];
          };
          nativeBuildInputs = with pkgs; [
            gems
            gems.wrappedRuby
            fish
            just
            nushell
            pre-commit
            yamllint
          ];
          buildInputs = with pkgs; [
          ];
        in
        with pkgs;
        {
          devShells.default = mkShell {
            inherit buildInputs nativeBuildInputs;
          };
          packages.default = callPackage ./default.nix { inherit gems; };
          apps = {
            default = let
              script = pkgs.writeShellApplication {
                name = "serve";
                runtimeInputs = with pkgs; [gems gems.wrappedRuby];
                text = ''
                  jekyll serve --destination ${self.packages.${system}.default}/srv --open-url --skip-initial-build
                '';
              };
            in {
              type = "app";
              program = "${script}/bin/serve";
            };
          };
        }
      );
}
