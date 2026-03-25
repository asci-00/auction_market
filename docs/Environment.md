# Auction Market Environment Contract

## Principles
- Commit example files only.
- Never commit real secrets.
- Backend secrets live in `backend/functions/.env`.
- Mobile public values live in `apps/mobile_flutter/dart_defines.json`.
- Mobile Firebase platform registration lives in native files:
  - `apps/mobile_flutter/ios/Runner/GoogleService-Info.plist`
  - `apps/mobile_flutter/android/app/google-services.json`
- Root `.env.example` is only a summary for local tooling and onboarding.

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
| `GCLOUD_PROJECT` | No | dev, staging, prod | `auction-market-staging` | engineering | Functions runtime | High. Firebase Admin will point to the wrong project. |
| `FIREBASE_PROJECT_ID` | No | dev, staging, prod | `auction-market-staging` | engineering | Functions runtime | High. Emulator scripts and admin setup become inconsistent. |
| `TOSS_SECRET_KEY` | Yes | staging, prod | `test_sk_...` or `live_sk_...` | product ops | Functions runtime | Release blocker for payment confirm. |
| `TOSS_WEBHOOK_SECRET` | Yes | staging, prod | `whsec_...` | product ops | Functions runtime | Release blocker for webhook verification. |
| `TOSS_API_BASE_URL` | No | staging, prod | `https://api.tosspayments.com` | engineering | Functions runtime | Medium. Payment calls fail if wrong. |
| `APP_BASE_URL` | No | staging, prod | `https://app.example.com` | engineering | Functions runtime | High. Payment return routing and deep-link handoff fail. |
| `OPS_ALERT_EMAILS` | No | staging, prod | `ops@example.com,support@example.com` | ops | Functions runtime | Low. Alert fan-out is reduced. |

## Mobile Public Build Defines
- Path: `apps/mobile_flutter/dart_defines.json`
- Example file: `apps/mobile_flutter/dart_defines.example.json`
- Load with `flutter run --dart-define-from-file=dart_defines.json`

| Name | Secret | Required In | Example Format | Owner | Load Location | Missing Value Impact |
| --- | --- | --- | --- | --- | --- | --- |
| `APP_ENV` | No | dev, staging, prod | `dev` | engineering | Flutter app config | Low. Labels and config branches may be wrong. |
| `USE_FIREBASE_EMULATORS` | No | dev | `true` | engineering | Flutter app config | Medium. App may hit real services by mistake. |
| `TOSS_CLIENT_KEY` | No | staging, prod | `test_ck_...` or `live_ck_...` | product ops | Flutter app config | Release blocker for payment start. |

## Mobile Firebase Native Config
- iOS source: `apps/mobile_flutter/ios/Runner/GoogleService-Info.plist`
- Android source: `apps/mobile_flutter/android/app/google-services.json`

| Value | Source Key | Where It Comes From | Current Local Value |
| --- | --- | --- | --- |
| Firebase project ID | `PROJECT_ID` / `project_info.project_id` | downloaded iOS plist or Android json | `auction-893cf` |
| Firebase iOS app ID | `GOOGLE_APP_ID` | `GoogleService-Info.plist` | `1:918877996410:ios:01977f2a50303e364302c3` |
| Firebase Android app ID | `client[0].client_info.mobilesdk_app_id` | `google-services.json` | `1:918877996410:android:97d00863c1cf22dc4302c3` |
| Firebase sender ID | `GCM_SENDER_ID` / `project_info.project_number` | downloaded iOS plist or Android json | `918877996410` |
| Firebase storage bucket | `STORAGE_BUCKET` / `project_info.storage_bucket` | downloaded iOS plist or Android json | `auction-893cf.firebasestorage.app` |
| Firebase API key | `API_KEY` / `client[0].api_key[0].current_key` | platform app config files | iOS: `AIzaSyBibwoRhELTNV-S8adq2YCVaQrE_CTfa5o`, Android: `AIzaSyBoiR18QZBPTAtPmbJaIJerhuuecuD8Gb8` |

## TODO Inventory
- `TOSS_SECRET_KEY`
  - Source system: TossPayments dashboard.
  - Why TODO exists: real secret is not stored in this repo.
  - Missing value impact: release blocker for staging and prod payment flow.
- `TOSS_WEBHOOK_SECRET`
  - Source system: TossPayments webhook settings.
  - Why TODO exists: real secret is not stored in this repo.
  - Missing value impact: release blocker for staging and prod webhook verification.
- `TOSS_CLIENT_KEY`
  - Source system: TossPayments dashboard.
  - Why TODO exists: public client key is not stored in this repo.
  - Missing value impact: release blocker for staging and prod payment start.
- `APP_BASE_URL`
  - Source system: deployment and mobile deep-link setup.
  - Why TODO exists: final public domain is not stored in this repo.
  - Missing value impact: release blocker for payment return routing in staging and prod.

## Loading Rules
- Never read backend secrets in Flutter.
- Never read mobile public config from server env.
- The app must fail early with a readable startup error when a required public define such as `APP_ENV` is missing.
- The app must reject placeholder `TODO_...` public values for fields it still reads from `dart-define`.
- On iOS and Android, Firebase app registration is loaded from native config files rather than `dart-define` values.
- Functions must fail fast during startup when a required secret is missing in `staging` or `prod`.

## Phase 3 Cutover Reminder
- The last unfinished Phase 3 task is the real Toss launcher cutover.
- That cutover must not begin until all four real values are present:
  - `TOSS_CLIENT_KEY`
  - `TOSS_SECRET_KEY`
  - `TOSS_WEBHOOK_SECRET`
  - `APP_BASE_URL`
- Until then, `dev` remains the validation source of truth through the server-driven dummy payment path and payment return routes.
