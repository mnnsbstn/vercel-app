# Release-Gate v1.0.0 (SBSTN-138)

Ziel-Datum: **27.11.2026** · Marketing-Version: **1.0.0**

## Pflicht (alle Haken vor Tag)

- [x] `main` grün in GitHub Actions (Build + Tests) — siehe [CI.md](CI.md)
- [ ] [RELEASE_SMOKE.md](RELEASE_SMOKE.md) auf Simulator + **physischem iPhone** durchgeführt
- [x] [SECURITY_PRIVACY.md](SECURITY_PRIVACY.md) auf `main` (Review 2025-11-15); „Vor Release“ beim Smoke bestätigen
- [ ] Redeploy nur auf isoliertem Testprojekt verifiziert
- [ ] `CHANGELOG.md` — Abschnitt `[1.0.0]` mit Release-Datum
- [ ] `MARKETING_VERSION` = `1.0.0` — mit Merge von Draft-PR **#13**
- [ ] Git-Tag `v1.0.0` — Anleitung [TAG_v1.0.0.md](TAG_v1.0.0.md), Text [RELEASE_NOTES_v1.0.0.md](RELEASE_NOTES_v1.0.0.md)

## Optional

- [ ] App-Icon in Assets — mit Merge von Draft-PR **#13** (SBSTN-136)
- [ ] TestFlight (SBSTN-139)

## Nach Tag

1. Auf dem iPhone installierte Build-Version notieren.
2. Linear SBSTN-137 / SBSTN-138 auf **Done**.
3. Bekannte Follow-ups als neue Issues, nicht in v1.0.0 blockieren.