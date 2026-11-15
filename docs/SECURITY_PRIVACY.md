# Security & Privacy (SBSTN-134)

Stand: 2026-11-15 · Version **0.9.x** · Gültig für privaten Release `v1.0.0`.

## Kurzfassung

**Vercel Manager** ist eine inoffizielle Client-App: Das iPhone spricht **direkt** mit `https://api.vercel.com`. Es gibt **keinen** eigenen Backend-Server, keine Werbe-SDKs und keine Analytics in der App.

| Daten | Wo | Übertragung |
|-------|-----|-------------|
| Vercel Personal Access Token | iOS-Keychain (`WhenUnlockedThisDeviceOnly`) | Nur im `Authorization: Bearer …` Header zu Vercel |
| Team-Scope (`scopeID`) | `UserDefaults` (kein Token) | — |
| Projekte, Deployments, Logs | Nur im RAM / UI | GET von Vercel |
| Build-Log-Text | UI (kopierbar) | GET Events von Vercel |

## Review-Checkliste (Code)

| Prüfpunkt | Status | Nachweis |
|-----------|--------|----------|
| Kein Token in Git / `.env` in `.gitignore` | OK | `.gitignore`, kein Secret im Repo |
| Kein `print` / `NSLog` des Tokens | OK | grep `VercelManager/` |
| Token nicht in `UserDefaults` | OK | nur `scopeID` in `AppModel` |
| Keychain `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` | OK | `KeychainStore.save` |
| Logout löscht Keychain + Scope | OK | `AppModel.signOut` |
| Nur HTTPS zu `api.vercel.com` | OK | `VercelAPI.baseURL` |
| API-Fehlertexte ohne Token-Leak | OK | `VercelAPIError` / Server-Message, kein lokales Logging |
| Redeploy nur nach UI-Bestätigung | OK | `RedeployConfirmationSheet` |
| Inoffiziell-Hinweis in UI | OK | `SettingsView` Footer |
| CI ohne Secrets | OK | `.github/workflows/ios-build.yml` ohne PAT |

## Token-Empfehlung für Nutzer

1. Eigenen PAT unter [vercel.com/account/tokens](https://vercel.com/account/tokens) anlegen.
2. **Minimale Scopes** — nur was für Lesen + Test-Redeploy nötig ist.
3. Token **nie** in Issues, Chat, Screenshots oder Git.
4. Bei Verdacht auf Leak: Token in Vercel **widerrufen** und in der App neu verbinden.

## App Transport Security (ATS)

Standard-iOS-ATS gilt: Nur HTTPS. Die App setzt keine `NSAllowsArbitraryLoads`-Ausnahme. Alle API-Calls gehen an `https://api.vercel.com`.

## Drittanbieter

- **Vercel Inc.** — API-Host und Datenquelle (unterliegt [Vercel Privacy Policy](https://vercel.com/legal/privacy-policy)).
- **Apple iOS** — Keychain, URLSession.
- **GitHub Actions** — Build/Test ohne App-Geheimnisse (öffentliches Repo).

## Bekannte Grenzen (v1.0.0)

- **PAT statt OAuth:** Wer das Gerät entsperrt hat und die App öffnet, kann API-Aktionen im Umfang des Tokens ausführen.
- **Kein App-Pin / Biometrie** zusätzlich zum System-Lock.
- **Build-Logs** können sensible Projektinformationen enthalten — Kopieren bewusst nur bei Bedarf.

## Vor Release erneut prüfen

- [ ] `git log` / `git grep` auf versehentliche Token-Strings
- [ ] Physisches Gerät: Logout → Keychain leer
- [ ] Redeploy nur auf Testprojekt verifiziert ([RELEASE_SMOKE.md](RELEASE_SMOKE.md))