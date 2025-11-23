{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
}:

let
  pname = "freeshow";
  version = "1.5.2";

  src = fetchurl {
    url = "https://github.com/ChurchApps/FreeShow/releases/download/v${version}/FreeShow-${version}-x86_64.AppImage";
    # NOTE: Replace this hash with the real one using `scripts/update-appimage.sh`
    # or `nix-prefetch-url`. This is a placeholder and will not build as-is.
    sha256 = "1zv2s65nxf8whmd11jzc1mawrplfczh2w7z453s3scfkd6afsy09";
  };

  appimage = appimageTools.wrapType2 {
    inherit pname version src;
  };

in
stdenv.mkDerivation {
  inherit pname version src;

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    ln -s ${appimage}/bin/${pname} $out/bin/${pname}

    # Desktop entry and icon for DE integration
    mkdir -p $out/share/applications
    install -Dm444 ${./freeshow.desktop} $out/share/applications/freeshow.desktop

    mkdir -p $out/share/icons/hicolor/scalable/apps
    install -Dm444 ${./freeshow-icon.svg} $out/share/icons/hicolor/scalable/apps/freeshow.svg
  '';

  meta = with lib; {
    description = "Free church worship service media presentation software";
    homepage = "https://github.com/ChurchApps/FreeShow";
    license = licenses.mit;
    mainProgram = "freeshow";
    platforms = [ "x86_64-linux" ];
  };
}
