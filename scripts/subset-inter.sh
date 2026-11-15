#!/usr/bin/env bash
# Regenerates assets/fonts/inter/ from the official Inter release:
# the static Regular, Medium and SemiBold cuts, subset to Latin (the
# latin + latin-ext ranges Google Fonts uses, plus the minus sign and the
# currency block), with every OpenType feature kept (tnum, kern, ...).
#
#   scripts/subset-inter.sh
#
# Needs curl, unzip, shasum and python3; fonttools goes into a throwaway venv.
set -euo pipefail

VERSION=4.1
# Same hash as Homebrew's font-inter cask; the release publishes none.
SHA256=9883fdd4a49d4fb66bd8177ba6625ef9a64aa45899767dde3d36aa425756b11e
FONTTOOLS=4.60.2
CUTS=(Regular Medium SemiBold)
UNICODES="U+0000-017F,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+2000-206F,U+20A0-20CF,U+2122,U+2190-2193,U+2212,U+2215,U+FEFF,U+FFFD"

root="$(cd "$(dirname "$0")/.." && pwd)"
out="$root/assets/fonts/inter"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

curl -sSfL --retry 3 -o "$work/inter.zip" \
  "https://github.com/rsms/inter/releases/download/v${VERSION}/Inter-${VERSION}.zip"
echo "${SHA256}  $work/inter.zip" | shasum -a 256 -c -

files=(LICENSE.txt)
for cut in "${CUTS[@]}"; do files+=("extras/ttf/Inter-${cut}.ttf"); done
unzip -q -d "$work/inter" "$work/inter.zip" "${files[@]}"

python3 -m venv "$work/venv"
"$work/venv/bin/pip" install --quiet --disable-pip-version-check "fonttools==${FONTTOOLS}"

mkdir -p "$out"
for cut in "${CUTS[@]}"; do
  "$work/venv/bin/pyftsubset" "$work/inter/extras/ttf/Inter-${cut}.ttf" \
    --unicodes="$UNICODES" \
    --layout-features='*' \
    --name-IDs='*' \
    --notdef-outline \
    --output-file="$out/Inter-${cut}.ttf"
done
cp "$work/inter/LICENSE.txt" "$out/OFL.txt"

ls -l "$out"
