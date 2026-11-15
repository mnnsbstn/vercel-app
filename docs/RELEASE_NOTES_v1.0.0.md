# Vercel Manager v1.0.0

**Inoffizielle** iOS-App zur Übersicht über Vercel-Projekte und Deployments (kein Produkt von Vercel Inc.).

## Highlights

- Vercel PAT im Keychain, Teams & persönlicher Account
- Projekte & Deployments mit Pagination und Suche
- Build-Logs lesen und kopieren
- Redeploy nur nach Bestätigung
- Dark Mode, Accessibility, Offline-Hinweise
- 21 automatisierte Unit-Tests in CI

## Installation

Siehe [README.md](../README.md) und [IPHONE_INSTALL.md](IPHONE_INSTALL.md).

## Sicherheit

[Kurzfassung](SECURITY_PRIVACY.md) — HTTPS nur zu `api.vercel.com`, Token nie in Git.

## Bekannte Grenzen

Kein OAuth, kein Push, kein Rollback/Löschen. PAT-Rechte = deine Vercel-Rechte.

---

_Text für GitHub Release beim Tag `v1.0.0`. Datum nach Smoketest in [CHANGELOG.md](../CHANGELOG.md) eintragen._