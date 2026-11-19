#!/usr/bin/env bash
# Create annotated tag v1.0.0 after human smoke gate (SBSTN-138).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

VERSION="${1:-1.0.0}"
TAG="v${VERSION}"
RELEASE_DATE="${RELEASE_DATE:-$(date +%Y-%m-%d)}"

usage() {
  cat <<EOF
Usage: CONFIRM_SMOKE=1 ./scripts/create-release.sh [version]

Requires CONFIRM_SMOKE=1 (or export) after SBSTN-133 / SMOKE_WALKTHROUGH passed.
Optional: RELEASE_DATE=YYYY-MM-DD (default: today)

Steps: updates CHANGELOG date line, commits if needed, tags, pushes tag.
Optional: CREATE_GITHUB_RELEASE=1 — erstellt GitHub Release via gh (falls installiert).
EOF
}

if [[ "${CONFIRM_SMOKE:-}" != "1" ]]; then
  echo "error: set CONFIRM_SMOKE=1 after smoketest passed (docs/SMOKE_WALKTHROUGH.md)." >&2
  usage
  exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "error: working tree not clean; commit or stash first." >&2
  exit 1
fi

CURRENT_BRANCH="$(git branch --show-current)"
if [[ "$CURRENT_BRANCH" != "main" ]]; then
  echo "error: run on main (currently: $CURRENT_BRANCH)" >&2
  exit 1
fi

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "error: tag $TAG already exists locally" >&2
  exit 1
fi

if git ls-remote --exit-code --tags origin "$TAG" >/dev/null 2>&1; then
  echo "error: tag $TAG already on origin" >&2
  exit 1
fi

CHANGELOG="$REPO_ROOT/CHANGELOG.md"
if grep -q "^## \[${VERSION}\] - ausstehend" "$CHANGELOG"; then
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/^## \\[${VERSION}\\] - ausstehend.*/## [${VERSION}] - ${RELEASE_DATE}/" "$CHANGELOG"
  else
    sed -i "s/^## \\[${VERSION}\\] - ausstehend.*/## [${VERSION}] - ${RELEASE_DATE}/" "$CHANGELOG"
  fi
  # Remove smoke checklist bullets under 1.0.0 section — move gate to released note
  git add CHANGELOG.md
  git commit -m "chore: set CHANGELOG ${VERSION} release date (${RELEASE_DATE})"
fi

git tag -a "$TAG" -m "Vercel Manager ${TAG} — private iOS release"
git push origin main
git push origin "$TAG"
echo "✓ Tagged and pushed ${TAG}"

NOTES_FILE="$REPO_ROOT/docs/RELEASE_NOTES_v${VERSION}.md"
if [[ "${CREATE_GITHUB_RELEASE:-}" == "1" ]]; then
  if ! command -v gh >/dev/null 2>&1; then
    echo "warning: gh not found; skip GitHub Release." >&2
  elif [[ ! -f "$NOTES_FILE" ]]; then
    echo "warning: missing $NOTES_FILE; skip GitHub Release." >&2
  else
    gh release create "$TAG" --title "Vercel Manager ${VERSION}" --notes-file "$NOTES_FILE"
    echo "✓ GitHub Release ${TAG} created"
  fi
else
  echo "Next: CREATE_GITHUB_RELEASE=1 re-run, or:"
  echo "  gh release create ${TAG} --title \"Vercel Manager ${VERSION}\" --notes-file docs/RELEASE_NOTES_v${VERSION}.md"
fi

echo "✓ Tagged and pushed ${TAG}"