{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nix-update-scripts.url = "github:jwillikers/nix-update-scripts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
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
      # deadnix: skip
      self,
      flake-utils,
      nix-update-scripts,
      nixpkgs,
      nixpkgs-unstable,
      pre-commit-hooks,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ ];
        pkgs = import nixpkgs { inherit system overlays; };
        unstablePkgs = import nixpkgs-unstable { inherit system overlays; };
        gems = pkgs.bundlerEnv {
          name = "jwillikers-blog";
          gemdir = ./.;
          extraConfigPaths = [ "${./.}/.ruby-version" ];
        };
        nativeBuildInputs = with pkgs; [
          asciidoctor
          bundix
          fish
          gems
          gems.wrappedRuby
          just
          lychee
          nil
          unstablePkgs.nushell
        ];
        buildInputs = [ ];
        treefmt.config = {
          programs = {
            actionlint.enable = true;
            deadnix.enable = true;
            fish_indent.enable = true;
            jsonfmt.enable = true;
            just.enable = true;
            nixfmt.enable = true;
            prettier.enable = true;
            statix.enable = true;
            taplo.enable = true;
            typos.enable = true;
            yamlfmt.enable = true;
          };
          settings.formatter.typos.excludes = [
            "*.avif"
            "*.bmp"
            "*.gif"
            "*.jpeg"
            "*.jpg"
            "*.png"
            "*.svg"
            "*.tiff"
            "*.webp"
            ".vscode/settings.json"
          ];
          projectRootFile = "flake.nix";
        };
        treefmtEval = treefmt-nix.lib.evalModule pkgs treefmt;
        pre-commit = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            check-added-large-files.enable = true;
            check-case-conflicts.enable = true;
            check-executables-have-shebangs.enable = true;

            # todo Not integrated with Nix?
            check-format = {
              enable = true;
              entry = "${treefmtEval.config.build.wrapper}/bin/treefmt --fail-on-change";
            };

            check-json.enable = true;
            check-shebang-scripts-are-executable.enable = true;
            check-symlinks.enable = true;
            check-toml.enable = true;
            check-yaml.enable = true;
            detect-private-keys.enable = true;
            editorconfig-checker.enable = true;
            end-of-file-fixer.enable = true;
            fix-byte-order-marker.enable = true;
            forbid-new-submodules.enable = true;
            # todo Enable lychee when asciidoc is supported.
            # See https://github.com/lycheeverse/lychee/issues/291
            # lychee.enable = true;
            # todo Broken for 24.05 branch
            # flake-checker.enable = true;
            mixed-line-endings.enable = true;
            nil.enable = true;

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
          inherit (nix-update-scripts.apps.${system}) update-nix-direnv;
          inherit (nix-update-scripts.apps.${system}) update-nixos-release;
          default =
            let
              script = pkgs.writeShellApplication {
                name = "serve";
                runtimeInputs = [
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
          nativeBuildInputs =
            nativeBuildInputs
            ++ [
              treefmtEval.config.build.wrapper
              # Make formatters available for IDE's.
              (lib.attrValues treefmtEval.config.build.programs)
            ]
            ++ pre-commit.enabledPackages;
          postShellHook = pre-commit.shellHook;
        };
        packages.default = callPackage ./default.nix { inherit gems; };
        formatter = treefmtEval.config.build.wrapper;
      }
    );
}
