---
title: Jaapam — Architecture Overview
description: Single-tenant architecture for a web-first Jain temple jaap tracking PWA. One Firebase project per temple, up to five deployments planned.
author: Jaapam team
ms.date: 2026-05-31
ms.topic: concept
---

## Purpose

This document describes the runtime architecture and technology stack for Jaapam. It is the reference for all subsequent design and implementation work. Read it before the data model, security rules, and setup documents.

## Product summary

Jaapam is a single-tenant devotional web app. **One deployment serves one Jain temple.** Devotees record personal and temple-linked jaap counts; temple admins run campaigns and announcements. Up to five temple deployments are planned. Each deployment is a separate Firebase project with its own free `*.web.app` URL.

Worked-example temples used throughout these docs:

| Temple    | `templeKey` | Dev URL                               | Prod URL                          |
|-----------|-------------|---------------------------------------|-----------------------------------|
| Gyanodaya | `gyanodaya` | `jaapam-gyanodaya-dev.web.app`        | `jaapam-gyanodaya.web.app`        |
| Vidyodaya | `vidyodaya` | `jaapam-vidyodaya-dev.web.app`        | `jaapam-vidyodaya.web.app`        |

## Tenancy model — and why single-tenant

Rather than packing many temples into one shared database with logical isolation, each temple gets its own Firebase project. Reasons:

* **Strong isolation by default.** One temple's bug, quota spike, or breach cannot affect another. No shared rules to over-think.
* **Simpler security rules.** No `temples/{templeId}/...` prefix on every collection. No tenant lookup on every rule check. Fewer billable rule reads.
* **Simpler data model.** Top-level collections (`members`, `campaigns`, `entries`) instead of nested subcollections four levels deep.
* **Free-tier friendly per temple.** Each Firebase project has its own Spark quotas, so five temples means five independent free tiers.
* **Easy decommissioning.** Closing a temple = deleting one Firebase project.

**Tradeoff (documented):** A devotee who attends two temples needs to sign in to each subdomain separately. Their jaap totals do not aggregate across temples. This is acceptable for v1; devotees usually engage with one home temple.

## High-level architecture

```text
+---------------------+        +---------------------+        +-----------------------+
|   Flutter web PWA   | <----> |  Firebase services  | <----> |  Cloud Functions      |
|   (browser, hosted  |  HTTPS |  - Auth (Google,    |  RPC   |  - onEntryWrite       |
|    on Firebase      |        |    Apple)           |        |  - onAnnouncementCreate|
|    Hosting)         |        |  - Firestore        |        |  - redeemInvite       |
+---------------------+        |  - Hosting          |        |  - setMemberRole      |
                               |  - FCM (web push)   |        |  - deleteAccount      |
                               +---------------------+        +-----------------------+
                                          ^
                                          |
                                          v
                                 +--------------------+
                                 |  Firestore data    |
                                 |  (single tenant,   |
                                 |   no temple prefix)|
                                 +--------------------+
```

* One Flutter web codebase, hosted as a PWA on Firebase Hosting.
* Firestore is the system of record. Top-level collections; no tenant key.
* Cloud Functions handle privileged work (claim assignment, aggregation, invite redemption, account deletion).
* Firebase Cloud Messaging (web push) delivers announcements and milestone notifications when the PWA is installed or the browser tab is open.

## Technology stack

| Layer            | Choice                                           | Rationale                                                                       |
|------------------|--------------------------------------------------|---------------------------------------------------------------------------------|
| Client framework | Flutter web (Dart, stable channel)               | One codebase; can extend to native Android/iOS later without rewrite            |
| State management | Riverpod 2.x                                     | Compile-safe DI, testable                                                       |
| Routing          | `go_router`                                      | Declarative, deep-link friendly, clean web URLs                                 |
| Auth             | `firebase_auth` + `google_sign_in_web`           | Google Sign-In only; free, unlimited MAU. No Apple or Phone OTP at launch.      |
| Database         | Cloud Firestore (`cloud_firestore`)              | Per-document security rules, offline cache via IndexedDB                        |
| Notifications    | `firebase_messaging` (web)                       | Free; works in Chrome, Edge, Firefox, and installed PWAs on iOS 16.4+           |
| Functions        | Cloud Functions for Firebase, Node 20, TypeScript| TypeScript catches bugs at compile time; needed for atomic transactions and custom claims |
| Hosting          | Firebase Hosting                                 | Matches Firebase backend; free 10 GB egress / month / project                   |
| i18n             | `flutter_localizations` + `intl` ARB files       | Standard Flutter localization                                                   |
| Local storage    | `shared_preferences` + IndexedDB (Firestore cache)| Persist UI prefs; Firestore cache handles offline reads                         |
| CI               | GitHub Actions                                   | Web build only; ~3 minutes per run                                              |

## Billing plan — Blaze required (with cap)

Cloud Functions deployment requires the Firebase **Blaze (pay-as-you-go) plan**. This is true even when usage stays inside the generous free tier. There is no way to deploy Functions on Spark.

**Mitigation:** Set a **$1/day budget alert** on each Firebase project. Expected monthly cost for one temple with ~200 active members: **$0**.

* Functions free tier: 2,000,000 invocations + 400,000 GB-seconds + 200,000 CPU-seconds per month. Per temple, expect well under 50,000 invocations per month.
* Firestore free tier: 50,000 reads + 20,000 writes + 20,000 deletes per day, 1 GiB storage. Per temple, well within reach if aggregation discipline holds.

See [`06-cost-model.md`](./06-cost-model.md) for the full projection.

## Authentication and roles

One sign-in provider at launch:

* **Google Sign-In** (web OAuth flow, `google_sign_in_web` package).

Federates into Firebase Auth and produces one `uid` per user per project.

**Why Google-only (and not Phone OTP):**

* Google Sign-In is free with unlimited MAU. Phone OTP costs ~$0.01 per SMS in India, ~$0.06 in the US, and would push monthly cost well above the free tier for a typical temple campaign.
* Apple Sign-In is not required because we ship as a web app, not in the App Store.

**Phone numbers for future campaigns:**

Devotees are asked for an **optional phone number** as a profile field at first sign-in (stored in `users/{uid}.phoneNumber`). This gives the temple a contactable database for WhatsApp or call-tree campaigns later — without paying for SMS-based auth. Field is editable in profile settings and clearly marked optional.

Roles, in increasing privilege:

| Role          | Where it lives                                              | Granted by                                          |
|---------------|-------------------------------------------------------------|-----------------------------------------------------|
| `member`      | `members/{uid}.role`                                        | Set automatically on join                           |
| `coordinator` | `members/{uid}.role`                                        | Promoted by an `admin` via `setMemberRole` Function |
| `admin`       | `members/{uid}.role` **and** custom claim `role: "admin"`   | First admin bootstrapped by `scripts/seed-admin.ts`; subsequent admins promoted via `setMemberRole` |

Rules consult the membership doc for `member` and `coordinator` checks. They consult the custom claim for `admin` checks (avoids extra Firestore reads in rules).

There is **no super-admin** role. Project ownership (Firebase IAM) gives the developer/operator emergency control without needing an app-level role.

## Aggregation strategy (cost control)

Dashboards never recompute over raw entries. Every `entries/{entryId}` write triggers `onEntryWrite`, which atomically updates aggregates:

* `users/{uid}.monthlyCounts.{YYYY-MM}` and `users/{uid}.currentStreakDays` (streak spans months, lives on user root)
* `campaigns/{campaignId}.currentCount` and `campaigns/{campaignId}.participantCount`
* `campaigns/{campaignId}/daily_totals/{YYYY-MM-DD}.count`

**Idempotency:** Cloud Functions are at-least-once. `onEntryWrite` writes a marker doc at `_processed_events/{eventId}` (TTL 7 days) inside the same transaction. If the marker exists, the function exits. Prevents double-counting on retry.

**Tap counter batching:** A tap counter accumulates in client memory and writes **one** `JaapEntry` per session commit (or per completed mala of 108). Each tap is NOT a Firestore write.

## Offline behavior

* Firestore offline persistence is enabled via IndexedDB. Devotees can log jaap entries without connectivity; entries sync when online.
* Aggregate counters update only after the entry reaches the server. The UI shows an optimistic local count and a "syncing" indicator until confirmed.

## Internationalization

* Supported at launch: `en`, `hi`.
* All user-facing strings live in `app/lib/l10n/app_en.arb` and `app_hi.arb`.
* Religious terminology (Jaap, Namokar Mantra, Paryushan, etc.) is reviewed by a native Hindi speaker from the pilot temple before launch. Glossary kept at `docs/glossary.md`.
* Date and number formatting use `intl` with the active locale.

## Notifications — web reality check

FCM web push works through a service worker (`web/firebase-messaging-sw.js`) and requires a VAPID key.

| Surface                              | Works? | Notes                                                                             |
|--------------------------------------|--------|-----------------------------------------------------------------------------------|
| Chrome / Edge / Firefox desktop      | Yes    | Permission prompt on first opt-in                                                 |
| Chrome / Firefox Android             | Yes    | Permission prompt on first opt-in                                                 |
| Safari macOS 16+                     | Yes    | Requires PWA installation (Safari → File → Add to Dock)                           |
| iOS Safari 16.4+                     | Yes    | **Only when PWA is installed to home screen** (Add to Home Screen)                |
| iOS Safari < 16.4                    | No     | Documented limitation; users get in-app announcements but no push                 |

In-app announcement screen is the universal fallback regardless of push support.

## Branding — editable without redeploy

All temple-specific branding lives in Firestore at `config/temple`:

* `templeName`, `templeAddress`, `templeAbout`
* `primaryColor`, `accentColor` (hex)
* `logoUrl` (uploaded by admin to Firebase Storage, or any HTTPS URL)
* `homeTimezone` (default `Asia/Kolkata`) — used for streak and daily-total calculations
* `joinPolicy` — `open` (anyone can self-join) or `invite_only` (must redeem an invite code)

The app reads `config/temple` once on launch and applies theme. Admin edits via the settings screen take effect on next app load.

## Environments per temple

Each temple deployment has its own dev and prod Firebase project:

| Environment | Firebase project ID (Temple 1: Gyanodaya)    | Hosting URL                       |
|-------------|----------------------------------------------|-----------------------------------|
| dev         | `jaapam-gyanodaya-dev`                       | `jaapam-gyanodaya-dev.web.app`    |
| prod        | `jaapam-gyanodaya`                           | `jaapam-gyanodaya.web.app`        |

Temple 2 (Vidyodaya) follows the same pattern: `jaapam-vidyodaya-dev` and `jaapam-vidyodaya`. The prod project ID intentionally omits the `-prod` suffix to keep the URL shorter (`jaapam-gyanodaya.web.app` reads more cleanly on QR codes than `jaapam-gyanodaya-prod.web.app`).

**No custom domain at launch.** We use the free `*.web.app` URLs that Firebase auto-provisions per project. This means zero annual domain cost and zero DNS work. Trade-off: URLs look slightly technical. A custom domain (e.g., `gyanodaya.jaapam.app`) can be connected to the same project later without any data migration or downtime — picked up as a post-v1 enhancement when a temple is ready to fund it (~₹700–₹1,400/year for the registrar; Firebase SSL and hosting remain free).

For simplicity at this scale, **staging is dropped**. Dev doubles as integration; prod is the live temple instance. Reintroduce staging if a temple's user base grows beyond a few hundred active members.

Flutter selects the environment via `--dart-define=ENV=dev|prod` and `--dart-define=TEMPLE=gyanodaya`, which picks the matching `firebase_options_<temple>_<env>.dart` file.

## Out of scope for v1

* Multi-tenant (one app, many temples in one DB) — replaced by per-temple deployment. Migration target documented in "Scaling roadmap" below.
* Super-admin / platform-approval flow — not needed in single-tenant.
* Native Android and iOS apps — PWA only at launch.
* Phone OTP login — Google Sign-In only. Phone captured as optional profile field for future outreach.
* Apple Sign-In — not required for web; would only matter if we shipped to App Store.
* Donation or seva modules.
* WhatsApp reminder integration (collected phone numbers enable this manually later).
* Family or group rollups.
* CSV export and suspicious-spike report — deferred to post-v1.
* Multiple simultaneous active campaigns.

## Scaling roadmap (5 → 50+ temples)

This design works for 1–5 temples as is. Beyond that, the operational cost of per-temple Firebase projects grows. The migration path is **already structured into the data model** so the move is mostly mechanical when needed.

| Temple count | Recommended architecture | What changes                                                                  |
|--------------|--------------------------|-------------------------------------------------------------------------------|
| 1–5          | Per-temple Firebase project (current design) | Nothing. Manual `flutterfire configure` per deployment.        |
| 5–15         | Per-temple project + provisioner script | Add `scripts/provision-temple.ts` that uses the Firebase Management API to create projects, enable services, and deploy rules/functions/hosting in one command. ~3 days of engineering. |
| 15–50        | **Shared project, multi-tenant via path prefix** | Migrate to `temples/{templeId}/...` collection paths. Reuse same Flutter codebase with `--dart-define=TEMPLE=...`. Subdomain still per temple via Firebase Hosting multi-site. Optional: Firebase Auth multi-tenancy so cross-temple users get one Google identity but separate per-tenant uids. ~2 weeks of engineering plus one-weekend migration per temple. |
| 50+          | Shared project + sharded counters + BigQuery export for analytics | Hot-write counters (campaign totals) get sharded to avoid Firestore's 1-write/sec/document soft limit. Analytics moves off Firestore. |

**Forward-compat decisions baked into v1:**

* Every top-level document carries a `templeId` field (always the same value today, but populated). When we shard into one shared project, paths can be rewritten without re-deriving the value.
* Cloud Functions take `templeId` as a parameter or derive it from the document path. No hardcoded collection names.
* The Flutter app reads its Firebase config from a build-time `--dart-define=TEMPLE=...`, so the same codebase already supports many target temples.

**Cost at 50 temples × 2,000 members each (Option B, shared project):**

Projected ~$50–$150/month all-in. Storage stays cheap (~$10/month at year 3). The main driver is Firestore reads (no per-temple free tier when shared). Still well within typical temple-trust budgets.

## Open architectural questions

* **First admin bootstrap.** Each new temple deployment needs its first admin set by hand using a Node script with a service-account key. Script lives at `scripts/seed-admin.ts`. Operator (you) runs it once per deployment.
* **Cross-temple sign-in.** A devotee active in two temples will have two `uid`s. No plan to unify in v1; revisit if multiple temples request it.
* **Logo storage.** v1 expects admin to paste a logo URL. If admins need an in-app uploader, that requires Firebase Storage to be enabled and storage rules to be written. Deferred unless a pilot temple asks for it.
