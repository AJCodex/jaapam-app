# Jain Temple Community Jaap App — RFP Style Feature Specification

## Document purpose
This document summarizes the proposed product in a Request for Proposal style so the scope, feature set, roles, technical expectations, and delivery boundaries are clear before design and development begin. The product is a multi-community devotional platform where each Jain temple operates as its own private or moderated community within one shared application.[1][2][3][4]

## Project summary
The proposed application will provide Jain temples with a digital platform to run community jaap campaigns, allow devotees to record personal and temple-linked jaap counts, and give temple administrators tools to manage members, campaigns, progress tracking, and communication. The solution should support a website-first experience with lightweight Android and iOS apps derived from the same core web application, which aligns well with a low-maintenance rollout model.[3][4]

## Business objective
The primary objective is to help each Jain temple organize, track, and grow devotional participation through structured community campaigns such as monthly jaap sankalp goals. The platform should also support personal discipline by letting each member define individual monthly targets while contributing toward temple-level collective goals.[1]

## Scope of work
The selected solution should include the following scope:

- A multi-temple application where each temple community is logically separated.
- Member onboarding with Google sign-in and invite-based joining.
- Personal jaap target tracking.
- Temple campaign creation and live progress monitoring.
- Temple admin tools for moderation and reporting.
- Basic communication features such as announcements and reminders.
- Responsive web application suitable for Android and iOS packaging.

The system should be designed using a shared backend with logical tenant isolation, which is a practical Firebase-compatible approach for multi-community applications.[3][4]

## Target users
The platform is expected to serve the following user groups:

| User type | Description |
|---|---|
| Devotee member | Joins a temple, logs daily jaap, tracks personal and temple progress. |
| Temple admin | Manages temple profile, members, campaigns, and reports. |
| Volunteer coordinator | Assists admins with campaign operations and communications. |
| Platform super admin | Oversees all temple communities and global platform controls. |

Temple-centered community software commonly relies on member management, communication, event or campaign coordination, and role-based administration, which supports this user model.[5][1][6]

## Functional requirements
### 1. Community and temple management
The application shall support creation of multiple temple communities within one platform. Each temple shall maintain its own identity, including temple name, location, description, active campaigns, member roster, and designated administrators.[1][2][4]

The system shall support temple-specific access so members only interact with data belonging to communities they have joined. A user may belong to one or more temple communities only if such multi-membership is allowed by business rules defined during implementation.[3][4]

### 2. Authentication and onboarding
The system shall support Google sign-in through Firebase Authentication for low-friction onboarding. Members shall be able to join a temple using an invite link, invite code, QR code, or admin approval workflow depending on the temple’s joining policy.[7][3]

### 3. Personal jaap tracking
Each member shall be able to set a monthly personal jaap target and log daily jaap counts. The system shall show personal total, target achievement percentage, streak, and recent entry history for the active month.

### 4. Temple campaign management
Temple admins shall be able to create campaign records with campaign title, spiritual reason, target count, start date, end date, and status. Members shall be able to contribute their daily jaap entries toward active temple campaigns where applicable.

### 5. Shared progress tracking
The application shall maintain live or near-real-time counters for campaign totals, remaining target, progress percentage, and daily pace required to achieve the target by the campaign end date. Aggregate values should be stored in optimized summary records rather than recalculated from all raw entries on every screen load to stay efficient on Firebase quotas.[3][4]

### 6. Communication and engagement
Temple admins should be able to publish announcements related to campaigns, milestones, and reminders. The platform should support milestone notifications such as 25 percent, 50 percent, 75 percent, and 100 percent completion to encourage participation.

### 7. Administration and reporting
Temple admins shall be able to review member activity summaries, view suspicious contribution spikes, export campaign summaries, and monitor overall campaign health. Platform super admins shall be able to manage temple approval, support requests, and platform-wide policy settings.

## Non-functional requirements
The proposed solution should meet the following non-functional requirements:

- Lightweight mobile-first user experience.
- Shared codebase for web, Android, and iOS where feasible.
- Secure role-based access to temple and member data.
- Scalable multi-community architecture.
- Efficient data reads and writes to remain cost-effective on Firebase.
- Simple onboarding for non-technical users.
- Auditability for corrections or unusual contribution edits.

## Suggested technical architecture
The preferred architecture is a website-first application with optional Android and iOS packaging using the same frontend. A shared Firebase backend with Firestore, Authentication, and Hosting is suitable for an MVP if the data model uses logical separation by temple and aggregate summary documents for dashboards.[3][4]

| Layer | Preferred option | Notes |
|---|---|---|
| Frontend | React or Next.js PWA | One codebase for web and mobile wrapper deployment. |
| Mobile apps | Capacitor or equivalent wrapper | Suitable when the web app is the core product. |
| Auth | Firebase Authentication with Google Sign-In | Low-friction onboarding. |
| Database | Cloud Firestore | Good fit for hierarchical temple and member data. |
| Hosting | Firebase Hosting | Suitable for lightweight web deployment. |
| Notifications | Firebase Cloud Messaging | Useful for reminders and milestones. |

## Suggested logical data model
A vendor proposal should account for at least the following logical entities:

- Temple
- TempleMember
- TempleRole
- Campaign
- CampaignDailyTotal
- Announcement
- UserProfile
- PersonalGoal
- JaapEntry
- AuditLog

A representative Firestore-style structure may include the following paths:

- `temples/{templeId}`
- `temples/{templeId}/members/{userId}`
- `temples/{templeId}/campaigns/{campaignId}`
- `temples/{templeId}/campaign_daily_totals/{date}`
- `temples/{templeId}/announcements/{announcementId}`
- `users/{userId}`
- `users/{userId}/personal_goals/{month}`
- `users/{userId}/entries/{entryId}`

## User roles and permissions
| Role | Key permissions |
|---|---|
| Platform super admin | Approve temples, manage support, define platform rules, access cross-temple analytics. |
| Temple admin | Manage temple settings, create campaigns, approve members, publish announcements, view reports. |
| Volunteer coordinator | Support campaign operations and limited member engagement tasks. |
| Member | Join temple, set personal goals, submit jaap entries, view own and temple progress. |

## Example user journeys
### Member journey
1. User signs in with Google.
2. User joins a temple via invite link or QR code.
3. User sets personal monthly target.
4. User logs daily jaap count.
5. User optionally allocates the entry to an active temple campaign.
6. User sees updated personal and temple progress.

### Temple admin journey
1. Admin creates or configures temple profile.
2. Admin invites members.
3. Admin launches monthly campaign with target and reason.
4. Admin monitors daily progress and member participation.
5. Admin publishes reminders or milestone announcements.
6. Admin exports summary at campaign completion.

## MVP deliverables
The minimum viable product should include:

- Google-based sign-in.
- Temple creation and temple join flow.
- One active campaign per temple.
- Personal monthly target management.
- Daily jaap entry logging.
- Temple and personal dashboards.
- Temple admin console.
- Invite link or QR code onboarding.
- Basic notifications and announcements.

## Optional future enhancements
Future phases may include:

- Multiple simultaneous campaigns per temple.
- Regional or national grouping of temples.
- Festival-specific campaigns such as Paryushan drives.
- Family-level or group-level participation views.
- Donation or seva modules.
- WhatsApp reminder integration.
- Analytics dashboards for temple trustees.

## Vendor response expectations
A vendor response should clearly specify:

- Proposed architecture and hosting model.
- Data isolation strategy for temple communities.
- Authentication and access-control design.
- Mobile deployment approach.
- Estimated Firebase usage and free-tier viability assumptions.
- Security, backup, and audit strategy.
- Delivery timeline by phase.
- Support and maintenance model.

## Acceptance criteria
The solution will be considered aligned with the requested specification if:

- Multiple Jain temples can operate independently within one platform.
- Members can log personal jaap and contribute to temple campaigns.
- Temple admins can manage campaigns and member participation.
- Temple data is logically separated and access-controlled.
- The application runs well as a responsive web app and can be packaged for mobile use.
- Core workflows remain simple enough for non-technical community members.