# Testing strategy

## Automated (run `flutter test`)
| File | Covers |
|---|---|
| test/auth_validation_test.dart | ALU-only email validation (accepts both ALU domains, rejects look-alike domains) |
| test/incident_provider_test.dart | Search, category/status filters, "my reports", summary counts, lookup by id |
| test/incident_model_test.dart | Status step order, status timestamps, anonymous name not stored |
| test/widget_test.dart | StatusChip and StatusTimeline widgets render correctly |

## Manual end-to-end checklist (use on emulator; record these in the demo)
| # | Scenario | Expected |
|---|---|---|
| 1 | Register with a gmail address | Rejected in the form |
| 2 | Register with ALU email | Verification email sent; "Verify your ALU email" screen shown |
| 3 | Tap "I've verified" before clicking the link | Stays on verify screen |
| 4 | Click link, tap "I've verified" | Home screen appears |
| 5 | Log out and log in | Session restored on app restart |
| 6 | Submit report with empty fields | Validation messages shown |
| 7 | Submit report with photo | Appears in list; photo visible in detail and in the Cloudinary Media Library (folder `incidents`) |
| 8 | Submit report anonymously | Other student sees "Anonymous"; Firestore doc has reporterName = Anonymous |
| 9 | Search / filter by status and category | List updates immediately |
| 10 | Student opens a report: no status controls | Staff controls hidden |
| 11 | Staff changes status to In Progress | Timeline updates; student's screen updates live |
| 12 | Student tries to change status via Firestore (rules simulator) | Denied |
| 13 | Student deletes own Submitted report | Deleted; cannot delete once In Progress |
| 14 | Airplane mode when loading | Error message with Retry button |
