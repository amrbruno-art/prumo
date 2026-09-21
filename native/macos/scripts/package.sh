#!/usr/bin/env bash
# Build Prumo.app, then a drag-install .dmg and a .pkg installer.
# Must run on macOS with Xcode. Not App Store distribution.
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script only runs on macOS with Xcode." >&2
  echo "On GitHub: Actions → macOS installer → Run workflow." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACOS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="$(cd "$MACOS_DIR/../.." && pwd)"
VERSION="$(grep -m1 MARKETING_VERSION "$MACOS_DIR/Prumo.xcodeproj/project.pbxproj" | sed -E 's/[^0-9.]+//g')"
VERSION="${VERSION:-1.0.0}"
IDENTIFIER="art.amrbruno.prumo"
DERIVED="$MACOS_DIR/DerivedData"
DIST="$REPO_DIR/dist/macos"
STAGE="$DIST/stage"
DMG_STAGE="$DIST/dmg"
PKG_ROOT="$DIST/pkgroot"
APP_NAME="Prumo.app"

rm -rf "$DIST"
mkdir -p "$DIST"

echo "==> Building $APP_NAME $VERSION (Release, ad-hoc sign unless Developer ID is set)"

SIGN_ARGS=(
  CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY:--}"
  CODE_SIGNING_ALLOWED=YES
  CODE_SIGN_STYLE=Manual
)
if [[ -n "${DEVELOPMENT_TEAM:-}" ]]; then
  SIGN_ARGS=(
    CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY:-Developer ID Application}"
    CODE_SIGNING_ALLOWED=YES
    CODE_SIGN_STYLE=Manual
    DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM"
  )
fi

xcodebuild \
  -project "$MACOS_DIR/Prumo.xcodeproj" \
  -scheme Prumo \
  -configuration Release \
  -derivedDataPath "$DERIVED" \
  -destination "generic/platform=macOS" \
  ARCHS="arm64 x86_64" \
  ONLY_ACTIVE_ARCH=NO \
  "${SIGN_ARGS[@]}"

BUILT_APP="$DERIVED/Build/Products/Release/$APP_NAME"
if [[ ! -d "$BUILT_APP" ]]; then
  echo "Build did not produce $BUILT_APP" >&2
  exit 1
fi

mkdir -p "$STAGE"
cp -R "$BUILT_APP" "$STAGE/$APP_NAME"

cat > "$STAGE/Leia-me.txt" <<TXT
Prumo $VERSION — instalação paralela (fora da Mac App Store)
Prumo $VERSION — sideload (not the Mac App Store)

PT
1. Arraste Prumo.app para a pasta Aplicativos (atalho nesta imagem de disco).
2. Abra Aplicativos e dê um duplo clique em Prumo. Instalar NÃO abre o app.
   Não aparece no Dock. Olhe à DIREITA da barra de menu (junto do relógio).
   Na primeira vez o extra mostra o texto “Prumo”.
   Clique no extra. Ajustes e Sobre listam os atalhos.
   Enquanto puxa: sem tecla = minutos; ⇧ Shift = minutos precisos;
   ⌥ Option = horas; Esc = cancela.
3. Se o macOS disser que o desenvolvedor não pôde ser verificado:
   clique com o botão direito em Prumo.app → Abrir → Abrir.
   Ou: Ajustes do Sistema → Privacidade e segurança → Abrir mesmo assim.
4. Este pacote NÃO vem da App Store. É distribuição direta / instalação paralela.
5. Sem garantia. Leia DISCLAIMER.md no repositório.
   https://github.com/amrbruno-art/prumo

EN
1. Drag Prumo.app onto Applications.
2. Open Applications and double-click Prumo. Installing does NOT launch it.
   There is no Dock icon. Look at the RIGHT of the menu bar (by the clock).
   The first run shows the word “Prumo” next to the extra.
   Click the extra. Settings and About list shortcuts.
   While pulling: no key = minutes; ⇧ Shift = exact minutes;
   ⌥ Option = hours; Esc = cancel.
3. If macOS says the developer cannot be verified: right-click → Open → Open.
4. This is not App Store software. Direct / parallel install.
5. AS IS. No warranty. See DISCLAIMER.md.
TXT

# --- zip ---
(
  cd "$STAGE"
  ditto -c -k --sequesterRsrc --keepParent "$APP_NAME" "$DIST/Prumo-$VERSION.zip"
)

# --- dmg (drag to Applications) ---
rm -rf "$DMG_STAGE"
mkdir -p "$DMG_STAGE"
cp -R "$STAGE/$APP_NAME" "$DMG_STAGE/"
cp "$STAGE/Leia-me.txt" "$DMG_STAGE/"
ln -s /Applications "$DMG_STAGE/Applications"
hdiutil create \
  -volname "Prumo $VERSION" \
  -srcfolder "$DMG_STAGE" \
  -ov \
  -format UDZO \
  "$DIST/Prumo-$VERSION.dmg"

# --- pkg (Installer.app → /Applications) ---
rm -rf "$PKG_ROOT"
mkdir -p "$PKG_ROOT/Applications"
cp -R "$STAGE/$APP_NAME" "$PKG_ROOT/Applications/"

COMPONENT_PLIST="$DIST/component.plist"
cat > "$COMPONENT_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
  <dict>
    <key>BundleHasStrictIdentifier</key>
    <true/>
    <key>BundleIsRelocatable</key>
    <false/>
    <key>RootRelativeBundlePath</key>
    <string>Applications/Prumo.app</string>
  </dict>
</array>
</plist>
PLIST

PKG_UNSIGNED="$DIST/Prumo-$VERSION.unsigned.pkg"
pkgbuild \
  --root "$PKG_ROOT" \
  --install-location "/" \
  --identifier "$IDENTIFIER" \
  --version "$VERSION" \
  --component-plist "$COMPONENT_PLIST" \
  --scripts "$SCRIPT_DIR/pkg" \
  "$PKG_UNSIGNED"

if [[ -n "${INSTALLER_SIGN_IDENTITY:-}" ]]; then
  productsign --sign "$INSTALLER_SIGN_IDENTITY" "$PKG_UNSIGNED" "$DIST/Prumo-$VERSION.pkg"
  rm -f "$PKG_UNSIGNED"
else
  mv "$PKG_UNSIGNED" "$DIST/Prumo-$VERSION.pkg"
fi

# optional notarization (paid Developer ID + app-specific password)
if [[ -n "${APPLE_ID:-}" && -n "${APPLE_APP_PASSWORD:-}" && -n "${APPLE_TEAM_ID:-}" ]]; then
  xcrun notarytool submit "$DIST/Prumo-$VERSION.dmg" \
    --apple-id "$APPLE_ID" \
    --password "$APPLE_APP_PASSWORD" \
    --team-id "$APPLE_TEAM_ID" \
    --wait
  xcrun stapler staple "$DIST/Prumo-$VERSION.dmg" || true
  xcrun notarytool submit "$DIST/Prumo-$VERSION.pkg" \
    --apple-id "$APPLE_ID" \
    --password "$APPLE_APP_PASSWORD" \
    --team-id "$APPLE_TEAM_ID" \
    --wait
  xcrun stapler staple "$DIST/Prumo-$VERSION.pkg" || true
fi

rm -rf "$STAGE" "$DMG_STAGE" "$PKG_ROOT" "$COMPONENT_PLIST"
(
  cd "$DIST"
  shasum -a 256 Prumo-$VERSION.dmg Prumo-$VERSION.pkg Prumo-$VERSION.zip > SHA256SUMS.txt
)

echo "==> Installers:"
ls -lh "$DIST"
echo
echo "Sideload (not App Store). Unsigned builds need right-click → Open."
echo "See INSTALL.md"
