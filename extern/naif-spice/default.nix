{
  stdenv,
  fetchzip,
  gzip,
  csh,
  gfortran,
}: let
  toolkit-release = "N0067";

  spice-platforms = {
    "x86_64-linux" = "PC_Linux_gfortran_64bit";
  };

  target-system = stdenv.targetPlatform.system;
  target-spice-platform = builtins.getAttr target-system spice-platforms;

  toolkit-url = "https://naif.jpl.nasa.gov/pub/naif/misc/toolkit_${toolkit-release}/FORTRAN/${target-spice-platform}/packages/toolkit.tar.Z";
in
  assert (builtins.hasAttr target-system spice-platforms);
    stdenv.mkDerivation {
      pname = "naif-spice";
      version = toolkit-release;

      src = fetchzip {
        name = "NAIF-SPICE-${target-spice-platform}-${toolkit-release}-source";
        url = toolkit-url;
        hash = "sha256-h1zZ2yH1cKuZee+7u7fo1IjMcWjsyCJuMfisQtEgVzY=";
        nativeBuildInputs = [gzip];
        postFetch = ''
          rm -rf $out/exe $out/lib
        '';
      };

      nativeBuildInputs = [
        csh
      ];

      buildInputs = [
        gfortran
        gfortran.libc
      ];

      C_COMPILEOPTIONS = "-m64 -fPIC -c";
      F_COMPILEOPTIONS = "-m64 -fPIC -c -std=legacy -Wno-character-truncation";
      TKLINKOPTIONS = "-m64";

      postPatch = ''
        patchShebangs --build makeall.csh $(find -name mkprodct.csh -print)
      '';

      dontConfigure = true;

      buildPhase = ''
        mkdir exe lib
        read -a nixLdFlags <<< "''${NIX_LDFLAGS}"
        echo "''${nixLdFlags[@]/#/-Wl,}"
        C_COMPILEOPTIONS="''${C_COMPILEOPTIONS} ''${NIX_CFLAGS_COMPILE}" TKLINKOPTIONS="''${TKLINKOPTIONS} ''${nixLdFlags[@]/#/-Wl,}" ./makeall.csh
      '';

      installPhase = ''
        mkdir $out
        install -D -t $out/bin exe/*
        install -D -t $out/lib lib/*
      '';
    }
