# Jetzt: v1.0.0 abschließen

**Stand:** `main` · Marketing-Version **1.0.0** · CI grün · **kein Tag** `v1.0.0` yet

## Für dich (ein Block, ~1 h)

1. `git pull origin main`
2. Optional Mac: `./scripts/verify-local.sh`
3. Xcode → **[SMOKE_WALKTHROUGH.md](SMOKE_WALKTHROUGH.md)** Phase 0–4 (Simulator + iPhone; Redeploy nur Testprojekt)
4. **[SMOKE_REPORT_TEMPLATE.md](SMOKE_REPORT_TEMPLATE.md)** ausfüllen oder Kurzfeedback in Linear **SBSTN-133** / Chat: **„Smoke OK“** + Gerätemodell (ohne Token)

## Nach bestandenem Smoke (Mac)

```bash
git pull origin main
CREATE_GITHUB_RELEASE=1 CONFIRM_SMOKE=1 ./scripts/create-release.sh
```

Details: [TAG_v1.0.0.md](TAG_v1.0.0.md) · Checkliste: [RELEASE_GATE.md](RELEASE_GATE.md)

## Agent / Repo erledigt

- Funktionen M1–M3, Security-Doku, 21 Unit-Tests, App-Icon, Release-Script + Tag-CI
- Offen: **echter Smoketest** (SBSTN-133/137) → Tag + Gate (SBSTN-138)

Nach v1.0.0: [V1_BACKLOG.md](V1_BACKLOG.md)