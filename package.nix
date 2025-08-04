{
  lib,
  stdenv,
  src,
  version,
  libtirpc,
  ...
}: 
let
  libtirpc' = libtirpc.overrideAttrs (oldAttrs: {
    configureFlags = (oldAttrs.configureFlags or []) ++ [
      "--disable-gssapi"
    ];
  });
in
  stdenv.mkDerivation {
  inherit src version;
  name = "lmbench";

  buildInputs = [
    libtirpc'
  ];

  postPatch = ''
    substituteInPlace src/Makefile \
      --replace-fail '/bin/rm' 'rm'
  '';

  preBuild = ''
    cd src
  '';

  makeFlags = [
    "CPPFLAGS=-I${libtirpc.dev}/include/tirpc"
    "OS=${stdenv.targetPlatform.config}"
    "AR=${stdenv.cc.targetPrefix}ar"
    "CC=${stdenv.cc.targetPrefix}cc"
  ];
  env.NIX_CFLAGS_COMPILE="-Wno-implicit-int -Wno-implicit-function-declaration -Wno-return-mismatch -Wno-format-security";

  installPhase = ''
    make install-target BASE=$out O=../bin/${stdenv.targetPlatform.config} OS=${stdenv.targetPlatform.config}
  '';
}
