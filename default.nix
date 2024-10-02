{ stdenv
,  gems
}:
stdenv.mkDerivation {
  pname = "jwillikers-blog";
  version = "0.1.0";

  src = ./.;

  buildInputs = [gems gems.wrappedRuby];

  buildPhase = ''
    jekyll build
  '';

  installPhase = ''
    mkdir --parents $out
    mv _site $out/srv
  '';
}
