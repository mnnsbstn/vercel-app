# Vercel Manager — Web-App & iPhone-Homescreen (PWA)

**Inoffizielle** Web-Variante mit **demselben App-Icon** wie die iOS-App (nicht das offizielle Vercel-Markenlogo).

## Warum Web?

- Kein Xcode-Entwicklermodus nötig für Tests
- Auf dem iPhone: **Safari → Teilen → Zum Home-Bildschirm** → eigenes Icon

## Grenzen (MVP)

- Token in **sessionStorage** (nicht so sicher wie iOS-Keychain)
- Funktionen: Login, Projekte, Team-Scope, Abmelden
- Deployments/Logs/Redeploy: weiter in der **nativen iOS-App** (oder später im Web nachrüsten)
- Vercel-API braucht einen **gleich-origin Proxy** (`/api/vercel/...`) — nicht nur statische Dateien

## Lokal auf dem Mac

```bash
cd web
npm install
npm run dev
```

→ http://127.0.0.1:5173

Produktion lokal:

```bash
npm run preview
```

→ http://127.0.0.1:4173

## iPhone (HTTPS nötig)

Safari installiert PWAs zuverlässig nur über **HTTPS** (nicht `http://` von deinem Mac LAN ohne Zertifikat).

Optionen:

1. **Gehostete URL** (z. B. Vercel, Cursor Published App, ngrok/cloudflared auf `npm run preview`)
2. Am Gerät: Seite öffnen → **Teilen** → **Zum Home-Bildschirm** → Name **Vercel Manager** → Icon erscheint wie in der App

## Token

[PAT erstellen](https://vercel.com/account/tokens) — nur in die Web-App eingeben, nie ins Git/Chat.