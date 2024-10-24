_: {
  config = {
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
}
