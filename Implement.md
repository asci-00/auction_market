# Auction Market Execution Log

## Current Task
- Phase 3 mobile flow work is active. Orders now support a `dev` server-driven dummy payment handoff from the buyer timeline, and the next unfinished product gap is the final automated Toss checkout handoff once real client key and return URL values are available.
- Phase 3 also still reserves a UI polish slice for animation, page transitions, countdown motion, and surface or blur tuning that must follow `docs/Design.md` without reducing readability.

## Locked Decisions
- All developer-facing docs use plain English.
- App UI supports Korean and English and follows the device locale without an in-app language switch.
- TossPayments is the only payment provider for v1.
- Apple sign in and Google sign in are the only login providers for v1.
- Emulator seed is the default dummy data path, and dependency-blocked integrations may use server-driven dummy responses in `dev` until the real handoff is ready.
- Secrets never live in repo files. Only example files are committed.
- Flutter mobile boot fails fast when required public `dart-define` values are missing or still set to `TODO_...`.
- Android uses `10.0.2.2` for Firebase emulator hosts and iOS uses `127.0.0.1`.
- Mobile Firebase initialization now reads native platform config files instead of Firebase values duplicated in `dart_defines.json`.
- Mobile Google and Apple browser sign-in are treated as live Firebase flows. When `USE_FIREBASE_EMULATORS=true`, the login screen blocks those buttons and shows the required runtime switch instead of launching a broken browser round trip.
- In `dev` with `USE_FIREBASE_EMULATORS=true`, the login screen also exposes seeded buyer and seller quick-login buttons backed by Auth Emulator email/password accounts.
- Backend payment confirmation uses Toss `/v1/payments/confirm`, and webhook updates flow through `tossPaymentWebhook` with `payment.lastWebhookEventId` idempotency markers.
- Backend critical transitions now write `auditEvents` documents instead of relying on implicit log-only traces.
- When a task depends on slow external integration setup, keep `dev` testable first through server-driven dummy or emulator-backed responses, then move the final real integration handoff to the end of the milestone.

## Open Blockers
- Real Toss client key, secret key, and webhook secret are not available in this repo yet.
- Real app base URL for payment return paths and deep links is not available in this repo yet.

## Validation Status
- `apps/mobile_flutter/android` and `apps/mobile_flutter/ios` exist, so `flutter run` has native targets again.
- `apps/mobile_flutter/lib/core/{app_config,firebase,routing,theme,error,widgets}` exists and owns shared mobile foundation code.
- Firebase bootstrap initializes from native iOS and Android config files, connects emulators when enabled, and surfaces readable startup errors.
- Guarded `go_router` navigation uses `StatefulShellRoute.indexedStack` for tab preservation and supports `app://auction/{id}` and `app://orders/{id}` deep-link normalization.
- Shared theme tokens, editorial hero patterns, auction cards, anchored bottom navigation, and sticky action bars match the updated design contract direction.
- Mobile copy is generated from `app_ko.arb` and `app_en.arb`, with device-locale fallback to Korean.
- Flutter shared context helpers now live in `core/extensions/build_context_x.dart`, so common access like snackbars, theme, text theme, media query, and navigator no longer requires repeated `ScaffoldMessenger.of(context)` or similar direct lookups in feature screens.
- Login, home, search, auction detail, sell, activity, orders, notifications, and my screens use localized product copy and no longer expose engineering-status labels in the UI.
- Home, search, auction detail, orders, notifications, and my screens now read from Firestore paths and fall back to localized unavailable states when documents are missing.
- Auction detail now calls `placeBid`, `setAutoBid`, and `buyNow` from the mobile UI, then routes completed buy-now orders into the order timeline.
- Auction detail and orders now split presentation widgets, data mappers, and callable action services into separate files instead of mixing Firestore maps, Functions calls, dialogs, and screen layout in one file.
- Login now splits seeded dev account data, auth action execution, error mapping, and panel widgets instead of keeping provider setup and every visual block in one file.
- Sell now runs live Storage image uploads plus `createOrUpdateItem` and `createAuctionFromItem`, stores draft pricing metadata in Firestore, reloads saved drafts into the editor, and keeps the route screen thin by splitting panels and action logic into feature files.
- Home, search, and my now also split Firestore document mapping, filtering helpers, and repeated section widgets away from the route screen files, so those route widgets mainly compose streams, sections, and navigation.
- Activity now reads live buyer orders, seller orders, and inbox notifications to show the next payment, shipment, receipt, and unread-alert queues instead of linking through static cards only.
- Orders now runs live payment-session preparation, payment confirmation, shipment update, and receipt confirmation callables from the mobile UI, and notifications mark themselves as read before routing when the callable succeeds.
- Orders now completes `dev` payment testing through a server-driven dummy payment key from `createPaymentSession`, so buyer smoke tests can move `AWAITING_PAYMENT` orders into paid escrow hold before real Toss checkout values exist.
- Backend callables now cover bootstrap, item draft save, auction publish, cancel, relist, bid, auto-bid, buy-now, payment session creation, Toss payment confirmation, shipment update, receipt confirmation, and notification read state.
- Toss webhook handling now exists as `tossPaymentWebhook` and updates payment and order state idempotently.
- Emulator seed now creates buyer and seller profiles, live and ended auctions, bids, auto-bid config, an awaiting-payment order, and inbox notifications.
- Emulator seed now keeps `order-paid` in `PAID_ESCROW_HOLD`, so seller and buyer can smoke test shipment and receipt actions end-to-end in dev.
- `npm run seed` now also creates Auth Emulator users for `buyer1`, `seller1`, and `ops1`, so dev mobile smoke tests can enter authenticated flows without live social login.
- Because `npm run seed` writes to Auth Emulator on `127.0.0.1:9099`, `npm run serve` must start `auth` together with `functions`, `firestore`, and `storage`.
- `apps/mobile_flutter/ios/Runner/GoogleService-Info.plist` and `apps/mobile_flutter/android/app/google-services.json` are present and aligned to package/bundle id `com.auction.market`.
- Android app module applies the Google Services Gradle plugin.
- Login screen now surfaces the Firebase Auth Emulator limitation for mobile Google and Apple browser sign-in instead of opening a non-functional browser loop.
- `cd backend/functions && npm run seed` passed on March 20, 2026.
- `cd backend/functions && npm run format:check` passed on March 24, 2026.
- `cd backend/functions && npm run lint` passed on March 24, 2026.
- `cd backend/functions && npm test` passed on March 24, 2026.
- `cd backend/functions && npm run build` passed on March 24, 2026.
- `cd apps/mobile_flutter && flutter gen-l10n` passed on March 24, 2026.
- `cd apps/mobile_flutter && dart format --output=none --set-exit-if-changed lib test` passed on March 24, 2026.
- `cd apps/mobile_flutter && flutter analyze` passed on March 24, 2026.
- `cd apps/mobile_flutter && flutter test` passed on March 24, 2026.

## Next Commands
1. `cd backend/functions && npm run serve`
2. `cd backend/functions && npm run seed`
3. `cd apps/mobile_flutter && flutter run --dart-define-from-file=dart_defines.json`
4. In `dev` emulator mode, sign in as `seller1`, save a draft with gallery and auth images, publish the auction, and verify the app opens the live auction detail route.
5. Sign in as `buyer1`, open a live auction, place a bid or save an auto-bid ceiling, then complete buy-now and confirm the order timeline opens.
6. Still as `buyer1`, open an `AWAITING_PAYMENT` order, prepare the payment session, and verify the `dev` dummy payment action moves the order to paid escrow hold without leaving the app.
7. Sign in as `seller1` and register shipment for `order-paid`, then sign back in as `buyer1` and confirm receipt from the same order.
8. Fill `backend/functions/.env` and `apps/mobile_flutter/dart_defines.json` with real Toss values for staging and prod verification.

## Update Rules
- Keep this file short.
- Replace completed tasks instead of appending long history.
- Keep only current task, locked decisions, blockers, validation status, and next commands.
- When a meaningful unit of work is complete and its required validations pass, leave a focused git commit before moving on to the next meaningful unit.
- Before that commit, run the applicable formatting and lint gates for each touched stack, not only tests and builds.
- When opening a PR for human review, write the PR title and body in Korean so the review intent and change scope are easy to scan.
