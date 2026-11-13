# M1 – Technische Prüfliste & Gap-Analyse (SBSTN-120 / SBSTN-121)

Stand: 2026-11-13 · Basis-Commit MVP: `d88b302` · Kein Live-API-Test in dieser Session (kein Token in der Umgebung).

## Setup & Build

| Prüfpunkt | Ergebnis |
| --- | --- |
| Repository-Struktur (`VercelManager.xcodeproj`, Core/Views) | Vorhanden, konsistent |
| Lokaler `xcodebuild` (Cloud Agent VM, Linux) | **Nicht verfügbar** – kein Xcode/macOS |
| GitHub Actions `ios-build.yml` auf `xcode-27` | **Grün** für MVP-Commit `d88b302` und nachfolgende Docs-Commits (Runs #1–#3) |
| XCTest-Target / `xcodebuild test` | **Fehlt** – nur App-Target, CI führt keine Tests aus |
| `AGENTS.md` / `docs/CURSOR_MASTER_PROMPT.md` | Auf `main` vorhanden |

Empfohlener lokaler Build (macOS):

```bash
xcodebuild -project VercelManager.xcodeproj -scheme VercelManager \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```

## API-Abgleich (Code vs. offizielle Doku)

| Bereich | Im Code | Doku / Risiko |
| --- | --- | --- |
| User | `GET /v2/user` | Unverändert üblich |
| Teams | `GET /v2/teams` | Unverändert üblich |
| Projekte | `GET /v9/projects`, `limit=100`, Pagination `from` | Aktuellste Listen-API: **v10**; v9 weiter nutzbar, Migration später prüfen. Pagination-Parameter `from` entspricht Doku. |
| Deployments | `GET /v6/deployments`, `teamId`, `projectId`, `limit` | Entspricht README; keine Deployment-Pagination im MVP (nur erste Seite) |
| Logs | — | **Nicht implementiert** |
| Redeploy | — | **Nicht implementiert** (bewusst) |
| POST / Schreibzugriffe | Keine | Entspricht MVP-README |

### Decoding-Risiken

- `VercelProject.updatedAt`, `VercelDeployment.created` als `Double` (ms seit Epoch) – plausibel für Vercel-JSON.
- `Pagination.next` als String **oder** Int64 – defensive Implementierung vorhanden.
- `APIErrorBody` nur `{ error: { message } }` – bei abweichendem Fehlerformat generischer Fallback.

### HTTP-Fehler

| Status | Verhalten |
| --- | --- |
| 401 | Deutsche Meldung |
| 403 | Deutsche Meldung |
| 429 | Deutsche Meldung |
| 404, 5xx | Generisch: `Vercel API (status): message` |
| Offline / Timeout | **Keine** dedizierte `URLError`-Übersetzung |
| JSON-Decode-Fehler | Wirft nach außen, Text oft technisch |

## Architektur & State

**Stärken:** Klare Schichtung API → Modelle → `AppModel` → SwiftUI; Keychain `WhenUnlockedThisDeviceOnly`; Token vor Save via `GET /v2/user`; Team-Scope als Query `teamId`; Projekt-Pagination mit Cursor-Schleife (max. 10 Seiten); `selectScope` leert Listen vor Reload; `ProjectDetailView` lädt bei `task(id: model.scopeID)` neu.

**Behoben in dieser Session:** `signOut()` löscht jetzt `scopeID` und UserDefaults; ungültiger gespeicherter Team-Scope wird nach Team-Laden zurückgesetzt.

**Offene Risiken**

- Abgelaufener Keychain-Token: App bleibt „authentifiziert“, zeigt nur Fehler – kein automatisches Sign-Out bei 401.
- `refresh()` bricht bei erstem Fehler ab (Projekte **und** Deployments parallel – ein Fehler → beide leer bzw. alter Stand).
- Kein Request-Deduplizierung bei schnellem Teamwechsel (nur `isRefreshing`-Guard).
- Account-Label bei ungültigem `scopeID`: zeigt kurz Team-Namen aus alter ID, bis Reconcile greift.

## UI / P0-Abdeckung (nur Code-Review)

| P0 | Stand |
| --- | --- |
| Login + Keychain + Token-Verify | Implementiert, **nicht live verifiziert** |
| Team-/Accountwahl | Implementiert + Scope-Reconcile |
| Projekte + Suche | Implementiert |
| Deployments (global + pro Projekt) | Implementiert, max. 40/50 ohne Pagination |
| Logs | Fehlt |
| Redeploy mit Confirm | Fehlt |
| Deployment-Links | URL-Härtung (`https`, Host) |
| Accessibility / Dynamic Type | Teilweise (einige Labels), kein Audit |
| Inoffizielles Branding | Textlich ok; generisches SF-Symbol-Icon |

## Gap-Analyse nach Priorität

### P0 (bis v1.0.0, Reihenfolge)

1. **XCTest-Target + URLProtocol-Mocks** (API-Fehler, Pagination-Cursor, Scope-State, Keychain-logik wo mockbar).
2. **CI: `build` + `test`** in `ios-build.yml`.
3. **401/Session-Recovery:** bei Auth-Fehler Keychain leeren und zur Login-Ansicht.
4. **Netzwerk-Fehler** (Timeout, offline) benutzerfreundlich auf Deutsch.
5. **Deployment-Logs** (offizielle Endpunkte, Empty/Expired).
6. **Redeploy** mit Bestätigungsdialog, Zielumgebung, nur Testprojekt zuerst.
7. **Live-Verifikation** mit realem Token (lokal auf Mac/iPhone, nicht im Repo).
8. **Physisches iPhone:** Signing, Smoke-Test-Matrix aus Master Prompt.

### P1

- Deployments-Pagination (accountweit > 100).
- Optional Migration `GET /v10/projects` nach Live-Test.
- Deployment-Status BUILDING/QUEUED konsistent in UI und VoiceOver.
- README: Changelog, Known Limitations, Install v1.0.0.
- App-Icon (nicht Vercel-Marke).

### P2

- OAuth „Sign in with Vercel“, Widgets, Push, Rollback UI, Env-Vars – Backlog in Linear.

## Nächste Linear-Issues (Vorschlag)

1. SBSTN-120 abschließen (lokaler Simulator auf deinem Mac – außerhalb Cloud Agent).
2. **Neu:** XCTest-Target + erster API-Mock-Test (blockiert CI-Qualitätsgate).
3. **Neu:** Auth-Session-Recovery bei 401.
4. M2-Issues: Live-Daten-Verifikation Teamwechsel, Deployment-Pagination.
