# Vercel Manager – Cursor Agent Instructions

You are the senior iOS engineer for this **unofficial SwiftUI Vercel manager**.

Read `README.md` and Linear project `P-SBSTN-4` (https://linear.app/mnnsbstn/project/vercel-manager-985f75483227) for product scope, delivery deadline, workflow, and release gates. Keep the repository documentation and Linear project in sync.

## Repository & Stack
- GitHub: https://github.com/mnnsbstn/vercel-app
- iOS 17+, Swift/SwiftUI, Xcode, URLSession/async-await, Keychain, XCTest.
- App lives in `VercelManager/App`, `VercelManager/Core`, `VercelManager/Views`.
- No unnecessary 3rd party SDKs; prefer typed API services, Codable, MVVM/state isolation.

## Non-negotiable
- Inspect existing code before editing. Never blindly recreate the application.
- Confirm current endpoints, HTTP methods, team scopes, payloads and pagination using **official Vercel API docs**: https://vercel.com/docs/rest-api.
- Never place personal access tokens in git, code, logs, UserDefaults, tests, screenshots or Linear. Store credentials only in iOS Keychain.
- Never run an actual production redeploy, deletion, rollback or other impactful Vercel operation without explicit human approval; first test against an isolated test project. Non-idempotent POSTs must not auto-retry.
- Do not claim something works until verified by actual build, tests, or live testing.
- Keep changes small, add tests, and maintain German UX copy and basic accessibility.
- Use a branch per Linear issue; note issue ID in commits/PRs; keep docs/current status up to date.
- For any required local iPhone signing or credential input, give the user safe UI steps instead of requesting secrets in chat.

## Build
```bash
xcodebuild -project VercelManager.xcodeproj -scheme VercelManager -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

## Deadline
**2026-11-27** = a private, tested, installable iPhone v1.0.0, not a guaranteed App Store release.

When beginning work, read the README and relevant Linear issue, inspect the repository, choose the next unblocked P0 Linear issue, plan briefly, implement, run verification, and report the test evidence plus remaining blocker(s).
