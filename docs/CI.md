# Continuous Integration (SBSTN-135)

## Workflow

GitHub Actions: [`.github/workflows/ios-build.yml`](../.github/workflows/ios-build.yml)

| Trigger | Zweig |
|---------|--------|
| `push` → `main` | Build + Unit-Tests |
| `push` → Tag `v*` | Build + Unit-Tests (Release-Sicherheitsnetz) |
| `pull_request` | Build + Unit-Tests auf PR-Branch |

Runner: **`macos` mit Label `xcode-27`** (Xcode 27, iOS Simulator).

## Was geprüft wird

1. **Build** — `VercelManager` für iOS Simulator (`CODE_SIGNING_ALLOWED=NO`)
2. **Tests** — gesamtes Target `VercelManagerTests` auf dem ersten verfügbaren **iPhone**-Simulator (aktuell **21 Tests**)

## Merge-Policy (empfohlen)

GitHub-Repository-Einstellung (manuell im Repo):

- Branch protection auf **`main`**
- Required status check: **`build`** (Workflow „iOS Simulator Build“)

Ohne grüne CI kein Merge auf `main` — erfüllt das Release-Gate-Punkt „main grün“ in [RELEASE_GATE.md](RELEASE_GATE.md).

## Lokal reproduzieren

Siehe [README.md](../README.md#tests-lokal-macos).