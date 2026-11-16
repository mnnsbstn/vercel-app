# Release-Gate v1.0.0 (SBSTN-138)

Ziel-Datum: **27.11.2026** · Marketing-Version: **1.0.0**

## Pflicht (alle Haken vor Tag)

- [x] `main` grün in GitHub Actions (Build + Tests) — siehe [CI.md](CI.md)
- [ ] [SMOKE_WALKTHROUGH.md](SMOKE_WALKTHROUGH.md) / [RELEASE_SMOKE.md](RELEASE_SMOKE.md) auf Simulator + **physischem iPhone** durchgeführt
- [x] [SECURITY_PRIVACY.md](SECURITY_PRIVACY.md) auf `main` (Review 2025-11-15); „Vor Release“ beim Smoke bestätigen
- [ ] Redeploy nur auf isoliertem Testprojekt verifiziert
- [ ] `CHANGELOG.md` — `[1.0.0]`-Datum nach erfolgreichem Smoke setzen
- [x] `MARKETING_VERSION` = `1.0.0` auf `main` (PR #13)
- [ ] Git-Tag `v1.0.0` — `CONFIRM_SMOKE=1 ./scripts/create-release.sh` oder [TAG_v1.0.0.md](TAG_v1.0.0.md); Notes [RELEASE_NOTES_v1.0.0.md](RELEASE_NOTES_v1.0.0.md)

## Optional

- [x] App-Icon in Assets auf `main` (SBSTN-136)
- [ ] TestFlight (SBSTN-139)

## Nach Tag

1. Auf dem iPhone installierte Build-Version notieren.
2. Linear SBSTN-137 / SBSTN-138 auf **Done**.
3. Follow-ups siehe [V1_BACKLOG.md](V1_BACKLOG.md) / Linear, nicht in v1.0.0 blockieren.