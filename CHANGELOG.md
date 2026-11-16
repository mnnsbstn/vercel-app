# Changelog

Alle wesentlichen Änderungen an **Vercel Manager** (inoffizielle iOS-App).

Format orientiert sich an [Keep a Changelog](https://keepachangelog.com/de/1.1.0/).

## [Unreleased]

_(Nur nach bestandenem Smoketest auf `main` taggen — siehe [RELEASE_GATE.md](docs/RELEASE_GATE.md).)_

## [1.0.0] - ausstehend (nach SBSTN-133)

### Hinzugefügt

- App-Icon (`Assets.xcassets`), Security/Privacy-Doku, 21 Unit-Tests inkl. URLProtocol-Mocks
- UX: Loading, VoiceOver, Reduce Motion

### Enthalten seit 0.9.0

- Logs, Redeploy-Bestätigung, Pagination, Team-Scope-Fixes, CI

### Release-Gate (vor Tag)

- [ ] [SMOKE_WALKTHROUGH.md](docs/SMOKE_WALKTHROUGH.md) abgeschlossen (SBSTN-133)
- [ ] iPhone bestätigt (SBSTN-137)

## [0.9.0] - 2026-11-14

### Hinzugefügt

- Build-Logs via `GET /v3/deployments/{id}/events` (Kopieren, Refresh)
- Redeploy mit Bestätigungsdialog (`POST /v13/deployments`)
- Projekt-Suche, Pagination-Hinweise (Projekte & Deployments)
- Deployment-Umgebungen: Preview/Staging/Production korrekt
- XCTest-Target (15 Tests), CI Build + Test auf GitHub Actions

### Geändert

- Teamwechsel: Race-Guard bei parallelen Refreshes
- 401: automatischer Logout und Keychain-Cleanup
- README und API-Limits dokumentiert

### Behoben

- Team-Scope nach Logout nicht mehr in UserDefaults
- `reconcileScopeWithTeams` nur nach erfolgreichem Team-Laden (kein Scope-Verlust bei API-Fehler)

## [0.1.0] - 2026-11-13

- Erster MVP: Token-Login, Dashboard, Projekte, Deployments, Teamwahl