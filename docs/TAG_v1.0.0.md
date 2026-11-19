# Tag `v1.0.0` anlegen (nach Gate)

Nur ausführen, wenn [RELEASE_GATE.md](RELEASE_GATE.md) und [SMOKE_WALKTHROUGH.md](SMOKE_WALKTHROUGH.md) abgeschlossen sind (`main` = **1.0.0**).

### Empfohlen (ein Befehl)

```bash
git checkout main && git pull origin main
CREATE_GITHUB_RELEASE=1 CONFIRM_SMOKE=1 ./scripts/create-release.sh
```

`CONFIRM_SMOKE=1` ist bewusst nötig — verhindert Tag ohne Smoketest.

### Manuell

```bash
git fetch origin && git checkout main && git pull origin main
git tag -a v1.0.0 -m "Vercel Manager v1.0.0 — private iOS release"
git push origin v1.0.0
```

Linear: SBSTN-138 und SBSTN-137 auf **Done**, Kommentar mit Gerätemodell + Build-Nummer.