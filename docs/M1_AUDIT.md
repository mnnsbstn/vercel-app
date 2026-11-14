# M1 – Technische Prüfliste & Gap-Analyse (SBSTN-120 / SBSTN-121)

Stand: 2026-11-14 · Basis: `main` @ **0.9.0** (PRs #2–#8) · Live-API-Tests nur lokal mit PAT (siehe [docs/RELEASE_SMOKE.md](RELEASE_SMOKE.md)).

## Setup & Build

| Prüfpunkt | Ergebnis |
| --- | --- |
| Repository-Struktur (`VercelManager.xcodeproj`, Core/Views) | Vorhanden, konsistent |
| Lokaler `xcodebuild` (Cloud Agent VM, Linux) | **Nicht verfügbar** – kein Xcode/macOS |
| GitHub Actions `ios-build.yml` auf `xcode-27` | **Grün** für `main` (Runs #1–#4); PR #1 mit Scope-Fix zunächst **rot** (Swift `guard`-Compile-Fehler) |
| XCTest-Target / `xcodebuild test` | **Vorhanden** – CI führt Build + 15 Unit-Tests aus |
| `AGENTS.md` | Auf `main` vorhanden |
| `docs/CURSOR_MASTER_PROMPT.md` | **Entfernt** in `0954e8f`; README verlinkt noch – Link reparieren oder Datei wiederherstellen |

Empfohlener lokaler Build (macOS):

```bash
xcodebuild -project VercelManager.xcodeproj -scheme VercelManager \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```

## API-Abgleich (Code vs. offizielle Doku)

| Bereich | Im Code | Doku / Risiko |
| --- | --- | --- |
| User | `GET /v2/user` | [Dokumentiert](https://vercel.com/docs/rest-api/reference/endpoints/user/get-the-user) |
| Teams | `GET /v2/teams` | [Dokumentiert](https://vercel.com/docs/rest-api/reference/endpoints/teams/list-teams) |
| Projekte | `GET /v9/projects`, `limit=100`, Pagination `from` | v9 weiter üblich; neuere Listen-API ist **v10** – nach Live-Test migrieren |
| Deployments | `GET /v6/deployments`, `teamId`, `projectId`, `limit` | [Dokumentiert](https://vercel.com/docs/rest-api/reference/endpoints/deployments/list-deployments); keine Pagination im MVP |
| Logs | — | **Nicht implementiert** (z. B. deployment events / build output – Endpoint vor Implementierung prüfen) |
| Redeploy | — | **Nicht implementiert** (bewusst) |
| POST / Schreibzugriffe | Keine | Entspricht MVP-README |

Team-Scope: `teamId` Query-Parameter bei team-gebundenen Ressourcen – entspricht Vercel-Konvention.

### Decoding-Risiken

- `VercelProject.updatedAt`, `VercelDeployment.created` als `Double` (ms seit Epoch).
- `Pagination.next` als String **oder** Int64 – defensive Codable-Implementierung.
- `APIErrorBody` nur `{ error: { message } }` – bei abweichendem Fehlerformat generischer Fallback.

## Architektur & State

**Stärken:** API → Modelle → `AppModel` → SwiftUI; Keychain `WhenUnlockedThisDeviceOnly`; Token vor Save via `GET /v2/user`; Pagination mit Cursor-Schleife (max. 10 Seiten).

**Behoben (Scope-Fix):** `signOut()` löscht `scopeID`/UserDefaults; nach Team-Laden `reconcileScopeWithTeams()`; `if` statt fehlerhaftem `guard`-fallthrough (CI #5).

**Offene Risiken**

- Abgelaufener Keychain-Token: App bleibt „authentifiziert“, kein Auto-Sign-Out bei 401.
- `refresh()`: parallele Fehler → nur generische Meldung, Daten evtl. veraltet.
- Deployments nur erste Seite (40/50 Einträge).

## Gap-Analyse (P0 first)

1. XCTest-Target + URLProtocol-Mocks; CI `test`.
2. 401-Session-Recovery (Keychain leeren → Login).
3. Netzwerkfehler (URLError) auf Deutsch.
4. Deployment-Logs, Redeploy mit Bestätigung.
5. Live-Verifikation auf Mac/iPhone (Token nur lokal).
6. README/Master-Prompt-Link konsolidieren.
