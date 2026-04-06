# Auction Market Execution Log

## Current Task
- Phase 4 settings and notification foundation is active.
- The current slice applies theme preference to the live app shell and simplifies locale behavior back to system-language-only, on top of the dedicated settings route, Firestore-backed notification preference toggles, OS notification-permission visibility, and settings entry points from the app bar and My screen.
- Device-token lifecycle and real push delivery remain later Phase 4 slices.

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
- Dev sandbox payment still depends on a live public tunnel session for `APP_BASE_URL`, because Toss redirect URLs cannot target localhost.
- Final real-device push delivery will require Firebase Messaging project setup and iOS APNs project setup.

## Validation Status
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
- The second Phase 4 settings slice now applies `users/{uid}.preferences.themeMode` to `MaterialApp`, and `/settings` now exposes a compact theme preview selector instead of a verbose radio list.
- Signed-in routes no longer expose a global locale picker in the shared app bar, and the signed-out login surface also no longer carries a manual locale menu; the app now follows the device locale only.
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
- `cd apps/mobile_flutter && flutter gen-l10n` passed on April 6, 2026 after adding the settings localization keys.
- `cd apps/mobile_flutter && dart format --output=none --set-exit-if-changed lib test` passed on April 6, 2026.
- `cd apps/mobile_flutter && flutter analyze` passed on April 6, 2026.
- `cd apps/mobile_flutter && flutter test` passed on April 6, 2026.
- `cd apps/mobile_flutter && flutter gen-l10n` passed on April 6, 2026 after adding settings appearance and language keys.
- `cd apps/mobile_flutter && dart format --output=none --set-exit-if-changed lib/app/app.dart lib/main.dart lib/features/auth/presentation/login_screen.dart lib/core/widgets/app_page_scaffold.dart lib/features/settings test/app/app_test.dart test/features/settings` passed on April 6, 2026.
- `cd apps/mobile_flutter && flutter analyze` passed on April 6, 2026 after wiring settings-driven theme apply and returning locale handling to device-only behavior.
- `cd apps/mobile_flutter && flutter test` passed on April 6, 2026 after adding app-level theme apply coverage and compact theme-selector tests.
- `cd backend/functions && npm run format:check && npm run lint && npm run build && npm test` passed on April 6, 2026 during the Phase 4 settings apply slice.
- `cd apps/mobile_flutter && dart analyze <orders payment files>` passed on April 5, 2026.
- `cd apps/mobile_flutter && flutter test test/features/orders/application/order_payment_handoff_service_test.dart test/features/orders/application/order_payment_launcher_service_test.dart test/features/orders/data/order_payment_session_test.dart test/core/routing/app_deeplink_test.dart` passed on April 5, 2026.
- `cd backend/functions && npm run seed` succeeded on April 2, 2026 against an already running local emulator suite.
- `cd backend/functions && npm run seed` succeeded on April 5, 2026 against the current emulator suite.
- `cd backend/functions && npm run serve` could not be restarted on April 2, 2026 because emulator ports were already occupied locally; this was an environment condition, not a repo failure.
- `backend/functions/.env` now holds a working dev sandbox config with `ENABLE_TOSS_SANDBOX=true`, a test `TOSS_SECRET_KEY`, and a public `APP_BASE_URL` that targets the `tossPaymentBridge` tunnel URL.
- Manual buyer and seller Phase 3 smoke paths are still the remaining close gate and stay documented in `Documentation.md`.

## Next Commands
1. `cd backend/functions && npm run serve`
2. `cd backend/functions && npm run seed`
3. `cd apps/mobile_flutter && flutter run --dart-define-from-file=dart_defines.json`
4. Sign in as `buyer1@test.local` or `seller1@test.local`
5. Open settings from the app bar or My screen and verify notification toggles, compact appearance mode selection, permission state, version, licenses, and debug-only info
6. Continue Phase 4 with device-token lifecycle and push delivery only after the settings apply slice is reviewed

## Update Rules
- Keep this file short.
- Keep only current task, locked decisions, blockers, validation status, and next commands.
- Replace completed items instead of appending long history.
- Before a commit, run the relevant format, lint, test, and build gates for the touched stack.
