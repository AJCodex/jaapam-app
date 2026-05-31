---
title: Jaapam — Cost Model
description: Projected Firebase costs per temple at v1 scale, scaling projections, recommended budget alerts, and what would actually push the bill above zero.
author: Jaapam team
ms.date: 2026-05-31
ms.topic: reference
---

## Purpose

Make the running cost of Jaapam transparent — for both the developer (you) and any temple trust evaluating whether to fund a deployment. All numbers below are **rough monthly estimates** at the listed scale; actuals depend on usage patterns. Source: Firebase pricing as of May 2026 ([firebase.google.com/pricing](https://firebase.google.com/pricing)).

## Headline numbers

| Scale                       | Expected cost per temple per month | Closest constraint  |
|-----------------------------|------------------------------------|---------------------|
| **1 temple, 2,000 members** | **~$0** (well within Blaze free quotas) | None hit            |
| 1 temple, 10,000 members    | ~$0–$2                              | Firestore reads     |
| 5 temples × 2,000 members   | ~$0 per temple (~$0 total)          | None hit            |
| 15 temples × 2,000 members  | ~$0–$5 total (if migrated to shared project, see scaling roadmap) | Firestore reads in shared project |
| 50 temples × 2,000 members  | ~$50–$150 total (shared project)    | Reads + network egress |

**Bottom line:** for the planned 1–5 temple v1 rollout, Firebase bills will hover at zero. The $5/month budget alert exists as a smoke detector, not because we expect spend.

## What you actually pay for

Firebase Blaze (pay-as-you-go) bills four resources that matter for Jaapam. Free quotas reset daily/monthly per project.

| Resource           | Free quota (per project)     | Price beyond free quota              | Jaapam's typical consumption (1 temple, 2,000 members) |
|--------------------|------------------------------|--------------------------------------|---------------------------------------------------------|
| Firestore reads    | 50,000 / day                 | $0.06 per 100,000                    | ~5,000–15,000/day (well under free)                     |
| Firestore writes   | 20,000 / day                 | $0.18 per 100,000                    | ~2,000–4,000/day (well under free)                      |
| Firestore deletes  | 20,000 / day                 | $0.02 per 100,000                    | <100/day                                                |
| Firestore storage  | 1 GiB                        | $0.18 per GiB/month                  | ~10 MB at launch; ~110 MB after year 1                  |
| Cloud Functions    | 2M invocations + 400K GB-sec / month | $0.40 per million invocations; $0.0000025 per GB-sec | ~150K invocations/month (well under free)     |
| Hosting bandwidth  | 360 MB/day (10 GB/month)     | $0.15 per GB                         | ~1–2 GB/month for 2,000 active members                  |
| Hosting storage    | 10 GB                        | $0.026 per GB/month                  | <50 MB (Flutter web build)                              |
| Auth               | Unlimited Google sign-ins    | $0 forever                           | Unlimited                                               |
| FCM web push       | Unlimited                    | $0 forever                           | Unlimited                                               |
| Cloud Storage      | 5 GB + 1 GB/day download     | $0.026/GB/month + $0.12/GB egress    | ~0 in v1 (no user uploads)                              |

**What's deliberately NOT in scope** that would change the picture:

* **Phone OTP**: ~$0.01/SMS in India, ~$0.06/SMS in US. Would cost ~$20–$100/month for a 2,000-member temple with monthly re-auth. Dropped from v1.
* **Cloud Storage for user photo uploads**: free quota covers it for a long time, but downloads from devotees scrolling galleries adds up. Not in v1.
* **BigQuery export**: ~$5–$20/month per temple if enabled. Deferred to post-v1.

## Worked example: Gyanodaya at 2,000 members

Assumptions:

* 2,000 registered members
* 600 daily active members (30% DAU)
* Each active member: opens app twice, logs ~3 jaap entries, scrolls campaign dashboard once
* One active campaign with daily totals
* One announcement per week

### Daily reads (per project)

| Operation                                | Reads per op | Frequency        | Total reads/day |
|------------------------------------------|--------------|------------------|-----------------|
| App open: load `config/temple` + `users/{uid}` + `members/{uid}` + campaign + 5 announcements | ~10 | 600 DAU × 2 opens | 12,000 |
| Dashboard: load own entries (last 7 days) | ~7         | 600 × 1          | 4,200           |
| Campaign view: load campaign + last 7 daily_totals | ~8 | 600 × 1          | 4,800           |
| Rule-level membership checks             | ~1 per request | ~3,000 requests | 3,000          |
| **Total daily reads**                    |              |                  | **~24,000**     |

Free quota: 50,000/day. **Usage: ~48%.** Cost: $0.

### Daily writes (per project)

| Operation                          | Writes per op | Frequency               | Total writes/day |
|------------------------------------|---------------|-------------------------|------------------|
| Member logs jaap (one entry per mala) | 1          | 600 × 3 entries         | 1,800            |
| `onEntryWrite` updates aggregates  | ~3 (user + campaign + daily_total) | 1,800     | 5,400            |
| Profile/lastSeen updates           | 1             | 600 × 2                 | 1,200            |
| Announcements                      | 1 + push      | 1 every few days        | <1               |
| `_processed_events` markers        | 1             | per trigger invocation  | ~7,000           |
| **Total daily writes**             |               |                         | **~15,400**      |

Free quota: 20,000/day. **Usage: ~77%.** Cost: $0, but this is the closest constraint at 2,000 members.

**Headroom analysis:** if the temple grows to 3,000 active members, daily writes climb to ~23,000 and bill becomes ~$0.02/day (~$0.60/month). Still trivial.

### Storage (cumulative)

| Collection                          | Approx. size                  | After 1 year (cumulative) |
|-------------------------------------|-------------------------------|---------------------------|
| `users/{uid}` × 2,000               | ~500 bytes each = 1 MB        | 1 MB                      |
| `members/{uid}` × 2,000             | ~200 bytes each = 0.4 MB      | 0.4 MB                    |
| `users/{uid}/entries/*` (3/day × 600 DAU × 365 days) | ~300 bytes × ~650K entries = 200 MB | 200 MB |
| `campaigns/*` + `daily_totals/*`    | ~100 KB total                 | 1 MB                      |
| `announcements/*`                   | ~50 KB                        | 0.3 MB                    |
| `audit_logs/*`                      | ~200 bytes × ~5,000 events    | 1 MB                      |
| **Total after year 1**              |                               | **~205 MB**               |

Free quota: 1 GiB. **Usage after year 1: ~20%.** Cost: $0.

At year 3 (~600 MB), still under free quota. At year 5 (~1 GiB), starts costing ~$0.03/month. **No purging needed.**

### Hosting bandwidth

Flutter web build is ~2 MB gzipped (cached aggressively after first load). FCM service worker negligible. API calls are JSON, small.

* First load per member: ~2 MB
* Cached repeat loads: ~50 KB JSON per session

Monthly bandwidth: ~2 MB × 2,000 first-loads + 50 KB × 600 DAU × 30 days = ~4 MB + 900 MB ≈ **~1 GB/month**.

Free quota: 10 GB/month. **Usage: ~10%.** Cost: $0.

### Cloud Functions

Invocations: ~15K writes/day × ~3 triggers fire per write on average = ~30K/day = **~900K/month**. Each completes in <500ms with 256 MB memory.

Free quota: 2M invocations + 400K GB-sec/month. **Usage: ~45%.** Cost: $0.

## Recommended budget alerts

Set per project in **Google Cloud Console → Billing → Budgets & alerts**:

| Alert level    | Budget | Action                                                     |
|----------------|--------|------------------------------------------------------------|
| Smoke detector | $5/mo  | Email at 50%, 90%, 100%                                    |
| Soft cap       | $25/mo | Email + Slack/WhatsApp to operator                         |
| Hard sanity    | $100/mo | Email + investigate immediately — something is very wrong |

You'd expect to never see even the first alert in normal operation. If $5 ever fires, the most likely cause is a runaway Cloud Function (e.g., a missing `_processed_events` check causing an infinite retry loop). The `04-setup.md` "Common gotchas" section calls this out.

> **Note:** Firebase budget alerts are *informational only* — they email you but do not stop service. To actually cap spend, you'd need a Pub/Sub-triggered function that disables billing on the project when the alert fires. Documented in post-v1 if a temple ever wants hard guarantees.

## Operator-side cost (you, the developer)

| Item                            | Cost                | Notes                                                    |
|---------------------------------|---------------------|----------------------------------------------------------|
| Firebase Blaze (per project)    | ~$0/month           | See above                                                |
| GitHub account                  | $0                  | Free for public repos; $4/month for private with Actions |
| Domain (optional, post-v1)      | ₹700–₹1,400/year per temple if temple wants it | We use free `.web.app` URLs at launch |
| Google Play developer fee       | $25 one-time        | Only if Phase 7 (native Android) is triggered            |
| Apple Developer Program         | $99/year            | Only if Phase 7 (native iOS) is triggered                |
| Service-account JSON key storage | $0                 | Local `.secrets/` folder; gitignored                     |
| **v1 operator total**           | **~$0/month**       |                                                          |

## Cost projections at higher temple counts

| Scenario | Architecture | Approx monthly cost | Per-temple |
|----------|--------------|---------------------|------------|
| 1 temple, 2K members | Per-project (current) | ~$0 | ~$0 |
| 5 temples, 2K each   | Per-project (current) | ~$0 | ~$0 |
| 15 temples, 2K each  | Per-project | ~$0 (each project keeps its own free quota) | ~$0 |
| 15 temples, 2K each  | Shared project (migrated, Option B) | ~$5–$15 | ~$0.50 |
| 50 temples, 2K each  | Per-project | ~$0–$10 (50 free quotas) | ~$0.20 |
| 50 temples, 2K each  | Shared project (one Firestore for all) | ~$50–$150 | ~$1–$3 |

**Interesting result:** per-project topology stays cheaper *forever* because each project gets its own free quota. The reason to migrate to a shared project at 15+ temples is **operational simplicity** (one rules deploy instead of 15), not cost. Don't migrate solely to save money; you might pay more after migration.

## When to revisit this doc

* When any temple's daily writes exceed 15,000 sustained for a week (would push past 75% of free quota; means the temple is growing fast).
* When a new feature is added that writes per-action (any "like", "comment", or per-tap write would invalidate the cost model).
* Before enabling BigQuery export, Cloud Storage uploads, Phone OTP, or any paid Firebase add-on.
* At 12 temples (one phase before migration to shared project becomes worth designing in detail).
