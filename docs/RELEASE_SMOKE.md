# Release-Smoketest (SBSTN-133)

Checkliste für manuelle Verifikation mit **isoliertem Vercel-Testprojekt** (kein Production-Blast).

## Vorbereitung

- [ ] `main` gebaut in Xcode (Simulator + optional iPhone)
- [ ] PAT mit Zugriff auf Test-Team/Testprojekt (nicht in Git/Chat)
- [ ] Vercel-Dashboard parallel offen zum Vergleich

## Auth & Scope

- [ ] Login mit gültigem Token → Dashboard lädt
- [ ] Logout → erneut Login, kein alter Team-Scope
- [ ] Team A → Team B schnell wechseln → Listen nur Team B
- [ ] Flugmodus → verständliche Fehlermeldung, App stürzt nicht ab

## Projekte & Deployments

- [ ] Projektliste: Suche, „Aktualisiert“, Pagination-Hinweis falls >1000
- [ ] Projekt-Detail: Deployments stimmen mit Dashboard überein (Status, Preview/Production)
- [ ] Deployment-Detail: Branch, Version, Logs (oder Leer-Hinweis)

## Schreibend (nur Testprojekt)

- [ ] Redeploy → **Abbrechen** → kein neues Deployment in Vercel
- [ ] Redeploy → **Bestätigen** auf Preview → neues `dpl_…` sichtbar

## Abschluss

- [ ] Ergebnisse in Linear SBSTN-133 kommentieren
- [ ] Offene Bugs als neue Issues, P0 vor v1.0.0