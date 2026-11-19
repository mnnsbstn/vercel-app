# TestFlight vorbereiten (optional, SBSTN-139)

**Nicht nötig** für privates iPhone-Release per Xcode. Nur wenn du Beta-Tester außerhalb deines Geräts willst.

## Voraussetzungen

- Apple Developer Program (paid)
- App in App Store Connect angelegt
- Signierung: Distribution-Zertifikat + Profil für Bundle-ID `de.mnnsbstn.VercelManager` (oder deine angepasste ID)

## Schritte (Kurz)

1. Xcode → **Product → Archive** (Generic iOS Device oder Any iOS Device)
2. Organizer → **Distribute App** → App Store Connect → Upload
3. App Store Connect → **TestFlight** → Build warten → interne Gruppe
4. Privacy/Export Compliance in ASC ausfüllen (kein eigener Tracking-SDK in v1.0)

## Grenzen v1.0

- Inoffizielle Vercel-App — **keine** Vercel-Marke als offizielle App verkaufen
- PAT-Login: in TestFlight-Hinweisen klar machen, dass Nutzer:eigenen Token brauchen

Nach privatem Release: Issue **SBSTN-139** in Linear schließen oder als Backlog belassen.