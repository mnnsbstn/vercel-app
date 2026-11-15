# Release-Gate v1.0.0 (SBSTN-138)

Ziel-Datum: **27.11.2026** · Marketing-Version: **1.0.0**

## Pflicht (alle Haken vor Tag)

- [ ] `main` grün in GitHub Actions (Build + Tests)
- [ ] [RELEASE_SMOKE.md](RELEASE_SMOKE.md) auf Simulator + **physischem iPhone** durchgeführt
- [ ] [SECURITY_PRIVACY.md](SECURITY_PRIVACY.md) Checkliste „Vor Release“ erledigt
- [ ] Redeploy nur auf isoliertem Testprojekt verifiziert
- [ ] `CHANGELOG.md` — Abschnitt `[1.0.0]` mit Release-Datum
- [ ] `MARKETING_VERSION` = `1.0.0` in `project.pbxproj`
- [ ] Git-Tag `v1.0.0` + Kurzbeschreibung auf GitHub Releases

## Optional

- [ ] App-Icon in Assets (SBSTN-136)
- [ ] TestFlight (SBSTN-139)

## Nach Tag

1. Auf dem iPhone installierte Build-Version notieren.
2. Linear SBSTN-137 / SBSTN-138 auf **Done**.
3. Bekannte Follow-ups als neue Issues, nicht in v1.0.0 blockieren.