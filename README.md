# Vercel Manager for iOS

Native, **inoffizielle** iOS-App zur Verwaltung und Überwachung von Vercel-Projekten. Entwickelt mit SwiftUI, ohne Drittanbieter-SDKs oder eigenen Backend-Server.

## Entwicklung in Cursor (13.–27. November 2026)

- **[AGENTS.md](AGENTS.md)** – automatisch gelesene, dauerhaft geltende Cursor-Agentenregeln.
- **[docs/M1_AUDIT.md](docs/M1_AUDIT.md)** – M1-Technikprüfung und Gap-Analyse (SBSTN-120/121).
- **[Linear-Projekt P-SBSTN-4](https://linear.app/mnnsbstn/project/vercel-manager-985f75483227)** – 4 Meilensteine, 20 Issues, Fristen und Abhängigkeiten.
- **Release-Ziel:** 27.11.2026: privat auf echtem iPhone getestete Version `v1.0.0` (kein garantierter App-Store-Release).

- **[CHANGELOG.md](CHANGELOG.md)** – Versionshistorie (aktuell **0.9.0** auf dem Weg zu v1.0.0).
- **[docs/RELEASE_SMOKE.md](docs/RELEASE_SMOKE.md)** – Smoketest-Checkliste vor Release (SBSTN-133).

## Funktionen (Stand `main`, Pre-Release 0.9.x)

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

## Sicherheit

Der Token wird im **iOS-Keychain** mit `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` gespeichert. Er wird niemals im Quelltext, in `UserDefaults`, in Logs oder im Repository abgelegt. Die Verbindung erfolgt direkt zwischen dem iPhone und der Vercel-API über HTTPS.

**Hinweis:** Die Access-Token-Eingabe ist bewusst für den privaten MVP vorgesehen. Für eine öffentlich angebotene App mit mehreren Nutzern sollte vor Veröffentlichung **Sign in with Vercel (OAuth/OIDC mit PKCE)** ergänzt werden. Ein Personal Access Token gewährt die Rechte seines Inhabers.

## Weiterentwicklung

Geplant: Deployment-Logs, sichere explizit bestätigte Deployment-Aktionen, Push-Alerts per Webhooks/Backend, Widgets, bessere Fehlerdiagnosen und automatisierte Tests.

Vercel und das Vercel-Logo sind Marken ihrer jeweiligen Inhaber. Dieses Projekt ist nicht offiziell mit Vercel verbunden.
