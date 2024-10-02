{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
         let
          overlays = [
            # (self: super: {
            #   defaultGemConfig = super.defaultGemConfig // {
            #     sass-embedded = attrs: {
            #       # buildFlags = [
            #         # "--with-pg-config=${lib.getDev pkgs."postgresql_${pg_version}"}/bin/pg_config"
            #       # ];
            #       # buildInputs = [
            #       #   pkgs.libffi
            #       # ];
            #     };
            #   };
            # })
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
          # todo Make it possible to pass --baseurl to the package build step.
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
