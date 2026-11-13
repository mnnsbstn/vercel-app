# Vercel Manager for iOS

Native, **inoffizielle** iOS-App zur Verwaltung und Überwachung von Vercel-Projekten. Entwickelt mit SwiftUI, ohne Drittanbieter-SDKs oder eigenen Backend-Server.

## Funktionen (MVP 0.1)

- Verbindung mit einem **persönlichen Vercel Access Token**, ausschließlich im iOS Keychain gespeichert
- Wechsel zwischen persönlichem Vercel-Account und Teams
- Übersicht und Suche über Projekte, inklusive Framework
- Liste der letzten Deployments mit Status, Umgebung und Zeitstempel
- Detailansicht pro Projekt und Deployment sowie Öffnen der Deployment-URL
- Manuelle Aktualisierung durch Pull-to-Refresh

**Bewusst noch nicht enthalten:** Redeploy, Rollback, Löschen, Build-Logs und Push-Nachrichten. Die erste Version führt ausschließlich lesende API-Anfragen aus.

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
- GET /v9/projects?limit=100
- GET /v6/deployments?limit=40
- GET /v6/deployments?projectId=...&limit=50

Für Team-Ressourcen wird automatisch `teamId` als Query-Parameter angehängt. Die Projektliste lädt maximal zehn Seiten mit je 100 Projekten, die Dashboard-Deployments maximal 40 Einträge.

## Sicherheit

Der Token wird im **iOS-Keychain** mit `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` gespeichert. Er wird niemals im Quelltext, in `UserDefaults`, in Logs oder im Repository abgelegt. Die Verbindung erfolgt direkt zwischen dem iPhone und der Vercel-API über HTTPS.

**Hinweis:** Die Access-Token-Eingabe ist bewusst für den privaten MVP vorgesehen. Für eine öffentlich angebotene App mit mehreren Nutzern sollte vor Veröffentlichung **Sign in with Vercel (OAuth/OIDC mit PKCE)** ergänzt werden. Ein Personal Access Token gewährt die Rechte seines Inhabers.

## Weiterentwicklung

Geplant: Deployment-Logs, sichere explizit bestätigte Deployment-Aktionen, Push-Alerts per Webhooks/Backend, Widgets, bessere Fehlerdiagnosen und automatisierte Tests.

Vercel und das Vercel-Logo sind Marken ihrer jeweiligen Inhaber. Dieses Projekt ist nicht offiziell mit Vercel verbunden.
