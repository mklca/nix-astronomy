{
  lib,
  runCommandLocal,
  tcsh,
}: let
  inherit (tcsh) version;
in
  runCommandLocal "tcsh-csh-stub-${version}" {
    inherit version;
  } ''
    mkdir -p $out/bin
    ln -s ${lib.getExe tcsh} $out/bin/csh
  ''
