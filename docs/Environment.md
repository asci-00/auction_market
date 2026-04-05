# Auction Market Environment Contract

## Principles
- Commit example files only.
- Never commit real secrets.
- Backend secrets live in `backend/functions/.env`.
- Mobile public values live in `apps/mobile_flutter/dart_defines.json`.
- Mobile Firebase native registration must stay local-only:
  - committed examples:
    - `apps/mobile_flutter/ios/Runner/GoogleService-Info.example.plist`
    - `apps/mobile_flutter/android/app/google-services.example.json`
  - ignored real files:
    - `apps/mobile_flutter/ios/Runner/GoogleService-Info.plist`
    - `apps/mobile_flutter/android/app/google-services.json`
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
| `APP_ENV` | No | dev, staging, prod | `dev` | engineering | Functions runtime | Low. Affects logs and config branches. |
| `ENABLE_TOSS_SANDBOX` | No | dev sandbox only | `true` | engineering | Functions runtime | Medium. If omitted in emulator-backed `dev`, payment falls back to `DEV_DUMMY` instead of real Toss sandbox. |
| `TOSS_SECRET_KEY` | Yes | staging, prod | `test_sk_...` or `live_sk_...` | product ops | Functions runtime | Release blocker for payment confirm. |
| `TOSS_WEBHOOK_SECRET` | Yes | staging, prod | `whsec_...` | product ops | Functions runtime | Release blocker for webhook verification. |
| `TOSS_API_BASE_URL` | No | staging, prod | `https://api.tosspayments.com` | engineering | Functions runtime | Medium. Payment calls fail if wrong. |
| `APP_BASE_URL` | No | staging, prod, dev sandbox | `https://app.example.com` or `https://<public-tunnel>/auction-893cf/us-central1/tossPaymentBridge` | engineering | Functions runtime | High. Payment return routing and deep-link handoff fail. |
| `OPS_ALERT_EMAILS` | No | staging, prod | `ops@example.com,support@example.com` | ops | Functions runtime | Low. Alert fan-out is reduced. |

- Do not put reserved Firebase runtime keys such as `GCLOUD_PROJECT` or `FIREBASE_PROJECT_ID` in `backend/functions/.env`. The Firebase CLI injects them for emulator and deploy flows.
- The current dev Toss sandbox path uses `tossPaymentBridge` plus a public HTTPS tunnel URL in `APP_BASE_URL`. This keeps the app on emulator-backed data while allowing Toss redirect URLs to remain public and valid.
- Use `cd backend/functions && npm run tunnel:toss` to open a localhost.run tunnel and rewrite `APP_BASE_URL` automatically. Keep that terminal open during Toss sandbox tests.
- If `npm run serve` was already running before the tunnel URL changed, restart it once so the Functions emulator reloads the updated `APP_BASE_URL`.

## Mobile Public Build Defines
- Path: `apps/mobile_flutter/dart_defines.json`
- Example file: `apps/mobile_flutter/dart_defines.example.json`
- Run commands from `apps/mobile_flutter`.
- Load with `flutter run --dart-define-from-file=dart_defines.json`
- Android physical-device default: keep `FIREBASE_EMULATOR_HOST=127.0.0.1` and use `./scripts/setup_android_device_emulators.sh`.
- iOS physical-device example: `dart_defines.ios_device.example.json`

| Name | Secret | Required In | Example Format | Owner | Load Location | Missing Value Impact |
| --- | --- | --- | --- | --- | --- | --- |
| `APP_ENV` | No | dev, staging, prod | `dev` | engineering | Flutter app config | Low. Labels and config branches may be wrong. |
| `USE_FIREBASE_EMULATORS` | No | dev | `true` | engineering | Flutter app config | Medium. App may hit real services by mistake. |
| `FIREBASE_EMULATOR_HOST` | No | dev physical-device testing | `127.0.0.1` on Android with `adb reverse`, Mac LAN IP on iOS | engineering | Flutter app config | Medium. Physical devices cannot reach Mac localhost without either `adb reverse` or a LAN-reachable host. |
| `TOSS_CLIENT_KEY` | No | staging, prod | `test_ck_...` or `live_ck_...` | product ops | Flutter app config | Release blocker for payment start. |

## Mobile Firebase Native Config
- Committed iOS example: `apps/mobile_flutter/ios/Runner/GoogleService-Info.example.plist`
- Committed Android example: `apps/mobile_flutter/android/app/google-services.example.json`
- Local real iOS file: `apps/mobile_flutter/ios/Runner/GoogleService-Info.plist`
- Local real Android file: `apps/mobile_flutter/android/app/google-services.json`
- Provision the real files by downloading them from Firebase Console for the target app IDs.

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
- Functions must fail fast during startup when a required secret is missing in `staging` or `prod`.
- For Android physical-device Firebase Emulator runs, prefer `adb reverse` and keep `FIREBASE_EMULATOR_HOST=127.0.0.1`.
- For iOS physical-device Firebase Emulator runs, set `FIREBASE_EMULATOR_HOST` to the Mac's current LAN IP and keep emulator ports reachable only on the local network.

## Physical-Device Emulator Notes

- Android over USB:
  - Run `apps/mobile_flutter/scripts/setup_android_device_emulators.sh`.
  - Keep `FIREBASE_EMULATOR_HOST=127.0.0.1`.
  - This forwards device traffic to Mac localhost for ports `9099`, `8080`, `5001`, and `9199` without exposing emulator ports to the network.
- iOS over USB or Wi-Fi:
  - `adb reverse` is not available.
  - Use the Mac LAN IP in `FIREBASE_EMULATOR_HOST`.
  - Ensure each required emulator port is reachable from the device on the local network.
