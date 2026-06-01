# Jaapam Release Checklist

Run this list before **every** production deploy. Tick boxes in the PR description, not in this file.

## 0. Pre-flight (local laptop)

- [ ] `git pull` on `main`, working tree clean
- [ ] `flutter pub get` succeeds
- [ ] `flutter gen-l10n` succeeds (always run after any ARB edit)
- [ ] `flutter analyze` reports **No issues found**
- [ ] `flutter test` reports **All tests passed**
- [ ] `flutter build web --release` produces `build/web/` (ignore the cosmetic wasm-dry-run warning on Windows PowerShell)

## 1. Smoke test in `chrome --incognito` against current build

Pre: one admin account (Firestore `users/{uid}.isAdmin = true`), one non-admin account, one second device (or second browser profile).

### Auth + onboarding
- [ ] `/welcome` renders hero + Get started + Privacy & Terms links
- [ ] Privacy + Terms pages load standalone, no chrome
- [ ] Sign in with Google → redirects to onboarding if profile incomplete
- [ ] Sign in with magic-link email → completes round-trip
- [ ] Onboarding form requires name + temple, saves to Firestore

### Personal jaap flow
- [ ] Home → add jaap (108) via confirm dialog → ring updates, today count increments
- [ ] Personal Target page → set monthly target → progress shows correct %
- [ ] Add manual entry sheet → adjust rounds, change mantra, pick yesterday → saved with correct date
- [ ] History list shows newest first; long-press a session deletes after confirm
- [ ] Streak count survives a same-day re-add

### Community campaign (as admin)
- [ ] Community tab shows **Start campaign** button
- [ ] Create campaign with title + goal → ring renders at 0 / goal
- [ ] Contribute from add sheet (toggle on) → ring and "My contribution" update
- [ ] Top contributors + Live activity populate after contribution
- [ ] End campaign confirm → ring disappears, empty state returns

### Community campaign (as devotee, non-admin)
- [ ] Community tab does **NOT** show Start campaign button when no campaign
- [ ] Empty-state copy reads "Your temple admin hasn't started a campaign yet"
- [ ] When admin starts one in other browser, devotee sees the new campaign on refresh
- [ ] Devotee can contribute via add sheet; cannot End campaign
- [ ] Devtools console: attempting to write `users/{uid}.isAdmin: true` returns `PERMISSION_DENIED`

### i18n
- [ ] Switch to Hindi from profile → every screen renders Hindi strings (no fallback English)
- [ ] Switch back to English; locale persists across reload

### Errors + resilience
- [ ] Offline (DevTools throttle = Offline) → add jaap shows error snack, recovers when back online
- [ ] Sign out → redirected to /welcome; protected routes redirect back to /welcome

## 2. Deploy

```powershell
$env:Path = "$env:Path;C:\src\flutter\bin;$env:LOCALAPPDATA\Pub\Cache\bin"
cd C:\Projects\WorkSpaceAJ\Jaapam
flutter gen-l10n
flutter analyze
flutter test
flutter build web --release --dart-define=APP_CHECK_KEY=<prod-recaptcha-v3-key>
firebase use <prod-or-dev-alias>
firebase deploy --only firestore:rules,hosting
```

## 3. Post-deploy verification

- [ ] Hard refresh https://<host>/ (Ctrl+Shift+R) — sees new build hash in console
- [ ] Firestore rules tab in Firebase Console shows the deployed revision matches `firestore.rules`
- [ ] App Check tab → Firestore + Hosting are **Enforced** (prod only)
- [ ] Analytics → Realtime shows your test session events: `login`, `jaap_added`, `target_set`, `campaign_started`, `campaign_contributed`
- [ ] No unexpected entries under Analytics → Events → `app_exception`

## 4. Rollback plan

If a deploy regresses prod:

```powershell
firebase hosting:rollback --project=<prod-project>
```

Then revert the offending commit on `main` and redeploy when fixed.

## 5. Backups (prod only — requires Blaze)

```powershell
gcloud firestore export gs://<prod-backup-bucket>/$(Get-Date -Format yyyy-MM-dd) `
  --project=<prod-project>
```

Schedule daily via Cloud Scheduler (one-time setup). Verify weekly that the newest export object is < 26h old.
