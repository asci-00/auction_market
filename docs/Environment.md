# Auction Market Environment Contract

## Principles
- Commit example files only.
- Never commit real secrets.
- Backend secrets live in `backend/functions/.env`.
- Mobile public values live in flavor-specific `dart_defines.<flavor>.json` files.
- Mobile Firebase native registration must stay local-only:
  - committed examples:
    - `apps/mobile_flutter/ios/Runner/Firebase/dev/GoogleService-Info.example.plist`
    - `apps/mobile_flutter/ios/Runner/Firebase/prod/GoogleService-Info.example.plist`
    - `apps/mobile_flutter/android/app/src/dev/google-services.example.json`
    - `apps/mobile_flutter/android/app/src/prod/google-services.example.json`
  - ignored real files:
    - `apps/mobile_flutter/ios/Runner/Firebase/dev/GoogleService-Info.plist`
    - `apps/mobile_flutter/ios/Runner/Firebase/prod/GoogleService-Info.plist`
    - `apps/mobile_flutter/android/app/src/dev/google-services.json`
    - `apps/mobile_flutter/android/app/src/prod/google-services.json`
- Root `.env.example` is only a summary for local tooling and onboarding.

## Note

- Payment-provider cutover requirements are tracked only in `Plan.md` under `Phase Undecided`.
- Push-delivery prerequisites and category rules are tracked in `docs/Notification.md`.
- This document keeps the current runtime load paths and active scaffold variable names only because they match the codebase today.
- If the final PG provider changes, rename provider-specific variables only when the deferred cutover work in `Plan.md` is activated.

## Root Summary File
- Path: `.env.example`
- Purpose: local inventory of project IDs, emulator hosts, and file locations.
- Real secret values do not belong here.

## Backend Runtime Env
- Path: `backend/functions/.env`
- Example file: `backend/functions/.env.example`

| Name | Secret | Required In | Example Format | Owner | Load Location | Missing Value Impact |
| --- | --- | --- | --- | --- | --- | --- |
| `APP_ENV` | No | dev, prod | `dev` | engineering | Functions runtime | Low. Affects logs and config branches. |
| `ENABLE_TOSS_SANDBOX` | No | dev sandbox only | `true` | engineering | Functions runtime | Medium. If omitted in `dev`, payment may stay on `DEV_DUMMY` instead of Toss sandbox. |
| `TOSS_SECRET_KEY` | Yes | prod, dev Toss sandbox | `test_sk_...` or `live_sk_...` | product ops | Functions runtime | Release blocker for payment confirm. |
| `TOSS_WEBHOOK_SECRET` | Yes | prod, dev Toss sandbox | `whsec_...` | product ops | Functions runtime | Release blocker for webhook verification. |
| `TOSS_API_BASE_URL` | No | dev, prod | `https://api.tosspayments.com` | engineering | Functions runtime | Medium. Payment calls fail if wrong. |
| `APP_BASE_URL` | No | dev, prod | `https://auction-market-dev-api.onrender.com` | engineering | Functions runtime | High. Payment return routing and deep-link handoff fail. |
| `OPS_ALERT_EMAILS` | No | prod | `ops@example.com,support@example.com` | ops | Functions runtime | Low. Alert fan-out is reduced. |

- Do not put reserved Firebase runtime keys such as `GCLOUD_PROJECT` or `FIREBASE_PROJECT_ID` in `backend/functions/.env`. The Firebase CLI injects them for emulator and deploy flows.
- The preferred dev path now uses a real Firebase dev project plus a public Render URL in `APP_BASE_URL`.
- The older emulator + public tunnel path remains optional for local-only debugging, but it is no longer the primary mobile physical-device contract.

## Mobile Public Build Defines
- Paths:
  - `apps/mobile_flutter/dart_defines.dev.json`
  - `apps/mobile_flutter/dart_defines.prod.json`
- Example files:
  - `apps/mobile_flutter/dart_defines.dev.example.json`
  - `apps/mobile_flutter/dart_defines.prod.example.json`
- Run commands from `apps/mobile_flutter`.
- Load dev with `flutter run --flavor dev --dart-define-from-file=dart_defines.dev.json`
- Load prod with `flutter run --flavor prod --dart-define-from-file=dart_defines.prod.json`

| Name | Secret | Required In | Example Format | Owner | Load Location | Missing Value Impact |
| --- | --- | --- | --- | --- | --- | --- |
| `APP_ENV` | No | dev, prod | `dev` | engineering | Flutter app config | Low. Labels and config branches may be wrong. |
| `APP_BACKEND_TRANSPORT` | No | dev, prod | `http` or `firebase_callable` | engineering | Flutter app config | High. Mobile mutation transport will be wrong. |
| `APP_API_BASE_URL` | No | dev HTTP transport | `https://auction-market-dev-api.onrender.com` | engineering | Flutter app config | High. HTTP backend cannot be reached. |
| `USE_FIREBASE_EMULATORS` | No | optional local override | `false` | engineering | Flutter app config | Medium. App may hit emulator or real services unexpectedly. |
| `FIREBASE_EMULATOR_HOST` | No | optional local override | `127.0.0.1` or a LAN IP | engineering | Flutter app config | Medium. Emulator path breaks on physical devices if wrong. |
| `TOSS_CLIENT_KEY` | No | dev, prod | `test_ck_...` or `live_ck_...` | product ops | Flutter app config | Release blocker for real payment start. |

## Mobile Firebase Native Config
- Committed iOS examples:
  - `apps/mobile_flutter/ios/Runner/Firebase/dev/GoogleService-Info.example.plist`
  - `apps/mobile_flutter/ios/Runner/Firebase/prod/GoogleService-Info.example.plist`
- Committed Android examples:
  - `apps/mobile_flutter/android/app/src/dev/google-services.example.json`
  - `apps/mobile_flutter/android/app/src/prod/google-services.example.json`
- Local real iOS files:
  - `apps/mobile_flutter/ios/Runner/Firebase/dev/GoogleService-Info.plist`
  - `apps/mobile_flutter/ios/Runner/Firebase/prod/GoogleService-Info.plist`
- Local real Android files:
  - `apps/mobile_flutter/android/app/src/dev/google-services.json`
  - `apps/mobile_flutter/android/app/src/prod/google-services.json`
- Provision the real files by downloading them from Firebase Console for the matching dev/prod Firebase projects.

| Value | Source Key | Where It Comes From | Current Local Value |
| --- | --- | --- | --- |
| Firebase project ID | `PROJECT_ID` / `project_info.project_id` | downloaded iOS plist or Android json | local-only |
| Firebase iOS app ID | `GOOGLE_APP_ID` | `GoogleService-Info.plist` | local-only |
| Firebase Android app ID | `client[0].client_info.mobilesdk_app_id` | `google-services.json` | local-only |
| Firebase sender ID | `GCM_SENDER_ID` / `project_info.project_number` | downloaded iOS plist or Android json | local-only |
| Firebase storage bucket | `STORAGE_BUCKET` / `project_info.storage_bucket` | downloaded iOS plist or Android json | local-only |
| Firebase API key | `API_KEY` / `client[0].api_key[0].current_key` | platform app config files | local-only |

## Loading Rules
- Never read backend secrets in Flutter.
- Never read mobile public config from server env.
- The app must fail early with a readable startup error when a required public define such as `APP_ENV` is missing.
- The app must reject placeholder `TODO_...` public values for fields it still reads from `dart-define`.
- On iOS and Android, Firebase app registration is loaded from local native config files rather than `dart-define` values.
- The real native Firebase config files must remain gitignored; commit only the example files.
- Functions must fail fast during startup when a required secret is missing in `prod` or in a `dev` Toss sandbox path that needs it.
- iOS chooses the correct Firebase plist from `Runner/Firebase/<flavor>/GoogleService-Info.plist` at build time through Xcode build configuration.
- Android chooses the correct `google-services.json` from `android/app/src/<flavor>/`.
- For Android physical-device Firebase Emulator runs, prefer `adb reverse` and keep `FIREBASE_EMULATOR_HOST=127.0.0.1`.
- For iOS physical-device Firebase Emulator runs, set `FIREBASE_EMULATOR_HOST` to the Mac's current LAN IP and keep emulator ports reachable only on the local network.

## Render Dev Server Runtime
- Path: `backend/render-dev-server`
- Primary purpose: expose a stable public dev URL for physical-device testing and payment redirect pages.
- Required env:
  - `APP_ENV=dev`
  - `APP_BASE_URL=https://<render-service>.onrender.com`
  - `FIREBASE_PROJECT_ID=<firebase-dev-project-id>`
  - `FIREBASE_SERVICE_ACCOUNT_JSON=<single-line service account json>`
  - `TOSS_SECRET_KEY=<optional for Toss sandbox confirm>`
  - `TOSS_WEBHOOK_SECRET=<optional for Toss webhook verify>`
  - `TOSS_API_BASE_URL=https://api.tosspayments.com`
  - `ENABLE_TOSS_SANDBOX=false|true`
- Render now talks to Firebase Auth and Firestore directly through Firebase Admin. It no longer requires deployed Firebase Functions just to support the dev HTTP transport.
- Prod still defaults to Firebase callable transport. Dev continues to use the Render HTTP path.

## Current Dev Quick Start
- Public dev backend URL:
  - `https://auction-market-dev-api.onrender.com`
- Public health check:
  - `https://auction-market-dev-api.onrender.com/healthz`
- Mobile local setup:
  1. Put the local dev Firebase files in:
     - `apps/mobile_flutter/android/app/src/dev/google-services.json`
     - `apps/mobile_flutter/ios/Runner/Firebase/dev/GoogleService-Info.plist`
  2. Create `apps/mobile_flutter/dart_defines.dev.json` from the example or run:
     - `apps/mobile_flutter/scripts/bootstrap_render_dev.sh`
  3. Launch the app:
     - `cd apps/mobile_flutter && flutter run --flavor dev --dart-define-from-file=dart_defines.dev.json`
- Current default dev `dart-define` values:
  - `APP_ENV=dev`
  - `APP_BACKEND_TRANSPORT=http`
  - `APP_API_BASE_URL=https://auction-market-dev-api.onrender.com`
  - `USE_FIREBASE_EMULATORS=false`

## Physical-Device Emulator Notes

- Android over USB:
  - Run `apps/mobile_flutter/scripts/setup_android_device_emulators.sh`.
  - Keep `FIREBASE_EMULATOR_HOST=127.0.0.1`.
  - This forwards device traffic to Mac localhost for ports `9099`, `8080`, `5001`, and `9199` without exposing emulator ports to the network.
- iOS over USB or Wi-Fi:
  - `adb reverse` is not available.
  - Use the Mac LAN IP in `FIREBASE_EMULATOR_HOST`.
  - Ensure each required emulator port is reachable from the device on the local network.
