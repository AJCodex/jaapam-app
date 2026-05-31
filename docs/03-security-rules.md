---
title: Jaapam — Security Rules Specification
description: Firestore and Cloud Functions authorization model for the single-tenant Jaapam deployment. Google-only auth, role via membership doc + custom claim, privileged work in Cloud Functions.
author: Jaapam team
ms.date: 2026-05-31
ms.topic: reference
---

## Purpose

This document specifies the authorization model: who can read or write each collection, how roles are evaluated, and which actions are restricted to Cloud Functions. It is the source for the rules file at `firestore.rules`.

## Principles

* **Default deny.** Anything not explicitly allowed is denied.
* **Single-tenant simplicity.** No `temples/{templeId}/...` prefix on rule checks. Top-level collections, simple paths.
* **Least privilege.** Members can read; coordinators can moderate; admins can configure.
* **Privileged writes are server-side.** Custom claims, aggregate counters, invite redemption, and account deletion are written only by Cloud Functions (via Admin SDK, which bypasses rules).
* **Audit on sensitive mutations.** Every role change, member suspension, entry edit by a non-owner, and temple-config change writes an `audit_logs` document.

## Role surface

| Role          | Source                                                  | Scope         |
|---------------|---------------------------------------------------------|---------------|
| `admin`       | Custom claim `role == "admin"` **and** `members/{uid}.role == "admin"` | Whole temple |
| `coordinator` | `members/{uid}.role == "coordinator"`                   | Whole temple |
| `member`      | `members/{uid}.role == "member"` and `status == "active"` | Whole temple |
| `signedIn`    | Any authenticated user                                  | Self-data only |

The `admin` role is stored in **both** the membership doc (so admins are visible in the UI roster) and the custom claim (so rules can check admin without an extra Firestore read). Functions keep the two in sync on every role change.

## Helper functions (sketch)

These will live at the top of `firestore.rules`:

```text
function isSignedIn()        { return request.auth != null; }
function uid()               { return request.auth.uid; }
function isSelf(userId)      { return isSignedIn() && uid() == userId; }
function isAdmin()           { return isSignedIn() && request.auth.token.role == "admin"; }
function membership()        { return get(/databases/$(database)/documents/members/$(uid())); }
function isActiveMember()    { return exists(/databases/$(database)/documents/members/$(uid()))
                                       && membership().data.status == "active"; }
function isCoordinator()     { return isActiveMember() && membership().data.role in ["coordinator", "admin"] || isAdmin(); }
```

> Each `get()` and `exists()` counts as a billable read. Member-status checks happen on most reads; we accept ~1 extra read per request as the cost of fine-grained authorization. Admin checks use the claim and add no reads.

## Rule matrix

### `config/temple`

| Operation | Allowed when                                            |
|-----------|---------------------------------------------------------|
| read      | `isSignedIn()` (everyone needs branding to render)      |
| update    | `isAdmin()` and `templeKey` field unchanged             |
| create    | Denied. Seeded by `scripts/seed-temple.ts`.             |
| delete    | Denied.                                                 |

### `users/{uid}`

| Operation | Allowed when                                                                                       |
|-----------|----------------------------------------------------------------------------------------------------|
| read      | `isSelf(uid)` or `isAdmin()`                                                                       |
| create    | `isSelf(uid)`, `request.resource.data.uid == uid`, function-maintained fields (`monthlyCounts`, `currentStreakDays`, `longestStreakDays`, `lastEntryDate`) are absent or zero |
| update    | `isSelf(uid)`, immutable fields preserved (`uid`, `email`, `createdAt`, `templeId`), function-maintained fields not changed by client |
| delete    | Denied. Account deletion goes through `deleteAccount` Cloud Function.                              |

### `users/{uid}/personal_goals/{month}`

| Operation | Allowed when     |
|-----------|------------------|
| read      | `isSelf(uid)`    |
| write     | `isSelf(uid)`    |

### `users/{uid}/entries/{entryId}`

| Operation | Allowed when                                                                                                       |
|-----------|--------------------------------------------------------------------------------------------------------------------|
| read      | `isSelf(uid)` or `isAdmin()`                                                                                       |
| create    | `isSelf(uid)`, `isActiveMember()`, `count > 0` and `count <= config/temple.maxEntryCount` (default 10,000)         |
| update    | `isSelf(uid)` within 24 hours of `createdAt`; `editedAt` set to `request.time`; `templeId` immutable               |
| delete    | `isSelf(uid)` within 24 hours of `createdAt`; older deletions require admin (writes an audit log)                  |

### `members/{uid}`

| Operation | Allowed when                                                                                                  |
|-----------|---------------------------------------------------------------------------------------------------------------|
| read      | `isActiveMember()` (roster visible to all members) or `isSelf(uid)` (self even before active)                 |
| create    | Self-join when `config/temple.joinPolicy == "open"` and `uid == request.auth.uid`, with `role: "member"` and `status: "active"` forced; otherwise function-only via `redeemInvite`/`requestJoin` |
| update    | Self can update own `displayName`; role and status changes require `isAdmin()`                                |
| delete    | Self can leave (delete own doc); admin can remove others (writes audit log)                                   |

### `campaigns/{campaignId}`

| Operation | Allowed when                                                                                                  |
|-----------|---------------------------------------------------------------------------------------------------------------|
| read      | `isActiveMember()`                                                                                            |
| create    | `isAdmin()`; `currentCount`, `participantCount`, `lastMilestone` forced to absent or zero; `status` in `["draft", "active"]` |
| update    | `isAdmin()` for editable fields (`title`, `reason`, `targetCount`, `endDate`, `status`); aggregate fields writable only by Cloud Function |
| delete    | Denied. Cancel via `status: "cancelled"`.                                                                     |

### `campaigns/{campaignId}/daily_totals/{date}`

| Operation | Allowed when                                            |
|-----------|---------------------------------------------------------|
| read      | `isActiveMember()`                                      |
| write     | **Denied for clients.** Cloud Function only.            |

### `announcements/{announcementId}`

| Operation | Allowed when                                            |
|-----------|---------------------------------------------------------|
| read      | `isActiveMember()`                                      |
| create    | `isCoordinator()`; `pushed` forced to `false`; `kind: "manual"`  |
| update    | `isCoordinator()`; `pushed` writable only by Cloud Function      |
| delete    | `isAdmin()`                                             |

### `invites/{inviteCode}`

| Operation | Allowed when                                                                                                  |
|-----------|---------------------------------------------------------------------------------------------------------------|
| read      | `isAdmin()` for full details; **unauthenticated reads denied** (use `redeemInvite` Function to redeem)        |
| create    | `isAdmin()`                                                                                                   |
| update    | `isAdmin()`; `usedCount` writable only by Cloud Function                                                      |
| delete    | `isAdmin()`                                                                                                   |

### `audit_logs/{auditId}`

| Operation | Allowed when                                            |
|-----------|---------------------------------------------------------|
| read      | `isAdmin()`                                             |
| write     | **Denied for clients.** Cloud Function only.            |

### `_processed_events/{eventId}` (internal)

| Operation | Allowed when                                            |
|-----------|---------------------------------------------------------|
| read      | Denied for clients.                                     |
| write     | **Denied for clients.** Cloud Function only.            |

TTL policy on `expireAt` auto-deletes after 7 days.

## Cloud Functions — privileged operations

The following actions are exposed as **HTTPS callable functions** (or Firestore triggers) and run with Admin SDK privileges. The Flutter client invokes the callables; rules do not need to allow the underlying writes.

| Function                | Type      | Purpose                                                                 | Authorization check inside function                          |
|-------------------------|-----------|-------------------------------------------------------------------------|--------------------------------------------------------------|
| `onEntryWrite`          | trigger   | Maintain aggregates; enqueue milestone announcements; idempotent        | None (trigger); idempotency via `_processed_events`          |
| `onAnnouncementCreate`  | trigger   | Fan out FCM push to topic `temple_main`; set `pushed: true`             | None (trigger)                                               |
| `onMemberWrite`         | trigger   | If member role changed to/from `admin`, update the custom claim         | None (trigger); only acts on diff of `role` field            |
| `redeemInvite`          | callable  | Validate invite code in transaction; create membership doc              | Signed-in caller                                             |
| `requestJoin`           | callable  | For `approval` join policy: create pending member doc                    | Signed-in caller                                             |
| `approveJoin`           | callable  | Flip pending member to active                                            | Caller must be `admin` or `coordinator`                      |
| `setMemberRole`         | callable  | Change role; updates `members/{uid}.role` and custom claim atomically; writes audit log | Caller must have `admin` claim                  |
| `cancelCampaign`        | callable  | Set campaign `status: "cancelled"`; writes audit log                     | Caller must have `admin` claim                               |
| `deleteAccount`         | callable  | Purge user data and anonymize membership                                 | `isSelf` (caller deletes only own account)                   |
| `seedAdmin` (script)    | one-shot  | Bootstrap first admin per deployment. Run from local machine with service-account key. | Not exposed as a function; standalone Node script. |

**Idempotency contract:** Every trigger function (`onEntryWrite`, `onAnnouncementCreate`, `onMemberWrite`) checks `_processed_events/{context.eventId}` inside a transaction and exits if the marker exists. This is required because Cloud Functions delivery is at-least-once.

## Threat model

| Risk                                              | Mitigation                                                                                |
|---------------------------------------------------|-------------------------------------------------------------------------------------------|
| User inflates `monthlyCounts` or `currentStreakDays` | Rule forbids client writes to function-maintained fields                               |
| User contributes to a campaign they shouldn't     | Entry create rule requires `isActiveMember()`; campaign rules require active membership   |
| User crafts an entry with extreme count           | Rule caps `count <= config/temple.maxEntryCount` (default 10,000)                         |
| User self-promotes to admin                       | `members.role` updates require `isAdmin()`; claim updates only from `setMemberRole` Function |
| Forged admin claim                                | Custom claims are signed by Firebase; only Admin SDK can set them via `setMemberRole`     |
| Replay of redeemed invite                         | `redeemInvite` runs in a transaction: read invite, verify `usedCount < maxUses` and `expiresAt > now`, write member doc + increment in same transaction |
| Bot-scripted account farms                        | App Check (reCAPTCHA v3 for web) enforced in production                                   |
| Double-counted entry due to retried trigger       | `_processed_events/{eventId}` marker inside transaction                                   |
| Admin loses their account                         | Project owner (you) can promote a new admin via `scripts/seed-admin.ts` with service-account key |

## Open questions

* **App Check enforcement.** Enable in production from day one. Risk: legitimate users on outdated browsers may fail reCAPTCHA. Mitigation: monitor App Check rejection rate in the Firebase console for first 2 weeks.
* **Member visibility of full roster.** Today: any active member can read `members/*`. If a temple wants to restrict this (e.g., only admins see the roster), it becomes a `config/temple.rosterVisibility` setting consumed by the rule. Defer unless a pilot temple asks.
* **Optional phone number visibility.** `users/{uid}.phoneNumber` is readable only by self and admin today. If temples want coordinators to do call-tree campaigns, expand to coordinator. Decide per temple via config.
