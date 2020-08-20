# Half-cloned from github/NixOS/nixpkgs/pkgs/applications/misc/st/default.nix
# Downsized. Simpler. For self-educational purpose.
#
# Current State: 
# 1. Can compile, but doesn't add automatically to PATH. 
# 2. `urlhandler` (alt+l) is broken. It's not in the PATH.
#
# Usage: In Luke Smith's st repo, run
# $ nix-build -E '(import <nixpkgs> {}).callPackage ./default.nix {}'

{ stdenv, fetchurl, pkgconfig, writeText, libX11, ncurses
,  libXft, conf ? null, patches ? [], extraLibs ? []}:

#with stdenv.lib;
with import <nixpkgs> {};

stdenv.mkDerivation rec {
  pname = "st";
  version = "0.8.4";

  src = ./.;

  nativeBuildInputs = [ pkgconfig ncurses ];
  buildInputs = [ libX11 libXft harfbuzz ];

installPhase = ''
  TERMINFO=$out/share/terminfo make install PREFIX=$out
'';
}
