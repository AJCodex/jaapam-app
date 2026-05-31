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

## Status snapshot (2026-05-31)

| Phase | Status | Notes |
|---|---|---|
| Phase 0 — Foundation | ✅ Done | Flutter scaffold, Riverpod, go_router, i18n, Functions skeleton, CI green, deployed to `jaapam-gyanodaya-dev.web.app`. |
| Phase 1 — Auth + onboarding | ✅ Done | Firebase Auth (Google + email link), profile onboarding (name/gotra/temple), Firestore rules, route guards, live at `https://jaapam-gyanodaya-dev.web.app`. |
| Phase 2 — Design system + jaap counter | ▶ Next | See mockup mapping below. |
| Phase 3 — History | ⏳ Pending | |
| Phase 4 — Profile / Settings | ⏳ Pending | |
| Phase 5 — Personal Target | ⏳ Pending | |
| Phase 6 — Community Campaign | ⏳ Pending | Requires Blaze plan (Cloud Functions for aggregates). |
| Phase 7 — Onboarding hero + PWA polish | ⏳ Pending | Lotus hero, swipeable intro, install prompt, icon/splash. |
| Phase 8 — Hardening + launch | ⏳ Pending | App Check, a11y, DPDP privacy, perf budget, error monitoring. |

## Visual reference — Sadhana-inspired mockup

Phases 2–7 below map to the 8-screen mockup (rust/orange + cream, serif display, soft rounded cards). Mockup screens:

1. **Welcome / Onboarding** — lotus hero, "Count Your Blessings, Connect with Community", Get Started + Log In → Phase 7.
2. **Login** — Continue with Google / Email, T&C → already shipped in Phase 1 (will get visual polish in Phase 2 theme pass).
3. **Home Dashboard** — today's count (108 / 1000 goal) in a big progress ring, quick-add chips `+1 / +11 / +21 / +51`, **Add Custom Count** CTA, Last Session + Streak cards, bottom nav → Phase 2.
4. **Personal Target** — monthly progress bar, weekly devotion grid, completed milestones, "Expand Your Practice" promo → Phase 5.
5. **Community Campaign** — global goal ring (e.g. "Gyanodaya 1M Jaap"), live activity feed, avg sessions, top speed → Phase 6.
6. **Add Entry (manual)** — rounds wheel, date picker, focus chips (Navkar / Logassa / Bhaktamar / Uvasaggaharam / Custom), observation note → Phase 2 (bottom sheet inside Home).
7. **History** — This Week / This Month / Custom Range tabs, total chant count, daily avg + current streak, recent entries list → Phase 3.
8. **Profile / Settings** — avatar + edit, Total Malas + Daily Streak stats, Notifications / Theme / Language toggles, Privacy Policy, Sign Out → Phase 4.

### Design system tokens (locked in Phase 2)

* **Palette**: background `#FAF6EF` (cream), primary `#E68C3A` (warm orange), accent `#C2410C` (deep rust), text `#1F1B16` (charcoal), surface `#FFFFFF` cards with soft amber shadows.
* **Typography**: serif display (Playfair Display or Lora via `google_fonts`) for hero numbers + section titles; sans (Inter) for body and labels.
* **Shape**: 20px radius cards, 28px radius hero ring, 12px radius chips, generous 24px spacing.
* **Bottom nav**: 5 tabs — Home, Community, **Add (center accent)**, History, Profile.
* **Mantras (Jain-adapted)**: Navkar Mantra (Namokar), Logassa, Uvasaggaharam, Bhaktamar Stotra, Custom.

## Phase 0 — Foundation ✅ DONE

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

## Phase 1 — Auth, tenancy, and provisioning ✅ DONE (subset)

Goal: a real person can sign in with Google, see their profile, and the operator can spin up a new temple in 5 minutes.

**What shipped (commit `e029c51`, live at `https://jaapam-gyanodaya-dev.web.app`):**
* Google popup sign-in + email-link sign-in (return handler deferred to Phase 2).
* Profile onboarding: full name, gotra, temple (single-temple dropdown — Gyanodaya).
* `users/{uid}` Firestore doc with owner-only rules.
* `go_router` redirect guard (unauth → /sign-in, no profile → /onboarding).
* EN + HI strings via ARB; language toggle in AppBar.

**Deferred to post-v1.1 (multi-temple rollout):**
* `templeId` build-time define, invite codes, `redeemInvite` callable, `onMemberWrite` claim sync, `setMemberRole`, audit logs, `provision-temple.ts`.

---

### Original Phase 1 scope (kept for reference, deferred items will come back in post-v1)


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

## Phase 2 — Design system + Home Dashboard + Jaap Counter ▶ NEXT

**Mockup screens:** 3 (Home Dashboard) + 6 (Add Entry).

Goal: a member opens the app, sees today's count in a beautiful big ring, and logs jaap in under 10 seconds.

### 2a. Theme + design system pass
* Apply palette + typography tokens from the **Design system tokens** section above.
* Replace current rust-red `ColorScheme` with cream/orange Material 3 scheme.
* Wire Playfair Display + Inter via `google_fonts`.
* Polish sign-in + onboarding screens to match the new aesthetic.
* 5-tab bottom nav scaffold (Home, Community, Add, History, Profile) — non-Home tabs render placeholders.

### 2b. Home Dashboard (screen 3)
* Big circular progress ring: `TODAY / GOAL` (default goal = 1000, editable in Profile later).
* Quick-add chips: `+1`, `+11`, `+27`, `+108` — each tap optimistically increments today + writes a session entry.
* **Add Custom Count** primary button → opens Add Entry bottom sheet.
* **Last Session** card: shows `Xm ago` or `Yesterday Y:YY PM`.
* **Streak** card: current consecutive-day streak.
* Greeting header: `Namaste, {firstName}`.

### 2c. Add Entry bottom sheet (screen 6)
* Rounds wheel/stepper (1 round = 108 jaaps; default 1).
* Date picker (default today; back-fill allowed within 24h).
* Mantra chips (focus): Navkar / Logassa / Bhaktamar / Uvasaggaharam / Custom.
* Observation text field (optional).
* **Add to History** button → writes session, closes sheet, animates count in ring.

### 2d. Data model + writes
* `users/{uid}/sessions/{sessionId}`: `{ count, mantra, observation?, sessionDate, createdAt, source: 'quick' | 'manual' }`.
* Optimistic local update; commit to Firestore.
* Aggregates **client-computed for v1** (read today's sessions on app start, sum into `todayCount`); move to Cloud Function trigger in Phase 6 when we go Blaze.
* Streak computed client-side from last 30 days of sessions.
* Firestore rules: `users/{uid}/sessions/{id}` — owner read/write only.

### 2e. Email magic-link return handler (carry-over from Phase 1)
* On app boot, check `Uri.base.queryParameters['emailSignIn']`; if present, call `completeEmailLinkSignIn`.
* Persist pending email in `shared_preferences` instead of in-memory variable.

**Exit criteria:** member opens `https://jaapam-gyanodaya-dev.web.app`, taps `+108` four times, sees ring fill to `432 / 1000`, refreshes, count persists.

## Phase 3 — History

**Mockup screen:** 7 (History).

Goal: a member sees their meditation journey across time.

* Tabs: **This Week / This Month / Custom Range**.
* Header card: **Total Chant Count** for the selected range (big serif number).
* Two stat cards: **Daily Avg** and **Current Streak**.
* **Recent Entries** list: date pill (OCT 24), session title (`Evening Sadhana 108`), observation snippet, count badge.
* Tap entry → detail sheet → edit (within 24h) / delete.
* Empty state: "Your journey starts with the first jaap."
* Firestore query: `users/{uid}/sessions` ordered by `sessionDate desc`, paginated.

**Exit criteria:** member with 30+ sessions across 14 days sees correct weekly/monthly totals and streak.

## Phase 4 — Profile / Settings

**Mockup screen:** 8 (Profile / Settings).

Goal: a member controls their identity, preferences, and account.

* Avatar + edit (initials placeholder; photo upload in post-v1).
* Practitioner-since date (from `users/{uid}.createdAt`).
* Stat cards: **Total Malas** (lifetime / 108) + **Daily Streak**.
* Preferences: Notifications toggle, Theme (Light / Dark / System), App Language (EN / HI).
* Privacy & Security: Privacy Policy link, Data export request (post-v1.2), Delete account (post-v1).
* **Sign Out** destructive button.
* Daily goal editor (1000 default — feeds Home ring).

**Exit criteria:** member changes goal, language, theme; all persist across reloads.

## Phase 5 — Personal Target

**Mockup screen:** 4 (Personal Target).

Goal: a member sets monthly intentions and watches devotion grow.

* Monthly target card with progress bar + `15,000 / 30,000` + `50% complete`.
* Edit Target button → bottom sheet (number stepper).
* **Weekly Devotion** strip: 7-day mini heatmap (M-T-W-T-F-S-S) showing relative intensity.
* **Completed Milestones** list: First 1,000 Beads, 7-Day Streak Mastery, Morning Sadhana Guru, etc. — auto-awarded on session write.
* **Expand Your Practice** promo card (links to guided meditations resource page — Phase 7).
* Data: `users/{uid}/personal_goals/{YYYY-MM}` doc with `target` and `currentCount` (client-summed).
* Milestones: enumerated locally; persisted as `users/{uid}/milestones/{milestoneId}` with `unlockedAt`.

**Exit criteria:** member sets 20,000-mantra monthly target on day 1, sees percent fill correctly as sessions accrue.

## Phase 6 — Community Campaign (requires Blaze plan)

**Mockup screen:** 5 (Community Campaign).

Goal: temple-wide campaign with live activity and aggregate counter.

* Admin: create / edit / cancel campaign (`campaigns/{campaignId}`). One active campaign at a time enforced in the UI.
* Member: when logging an entry, optional toggle to attribute to active campaign.
* `onSessionWrite` Cloud Function trigger cascades: increments `campaigns/{campaignId}.currentCount` and `campaigns/{campaignId}/daily_totals/{YYYY-MM-DD}.total` transactionally; idempotent via `_processed_events/{eventId}`.
* Community Campaign screen:
  * Title + subtitle (e.g. `Global Peace 100 Million Jaap`, `12,450 devotees participating`).
  * Big ring with `68.4M of 100M goal` (campaign aggregate).
  * **Contribute Now** CTA → opens Add Entry sheet with campaign pre-attributed.
  * **Live Activity** feed: real-time stream of `name just added X jaap`, `name reached 5,000 jaap (MILESTONE)`, `name joined the campaign`, with avatars and timestamps.
  * **Avg Sessions** + **Top Speed** metric cards.
* Per-day breakdown chart pulled from `daily_totals` subcollection.
* Activity feed: `campaigns/{campaignId}/activity/{eventId}` rolling 100 events, fed by the same trigger.

**Pre-req:** upgrade `jaapam-gyanodaya-dev` to Blaze (still free under tiny usage — pay-as-you-go from $0).

**Exit criteria:** temple runs a 30-day Paryushan campaign with 100 members; aggregate count + live feed update within 2 seconds of any member's session write.

## Phase 7 — Onboarding hero + PWA polish

**Mockup screen:** 1 (Welcome / Onboarding).

Goal: first-touch delight + installability.

* Welcome screen with lotus illustration (SVG asset), warm gradient background, "Count Your Blessings, Connect with Community" hero copy.
* `Get Started` → onboarding form; `Log In` → sign-in.
* PWA manifest: icon (1024, 512, 192, maskable), splash, theme color, display: standalone.
* iOS Safari + Android Chrome "Add to Home Screen" prompts.
* Resource page (linked from Phase 5 promo): mantra references, pronunciation audio (post-v1).
* Brand assets: app icon, favicon, social share image.

**Exit criteria:** first-time visitor sees lotus welcome, installs to home screen, launches as standalone app.

## Phase 8 — Invites, announcements, and push

Goal: admins communicate; members get notified.

* Invite management UI: admin creates invite codes (`invites/{inviteCode}`) with `maxUses` and `expiresAt`. QR code rendered for printing/sharing.
* `redeemInvite` callable validates code in transaction, creates `members/{uid}` doc, increments `usedCount`.
* Announcements: coordinator/admin creates `announcements/{announcementId}`; `onAnnouncementCreate` trigger fans out FCM push to topic `temple_main`.
* FCM web push wired in Flutter (`firebase_messaging`); service worker registered; tokens stored in `users/{uid}.fcmTokens`.
* Milestone announcements: `onEntryWrite` cascade emits a `kind: "milestone"` announcement when campaign crosses 25/50/75/100% (idempotent via `lastMilestone`).
* In-app announcements feed (subscribes to `announcements` ordered by `createdAt desc`).

Exit criteria: admin posts an announcement; subscribed members on iOS 16.4+ and Android Chrome receive a push within 30 seconds.

## Phase 9 — Admin tooling

Goal: admins can run the temple without developer help.

* Member roster screen: search, filter by role/status, change role, suspend/reinstate.
* Audit log viewer (admin-only): `audit_logs/*` paginated with filters.
* Temple settings screen: branding (logo, colors, about), `joinPolicy`, `supportEmail`, `supportWhatsapp`, `homeTimezone`, `maxEntryCount`.
* Support page (member-facing): renders `supportEmail` as mailto with pre-filled subject, `supportWhatsapp` as `https://wa.me/<phone>` link, "Report a problem" form that emails the admin with diagnostics (uid, browser, last route).
* Self account deletion (`deleteAccount` callable): purges `users/{uid}` + entries, anonymizes `members/{uid}`, retains audit logs.

Exit criteria: admin onboards 50 members, runs one full campaign, and resolves one support request without contacting the developer.

## Phase 10 — Hardening and launch

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

### Post-v1.8 — Native Android and iOS apps

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
