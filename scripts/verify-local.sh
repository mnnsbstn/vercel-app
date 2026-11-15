#!/usr/bin/env bash
# Lokale Vorprüfung wie CI (SBSTN-133 Phase 0). Kein Token nötig.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "→ Build (generic Simulator)…"
xcodebuild -project VercelManager.xcodeproj \
  -scheme VercelManager \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build

SIMULATOR_ID="$(
  xcrun simctl list devices available | grep -E '^\s+iPhone' | head -1 | grep -oE '[0-9A-F-]{36}' || true
)"
if [[ -z "${SIMULATOR_ID}" ]]; then
  echo "Kein iPhone-Simulator gefunden — nur Build OK."
  exit 0
fi

echo "→ Tests auf Simulator ${SIMULATOR_ID}…"
xcodebuild -project VercelManager.xcodeproj \
  -scheme VercelManager \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=${SIMULATOR_ID}" \
  CODE_SIGNING_ALLOWED=NO \
  test -only-testing:VercelManagerTests

echo "✓ Build + 21 Tests OK — Smoketest Phase 1 starten (docs/SMOKE_WALKTHROUGH.md)."