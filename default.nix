{ pkgs, manifest ? builtins.fromJSON (builtins.readFile ./releases.json) }:
let
  inherit (pkgs) lib;
  system = pkgs.stdenv.hostPlatform.system;
  products = lib.filterAttrs (_: product: builtins.hasAttr system product.artifacts) manifest.products;
  makePackage = pname: product:
    let
      artifact = product.artifacts.${system};
      isTui = pname == "careervector-tui";
      isLinux = pkgs.stdenv.hostPlatform.isLinux;
      nativeLibraries = with pkgs; [ stdenv.cc.cc.lib zlib gsettings-desktop-schemas mesa ]
        ++ lib.optionals isTui [ openssl gtk4 libadwaita fontconfig freetype libGL libxkbcommon wayland ]
        ++ lib.optionals (!isTui) [ gtk3 webkitgtk_4_1 glib cairo gdk-pixbuf dbus glib-networking ];
      schemaDirectories = map pkgs.glib.getSchemaDataDirPath [
        pkgs.gsettings-desktop-schemas
        (if isTui then pkgs.gtk4 else pkgs.gtk3)
      ];
      desktopDataPath = lib.concatStringsSep ":"
        ([ (lib.makeSearchPath "share" nativeLibraries) ] ++ schemaDirectories);
      privateDir = if isLinux then "$out/lib/${pname}" else "$out/Applications/CareerVector.app";
    in assert !isLinux || lib.versionAtLeast pkgs.glibc.version artifact.minimum_glibc;
    pkgs.stdenvNoCC.mkDerivation {
      inherit pname;
      version = product.version;
      src = pkgs.fetchurl { inherit (artifact) url sha256; };
      sourceRoot = artifact.archive_root;
      nativeBuildInputs = [ pkgs.makeWrapper ] ++ lib.optionals isLinux [ pkgs.autoPatchelfHook ];
      buildInputs = lib.optionals isLinux nativeLibraries;
      dontBuild = true;
      dontConfigure = true;
      dontStrip = true;
      installPhase = ''
        runHook preInstall
        mkdir -p "${privateDir}"
        cp -a . "${privateDir}/"
      '' + lib.optionalString isLinux ''
        # GLib relocates schemas into versioned package directories. Verify
        # the actual compiled data before adding those paths to the wrappers.
        for schemaDirectory in ${lib.escapeShellArgs schemaDirectories}; do
          test -f "$schemaDirectory/glib-2.0/schemas/gschemas.compiled"
        done
      '' + lib.optionalString (isLinux && !isTui) ''
        wrapProgram "${privateDir}/${artifact.entrypoint}" \
          --set GIO_MODULE_DIR "${pkgs.glib-networking}/lib/gio/modules" \
          --set __EGL_VENDOR_LIBRARY_FILENAMES "${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json" \
          --set LIBGL_DRIVERS_PATH "${pkgs.mesa}/lib/dri" \
          --prefix XDG_DATA_DIRS : "${desktopDataPath}"
      '' + lib.optionalString isTui ''
        mkdir -p "$out/bin"
        makeWrapper "${privateDir}/${artifact.entrypoint}" "$out/bin/careervector" \
          --set __EGL_VENDOR_LIBRARY_FILENAMES "${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json" \
          --set LIBGL_DRIVERS_PATH "${pkgs.mesa}/lib/dri" \
          --prefix XDG_DATA_DIRS : "${desktopDataPath}"
      '' + lib.optionalString (isLinux && !isTui) ''
        mkdir -p "$out/share/applications" "$out/share/icons/hicolor/256x256/apps"
        cp "${privateDir}/${artifact.desktop_file}" "$out/share/applications/ch.corbet.careervector.desktop"
        substituteInPlace "$out/share/applications/ch.corbet.careervector.desktop" \
          --replace-fail '/usr/lib/careervector/careervector' "$out/lib/careervector/${artifact.entrypoint}" \
          --replace-fail 'Icon=ch.corbet.careervector' "Icon=$out/share/icons/hicolor/256x256/apps/ch.corbet.careervector.png"
        cp "${privateDir}/${artifact.icon}" "$out/share/icons/hicolor/256x256/apps/ch.corbet.careervector.png"
      '' + ''
        mkdir -p "$out/share/licenses/${pname}"
        cp -a "${privateDir}/${artifact.license_directory}/." "$out/share/licenses/${pname}/"
        runHook postInstall
      '';
      meta = {
        description = if isTui then "CareerVector terminal workspace" else "CareerVector desktop workspace";
        homepage = "https://careervector.corbet.ch";
        license = lib.licenses.bsl11;
        platforms = builtins.attrNames product.artifacts;
      } // lib.optionalAttrs isTui { mainProgram = "careervector"; };
      passthru = {
        sourceRevision = product.source_revision;
        nativeEvidence = artifact.native_evidence;
        packageRevision = product.package_revision;
      };
    };
in assert manifest.schema_version == 1;
  lib.mapAttrs makePackage products
