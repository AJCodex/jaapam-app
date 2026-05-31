---
title: Jaapam — Jain Temple Community Jaap Tracker
description: Single-tenant Flutter web app for Jain temples to track personal and community jaap counts, run campaigns, and engage devotees. Free-to-run on Firebase.
author: Jaapam team
ms.date: 2026-05-31
ms.topic: overview
---

## What is Jaapam?

Jaapam is a devotional web app that lets a Jain temple community:

* **Members** track personal monthly jaap targets, log daily counts, and see their streak.
* **Temple admins** run community campaigns (e.g., Paryushan), watch live progress, and send announcements.
* **Coordinators** help admins moderate members and campaigns.

It runs as an installable web app (PWA) at a free `*.web.app` URL. One Firebase project per temple. Expected cost per temple: **~$0/month**.

## Live deployments (planned for v1)

| Temple                                  | `templeKey` | Dev URL                            | Prod URL                       |
|-----------------------------------------|-------------|------------------------------------|--------------------------------|
| Shri Gyanodaya Jain Mandir              | `gyanodaya` | `jaapam-gyanodaya-dev.web.app`     | `jaapam-gyanodaya.web.app`     |
| Shri Vidyodaya Jain Mandir              | `vidyodaya` | `jaapam-vidyodaya-dev.web.app`     | `jaapam-vidyodaya.web.app`     |

Up to five temples are in scope for v1. See [docs/05-roadmap.md](docs/05-roadmap.md) for the scaling plan beyond that.

## Final decisions at a glance

| Area               | Decision                                                                                  |
|--------------------|-------------------------------------------------------------------------------------------|
| Tenancy            | **Single-tenant per Firebase project.** No `temples/{templeId}/` prefix in Firestore paths. `templeId` field on every doc for forward-compat. |
| Tech stack         | Flutter web (Dart) + Riverpod + `go_router`; Cloud Functions (Node 20, TypeScript); Firestore; Firebase Hosting; FCM web push. |
| Frontend platforms | **PWA at launch.** Native Android + iOS in post-v1 (Phase 7), same Flutter codebase, same Firebase backend — no data migration. |
| Auth               | **Google Sign-In only.** Apple Sign-In added when iOS native ships. Phone OTP not used. |
| Phone numbers      | Captured as **optional profile field** (`users/{uid}.phoneNumber`) for future temple WhatsApp/call-tree campaigns. Not used for auth. |
| URLs               | Free `*.web.app` URLs at launch. No custom domain purchase. Domains can be added per-temple later without data migration. |
| Billing            | **Blaze (pay-as-you-go)** with $5/month budget alert per project. Expected actual spend: $0/month for a 2,000-member temple. |
| Environments       | Two Firebase projects per temple: `<templeKey>-dev` and `<templeKey>` (prod). No staging. |
| Cross-temple view  | **None.** Each temple has its own URL. A user in two temples bookmarks both, signs in to each separately. |
| Roles              | `member`, `coordinator`, `admin`. No super-admin. `admin` also gets a Firebase custom claim for cheap rule checks. |
| First admin        | Bootstrapped via `scripts/seed-admin.ts` with a service-account key. No self-promotion path. |
| Tap counter        | Client-side batched: one Firestore write per session/mala (108 taps), not per tap. |
| Trigger idempotency | `_processed_events/{eventId}` marker docs (TTL 7 days) inside a transaction. Required because Functions are at-least-once. |
| Data retention     | **No purging.** Devotional history is the product; storage is cheap. Only `_processed_events` has TTL. |
| New temple onboarding | `scripts/provision-temple.ts` — one command, ~5 minutes. Built in Phase 1. |
| Support page       | Per-temple `supportEmail` (mailto) and optional `supportWhatsapp` (wa.me link). Both edited by admin in temple settings. |
| Scaling path       | 1–5 temples: stay per-project. 5–15: harden provisioner. 15–50: migrate to shared multi-tenant project. 50+: sharded counters. |

## Documentation index

| Doc | Purpose |
|-----|---------|
| [docs/01-architecture.md](docs/01-architecture.md) | Runtime topology, tech stack, tenancy rationale, scaling roadmap. |
| [docs/02-data-model.md](docs/02-data-model.md) | Every Firestore collection, schema, indexes, aggregation pipeline, retention. |
| [docs/03-security-rules.md](docs/03-security-rules.md) | Role model, rule matrix per collection, Cloud Functions privileged operations, threat model. |
| [docs/04-setup.md](docs/04-setup.md) | Local toolchain, per-temple Firebase project creation (manual + automated), emulator workflow, deploy. |
| [docs/05-roadmap.md](docs/05-roadmap.md) | Phase 0 → Phase 6 delivery plan, post-v1 backlog including native apps. |
| [docs/06-cost-model.md](docs/06-cost-model.md) | Firebase free-quota math, $0/month projection, budget alerts, scaling cost projections. |

Original RFP: [# Jain Temple Community Jaap App — RFP S.md](# Jain Temple Community Jaap App — RFP S.md)

## Planned repository layout

```text
jaapam/
  lib/                                       # Flutter app (Dart)
    firebase_options_<temple>_<env>.dart     # generated per deployment; gitignored
    app/                                     # routes, theme, localizations
    features/
      auth/
      members/
      entries/                               # personal jaap logging + tap counter
      campaigns/
      announcements/
      admin/                                 # admin-only screens
      support/
    shared/                                  # widgets, models, providers, services
  functions/                                 # Cloud Functions (Node 20, TypeScript)
    src/
      triggers/                              # onEntryWrite, onAnnouncementCreate, onMemberWrite
      callables/                             # redeemInvite, setMemberRole, deleteAccount, ...
      lib/                                   # idempotency, audit, FCM helpers
  scripts/
    provision-temple.ts                      # automated new-temple onboarding (Phase 1)
    seed-temple.ts                           # writes config/temple doc
    seed-admin.ts                            # bootstraps first admin
  firestore.rules
  firestore.indexes.json
  storage.rules
  firebase.json
  .firebaserc                                # maps short alias -> project ID
  .github/
    workflows/
      ci.yml                                 # lint + test + build on PR
      deploy-dev.yml                         # auto-deploy to dev on push to main
      deploy-prod.yml                        # manual approval, deploy to prod
  docs/
    01-architecture.md
    02-data-model.md
    03-security-rules.md
    04-setup.md
    05-roadmap.md
    06-cost-model.md
  test/
    fixtures/                                # emulator seed data
  l10n/
    en.arb
    hi.arb
  .secrets/                                  # service-account JSON keys; gitignored
  README.md
```

## What happens next

1. **Phase 0 — Foundation.** Scaffold the Flutter web project, Cloud Functions, GitHub Actions CI, and the first Firebase project (Gyanodaya dev). See [docs/05-roadmap.md](docs/05-roadmap.md#phase-0--foundation).
2. **Phase 1 — Auth, tenancy, provisioning.** Wire Google Sign-In, build `scripts/provision-temple.ts`, and stand up Gyanodaya prod.
3. **Phases 2–5.** Personal jaap tracking → temple campaigns → invites/announcements/push → admin tooling.
4. **Phase 6.** Harden, App Check, accessibility, privacy, launch to real devotees.
5. **Post-v1.** Onboard Vidyodaya; then prioritize from the backlog based on which temple asks for what first.

No code has been written yet — these design docs are the source of truth before scaffolding begins. Once design is approved, scaffolding starts at Phase 0.

## Status

| Item | Status |
|------|--------|
| RFP review and scope reduction | Complete |
| Architecture design | Complete |
| Data model | Complete |
| Security rules spec | Complete |
| Setup runbook | Complete |
| Delivery roadmap | Complete |
| Cost model | Complete |
| Code scaffolding | Not started — awaiting design sign-off |

## License

TBD — likely MIT or Apache-2.0; pinned before Phase 0.
