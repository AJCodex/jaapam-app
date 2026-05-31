---
title: Jaapam — Data Model
description: Firestore collection schema for the single-tenant Jaapam deployment. Top-level collections, no temple prefix, aggregate counters maintained by Cloud Functions.
author: Jaapam team
ms.date: 2026-05-31
ms.topic: reference
---

## Purpose

This document defines every Firestore collection, the shape of its documents, the indexes required, and the aggregation pipeline. It is the source for the rules file at `firestore.rules` and for all Dart data classes. Read it after `01-architecture.md` and before `03-security-rules.md`.

## Collection map

```text
config/
  temple                 // single doc — branding, join policy, timezone

users/{uid}
  personal_goals/{YYYY-MM}
  entries/{entryId}      // raw jaap entries owned by this user

members/{uid}            // one per member; mirrors users/{uid} but is temple-scoped role data

campaigns/{campaignId}
  daily_totals/{YYYY-MM-DD}

announcements/{announcementId}

invites/{inviteCode}

audit_logs/{auditId}

_processed_events/{eventId}   // function idempotency markers (TTL 7 days)
```

There is **no `temples/{templeId}/`** prefix — this is a single-tenant deployment.

## Document schemas

### `config/temple`

The one source of truth for branding and temple-level settings. Editable by `admin` through the settings UI.

| Field            | Type      | Notes                                                          |
|------------------|-----------|----------------------------------------------------------------|
| `templeName`     | string    | Displayed in app bar, browser title, and notifications         |
| `templeAddress`  | string    |                                                                |
| `templeAbout`    | string    | Short paragraph shown on the home screen                       |
| `primaryColor`   | string    | Hex (e.g., `#8E0000`)                                          |
| `accentColor`    | string    | Hex                                                            |
| `logoUrl`        | string    | HTTPS URL; rendered in app bar and on the install icon         |
| `homeTimezone`   | string    | IANA tz name, default `Asia/Kolkata`                           |
| `joinPolicy`     | string    | `open` or `invite_only`                                        |
| `maxEntryCount`  | number    | Per-entry cap (default `10000`); enforced in rules and function |
| `supportEmail`   | string    | Shown on the Support page; mailto link with pre-filled subject |
| `supportWhatsapp` | string?  | E.164 (`+91...`); rendered as a `https://wa.me/<phone>` link on the Support page; hidden if absent |
| `templeKey`      | string    | Short slug (e.g., `gyanodaya`). Same value goes into every doc's `templeId` field. Forward-compat for path-based multi-tenant migration. |
| `updatedAt`      | timestamp |                                                                |
| `updatedBy`      | string    | uid of last editor                                             |

### `users/{uid}`

Profile + denormalized aggregate fields for the dashboard. Created on first sign-in.

| Field                | Type                       | Notes                                                       |
|----------------------|----------------------------|-------------------------------------------------------------|
| `uid`                | string                     | Mirror of doc id                                            |
| `displayName`        | string                     | From Google profile, editable                               |
| `email`              | string                     | From Google profile                                         |
| `photoUrl`           | string?                    | From Google profile                                         |
| `phoneNumber`        | string?                    | **Optional**, captured during onboarding for future temple campaigns (WhatsApp, call-tree). E.164 format (`+91...`). Not used for auth. |
| `phoneVerified`      | boolean                    | False unless admin manually verifies (out of scope for v1)  |
| `locale`             | string                     | `en` or `hi`                                                |
| `templeId`           | string                     | Forward-compat: always the single temple id today. Populated by client on user-doc create. |
| `fcmTokens`          | string[]                   | Active web push tokens                                      |
| `monthlyCounts`      | map<string, number>        | `"YYYY-MM" → totalCount`. Function-maintained.              |
| `currentStreakDays`  | number                     | Crosses months. Function-maintained.                        |
| `longestStreakDays`  | number                     | Function-maintained.                                        |
| `lastEntryDate`      | string                     | `YYYY-MM-DD` in `homeTimezone`. Function-maintained.        |
| `createdAt`          | timestamp                  | Server time                                                 |
| `lastSeenAt`         | timestamp                  | Updated by client on app open                               |
| `consent`            | map                        | `{ privacyVersion: "1.0", acceptedAt: timestamp }`          |

Embedding monthly totals as a map on the user doc keeps a year of history in one read (12 keys, well under document limit).

### `users/{uid}/personal_goals/{YYYY-MM}`

| Field         | Type      | Notes                                                       |
|---------------|-----------|-------------------------------------------------------------|
| `month`       | string    | `YYYY-MM`                                                   |
| `targetCount` | number    | Personal target for the month                               |
| `createdAt`   | timestamp |                                                             |
| `updatedAt`   | timestamp |                                                             |

### `users/{uid}/entries/{entryId}`

Raw entries — the only place jaap counts are recorded. Aggregates are derived from here by `onEntryWrite`.

| Field          | Type      | Notes                                                                                  |
|----------------|-----------|----------------------------------------------------------------------------------------|
| `entryId`      | string    | UUID                                                                                   |
| `count`        | number    | Positive, `<= config/temple.maxEntryCount`                                             |
| `inputMethod`  | string    | `manual` or `tap` (tap = one commit per session/mala, not per tap)                     |
| `date`         | string    | `YYYY-MM-DD` derived from `createdAt` in temple's `homeTimezone`                       |
| `createdAt`    | timestamp | Server time                                                                            |
| `campaignId`   | string?   | When contributed to the active campaign                                                |
| `editedAt`     | timestamp?| Set when the user edits                                                                |
| `editedBy`     | string?   | uid of editor (self or admin)                                                          |

Entries are owned by the user. They optionally roll up into the active campaign when `campaignId` is set.

### `members/{uid}`

Role and status. Created when a user joins (open join or invite redemption).

| Field          | Type      | Notes                                                                                  |
|----------------|-----------|----------------------------------------------------------------------------------------|
| `uid`          | string    | Mirror of doc id                                                                       |
| `displayName`  | string    | Denormalized for fast roster rendering                                                 |
| `role`         | string    | `admin` / `coordinator` / `member`                                                     |
| `status`       | string    | `active` / `pending` / `suspended`                                                     |
| `joinedAt`     | timestamp |                                                                                        |
| `joinedVia`    | string    | `open` / `invite:{code}` / `seed_script`                                               |
| `invitedBy`    | string?   | uid of inviter                                                                         |

A user document at `users/{uid}` can exist without a `members/{uid}` doc only briefly (between sign-in and join). Rules and Functions enforce the link.

### `campaigns/{campaignId}`

Only one campaign at a time has `status: "active"` (enforced by Function on transition).

| Field              | Type      | Notes                                                                              |
|--------------------|-----------|------------------------------------------------------------------------------------|
| `campaignId`       | string    | Mirror of doc id                                                                   |
| `title`            | string    |                                                                                    |
| `reason`           | string    | Spiritual reason / dedication                                                      |
| `targetCount`      | number    |                                                                                    |
| `currentCount`     | number    | Function-maintained                                                                |
| `participantCount` | number    | Distinct contributors. Function-maintained.                                        |
| `startDate`        | string    | `YYYY-MM-DD` in temple `homeTimezone`                                              |
| `endDate`          | string    | `YYYY-MM-DD`                                                                       |
| `status`           | string    | `draft` / `active` / `completed` / `cancelled`                                     |
| `createdBy`        | string    | admin uid                                                                          |
| `createdAt`        | timestamp |                                                                                    |
| `lastMilestone`    | number?   | Last milestone % notified (25 / 50 / 75 / 100). Function-maintained.               |

To find the active campaign: `campaigns where status == "active" limit 1`. No `activeCampaignId` pointer — single source of truth.

### `campaigns/{campaignId}/daily_totals/{YYYY-MM-DD}`

| Field          | Type      | Notes                                                  |
|----------------|-----------|--------------------------------------------------------|
| `date`         | string    | `YYYY-MM-DD`                                           |
| `count`        | number    | Sum of contributions on this date                      |
| `contributors` | number    | Distinct contributors on this date                     |
| `updatedAt`    | timestamp |                                                        |

### `announcements/{announcementId}`

| Field        | Type      | Notes                                                    |
|--------------|-----------|----------------------------------------------------------|
| `id`         | string    |                                                          |
| `title`      | string    |                                                          |
| `body`       | string    |                                                          |
| `campaignId` | string?   | Optional link to a campaign                              |
| `createdBy`  | string    | admin or coordinator uid                                 |
| `createdAt`  | timestamp |                                                          |
| `pushed`     | boolean   | True once FCM fan-out has run                            |
| `kind`       | string    | `manual` / `milestone`                                   |

### `invites/{inviteCode}`

Short alphanumeric code (e.g., `JX7K9P`). Distributed as a link (`/join?code=JX7K9P`) or QR.

| Field        | Type      | Notes                                                    |
|--------------|-----------|----------------------------------------------------------|
| `code`       | string    | Mirror of doc id                                         |
| `createdBy`  | string    | admin uid                                                |
| `createdAt`  | timestamp |                                                          |
| `expiresAt`  | timestamp |                                                          |
| `maxUses`    | number    |                                                          |
| `usedCount`  | number    |                                                          |
| `status`     | string    | `active` / `expired` / `revoked`                         |

### `audit_logs/{auditId}`

Append-only.

| Field      | Type      | Notes                                                      |
|------------|-----------|------------------------------------------------------------|
| `actor`    | string    | uid                                                        |
| `action`   | string    | e.g., `member.promote`, `entry.edit_by_admin`, `campaign.cancel`, `temple.config_update` |
| `target`   | string    | Affected doc path                                          |
| `before`   | map?      | Previous values                                            |
| `after`    | map?      | New values                                                 |
| `createdAt`| timestamp |                                                            |

### `_processed_events/{eventId}` (internal)

Idempotency markers for Cloud Function triggers. Written by `onEntryWrite` and similar triggers as the first step of their transaction. TTL policy (Firestore TTL feature) auto-deletes entries older than 7 days.

| Field        | Type      | Notes                                            |
|--------------|-----------|--------------------------------------------------|
| `eventId`    | string    | Mirror of doc id (Cloud Functions event id)     |
| `function`   | string    | Function name                                    |
| `processedAt`| timestamp |                                                  |
| `expireAt`   | timestamp | TTL field; doc auto-deletes after this time      |

## Forward-compatibility: `templeId` field on every top-level doc

Every top-level document (`users/*`, `members/*`, `campaigns/*`, `announcements/*`, `invites/*`, `audit_logs/*`) carries a `templeId` field. In single-tenant v1, this value is always the same string (set from `config/temple.templeKey`, e.g., `"gyanodaya"`).

**Why bother today:** When the temple count crosses ~15 and we migrate to a shared multi-tenant project (see scaling roadmap in `01-architecture.md`), the migration becomes a mechanical path rewrite (`/users/{uid}` → `/temples/{templeId}/users/{uid}`) instead of a schema change. The `templeId` field already exists in every document, ready to drive the path.

The Cloud Function `onEntryWrite` and all other triggers also write `templeId` into the marker doc and into any output documents. No hardcoded collection paths in function code.

## Required composite indexes

```text
campaigns
  status ASC, startDate DESC

members
  status ASC, role ASC, joinedAt DESC

users/{uid}/entries
  date DESC, createdAt DESC

users/{uid}/entries
  campaignId ASC, date DESC

announcements
  createdAt DESC
```

These will be expressed in `firestore.indexes.json` at the repo root.

## Aggregation pipeline

`onEntryWrite` is a Firestore trigger on `users/{uid}/entries/{entryId}`. It runs on create, update, and delete.

Pseudocode:

```text
function onEntryWrite(change, context):
  ref = firestore.doc("_processed_events/" + context.eventId)
  result = firestore.runTransaction(tx => {
    if (tx.get(ref).exists) return "skipped"
    tx.set(ref, { function: "onEntryWrite", processedAt: now(), expireAt: now() + 7d })

    before = change.before.data()
    after  = change.after.data()
    delta  = (after?.count ?? 0) - (before?.count ?? 0)
    if (delta == 0) return "noop"

    uid   = context.params.uid
    date  = (after ?? before).date          // already in homeTimezone
    month = date.substring(0, 7)
    campaignId = (after ?? before).campaignId

    // User aggregates
    userRef = firestore.doc("users/" + uid)
    tx.update(userRef, {
      ["monthlyCounts." + month]: FieldValue.increment(delta),
      lastEntryDate: maxString(tx.get(userRef).data().lastEntryDate, date),
    })
    recomputeStreak(tx, userRef, date)     // bumps currentStreakDays / longestStreakDays

    // Campaign aggregates
    if (campaignId) {
      campRef = firestore.doc("campaigns/" + campaignId)
      tx.update(campRef, { currentCount: FieldValue.increment(delta) })

      dailyRef = firestore.doc("campaigns/" + campaignId + "/daily_totals/" + date)
      tx.set(dailyRef, {
        date,
        count: FieldValue.increment(delta),
        updatedAt: now(),
      }, { merge: true })

      maybeEnqueueMilestone(tx, campRef)  // creates announcement when 25/50/75/100% crossed
    }
    return "ok"
  })
}
```

All counters use `FieldValue.increment()` so concurrent writes do not clobber each other. The idempotency marker ensures at-least-once delivery does not double-count.

## Data lifecycle and retention

* **Jaap entries are kept indefinitely.** Devotional history is the product. Storage is ~110 MB/year for a 2,000-member temple ($0.02/month at $0.18/GiB) — not worth purging.
* **Audit logs and announcements** are kept indefinitely; revisit at year 3 if any temple's storage approaches 1 GiB.
* **`_processed_events/*`** is the only collection with active cleanup. Firestore TTL policy is configured on the `expireAt` field and auto-deletes docs after 7 days. Configure once per project via the Firebase Console (Firestore → TTL) or `gcloud firestore fields ttls update expireAt --collection-group=_processed_events`.
* **Expired invites** are kept (status: `expired`) for the audit trail. Admins may manually delete via the invites screen.
* **Account self-delete** (`deleteAccount` Function): purges `users/{uid}` and `users/{uid}/entries/*`, anonymizes `members/{uid}` (`displayName` blanked, `status: "deleted"`). Audit logs retain the orphan uid for accountability.

## Open data-model questions

* **Timezone source of truth.** `entry.date` is computed by the **server** from `createdAt` and `config/temple.homeTimezone`, not by the client. This means a devotee logging from another country still credits the temple's day. Trade-off: a devotee traveling may see their own "today" misaligned with the entry date.
* **Embedded monthly map vs. subcollection.** `users/{uid}.monthlyCounts` as a map keeps dashboards to one read. Stops being viable around 100+ months (8+ years). Acceptable for v1; revisit if any user crosses that threshold.
* **Entry edits by admin.** Permitted (for typo corrections) but always written to `audit_logs` with `before`/`after`. UI must show "edited by admin" badge on such entries.
