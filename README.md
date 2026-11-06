# Campus Incident Reporting App (Flutter + Firebase)

Students report campus issues (facilities, water, electricity, furniture, safety, sanitation) with optional photos.
ALU staff review reports and move them from Submitted -> In Progress -> Resolved.

## Stack
Flutter, Provider (state management), Firebase Auth, Cloud Firestore, Cloudinary (photo storage).

## Architecture
`models/` data classes -> `services/` Firebase access -> `providers/` state (ChangeNotifier) -> `screens/` + `widgets/` UI.
`AuthProvider` owns session + role. `IncidentProvider` listens to a Firestore stream (bound to the signed-in user through
a ChangeNotifierProxyProvider), so Home, Reports, Profile and Detail screens all update in real time.

## Setup
1. `flutter create .`  (generates android/ios; keeps lib/, test/ and pubspec.yaml)
2. Create a Firebase project; enable Email/Password auth and Firestore. Create a free Cloudinary account, add an **Unsigned** upload preset, and put the cloud name and preset name in `lib/services/cloudinary_service.dart`.
3. `dart pub global activate flutterfire_cli` then `flutterfire configure` (creates lib/firebase_options.dart)
4. Publish `firebase/firestore.rules` in the Console (`firebase/storage.rules` is not used, since photos are stored on Cloudinary).
5. Android: set `minSdkVersion` to 23+ in android/app/build.gradle; iOS: add camera/photo usage strings to Info.plist.
6. `flutter pub get && flutter run`
7. `flutter test`

## Roles and test accounts (for graders)
Role is decided by the ALU email domain at registration:
- `@alustudent.com` -> **student** (submits and tracks reports)
- `@alueducation.com` -> **staff** (reviews reports and updates status)

Register in the app, open the verification link sent to that email, tap "I've verified". Both domains are enforced in the app AND in the Firestore rules, so a student address can never create a staff profile.
A role can also be changed by an administrator in the Firebase Console (`users/{uid}.role`), then log out and in.

## Access control
- Student: submit, browse, search, filter, delete own report while status is Submitted.
- Staff: update status/notes on any report, delete any report, look up anonymous reporters.
- Enforced in the UI AND in Firestore rules (verified ALU email required; staff updates limited to status fields).

## Data model
users/{uid}: name, email, role, createdAt
incidents/{id}: title, description, category, location, status, statusHistory[{status, at}], photoUrl, reporterId,
reporterName ("Anonymous" if anonymous), anonymous, staffNote, createdAt, updatedAt
Photos: uploaded to Cloudinary (folder `incidents`); `photoUrl` holds the returned HTTPS URL.
Known limitation: unsigned uploads cannot be deleted from the app, so deleting a report leaves its image in Cloudinary.
