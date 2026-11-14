# Changelog

Alle wesentlichen Änderungen an **Vercel Manager** (inoffizielle iOS-App).

Format orientiert sich an [Keep a Changelog](https://keepachangelog.com/de/1.1.0/).

## [Unreleased]

### Geplant bis v1.0.0 (27.11.2026)

- End-to-End-Smoketest mit isoliertem Vercel-Testprojekt (SBSTN-133)
- Install und QA auf physischem iPhone (SBSTN-137)
- Security/Privacy-Review und Release-Gate (SBSTN-134, SBSTN-138)
- Erweiterte Unit-Tests mit URLProtocol-Mocks (SBSTN-132)

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