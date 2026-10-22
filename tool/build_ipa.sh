#!/bin/bash
# Compila el IPA para App Store Connect.
# Los frameworks de native assets (objective_c) quedan cacheados en
# build/native_assets y .dart_tool: si la última build fue de simulador, se
# cuelan al IPA y App Store Connect lo rechaza (409). Por eso se limpia todo
# antes y se verifica que cada framework sea solo arm64 de iOS (platform 2).
set -euo pipefail
cd "$(dirname "$0")/.."
OPTS="${1:-ios/ExportOptions.plist}"
flutter clean >/dev/null
flutter pub get >/dev/null
flutter build ipa --release --export-options-plist="$OPTS"
ok=1
for fw in build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/Frameworks/*.framework; do
  bin="$fw/$(basename "$fw" .framework)"
  archs=$(lipo -archs "$bin")
  platforms=$(otool -l "$bin" | awk '/LC_BUILD_VERSION/{f=1} f&&/platform/{print $2; f=0}' | sort -u | tr '\n' ' ')
  echo "$(basename "$fw"): $archs / platform $platforms"
  if [ "$archs" != "arm64" ] || [ "$platforms" != "2 " ]; then ok=0; fi
done
[ $ok = 1 ] || { echo "ERROR: hay frameworks que no son de dispositivo iOS"; exit 1; }
ls -la build/ios/ipa/*.ipa
