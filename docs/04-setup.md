---
title: Jaapam — Setup Guide
description: Toolchain, per-temple Firebase project creation, local emulator workflow, and the provisioning script that automates new-temple onboarding.
author: Jaapam team
ms.date: 2026-05-31
ms.topic: how-to
---

## Purpose

This guide gets a developer from a clean Windows machine to a running local Jaapam dev environment, and explains how to stand up a new temple's Firebase project (both the manual path and the automated `provision-temple` script).

## 1. Local toolchain

Install once on the developer machine.

| Tool                | Version              | Install command (PowerShell)                                     | Why                                            |
|---------------------|----------------------|------------------------------------------------------------------|------------------------------------------------|
| Git                 | 2.40+                | `winget install Git.Git`                                         | Source control                                 |
| Flutter SDK         | stable, 3.24+        | Download from <https://docs.flutter.dev/get-started/install/windows> and extract; add `flutter\bin` to PATH | Web build today, native build later            |
| Node.js             | 20 LTS               | `winget install OpenJS.NodeJS.LTS`                               | Cloud Functions runtime; build scripts         |
| Firebase CLI        | 13+                  | `npm install -g firebase-tools`                                  | Deploy, emulators, project management          |
| FlutterFire CLI     | latest               | `dart pub global activate flutterfire_cli`                       | Generates `firebase_options.dart` per project  |
| Google Chrome       | latest               | Already installed                                                | Flutter web debug target                       |
| VS Code             | latest               | `winget install Microsoft.VisualStudioCode`                      | Editor + Flutter + Dart extensions             |

> **Not needed for v1:** Android Studio, Xcode, Android SDK, JDK. These come in only when we add Phase 7 (native apps).

Verify:

```powershell
flutter doctor -v
flutter config --enable-web
firebase --version
node --version
flutterfire --version
```

`flutter doctor` should report green for the Flutter SDK and Chrome. Android/iOS toolchain warnings are expected and ignored at this stage.

## 2. Clone and bootstrap the repo

```powershell
git clone https://github.com/<org>/jaapam.git
cd jaapam
flutter pub get
cd functions
npm install
cd ..
```

The repo layout (created during Phase 0 of the roadmap):

```text
jaapam/
  lib/                          # Flutter app
    firebase_options_<temple>_<env>.dart   # generated per deployment, gitignored except for templates
  functions/                    # Cloud Functions (TypeScript)
  scripts/
    provision-temple.ts         # automated new-temple onboarding (added in Phase 1)
    seed-temple.ts              # writes config/temple doc
    seed-admin.ts               # bootstraps first admin
  firestore.rules
  firestore.indexes.json
  storage.rules
  firebase.json                 # references per-project hosting targets
  .firebaserc                   # maps short alias -> project ID
  docs/
```

## 3. Per-temple Firebase projects

Each temple needs **two** Firebase projects: dev and prod. There are two paths — the **manual** path (used for the first 1–2 temples before the provisioner script exists, and as the fallback when something needs a custom touch), and the **automated** path (used from temple #3 onwards, takes ~5 minutes).

### 3a. Manual path (first temple)

For each environment (`dev`, then `prod`), do the following in the Firebase console (<https://console.firebase.google.com>):

1. **Create project** named `jaapam-<templeKey>-<env>` for dev, and `jaapam-<templeKey>` (no `-prod` suffix) for prod. Example: `jaapam-gyanodaya-dev` and `jaapam-gyanodaya`. The shorter prod project ID keeps the URL clean on QR codes (`jaapam-gyanodaya.web.app`).
2. **Skip Google Analytics** (not needed; reduces noise and cost).
3. **Upgrade to Blaze plan** (required for Cloud Functions). Credit card needed — billing target is ~$0/month for a 2,000-member temple.
4. **Set a $5/month budget alert**: Google Cloud Console → Billing → Budgets & alerts → Create budget → scope to this single project → amount `$5` → alert at 50%, 90%, 100% → email to operator.
5. **Enable services:**
   * Authentication → Sign-in method → **Google** → Enable. Set project support email.
   * Firestore Database → Create database → **Production mode** → region `asia-south1` (Mumbai) for India temples.
   * Storage → Get started → Production mode → same region.
   * Hosting → Get started (the CLI handles the rest).
   * Functions → enabled automatically by Blaze; nothing to click.
6. **Configure Google OAuth** for web:
   * The Firebase console auto-creates an OAuth client when you enable Google sign-in.
   * In **Google Cloud Console → APIs & Services → Credentials**, open the "Web client (auto-created by Google service)" client.
   * **Authorized JavaScript origins:** add `https://jaapam-<templeKey>[-dev].web.app` (e.g., `https://jaapam-gyanodaya.web.app` for prod, `https://jaapam-gyanodaya-dev.web.app` for dev) and `http://localhost:5000` (for emulator).
   * **Authorized redirect URIs:** `https://jaapam-<templeKey>[-dev].web.app/__/auth/handler` is added automatically; no manual change needed.
7. **Enable TTL on `_processed_events`:**
   ```powershell
   gcloud firestore fields ttls update expireAt --collection-group=_processed_events --enable-ttl --project=jaapam-gyanodaya-dev
   ```
   (One-time per project. Requires `gcloud` CLI; install via `winget install Google.CloudSDK` if missing.)

Then, locally:

```powershell
# Add a Firebase project alias for easy CLI use
firebase use --add
# Pick the project, give it alias "gyanodaya-dev" (or "gyanodaya" for prod)

# Generate Flutter Firebase config
flutterfire configure `
  --project=jaapam-gyanodaya-dev `
  --platforms=web `
  --out=lib/firebase_options_gyanodaya_dev.dart

# Seed temple config doc
npx ts-node scripts/seed-temple.ts --temple=gyanodaya --env=dev `
  --name="Shri Gyanodaya Jain Mandir" --tz="Asia/Kolkata" --joinPolicy=invite_only `
  --supportEmail="admin@gyanodaya.example"

# Seed the first admin user (uid comes from their first Google sign-in)
# Run this AFTER the admin has signed in once via the dev app
npx ts-node scripts/seed-admin.ts --temple=gyanodaya --env=dev --uid=<google-uid>

# Deploy rules, indexes, functions, hosting
firebase deploy --only firestore:rules,firestore:indexes,functions,hosting --project=gyanodaya-dev
```

### 3b. Automated path (`scripts/provision-temple.ts`)

Built during Phase 1 of the roadmap. One command replaces ~30 manual clicks:

```powershell
npx ts-node scripts/provision-temple.ts `
  --templeKey=vidyodaya `
  --templeName="Shri Vidyodaya Jain Mandir" `
  --env=prod `
  --region=asia-south1 `
  --timezone=Asia/Kolkata `
  --joinPolicy=invite_only `
  --supportEmail="admin@vidyodaya.example" `
  --supportWhatsapp="+919876543210" `
  --budgetUsd=5 `
  --bootstrapAdminEmail="admin@vidyodaya.example"
```

What it does, in order:

1. Calls the **Firebase Management API** to create project `jaapam-vidyodaya` (or `jaapam-vidyodaya-dev` when `--env=dev`).
2. Adds the project to your billing account (required for Blaze).
3. Sets the $5/month budget alert via the Cloud Billing Budgets API.
4. Enables Auth (Google provider), Firestore (production mode, `asia-south1`), Storage, Hosting, Functions.
5. Adds `https://jaapam-vidyodaya.web.app` (or `-dev`) to the OAuth client's authorized origins.
6. Enables TTL on `_processed_events`.
7. Runs `flutterfire configure` to produce `lib/firebase_options_vidyodaya_prod.dart` (or `_dev`).
8. Runs `firebase deploy` for rules, indexes, functions, and the web build.
9. Writes the `config/temple` document with the supplied branding fields.
10. Sends an invite email to `bootstrapAdminEmail`. After they sign in once, runs `seed-admin.ts` automatically against their uid (polls for ~5 minutes).
11. Prints the live URL and a "next steps" summary.

Expected runtime: ~5 minutes per environment (project creation + first deploy dominate).

> **Operator prerequisite:** the operator running this script needs `Owner` on the Google Cloud billing account and a service-account JSON key with `Firebase Admin` and `Project Creator` roles. Stored in a local `.secrets/` folder (gitignored). Documented in the script's README.

## 4. Local emulator workflow

```powershell
# In one terminal: start the emulator suite (auth, firestore, functions, hosting)
firebase emulators:start --project=demo-jaapam

# In another terminal: run the Flutter web app pointed at the emulator
flutter run -d chrome `
  --dart-define=TEMPLE=gyanodaya `
  --dart-define=ENV=dev `
  --dart-define=USE_EMULATOR=true
```

The Flutter bootstrap code checks `USE_EMULATOR` and routes Firebase calls to `localhost` ports (Auth `9099`, Firestore `8080`, Functions `5001`, Hosting `5000`).

The Auth emulator includes a UI at <http://localhost:4000/auth> to create test Google-flavored accounts without a real Google OAuth flow.

Seed the emulator with test data:

```powershell
firebase emulators:start --import=./test/fixtures --export-on-exit=./test/fixtures --project=demo-jaapam
```

## 5. Deploying changes

Day-to-day deploys after a temple is provisioned:

```powershell
# Deploy only what changed (prod alias "gyanodaya" maps to project jaapam-gyanodaya)
firebase deploy --only hosting --project=gyanodaya
firebase deploy --only functions --project=gyanodaya
firebase deploy --only firestore:rules --project=gyanodaya
```

CI (GitHub Actions, Phase 0 setup) runs `firebase deploy` automatically on push to `main`, gated by branch protection and a manual approval step for prod.

## 6. Onboarding a new temple — the 5-minute version

Once the provisioner exists and the operator's `.secrets/` is set up, adding Vidyodaya (Temple 2) becomes:

```powershell
git pull
npx ts-node scripts/provision-temple.ts `
  --templeKey=vidyodaya --templeName="Shri Vidyodaya Jain Mandir" --env=prod `
  --supportEmail="admin@vidyodaya.example" --bootstrapAdminEmail="admin@vidyodaya.example"
```

Hand the resulting URL (`https://jaapam-vidyodaya.web.app`) and the admin's first-sign-in instructions to the temple. Done.

## 7. Common gotchas

| Symptom                                                | Cause                                              | Fix                                                                |
|--------------------------------------------------------|----------------------------------------------------|--------------------------------------------------------------------|
| `flutter doctor` reports "Unable to find git in PATH"  | Git installed but PATH not refreshed               | Close and reopen PowerShell                                        |
| `flutterfire configure` asks for Android package name  | Picked Android platform by accident                | Re-run with `--platforms=web` only                                 |
| Cloud Function deploy fails with "billing not enabled" | Project still on Spark                             | Upgrade to Blaze before first deploy                               |
| Google sign-in popup blocked on emulator               | Browser pop-up blocker on `localhost`              | Allow pop-ups for `localhost:5000` once                            |
| "Permission denied" on Firestore write from client     | Rule mismatch; usually `members/{uid}` missing     | Member must self-join (or redeem invite) first; check `joinPolicy` |
| `_processed_events` docs not deleting                  | TTL policy not enabled on the project              | Run the `gcloud firestore fields ttls update` command from step 7  |
| Function trigger fires twice for one entry             | Expected — at-least-once delivery                  | Confirm `_processed_events/{eventId}` idempotency marker is set    |
