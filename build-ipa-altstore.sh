#!/bin/bash
set -euo pipefail
TASK_ROOT="$(cd "$(dirname "$0")" && pwd)"
if [[ "$(uname -s)" != "Darwin" ]] || ! command -v xcodebuild >/dev/null; then
  echo "Este script precisa de macOS com Xcode completo e SDK de iOS instalado." >&2
  exit 1
fi
TASK_BUILD="$(mktemp -d "${TMPDIR:-/tmp}/parkview-build.XXXXXX")"
trap 'rm -rf "$TASK_BUILD"' EXIT
TASK_OUTPUT="$TASK_ROOT/Output"
mkdir -p "$TASK_OUTPUT"
xcodebuild -project "$TASK_ROOT/ParkView.xcodeproj" -scheme ParkView \
  -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' \
  -derivedDataPath "$TASK_BUILD/DerivedData" CODE_SIGNING_ALLOWED=NO build
TASK_APP="$TASK_BUILD/DerivedData/Build/Products/Release-iphoneos/ParkView.app"
test -d "$TASK_APP"
mkdir -p "$TASK_BUILD/Package/Payload"
ditto "$TASK_APP" "$TASK_BUILD/Package/Payload/ParkView.app"
(cd "$TASK_BUILD/Package" && /usr/bin/zip -q -r "$TASK_OUTPUT/ParkView-AltStore.ipa" Payload)
echo "IPA sem assinatura criado: $TASK_OUTPUT/ParkView-AltStore.ipa"
echo "O AltStore Classic deverá assinar o IPA. Esta variante não aparece como app CarPlay."
