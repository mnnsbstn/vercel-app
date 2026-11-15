# Smoketest Schritt für Schritt (SBSTN-133 + 137)

**Ziel:** Ein Durchlauf auf **Simulator** und **physischem iPhone** mit Test-PAT (nie ins Repo).

**Build:** `main` · **1.0.0** · App-Icon aktiv · ca. 45–60 Minuten gesamt

---

## Phase 0 — Xcode vorbereiten (5 Min.)

1. `git clone` / `git pull` auf `main`.
2. `VercelManager.xcodeproj` öffnen.
3. Optional: `xcodebuild test` wie in [README.md](../README.md#tests-lokal-macos) — muss lokal grün sein.
4. PAT in Zwischenablage (nur lokal), **nicht** in Cursor/Git/Linear einfügen.

---

## Phase 1 — Simulator (15 Min.)

| # | Aktion | Erwartung | ✓ |
|---|--------|-----------|---|
| 1 | Run auf **iPhone 16** Simulator | App startet, Login-Screen | |
| 2 | Token eingeben → Verbinden | Dashboard lädt Metriken | |
| 3 | Tab **Projekte** → Suche tippt 2 Zeichen | Liste filtert | |
| 4 | Projekt öffnen → Deployments | Liste oder Empty-State | |
| 5 | Deployment → **Build-Logs** | Events oder sinnvoller Leer-Hinweis | |
| 6 | **Einstellungen** → Team wechseln | Daten wechseln, kein Crash | |
| 7 | Pull-to-refresh auf Übersicht | Spinner, Daten bleiben konsistent | |
| 8 | **Flugmodus** an → Refresh | Deutsche Offline-Meldung | |
| 9 | Flugmodus aus → Refresh | Wieder Daten | |
| 10 | Abmelden → erneut anmelden | Funktioniert, Scope ok | |

---

## Phase 2 — iPhone (15 Min.)

Siehe [IPHONE_INSTALL.md](IPHONE_INSTALL.md).

| # | Aktion | Erwartung | ✓ |
|---|--------|-----------|---|
| 1 | Gerät wählen, Run (⌘R) | Install + Trust Developer falls nötig | |
| 2 | Login wie Phase 1 | Gleiches Verhalten wie Simulator | |
| 3 | **Einstellungen** zeigt **Version 1.0.0** | Marketing-Version stimmt | |
| 4 | App-Icon auf Home Screen | Schwarz/weiß Dreieck (inoffiziell) | |
| 5 | App killen → erneut öffnen | Session aus Keychain, kein erneuter Token | |
| 6 | Kurz Teamwechsel + ein Projekt | Performance ok | |

---

## Phase 3 — Schreibend (nur Testprojekt!) (10 Min.)

| # | Aktion | Erwartung | ✓ |
|---|--------|-----------|---|
| 1 | Preview-Deployment → **Redeploy** → **Abbrechen** | Kein neues `dpl_` in Vercel | |
| 2 | Redeploy → **Bestätigen** auf **Testprojekt** | Neues Deployment im Dashboard | |
| 3 | Logs des neuen Deployments | Neue Zeilen sichtbar | |

---

## Phase 4 — Abschluss (5 Min.)

1. [SMOKE_REPORT_TEMPLATE.md](SMOKE_REPORT_TEMPLATE.md) ausfüllen (oder als Kommentar in **SBSTN-133**).
2. P0-Bugs sofort notieren; P1 können nach v1.0.0.
3. Wenn **alle P0 grün**: [TAG_v1.0.0.md](TAG_v1.0.0.md) ausführen → **SBSTN-138** / **137** auf Done.

---

## VoiceOver (optional, 5 Min.)

Simulator → Einstellungen → Bedienungshilfen → VoiceOver → App durchgehen:

- Dashboard-Metriken lesbar
- Deployment-Zeile kombiniert Status + Name
- Redeploy-Button mit Hinweis