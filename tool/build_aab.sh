#!/bin/bash
# Compila el App Bundle para Google Play, firmado con la clave de subida
# (android/key.properties) y con el código Dart ofuscado. Los símbolos para
# leer los crashes quedan en build/symbols/android (no se suben al repo).
set -euo pipefail
cd "$(dirname "$0")/.."
[ -f android/key.properties ] || { echo "ERROR: falta android/key.properties (ver README, «Clave de Android»)"; exit 1; }
flutter clean >/dev/null
flutter pub get >/dev/null
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols/android
ls -la build/app/outputs/bundle/release/*.aab
