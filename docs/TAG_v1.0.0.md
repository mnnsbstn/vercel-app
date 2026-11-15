# Tag `v1.0.0` anlegen (nach Gate)

Nur ausführen, wenn [RELEASE_GATE.md](RELEASE_GATE.md) vollständig abgehakt ist und Release-PR **#13** auf `main` gemergt ist.

```bash
git fetch origin
git checkout main
git pull origin main

# Optional: Versionszeile in CHANGELOG mit heutigem Datum setzen

git tag -a v1.0.0 -m "Vercel Manager v1.0.0 — private iOS release"
git push origin v1.0.0
```

GitHub: **Releases → Draft a new release** → Tag `v1.0.0`, Text aus [RELEASE_NOTES_v1.0.0.md](RELEASE_NOTES_v1.0.0.md).

Linear: SBSTN-138 und SBSTN-137 auf **Done**, Kommentar mit Gerätemodell + Build-Nummer.