#!/bin/bash
# Compila el IPA para App Store Connect.
# Los frameworks de native assets (objective_c) traen un slice x86_64 de
# simulador que App Store Connect rechaza (409): se quita y se re-exporta.
set -euo pipefail
cd "$(dirname "$0")/.."
OPTS="${1:-ios/ExportOptions.plist}"

flutter build ipa --release --export-options-plist="$OPTS"

ARCHIVE=build/ios/archive/Runner.xcarchive
for fw in "$ARCHIVE"/Products/Applications/Runner.app/Frameworks/*.framework; do
  bin="$fw/$(basename "$fw" .framework)"
  if lipo -archs "$bin" | grep -q x86_64; then
    echo "Quitando x86_64 de $(basename "$fw")"
    lipo -remove x86_64 "$bin" -output "$bin"
  fi
done

rm -rf build/ios/ipa
xcodebuild -exportArchive -archivePath "$ARCHIVE" \
  -exportPath build/ios/ipa -exportOptionsPlist "$OPTS" -allowProvisioningUpdates | tail -3
ls -la build/ios/ipa/*.ipa
