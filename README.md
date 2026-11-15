# Vercel Manager for iOS

Native, **inoffizielle** iOS-App zur Verwaltung und Überwachung von Vercel-Projekten. Entwickelt mit SwiftUI, ohne Drittanbieter-SDKs oder eigenen Backend-Server.

## Entwicklung in Cursor (13.–27. November 2026)

- **[AGENTS.md](AGENTS.md)** – automatisch gelesene, dauerhaft geltende Cursor-Agentenregeln.
- **[docs/M1_AUDIT.md](docs/M1_AUDIT.md)** – M1-Technikprüfung und Gap-Analyse (SBSTN-120/121).
- **[Linear-Projekt P-SBSTN-4](https://linear.app/mnnsbstn/project/vercel-manager-985f75483227)** – 4 Meilensteine, 20 Issues, Fristen und Abhängigkeiten.
- **Release-Ziel:** 27.11.2026: privat auf echtem iPhone getestete Version `v1.0.0` (kein garantierter App-Store-Release).

- **[CHANGELOG.md](CHANGELOG.md)** – Versionshistorie (**1.0.0** nach Smoketest-Gate).
- **[docs/SMOKE_WALKTHROUGH.md](docs/SMOKE_WALKTHROUGH.md)** – Smoketest **Schritt für Schritt** (SBSTN-133/137).
- **[docs/RELEASE_SMOKE.md](docs/RELEASE_SMOKE.md)** – kompakte Checkliste.
- **[docs/SECURITY_PRIVACY.md](docs/SECURITY_PRIVACY.md)** – Security- & Privacy-Review (SBSTN-134).
- **[docs/RELEASE_GATE.md](docs/RELEASE_GATE.md)** – Release-Gate für Tag `v1.0.0` (SBSTN-138).
- **[docs/IPHONE_INSTALL.md](docs/IPHONE_INSTALL.md)** – Installation auf physischem iPhone (SBSTN-137).
- **[docs/CI.md](docs/CI.md)** – GitHub Actions & Merge-Policy (SBSTN-135).

## Funktionen (Stand `main`, Release-Kandidat 1.0.0)

- Verbindung mit **Vercel Access Token** (Keychain, `WhenUnlockedThisDeviceOnly`)
- Persönlicher Account und Teams, robuster Scope-Wechsel
- Projekte: Suche, Pagination mit dokumentierten Limits
- Deployments: Pagination, Preview/Staging/Production, Branch/Commit in der UI
- Build-Logs lesen, kopieren, aktualisieren
- **Redeploy** nur nach explizitem Bestätigungsdialog (Testprojekt zuerst)
- 401-Session-Recovery, deutsche Netzwerk-/API-Fehlertexte
- Unit-Tests + CI (Simulator Build & Test)

**Nicht in v1.0.0:** Rollback, Löschen, Push, OAuth, Widgets.

## Installation auf Mac & iPhone

1. Repository klonen oder als ZIP herunterladen.
2. Die Datei **VercelManager.xcodeproj** in Xcode 16 oder neuer öffnen.
3. Als Run-Destination einen iOS-Simulator oder dein iPhone auswählen (iOS 17+).
4. Bei Installation auf einem echten Gerät unter **Signing & Capabilities** dein eigenes Apple-Entwicklerteam auswählen. Bei Bedarf die Bundle-ID anpassen.
5. Mit **Run (⌘R)** starten.
6. Unter https://vercel.com/account/tokens einen Vercel Access Token anlegen. Achte darauf, dass der Token Zugriff auf die gewünschten Accounts und Teams hat.
7. Token nur in der App eingeben, **niemals ins GitHub-Repository oder in einen Issue kopieren**.

## Technischer Aufbau

- **SwiftUI**: native iOS-Oberfläche, Dark Mode
- **URLSession**: direkte HTTPS-Requests an https://api.vercel.com
- **Keychain**: sichere lokale Speicherung des Zugriffstokens (ThisDeviceOnly)
- **AppModel**: Accountwechsel, Loading- und Fehlerzustände
- **VercelAPI**: Vercel REST API (User, Teams, Projekte, Deployments)
- **GitHub Actions**: iOS-Simulator-Build bei Push oder Pull Request

### Wichtige API-Routen

- GET /v2/user
- GET /v2/teams
- GET /v9/projects?limit=100&from=… (Pagination, App-Limit: 10 Seiten = max. 1.000 Projekte)
- GET /v6/deployments?limit=40
- GET /v6/deployments?projectId=…&limit=100&until=… (Pagination; Dashboard max. 300, Projekt max. 800)
- GET /v3/deployments/{id}/events?direction=backward&limit=200 (Build-Logs)
- POST /v13/deployments `{ name, deploymentId }` (Redeploy nach Bestätigung)

Für Team-Ressourcen wird automatisch `teamId` angehängt. Limits: Projekte max. 1.000, Dashboard-Deployments max. 300, Projekt-Deployments max. 800 — mit UI-Hinweis, wenn Vercel mehr liefert.

## Tests lokal (macOS)

```bash
xcodebuild -project VercelManager.xcodeproj -scheme VercelManager \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO test
```

## Sicherheit & Datenschutz

Details: **[docs/SECURITY_PRIVACY.md](docs/SECURITY_PRIVACY.md)**.

Der Token liegt im **iOS-Keychain** (`WhenUnlockedThisDeviceOnly`), nicht in `UserDefaults`, Logs oder Git. HTTPS nur zu `https://api.vercel.com`. Beim Abmelden wird der Keychain-Eintrag gelöscht.

Für einen **öffentlichen** Multi-User-Release sollte **OAuth/OIDC (PKCE)** statt PAT perspektivisch ergänzt werden.

Vercel und das Vercel-Logo sind Marken ihrer jeweiligen Inhaber. **Inoffizielle App** — nicht von Vercel Inc. betrieben oder unterstützt.
