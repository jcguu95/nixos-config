with import <nixpkgs> {}; stdenv.mkDerivation {
  name = "hello";
  src = ./.;
  buildInputs = [ coreutils gcc ];
  configurePhase = ''
    declare -xp
  '';
  buildPhase = ''
    gcc hello.c -o ./hello
  '';
  installPhase = ''
    mkdir -p "$out/bin"
    cp ./hello "$out/bin/"
  '';
}
