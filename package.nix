{ stdenvNoCC, gems }:
stdenvNoCC.mkDerivation {
  pname = "jwillikers-blog";
  version = "0.1.0";

  src = ./.;

  buildInputs = [
    gems
    gems.wrappedRuby
  ];

  buildPhase = ''
    runHook preBuild
    jekyll build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir --parents $out
    mv _site $out/srv
    runHook postInstall
  '';
}
