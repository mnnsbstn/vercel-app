# Installation auf iPhone (SBSTN-137)

Kurzanleitung für den **privaten v1.0.0**-Build auf einem physischen Gerät (iOS 17+).

## Voraussetzungen

- Mac mit **Xcode 16+** (empfohlen: Xcode entsprechend CI)
- Apple-ID / **kostenloses oder bezahltes** Developer-Team
- iPhone per USB oder WLAN-Debugging verbunden

## Schritte

1. Repo auf **`main`** (0.9.x) oder nach Merge von Release-PR **1.0.0** auschecken.
2. `VercelManager.xcodeproj` öffnen.
3. Target **VercelManager** → **Signing & Capabilities**:
   - Team wählen
   - Bundle ID ggf. anpassen (`com.mnnsbstn.vercelmanager` oder eigene)
4. Oben ein **physisches iPhone** als Run-Destination wählen (nicht nur Simulator).
5. **Run (⌘R)** — erste Installation kann „Untrusted Developer“ melden:
   - iPhone: **Einstellungen → Allgemein → VPN & Geräteverwaltung** → Entwickler-App vertrauen.
6. App öffnen → Token eingeben (nur lokal, nie ins Repo).

## QA-Minimum vor Release

- Version in **Einstellungen** stimmt mit erwarteter Marketing-Version überein.
- [RELEASE_SMOKE.md](RELEASE_SMOKE.md) vollständig auf **diesem Gerät** durchlaufen.
- Protokoll: [SMOKE_REPORT_TEMPLATE.md](SMOKE_REPORT_TEMPLATE.md).

## TestFlight (optional, SBSTN-139)

Nicht für privates Sideloading nötig. Für spätere Verteilung an Tester: Archive → Distribute → TestFlight im Apple Developer Program erforderlich.