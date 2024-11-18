{ pkgs, treefmtEval, ... }:
{
  src = ./.;
  hooks = {
    check-added-large-files.enable = true;
    check-case-conflicts.enable = true;
    check-executables-have-shebangs.enable = true;

    # todo Not integrated with Nix?
    check-format = {
      enable = true;
      entry = "${pkgs.lib.getExe treefmtEval.config.build.wrapper} --fail-on-change";
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
}
