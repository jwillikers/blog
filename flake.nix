{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nix-update-scripts = {
      url = "github:jwillikers/nix-update-scripts";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "pre-commit-hooks";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      # deadnix: skip
      self,
      flake-utils,
      nix-update-scripts,
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
          gemConfig = pkgs.defaultGemConfig // {
            # Newer versions of sass-embedded no longer create the extension directory before writing cli.rb.
            # The default Nixpkgs config removes the dependency on the dart-sass task, which used to create it.
            sass-embedded =
              attrs:
              let
                default = pkgs.defaultGemConfig.sass-embedded attrs;
              in
              default
              // {
                postPatch = default.postPatch + ''
                  substituteInPlace ext/sass/Rakefile \
                    --replace-fail "file File.absolute_path('cli.rb', ARCHDIR) do |task|" \
                      "file File.absolute_path('cli.rb', ARCHDIR) do |task|
                    mkdir_p ARCHDIR"
                '';
              };
          };
        };
        pre-commit = pre-commit-hooks.lib.${system}.run (
          import ./pre-commit-hooks.nix { inherit pkgs treefmtEval; }
        );
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in
      with pkgs;
      {
        apps = {
          inherit (nix-update-scripts.apps.${system}) update-nix-direnv update-nixos-release;
          default = {
            type = "app";
            program = builtins.toString (
              pkgs.writers.writeNu "serve" ''
                ^${gems}/bin/jekyll serve --destination ${
                  self.packages.${system}.default
                }/srv --open-url --skip-initial-build
              ''
            );
          };
        };
        devShells.default = mkShell {
          nativeBuildInputs =
            with pkgs;
            [
              asciidoctor
              bundix
              bundler
              fish
              gems
              gems.wrappedRuby
              just
              lychee
              nushell
              treefmtEval.config.build.wrapper
            ]
            ++ builtins.attrValues treefmtEval.config.build.programs
            ++ pre-commit.enabledPackages;
          inherit (pre-commit) shellHook;
        };
        packages.default = callPackage ./package.nix { inherit gems; };
        formatter = treefmtEval.config.build.wrapper;
      }
    );
}
