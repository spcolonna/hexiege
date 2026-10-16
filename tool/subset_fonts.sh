#!/usr/bin/env bash
# Recorta las fuentes de los estilos de interfaz a latín + los kanji que usa la UI.
# Uso: tool/subset_fonts.sh <carpeta con los .ttf completos de Google Fonts>
# Requiere fonttools (pip install fonttools). Volver a correrlo al sumar kanji nuevos.
set -euo pipefail
SRC=${1:?carpeta con los .ttf originales}
cd "$(dirname "$0")/.."
KANJI=$(grep -rhoP "[\x{3400}-\x{9FFF}]" lib/ui lib/match lib/engine lib/solo | sort -u | tr -d '\n')
for f in "$SRC"/*.ttf; do
  pyftsubset "$f" \
    --unicodes="U+0020-024F,U+2000-206F,U+20AC,U+2190-2193,U+2022,U+00D7,U+30FB,U+300C-300D" \
    --text="$KANJI" --layout-features='kern,liga,palt,tnum,lnum' \
    --output-file="assets/fonts/$(basename "$f")"
done
