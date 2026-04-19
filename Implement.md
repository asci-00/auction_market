# Auction Market Execution Log

## Current Task
- Phase 4 settings and notification foundation is active.
- The current slice now includes the real Firebase dev project split, Render dev server deployment, dev/prod mobile flavor separation, structured mobile logging, backend gateway split, device-token lifecycle, backend Firebase Admin Messaging fan-out for the inbox-backed product events that already exist, and mobile push presentation plus tap-routing foundation.
- Android physical-device dev builds now default to real Firebase dev + Render HTTP instead of local emulator networking.
- A debug-only push probe trigger now exists in both backend transports: callable `sendDebugPushProbe` and Render `POST /api/notifications/debug/push-probe`, both guarded by `APP_ENV=dev` and aligned to current push eligibility rules.
- Real push delivery is still incomplete: token registration, backend dispatch, Android channel wiring, foreground surfaced messages, and push tap routing now exist, but the remaining unsupported push-event gaps and final real-device verification are still open.

## Locked Decisions
- All developer-facing docs use plain English.
- App UI supports Korean and English. The app follows the device locale, and there is no in-app language override.
- Payment integration stays adapter-based until the user explicitly activates the deferred cutover work in `Plan.md`.
- Apple sign in and Google sign in are the only login providers for v1.
- Emulator seed is the default dummy data path. Dependency-blocked integrations may use server-driven dummy responses only in `dev`.
- Shared blocking loading states use `apps/mobile_flutter/assets/lotties/loading.lottie`.
- Push delivery and inbox alignment must follow `docs/Notification.md` once Phase 4 starts.
- Secrets never live in repo files. Only example files are committed.

## Open Blockers
- Real payment-provider webhook secret is still not configured in this repo.
- Final real-device push delivery still needs real-device token availability on the target runtime plus end-to-end verification of foreground, background, and terminated notification paths.
- iOS real-device push remains blocked on Apple APNs auth setup in the Firebase dev project.
- Android can already use the real Firebase dev project and the public Render dev backend, but final product push verification still depends on a runtime that can return a real FCM token.

## Validation Status
- The public dev backend is live at `https://auction-market-dev-api.onrender.com`, and `https://auction-market-dev-api.onrender.com/healthz` returns runtime metadata for the dev Firebase project.
- Dev Firebase project split is in place for Android and iOS local native config files, and Render now uses Firebase Admin directly instead of deployed Firebase Functions.
- Mobile dev builds now read `APP_ENV`, `APP_BACKEND_TRANSPORT`, `APP_API_BASE_URL`, emulator mode, and `TOSS_CLIENT_KEY` from flavor-specific define files.
- Android and iOS flavors plus native config selection are wired as:
  - Android: `dev` and `prod`
  - iOS: `dev` and `prod` schemes with `Debug-dev`/`Release-dev`/`Profile-dev` and `Debug-prod`/`Release-prod`/`Profile-prod`
- The mobile backend gateway now keeps prod on Firebase callable and dev on Render HTTP without changing feature-level mutation contracts.
- Structured mobile logging now flows through `AppLogger`, with timestamp, level, domain, and source.
- Mobile foundation folders, guarded routing, Firebase bootstrap, localized core screens, and shared editorial design primitives exist.
- Firestore read paths and Functions write paths cover login, browse, auction detail, sell, orders, notifications, and activity flows.
- Phase 3 polish already includes dark-theme groundwork, shared loading overlays, keyboard-safe modal handling, Hero-enabled auction continuity, and localized empty or error states.
- The sell route now surfaces visible step progress and draft-save status, so category/details/pricing/images/publish readiness and unsaved-draft state are legible before save or publish.
- The sell route now renders field-level validation errors inline and a localized summary near the submit actions, so sellers do not have to infer correction targets from one snackbar line.
- Phase 3 quiet states now expose only concrete recovery actions that the current architecture can honor, such as sign-in return paths and browse recovery, instead of generic retry affordances on cached Firestore reads.
- Search filter chips now affect live result filtering for category, price band, ending-soon urgency, and buy-now availability instead of remaining decorative UI.
- The search route now keeps the query field pinned while results scroll, so users can refine live search results without losing the primary input control.
- The search route now lets users switch between large auction cards and a compact list, so discovery can adapt to browsing or scanning without changing the underlying query and filter logic.
- The home route now fills the design-contract gap for curated category rows by deriving separate goods and precious rails from the live auctions it already reads, without adding new backend query contracts.
- Notification inbox rows now show a destination hint derived from each deeplink, so title, body, time, and next destination are all visible before the user taps through.
- Auction detail fast actions now expose action-specific pending copy in the sticky action bar, so bid, auto-bid, and buy-now no longer collapse into one generic disabled state while the callable is in flight.
- Remaining sell empty-state copy no longer exposes `Firestore` in release-facing UI, so the drafts panel stays aligned with the product-copy contract.
- Auction detail now reads the linked item document so the top of the screen can show a true image gallery plus product description and item metadata instead of a single auction snapshot image.
- Auction detail now joins auction and item streams through a dedicated binding helper instead of `asyncExpand`, so live auction changes keep propagating after item subscription starts.
- Auction detail gallery state now clamps safely when the image list shrinks, and dedicated widget and data tests cover both the stream join behavior and the gallery index reset path.
- Auction detail now also exposes a dedicated presentation-level scaffold widget with tests for live buyer, seller-owned, and missing-document states, so the close review covers route composition as well as lower-level stream and gallery behavior.
- The pinned search header was revalidated after the latest query-sync fixes and now keeps raw input, clear affordance, and trimmed execution query aligned while remaining tappable below the app bar.
- Phase 4 now has its first settings foundation slice: `/settings` exists, the app bar and My screen can open it, signed-in users see notification preference toggles backed by `users/{uid}.preferences`, and signed-out users are redirected back through `/login?from=/settings`.
- Settings now falls back to an in-app default preference model when `users/{uid}` exists without a `preferences` payload yet, so notification controls can still render before a full profile bootstrap is complete.
- The settings screen now shows current OS notification permission state, a request-permission or open-system-settings recovery action when applicable, app version, open-source licenses, and debug-only environment info.
- The debug-only developer settings area now includes a compact push-probe action that calls `sendDebugPushProbe` through the backend gateway abstraction, so dev HTTP and callable modes keep one feature-level trigger path for signed-in tester diagnostics.
- The second Phase 4 settings slice now applies a local `SharedPreferences` theme preference to `MaterialApp`, and `/settings` now exposes a compact theme preview selector instead of a verbose radio list.
- The settings screen now includes a dedicated language behavior confirmation section that states locale follows the system setting, surfaces the current effective app language, and explicitly documents the supported `ko` or `en` set with `ko` fallback.
- Signed-in routes no longer expose a global locale picker in the shared app bar, and the signed-out login surface also no longer carries a manual locale menu; the app now follows the device locale only.
- Login now hard-gates dev quick-login panels behind non-release mode, so seeded-account shortcuts cannot render in release builds even when `APP_ENV=dev` and emulator flags are present.
- Mobile logging policy now treats release mode as production-safe regardless of `APP_ENV`, forcing info-level minimum logging plus redaction in release builds, and push-service fallback `debugPrint` logging now stays disabled in release mode.
- Mobile now calls `registerDeviceToken` after permission grant and token refresh, calls `deactivateDeviceToken` before sign-out or when push is disabled, and re-syncs permission plus token state when the app resumes.
- Android notification permission declaration is present, and the app can request permission plus register or deactivate FCM tokens against the dev backend.
- Backend now writes inbox documents with `category`, `entityType`, and `entityId`, then best-effort fans out Firebase Admin Messaging payloads for `OUTBID`, `AUTO_BID_CEILING_REACHED`, `WON`, `BUY_NOW_COMPLETED`, `ORDER_AWAITING_PAYMENT`, `PAYMENT_COMPLETED`, `PAYMENT_FAILED`, `SHIPPED`, `RECEIPT_CONFIRMED`, and `SETTLED` when user preferences and active device tokens allow delivery.
- Backend now also emits `PAYMENT_DUE`, `SHIPMENT_REMINDER`, and `RECEIPT_REMINDER` from an order reminder scheduler, with deterministic inbox ids per order reminder type to prevent repeated scheduler duplicates.
- Render dev server now resolves currently emitted inbox-backed notification copy through centralized `ko`/`en` templates, with locale priority `users/{uid}.preferences.languageCode` then active device-token locale metadata then `ko` fallback.
- Backend Functions inbox and push copy for all supported notification event types now resolve from a centralized `ko`/`en` localization engine, with locale priority `users/{uid}.preferences.languageCode` then latest deliverable token locale then `ko` fallback.
- Mobile now handles push payloads through `onMessage`, `getInitialMessage`, and `onMessageOpenedApp`, surfaces foreground messages with a `SnackBar`, routes opened notifications through the existing deep-link resolver, and falls back to `/notifications` when a push deeplink is missing or unsupported.
- Foreground push handling now also refreshes route state when the currently visible route already matches the pushed entity path, covering `/auction/:id`, `/orders`, `/orders/:orderId`, and `/notifications` without waiting for tap-open navigation.
- Android now declares a default Firebase Messaging channel id in the manifest and creates the matching notification channel from `MainActivity` on Android O and above.
- Emulator seed data now covers separate buyer and seller notification, payment, shipment, confirmed-receipt, settled, cancelled-unpaid, draft, unsold, and cancelled-listing paths without cross-linking orders to unrelated auctions.
- Backend callables cover bootstrap, draft lifecycle, bid and auto-bid, buy now, payment-session preparation, payment confirmation, shipment update, receipt confirmation, and notification read state.
- The backend now exposes `tossPaymentBridge` so emulator-backed `dev` can return a real Toss sandbox `checkoutUrl`, `successUrl`, and `failUrl` when `ENABLE_TOSS_SANDBOX=true`.
- The mobile app now launches Toss checkout through the returned bridge URL, registers `app://` deep-link return handling on Android and iOS, and keeps manual payment-key recovery only as the fallback path.
- `cd backend/functions && npm run tunnel:toss` now opens the public localhost.run bridge tunnel and rewrites `backend/functions/.env` so repeated sandbox tests do not require manual `APP_BASE_URL` edits.
- The bridge now keeps `successUrl` and `failUrl` query-free and relies on Toss redirect parameters for `orderId`, `paymentKey`, and `amount`, avoiding duplicate query collisions on return.
- `cd backend/functions && npm run format:check` passed on April 2, 2026.
- `cd backend/functions && npm run lint` passed on April 2, 2026.
- `cd backend/functions && npm run build` passed on April 2, 2026.
- `cd backend/functions && npm test` passed on April 2, 2026.
- `cd apps/mobile_flutter && flutter gen-l10n` ran on April 2, 2026 without contract changes.
- `cd apps/mobile_flutter && dart format --output=none --set-exit-if-changed lib test` required no retained source changes for the current close-review slice on April 2, 2026.
- `cd apps/mobile_flutter && flutter analyze` passed on April 2, 2026.
- `cd apps/mobile_flutter && flutter test` passed on April 2, 2026.
- `cd apps/mobile_flutter && flutter gen-l10n` passed on April 3, 2026.
- `cd apps/mobile_flutter && dart format --output=none --set-exit-if-changed lib/features/auction/presentation/auction_detail_screen.dart lib/features/auction/presentation/widgets/auction_detail_action_bar.dart lib/features/auction/presentation/widgets/auction_detail_view.dart test/features/auction/presentation/widgets/auction_detail_action_bar_test.dart test/features/auction/presentation/widgets/auction_detail_view_test.dart` passed on April 3, 2026.
- `cd apps/mobile_flutter && flutter analyze` passed on April 3, 2026.
- `cd apps/mobile_flutter && flutter test` passed on April 3, 2026.
- `cd backend/functions && npm run format:check && npm run lint && npm run build && npm test` passed on April 5, 2026 after the Toss sandbox bridge changes.
- `cd backend/functions && npm run format:check` passed on April 11, 2026 after adding notification dispatch foundation.
- `cd backend/functions && npx eslint src/index.ts src/domain/notificationDispatchEngine.ts test/notificationDispatchEngine.test.ts && npx tsc --noEmit` passed on April 11, 2026 after adding notification dispatch foundation.
- `cd backend/functions && npm run build` passed on April 11, 2026 after adding notification dispatch foundation.
- `cd backend/functions && npm test` passed on April 11, 2026 after adding notification dispatch foundation.
- `cd backend/functions && npm run format:check` passed on April 13, 2026 after adding `AUTO_BID_CEILING_REACHED` plus payment-failure event-gap updates.
- `cd backend/functions && npx eslint src/index.ts src/domain/auctionEngine.ts src/domain/notificationDispatchEngine.ts src/domain/paymentEngine.ts test/auctionEngine.test.ts test/notificationDispatchEngine.test.ts test/paymentEngine.test.ts && npx tsc --noEmit` passed on April 13, 2026 after adding `AUTO_BID_CEILING_REACHED` plus payment-failure event-gap updates.
- `cd backend/functions && npm run build` passed on April 13, 2026 after adding `AUTO_BID_CEILING_REACHED` plus payment-failure event-gap updates.
- `cd backend/functions && npm test` passed on April 13, 2026 after adding `AUTO_BID_CEILING_REACHED` plus payment-failure event-gap updates.
- `cd backend/functions && npm run format:check` passed on April 13, 2026 after adding reminder event-matrix coverage and deterministic reminder inbox ids.
- `cd backend/functions && npx eslint src/index.ts src/domain/notificationDispatchEngine.ts test/notificationDispatchEngine.test.ts && npx tsc --noEmit` passed on April 13, 2026 after adding reminder event-matrix coverage and deterministic reminder inbox ids.
- `cd backend/functions && npm run build` passed on April 13, 2026 after adding reminder event-matrix coverage and deterministic reminder inbox ids.
- `cd backend/functions && npm test` passed on April 13, 2026 after adding reminder event-matrix coverage and deterministic reminder inbox ids.
- `cd backend/functions && npx eslint src/index.ts src/domain/notificationDispatchEngine.ts src/domain/orderReminderEngine.ts test/notificationDispatchEngine.test.ts test/orderReminderEngine.test.ts && npx tsc --noEmit` passed on April 13, 2026 after adding reminder precondition revalidation and lookback-bounded candidate checks.
- `cd backend/functions && npm run build` passed on April 13, 2026 after adding reminder precondition revalidation and lookback-bounded candidate checks.
- `cd backend/functions && npm test` passed on April 13, 2026 after adding reminder precondition revalidation and lookback-bounded candidate checks.
- `cd backend/functions && npm run format:check` passed on April 14, 2026 after adding the `sendDebugPushProbe` callable and `SYSTEM_TEST` notification mapping.
- `cd backend/functions && npx eslint src/index.ts src/domain/notificationDispatchEngine.ts test/notificationDispatchEngine.test.ts && npx tsc --noEmit` passed on April 14, 2026 after adding the debug push probe callable path.
- `cd backend/functions && npm run build` passed on April 14, 2026 after adding the debug push probe callable path.
- `cd backend/functions && npm test` passed on April 14, 2026 after adding the debug push probe callable path.
- `cd backend/functions && npm run format:check && npm run lint && npm run build && npm test` passed on April 19, 2026 after adding localized notification copy resolution for all supported inbox-backed event types in Firebase Functions.
- `cd apps/mobile_flutter && flutter gen-l10n` passed on April 6, 2026 after adding the settings localization keys.
- `cd apps/mobile_flutter && dart format --output=none --set-exit-if-changed lib test` passed on April 6, 2026.
- `cd apps/mobile_flutter && flutter analyze` passed on April 6, 2026.
- `cd apps/mobile_flutter && flutter test` passed on April 6, 2026.
- `cd apps/mobile_flutter && flutter gen-l10n` passed on April 6, 2026 after adding settings appearance and language keys.
- `cd apps/mobile_flutter && dart format --output=none --set-exit-if-changed lib/app/app.dart lib/main.dart lib/features/auth/presentation/login_screen.dart lib/core/widgets/app_page_scaffold.dart lib/features/settings test/app/app_test.dart test/features/settings` passed on April 6, 2026.
- `cd apps/mobile_flutter && flutter analyze` passed on April 6, 2026 after wiring settings-driven theme apply and returning locale handling to device-only behavior.
- `cd apps/mobile_flutter && flutter test` passed on April 6, 2026 after adding app-level theme apply coverage and compact theme-selector tests.
- `cd backend/functions && npm run format:check && npm run lint && npm run build && npm test` passed on April 6, 2026 during the Phase 4 settings apply slice.
- `cd apps/mobile_flutter && flutter analyze` passed on April 8, 2026 after the dev/prod flavor, gateway, and logging changes.
- `cd apps/mobile_flutter && flutter test` passed on April 8, 2026 after the dev/prod flavor, gateway, and logging changes.
- `cd apps/mobile_flutter && flutter analyze` passed on April 11, 2026 after adding mobile push presentation and tap-routing foundation.
- `cd apps/mobile_flutter && flutter test test/features/notifications/application/notification_push_service_test.dart test/features/notifications/application/notification_device_token_service_test.dart test/app/app_test.dart` passed on April 11, 2026 after adding mobile push presentation and tap-routing foundation.
- `cd apps/mobile_flutter/android && ./gradlew app:compileDevDebugKotlin` reached the Android build graph on April 11, 2026 but stopped at `:app:copyFlutterAssetsDevDebug` because the local workspace could not apply file mode `644` to `kernel_blob.bin`; Kotlin and manifest wiring were not the failing layer.
- `cd backend/render-dev-server && npm test` passed on April 8, 2026 after the Firebase Admin refactor and `/healthz` route addition.
- `cd backend/render-dev-server && npm test` passed on April 14, 2026 after adding `POST /api/notifications/debug/push-probe` and push-dispatch contract tests.
- `cd backend/render-dev-server && npm test` passed on April 19, 2026 after adding localized notification copy resolution with `en` and unsupported-locale fallback coverage for debug push probe dispatch.
- `cd apps/mobile_flutter && flutter gen-l10n` passed on April 14, 2026 after adding debug push-probe copy and skipped-dispatch messaging.
- `cd apps/mobile_flutter && dart format --output=none --set-exit-if-changed lib/core/backend/backend_gateway.dart lib/features/settings/presentation/settings_screen.dart lib/features/settings/presentation/widgets/settings_app_info_section.dart test/features/settings/presentation/widgets/settings_app_info_section_test.dart` passed on April 14, 2026 after adding the settings debug push-probe action.
- `cd apps/mobile_flutter && flutter analyze` passed on April 14, 2026 after adding the settings debug push-probe action and transport guard handling.
- `cd apps/mobile_flutter && flutter test test/features/settings/presentation/settings_screen_test.dart test/features/settings/presentation/widgets/settings_app_info_section_test.dart test/features/settings/presentation/widgets/settings_notification_section_test.dart test/features/settings/presentation/widgets/settings_theme_section_test.dart` passed on April 14, 2026 after adding the debug push-probe UI flow.
- `cd apps/mobile_flutter && flutter gen-l10n` passed on April 15, 2026 after adding settings language-behavior confirmation copy.
- `cd apps/mobile_flutter && dart format --output=none --set-exit-if-changed lib/features/auth/presentation/login_screen.dart lib/features/settings/presentation/settings_screen.dart lib/features/settings/presentation/widgets/settings_language_section.dart test/features/auth/presentation/login_screen_test.dart test/features/settings/presentation/settings_screen_test.dart test/features/settings/presentation/widgets/settings_language_section_test.dart` passed on April 15, 2026 after release-mode quick-login hardening and settings language confirmation updates.
- `cd apps/mobile_flutter && flutter test test/features/auth/presentation/login_screen_test.dart test/features/settings/presentation/settings_screen_test.dart test/features/settings/presentation/widgets/settings_language_section_test.dart test/core/logging/app_logger_test.dart test/features/notifications/application/notification_push_service_test.dart` passed on April 15, 2026 after adding release-mode dev-panel gating, settings language confirmation, and release-safe logger fallback handling.
- `cd apps/mobile_flutter && flutter analyze` passed on April 15, 2026 after adding release-mode dev-panel gating, settings language confirmation, and release-safe logger fallback handling.
- `cd apps/mobile_flutter && xcodebuild -list -project ios/Runner.xcodeproj` confirmed `dev` and `prod` schemes plus flavor-specific build configurations on April 8, 2026.
- `cd apps/mobile_flutter/android && ./gradlew app:tasks --all | rg "assemble(Dev|Prod)"` confirmed Android dev/prod variants on April 8, 2026.
- `curl https://auction-market-dev-api.onrender.com/healthz` returned `200` on April 8, 2026.
- `cd apps/mobile_flutter && dart analyze <orders payment files>` passed on April 5, 2026.
- `cd apps/mobile_flutter && flutter test test/features/orders/application/order_payment_handoff_service_test.dart test/features/orders/application/order_payment_launcher_service_test.dart test/features/orders/data/order_payment_session_test.dart test/core/routing/app_deeplink_test.dart` passed on April 5, 2026.
- `cd apps/mobile_flutter && flutter analyze` passed on April 6, 2026 for the current close-review checkpoint.
- `cd apps/mobile_flutter && flutter test` passed on April 6, 2026 for the current close-review checkpoint.
- `cd backend/functions && npm run seed` succeeded on April 2, 2026 against an already running local emulator suite.
- `cd backend/functions && npm run seed` succeeded on April 5, 2026 against the current emulator suite.
- `./node_modules/.bin/tsx ./scripts/seed.ts` reset the running local emulator data on April 6, 2026, even though the local shell process did not terminate cleanly after writes completed.
- A headless April 6 close-review smoke against the running emulator suite verified these callable paths on seeded buyer and seller accounts:
  - `buyNow` created a new `AWAITING_PAYMENT` order from `auction-live-camera`.
  - `createPaymentSession` returned a Toss bridge checkout contract for `order-awaiting`.
  - `createOrUpdateItem` plus `createAuctionFromItem` created and published a new seller-owned live auction.
  - `shipmentUpdate` moved `order-paid` to `SHIPPED`.
  - `confirmReceipt` moved the same order to `CONFIRMED_RECEIPT`.
- `cd backend/functions && npm run serve` could not be restarted on April 2, 2026 because emulator ports were already occupied locally; this was an environment condition, not a repo failure.
- `backend/functions/.env` now holds a working dev sandbox config with `ENABLE_TOSS_SANDBOX=true`, a test `TOSS_SECRET_KEY`, and a public `APP_BASE_URL` that targets the `tossPaymentBridge` tunnel URL.
- Phase 3 close evidence remains documented in `Documentation.md`.

## Next Commands
1. `cd apps/mobile_flutter && ./scripts/bootstrap_render_dev.sh`
2. Place the local dev Firebase files in:
   - `apps/mobile_flutter/android/app/src/dev/google-services.json`
   - `apps/mobile_flutter/ios/Runner/Firebase/dev/GoogleService-Info.plist`
3. `cd apps/mobile_flutter && flutter run --flavor dev --dart-define-from-file=dart_defines.dev.json`
4. For local emulator fallback, use:
   - `cd backend/functions && npm run serve`
   - `cd apps/mobile_flutter && flutter run --flavor dev --dart-define-from-file=dart_defines.local-emulator.json`
5. On Android real device, open settings and verify:
   - notification permission request
   - push toggle writes
   - device token register or deactivate diagnostics
6. Continue Phase 4 by implementing:
   - Android and iOS real-device verification for foreground, background, and terminated notification paths
   - iOS APNs project setup and final iOS delivery signoff

## Update Rules
- Keep this file short.
- Keep only current task, locked decisions, blockers, validation status, and next commands.
- Replace completed items instead of appending long history.
- Before a commit, run the relevant format, lint, test, and build gates for the touched stack.
