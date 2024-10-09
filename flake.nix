{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      pre-commit-hooks,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ ];
        pkgs = import nixpkgs { inherit system overlays; };
        gems = pkgs.bundlerEnv {
          name = "jwillikers-blog";
          gemdir = ./.;
          extraConfigPaths = [ "${./.}/.ruby-version" ];
        };
        nativeBuildInputs = with pkgs; [
          fish
          gems
          gems.wrappedRuby
          just
          nushell
        ];
        buildInputs = with pkgs; [ ];
        treefmt = {
          config = {
            programs = {
              actionlint.enable = true;
              jsonfmt.enable = true;
              just.enable = true;
              nixfmt.enable = true;
              prettier.enable = true;
              typos.enable = true;
              yamlfmt.enable = true;
            };
            projectRootFile = "flake.nix";
          };
        };
        treefmtEval = treefmt-nix.lib.evalModule pkgs treefmt;
        pre-commit = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            check-executables-have-shebangs.enable = true;

            # todo Not integrated with Nix?
            check-format = {
              enable = true;
              entry = "${treefmtEval.config.build.wrapper}/bin/treefmt --fail-on-change";
            };

            check-json.enable = true;
            check-toml.enable = true;
            check-yaml.enable = true;
            detect-private-keys.enable = true;
            editorconfig-checker.enable = true;
            end-of-file-fixer.enable = true;
            fix-byte-order-marker.enable = true;
            # todo Broken for 24.05 branch
            # flake-checker.enable = true;
            mixed-line-endings.enable = true;

            strip-location-metadata = {
              name = "Strip location metadata";
              description = "Strip geolocation metadata from image files";
              enable = true;
              entry = "${pkgs.exiftool}/bin/exiftool -duplicates -overwrite_original '-gps*='";
              package = pkgs.exiftool;
              types = [ "image" ];
            };

            trim-trailing-whitespace.enable = true;
            yamllint.enable = true;
          };
        };
      in
      with pkgs;
      {
        apps = {
          default =
            let
              script = pkgs.writeShellApplication {
                name = "serve";
                runtimeInputs = with pkgs; [
                  gems
                  gems.wrappedRuby
                ];
                text = ''
                  jekyll serve --destination ${self.packages.${system}.default}/srv --open-url --skip-initial-build
                '';
              };
            in
            {
              type = "app";
              program = "${script}/bin/serve";
            };
        };
        devShells.default = mkShell {
          inherit buildInputs;
          inherit (pre-commit) shellHook;
          nativeBuildInputs =
            nativeBuildInputs
            ++ [
              treefmtEval.config.build.wrapper
              # Make formatters available for IDE's.
              (lib.attrValues treefmtEval.config.build.programs)
            ]
            ++ pre-commit.enabledPackages;
        };
        packages.default = callPackage ./default.nix { inherit gems; };
        formatter = treefmtEval.config.build.wrapper;
      }
    );
}
