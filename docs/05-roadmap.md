---
title: Jaapam — Delivery Roadmap
description: Phased delivery plan from foundation through launch, plus post-v1 enhancements including native Android/iOS apps and scaling to 15+ temples.
author: Jaapam team
ms.date: 2026-05-31
ms.topic: reference
---

## Purpose

This roadmap sequences the work for Jaapam v1 (single-tenant web PWA, two temples: Gyanodaya and Vidyodaya) and lists the post-v1 enhancements in priority order. Phases are not time-estimated — they are scope-estimated. Each phase produces a working slice that can be demoed.

## Guiding principles

* **Ship the smallest useful thing first.** A working personal jaap log on a phone is more valuable than a half-built campaign system.
* **Each phase is releasable.** No phase ends with broken or hidden functionality.
* **Existing user data is never broken.** Every schema or auth change is forward-compatible (the `templeId` field, the function-maintained aggregates, and the optional `phoneNumber` field are all designed with this in mind).
* **No premature scope.** Multi-tenant, native apps, custom domains, super-admin, and analytics all sit in post-v1 by design.

## Phase 0 — Foundation

Goal: an empty Flutter web app deploys to a real Firebase project automatically on every push to `main`.

* Initialize Flutter project (`flutter create jaapam --platforms=web`).
* Riverpod, `go_router`, `flutter_localizations`, `intl` wired in.
* Repo structure scaffolded per `04-setup.md` section 2.
* Cloud Functions (TypeScript, Node 20) project scaffolded with one hello-world callable.
* `firestore.rules` with default deny.
* `firestore.indexes.json` with the indexes from `02-data-model.md`.
* `.firebaserc` aliasing `gyanodaya-dev` and (later) `gyanodaya` prod projects.
* GitHub Actions workflow: lint + test + `flutter build web` + `firebase deploy --only hosting,functions,firestore:rules` on push to `main`, gated by branch protection.
* `scripts/seed-temple.ts` and `scripts/seed-admin.ts` written and tested locally against the emulator.
* Gyanodaya **dev** project created manually per `04-setup.md` section 3a; first deploy succeeds.

Exit criteria: opening `https://jaapam-gyanodaya-dev.web.app` shows a placeholder app bar with the temple name.

## Phase 1 — Auth, tenancy, and provisioning

Goal: a real person can sign in with Google, see their profile, and the operator can spin up a new temple in 5 minutes.

* Firebase Auth wired with Google Sign-In (web flow via `google_sign_in`).
* First sign-in creates `users/{uid}` doc with `templeId` populated from build-time `--dart-define=TEMPLE=...`.
* Onboarding screen captures **optional phone number** (E.164 validation, clearly marked optional).
* Self-join when `joinPolicy: open`; invite-code redemption when `invite_only` (via `redeemInvite` callable).
* First admin bootstrapped via `seed-admin.ts` script (sets `members/{uid}.role = "admin"` and the custom claim).
* `onMemberWrite` trigger keeps custom claim in sync with `members/{uid}.role` changes.
* `setMemberRole` callable for admin-driven role changes; writes audit log.
* i18n scaffolded with `en.arb` and `hi.arb`; language picker in profile.
* **`scripts/provision-temple.ts`** built and tested end-to-end. Creates project, enables services, configures OAuth, deploys app, seeds config, in one command.

Exit criteria: operator runs the provisioner script for Gyanodaya **prod** and a real admin signs in to `https://jaapam-gyanodaya.web.app`.

## Phase 2 — Personal jaap tracking

Goal: a member can log jaap counts and see their personal progress.

* Personal goal screen (set monthly target in `users/{uid}/personal_goals/{YYYY-MM}`).
* Manual entry form (count + optional date back-fill within 24h).
* Tap counter screen: client-side batches taps; commits one `users/{uid}/entries/{entryId}` per mala (108) or session — never one write per tap.
* `onEntryWrite` trigger maintains `users/{uid}.monthlyCounts`, `currentStreakDays`, `longestStreakDays`, `lastEntryDate`. Idempotent via `_processed_events/{eventId}`.
* Personal dashboard: this-month total, percent of target, current streak, last 7 days sparkline, recent entries list.
* Edit/delete own entry within 24h of creation; older edits require admin (writes audit log).

Exit criteria: a member can log a day's jaap from their phone in <10 seconds and see the dashboard update.

## Phase 3 — Temple campaigns

Goal: an admin can run a community campaign and members can contribute.

* Admin: create / edit / cancel campaign (`campaigns/{campaignId}`). One active campaign at a time enforced in the UI.
* Member: when logging an entry, optional dropdown to attribute to active campaign (`entries/{entryId}.campaignId`).
* `onEntryWrite` cascades campaign-attributed entries: increments `campaigns/{campaignId}.currentCount` and `campaigns/{campaignId}/daily_totals/{YYYY-MM-DD}.total` in the same transaction.
* Temple home screen: live campaign progress bar (target, current, percent, days remaining, daily pace required).
* Per-day breakdown chart pulled from `daily_totals` subcollection.

Exit criteria: temple runs a 30-day Paryushan campaign with 100 members; counts add up correctly.

## Phase 4 — Invites, announcements, and push

Goal: admins communicate; members get notified.

* Invite management UI: admin creates invite codes (`invites/{inviteCode}`) with `maxUses` and `expiresAt`. QR code rendered for printing/sharing.
* `redeemInvite` callable validates code in transaction, creates `members/{uid}` doc, increments `usedCount`.
* Announcements: coordinator/admin creates `announcements/{announcementId}`; `onAnnouncementCreate` trigger fans out FCM push to topic `temple_main`.
* FCM web push wired in Flutter (`firebase_messaging`); service worker registered; tokens stored in `users/{uid}.fcmTokens`.
* Milestone announcements: `onEntryWrite` cascade emits a `kind: "milestone"` announcement when campaign crosses 25/50/75/100% (idempotent via `lastMilestone`).
* In-app announcements feed (subscribes to `announcements` ordered by `createdAt desc`).

Exit criteria: admin posts an announcement; subscribed members on iOS 16.4+ and Android Chrome receive a push within 30 seconds.

## Phase 5 — Admin tooling

Goal: admins can run the temple without developer help.

* Member roster screen: search, filter by role/status, change role, suspend/reinstate.
* Audit log viewer (admin-only): `audit_logs/*` paginated with filters.
* Temple settings screen: branding (logo, colors, about), `joinPolicy`, `supportEmail`, `supportWhatsapp`, `homeTimezone`, `maxEntryCount`.
* Support page (member-facing): renders `supportEmail` as mailto with pre-filled subject, `supportWhatsapp` as `https://wa.me/<phone>` link, "Report a problem" form that emails the admin with diagnostics (uid, browser, last route).
* Self account deletion (`deleteAccount` callable): purges `users/{uid}` + entries, anonymizes `members/{uid}`, retains audit logs.

Exit criteria: admin onboards 50 members, runs one full campaign, and resolves one support request without contacting the developer.

## Phase 6 — Hardening and launch

Goal: ready for real devotees.

* **App Check** (reCAPTCHA v3 for web) enforced in production.
* Accessibility pass: contrast checks, keyboard navigation, screen-reader labels on tap counter and dashboard.
* DPDP-aligned privacy page: data collected, retention, deletion right, contact for grievances.
* Consent capture at first sign-in (`users/{uid}.consent`).
* PWA install promo (Android Chrome + iOS Safari "Add to Home Screen" instructions).
* Performance budget: first-contentful-paint <2.5s on a mid-range Android over 4G; Lighthouse PWA score ≥90.
* Error monitoring: Cloud Logging + a weekly digest email to the operator.
* Backup plan: daily Firestore export to a separate GCS bucket per project (configured in `firebase.json`).
* Launch checklist: budget alerts confirmed firing, App Check rejection rate <2%, all functions deployed and triggers verified end-to-end.

Exit criteria: Gyanodaya goes live with their full member base.

---

## Post-v1 backlog

Sequenced by expected value. Pick from the top when v1 is stable.

### Post-v1.1 — Vidyodaya rollout

Trigger: Gyanodaya runs stable for 4 weeks; second temple expresses interest.

* Run `provision-temple.ts` for `jaapam-vidyodaya-dev` and `jaapam-vidyodaya`.
* Reuse same Flutter codebase, no code changes expected.
* Validate the operator runbook from `04-setup.md` section 6 in real conditions; patch gaps.

### Post-v1.2 — CSV export and suspicious-spike report

Trigger: any admin asks for end-of-campaign reporting.

* Callable function `exportCampaignCsv` streams a CSV of per-member contributions for a campaign.
* Daily scheduled function flags entries that exceed 3× the member's 30-day rolling average; surfaces in audit log with `kind: "suspicious_spike"`.

### Post-v1.3 — Multiple simultaneous campaigns

Trigger: a temple wants to run Paryushan and a daily-japam drive at the same time.

* Remove the "one active campaign" UI constraint.
* Member's entry-attribution dropdown becomes multi-select (one entry can split across campaigns by count — needs design).
* Dashboard becomes a campaign picker.

### Post-v1.4 — Custom domain per temple

Trigger: a temple wants `gyanodaya.org` instead of `jaapam-gyanodaya.web.app`.

* Temple registers domain themselves (~₹700–₹1,400/year).
* Add custom domain to Firebase Hosting → DNS verification → SSL provisioned automatically.
* Update OAuth authorized origins to include the new domain. Old `.web.app` URL continues to work; no data migration.

### Phase 7 — Native Android and iOS apps

Trigger: temples report meaningful drop-off because PWA install is unfamiliar to devotees, OR push delivery on iOS Safari proves unreliable.

* **Same Flutter codebase**, add `android/` and `ios/` platform folders via `flutter create . --platforms=android,ios`.
* Existing users keep all data: the native app connects to the same Firebase project, uses the same Google Sign-In, sees the same `users/{uid}` and entries. Nothing migrates.
* Android-specific:
  * Google Sign-In already works via the same `google_sign_in` plugin.
  * Build APK + AAB; submit to Google Play (~$25 one-time developer fee).
  * Configure SHA-1 / SHA-256 fingerprints in Firebase Auth.
* iOS-specific:
  * **Add Apple Sign-In** as a second provider (App Store requires it alongside Google for new apps).
  * Existing Google-only users keep their existing `uid` — adding a provider doesn't change identity. Users who later sign in with Apple get a *new* `uid` unless we add account linking (a small Phase 7 sub-task).
  * Build IPA; submit to App Store (~$99/year Apple Developer fee).
  * APNs key configured for FCM.
* FCM tokens for native devices automatically append to `users/{uid}.fcmTokens` array; existing web tokens continue to work.

Estimated scope: ~1–2 weeks of focused work for Android, ~1–2 weeks for iOS (Apple review cycles add wall-clock time).

### Post-v1.5 — Family / group rollups

Trigger: temples want to attribute jaap to a household or guru-shishya group.

* New collection `groups/{groupId}` with members; entries can be attributed to a group.
* Group dashboard; group leaderboards.

### Post-v1.6 — Donation / seva modules

Trigger: temple asks for digital seva ledger. Out of scope until then; potentially needs payment-gateway compliance work.

### Post-v1.7 — Cross-temple analytics for trustees

Trigger: temple trust wants an overview of multiple Jaapam instances.

* If still on per-project topology: nightly cross-project BigQuery export + a separate dashboard.
* If migrated to shared multi-tenant project: built-in.

### Scaling-driven work (see `01-architecture.md` scaling roadmap)

* **At 5–15 temples:** harden the provisioner; add a delete-temple script; document recovery from a corrupted project.
* **At 15–50 temples:** migrate to shared multi-tenant project (`temples/{templeId}/...` paths). The `templeId` field on every doc and the build-time `TEMPLE` define already prepare the code for this — the migration is a Cloud Function script that rewrites paths per project into the shared one. Plan a one-weekend migration per temple, with a maintenance banner.
* **At 50+ temples:** sharded counters for high-write campaigns; BigQuery export for analytics.

## What we are explicitly NOT doing in v1

Reaffirmed so scope doesn't creep:

* No super-admin / cross-temple portal.
* No native Android or iOS apps.
* No Apple Sign-In or Phone OTP.
* No custom domain purchase or DNS work.
* No CSV export or suspicious-spike report.
* No multiple simultaneous campaigns.
* No payment, donation, or seva modules.
* No automated WhatsApp/SMS sending (the optional phone number capture enables this manually by the temple later).
* No staging environment (dev doubles as integration).
