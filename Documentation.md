# Auction Market Technical Documentation

## Source Of Truth
- This file is the implementation contract for schema, write paths, environment loading, and operations.
- `docs/Design.md` is the visual and UX contract.
- `docs/Environment.md` is the external config contract.
- `docs/Notification.md` is the push-notification and inbox-delivery contract.
- `Implement.md` is the live execution log.

## Repo Layout
- `apps/mobile_flutter`: mobile app.
- `backend/functions`: Firebase Functions.
- `backend/emulator-seed`: deterministic emulator seed data.
- `backend/firestore.rules`: Firestore read and write policy.
- `backend/firestore.indexes.json`: Firestore query indexes.

## Environment Model
- `dev`: real Firebase development project plus the Render dev server for public mobile HTTP entrypoints and payment redirect pages.
- `prod`: real Firebase production project with Firebase callable remaining the default mutation transport.
- When a third-party dependency is not ready yet, `dev` may expose server-driven dummy integration payloads so the mobile app can validate the surrounding product flow before the final real handoff is wired.
- External PG cutover planning is tracked only in `Plan.md` under `Phase Undecided`.
- The app switches environment only through build-time public config for `APP_ENV`, backend transport, emulator mode, and other non-secret app settings.
- Backend runtime switches environment only through env variables.
- Flutter mobile boot on iOS and Android reads Firebase app registration from native platform files instead of `dart-define` values.
- Mobile public config now comes from flavor-specific `dart_defines.dev.json`, `dart_defines.local-emulator.json`, and `dart_defines.prod.json`.
- Android flavors are `dev` and `prod`.
- iOS build configurations and schemes are `Debug-dev`/`Release-dev`/`Profile-dev` and `Debug-prod`/`Release-prod`/`Profile-prod` with shared schemes `dev` and `prod`.
- Mobile locale selection defaults to the device locale and falls back to Korean when the device language is unsupported. When a persisted in-app override is added, it may only select `ko` or `en`.

## Mobile App Architecture
- Use feature-first folders with `presentation`, `application`, `domain`, and `data`.
- Add a shared `core/` layer with:
  - `app_config`: reads build-time defines and exposes typed config.
  - `firebase`: initializes Firebase, emulator mode, auth, functions, storage, and messaging.
  - `l10n`: owns locale resolution helpers and display formatting.
  - `extensions`: owns `BuildContext` convenience accessors for shared UI infrastructure such as snackbars, text theme, and navigator access.
  - `routing`: guarded `go_router` config with deep links and tab restoration.
  - `theme`: colors, typography, spacing, shapes, motion tokens.
  - `error`: typed app errors and user-safe error messages.
  - `widgets`: reusable layout and interaction components.
- Current Phase 1 implementation details:
  - `lib/main.dart` installs zoned startup error capture for Flutter framework and platform errors.
  - `lib/core/app_config/app_config.dart` validates non-secret app defines such as `APP_ENV`, `APP_BACKEND_TRANSPORT`, `APP_API_BASE_URL`, emulator mode, and the currently wired payment launch key when the active adapter needs one.
  - `lib/core/backend/backend_gateway.dart` selects `FirebaseCallableBackendGateway` for prod and `HttpBackendGateway` for dev HTTP transport, so existing services keep the same high-level mutation contract while transport changes underneath.
  - `lib/core/firebase/firebase_bootstrap.dart` initializes Firebase from native iOS and Android config files, then attaches Auth, Firestore, Functions, and Storage emulators when enabled.
  - `lib/core/logging/app_logger.dart` is the single structured mobile logger entrypoint and emits `timestamp | level | domain | source | message`; release builds force production-safe logger policy (info-level minimum with redaction) even when runtime `APP_ENV` is `dev`.
  - `lib/core/l10n/app_localization.dart` resolves device locale to `ko` or `en` and exposes generated localization accessors.
  - `lib/core/extensions/build_context_x.dart` centralizes repeated `BuildContext` lookups like `Theme.of`, `ScaffoldMessenger.of`, `MediaQuery.of`, `Navigator.of`, and `GoRouter.of`.
  - `lib/core/routing/app_router.dart` owns guarded routing, deep-link normalization, payment return routes, and shared fade-plus-rise transitions for modal detail routes.
  - `lib/core/theme/app_theme.dart` applies the warm neutral, charcoal, copper, coral, and sage token system from `docs/Design.md`, including anchored navigation, sticky action sizing, and a dedicated warm dark-mode palette.
  - `lib/core/widgets/` owns the shared editorial hero, auction card, shell, page scaffold, panel, badge, section heading, sticky action bar, empty-state, motion, countdown, shimmer, and loading-overlay primitives.
  - `apps/mobile_flutter/analysis_options.yaml` now excludes generated localization files from manual lint noise, enables strict analyzer modes for casts, inference, and raw types, and adds a small set of project-wide lint rules for explicit return types, final locals and fields, and redundant lambda cleanup.
- Current mobile UX and localization implementation details:
  - `apps/mobile_flutter/lib/l10n/app_ko.arb` and `apps/mobile_flutter/lib/l10n/app_en.arb` own user-facing mobile copy for `ko` and `en`.
  - `lib/app/app.dart` wires `supportedLocales`, localization delegates, and locale fallback into `MaterialApp`.
  - Login, home, search, auction detail, sell, activity, orders, notifications, and my screens now use localized copy and the shared editorial design primitives.
  - Login now blocks Google and Apple browser sign-in when `USE_FIREBASE_EMULATORS=true`, because the project treats mobile social-login verification as a real-Firebase path rather than an Auth Emulator path.
  - Login also exposes seeded buyer and seller quick-login actions only when not in release mode and when `APP_ENV=dev` plus `USE_FIREBASE_EMULATORS=true`, so emulator smoke tests can enter authenticated routes without exposing debug shortcuts in release builds.
  - Login now keeps seeded account constants in `features/auth/data`, auth mutations in `features/auth/application`, and each major visual block in `features/auth/presentation/widgets`.
  - Auction detail now keeps the screen in `presentation`, pushes callable writes through `features/auction/application/auction_detail_action_service.dart`, and maps Firestore documents through `features/auction/data/auction_detail_view_data.dart`.
  - Auction detail now combines `auctions/{auctionId}` with the linked `items/{itemId}` document so the screen can render a real image gallery, item description, and lightweight item metadata above bid history.
  - Auction detail now binds the auction stream and linked item stream through `features/auction/data/auction_detail_stream.dart`, so item enrichment does not suppress later auction updates when price, order, or status changes continue in Firestore.
  - Auction detail header now clamps its gallery index when the backing image list shrinks, preventing stale page state from surviving a live image-list update.
  - Auction detail now exposes `features/auction/presentation/widgets/auction_detail_view.dart` so route composition can be tested directly for live buyer, seller-owned, and unavailable states without pulling Firebase providers into widget tests.
  - Orders now keeps the screen layout in `presentation`, pushes payment, shipment, and receipt callables through `features/orders/application/order_action_service.dart`, and maps Firestore documents through `features/orders/data/order_summary.dart`.
  - Sell now keeps Functions and Storage writes in `features/sell/application/sell_flow_service.dart`, draft mapping in `features/sell/data`, and section widgets in `features/sell/presentation/widgets`, so the route screen mostly owns form state and composition.
  - Sell now also renders a dedicated `SellProgressPanel` that tracks category, details, pricing, image, and publish readiness plus current draft-save state, so the `docs/Design.md` requirement for visible step progress and draft-save status is met without turning the route into a full wizard.
  - Sell validation now keeps action-aware form errors in presentation state, so `save draft` and `publish auction` can each render inline `errorText` feedback on the affected fields plus a localized summary block near the submit actions instead of relying on a snackbar-only correction loop.
  - Sell draft empty states now describe saved item basics in product language instead of referencing Firestore directly, keeping release-facing copy aligned with the design contract.
  - Sell draft save and publish now wrap the entire route body in a delayed blocking loading overlay backed by `assets/lotties/loading.lottie`, because image uploads plus Functions writes are the longest user-blocking action chain currently present in `dev`.
  - Faster interactions such as auth sign-in and auction bid actions stay outside the blocking overlay path, and auction detail now uses action-specific pending labels plus sticky-bar helper copy for `bid`, `auto-bid`, and `buy now` so buyers can tell which mutation is in flight before toast-based success or failure feedback arrives.
  - Keyboard-sensitive modals now use a shared inset wrapper so the orders payment sheet, orders shipment and payment-key dialogs, and auction bid amount dialogs remain scrollable and visible when the software keyboard is open.
  - Keyboard-prone modal surfaces now share a small `core/widgets/app_keyboard_safe_inset.dart` wrapper so order payment sheets, shipment dialogs, and auction amount dialogs animate with `viewInsets`, stay scrollable, and remain usable on narrow devices.
  - The sell route now increases its bottom list inset while the keyboard is open, so pricing inputs and lower form actions stay reachable without manual layout hacks.
  - `core/widgets/app_page_scaffold.dart` now measures local page-level `bottomBar` height and combines it with shell insets before padding the body, so Android edge-to-edge mode keeps scrolling content above both the OS navigation area and sticky bottom action bars without screen-level magic numbers.
  - `lib/app/app.dart` now wires both light and dark themes with `ThemeMode.system`, and the shared scaffold, panel, shell, and shimmer primitives resolve warm dark tokens instead of forcing the light palette under system dark mode.
  - Shared foundations now honor system dark mode through `MaterialApp.darkTheme`, a warm dark scaffold gradient, dark-aware panel tones, and a floating shell plate that preserves the editorial hierarchy without default Material dark chrome.
  - Shared editorial hero, empty-state, shimmer, badge, and auction-card widgets now resolve theme-aware colors too, so common reusable surfaces do not leak the light palette back into dark mode routes.
  - Shared loading-overlay barriers, order payment helper plates, activity stat icon tiles, and home action buttons now resolve theme-aware nested surfaces as well, so dark mode no longer mixes bright inset cards into otherwise warm dark flows.
  - Transactional order dialogs, payment sheets, and auction amount dialogs now route through a shared `core/widgets/app_modal.dart` helper, which keeps modal barrier tone and fade-plus-rise presentation aligned with route transitions and loading overlays.
  - Auction detail header overlays and fallback gradients, sell image fallback tiles, login support copy panels, and payment return status labels now resolve brightness-aware tokens too, so dark mode no longer falls back to light-only inset colors in those live user flows.
  - Activity now keeps queue summary mapping in `features/activity/data` and composes buyer, seller, and notification stream cards from dedicated widgets instead of using static navigation-only tiles.
  - Notification inbox rows now derive a localized destination hint from each deeplink, so the row itself shows title, body, time, and the next destination before navigation begins.
  - Home now maps auction rail documents through `features/home/data/home_auction_summary.dart` and keeps reusable rail and action button widgets in `features/home/presentation/widgets`.
  - Home now also derives curated goods and precious rails client-side from the same live-auction read set used for `endingSoon` and `hot`, which closes the `docs/Design.md` home composition gap without introducing new Firestore index or query requirements.
  - Search now maps Firestore records through `features/search/data/search_auction_summary.dart`, keeps filtering logic in `features/search/application/search_auction_filter.dart`, and uses dedicated query, filter-chip, and result-grid widgets.
  - Search filter chips now drive real local filtering for category, price band, ending-soon urgency, and buy-now availability, so visible search controls no longer behave like decorative placeholders.
  - The search route now uses a sliver-based body with a pinned query-field header, keeping the primary search input visible while the result grid scrolls underneath.
  - The search route now also keeps a local presentation-only layout mode, letting users switch the same filtered result set between large cards and a compact list without changing provider contracts or query behavior.
  - My now maps the user document through `features/my/data/my_profile_summary.dart`, keeps verification label logic separate, and composes account and verification blocks from dedicated widgets.
  - Settings now lives under `features/settings/` with a dedicated data model for notification preferences, an application service for Firestore preference writes and OS permission helpers, and presentation widgets for notification controls plus app info.
  - The first Phase 4 settings slice now exposes `/settings` from both the global app bar and the My screen, and it currently covers notification preferences, OS notification-permission state, appearance mode, app version, licenses, and debug-only environment info.
  - Settings now also includes a dedicated language behavior confirmation section that shows the current effective app language from locale resolution and explicitly documents supported locales (`ko`, `en`) with `ko` fallback.
  - The debug-only settings developer area now also exposes a server push-probe trigger for the signed-in user, routed through `core/backend/backend_gateway.dart` as `sendDebugPushProbe` so both dev HTTP and callable transports compile from the same feature-level call path.
  - Settings reads `users/{uid}.preferences` directly from Firestore and falls back to `SettingsPreferences.defaults()` when the signed-in user document exists without a populated `preferences` payload yet.
  - `app/app.dart` now applies theme mode from local `SharedPreferences` state instead of the signed-in user document, while locale always follows the device setting through the shared locale resolver.
  - Notification device-token lifecycle now lives under `features/notifications/application/notification_device_token_service.dart`, where the signed-in app session calls `registerDeviceToken` after permission grant, re-syncs on app resume and FCM token rotation, and calls `deactivateDeviceToken` before sign-out or when push is disabled.
  - In `dev`, that same service now emits console diagnostics for permission state, token resolution, callable register or deactivate attempts, and skip reasons so silent push-token no-op paths can be traced without exposing raw token values in release UI.
  - Signed-in routes no longer expose a separate global locale picker in the shared app bar, and the login screen no longer carries a manual locale menu either; language behavior is system-driven only.
  - Theme selection now uses a compact preview-card selector instead of long descriptive radio rows, aligning the settings surface with common mobile-app patterns.
  - Notifications now reuse the shared app deep-link normalizer instead of carrying a screen-local route parser.
  - Auction detail now runs `placeBid`, `setAutoBid`, and `buyNow` from the sticky action bar when the viewer is an eligible buyer on a live auction, and redirects completed buy-now orders into `/orders/{orderId}`.
  - Orders now routes `createPaymentSession`, `confirmOrderPayment`, `shipmentUpdate`, and `confirmReceipt` through `features/orders/application/order_action_service.dart`, and notifications call `markNotificationRead` before deep-link navigation.
  - Orders now resolves payment handoff semantics through `features/orders/application/order_payment_handoff_service.dart`, so `DEV_DUMMY`, provider-launch-ready mode, and manual payment-key fallback states stay out of the order list widget.
  - Buyer order cards now surface `AWAITING_PAYMENT` actions, prepare the payment session in-app, and in `dev` prefer the real Toss sandbox launcher path when `ENABLE_TOSS_SANDBOX=true`.
  - Payment return handling now lives in `features/orders/presentation/order_payment_return_screen.dart`, where `/payments/success` confirms a returned payment payload and `/payments/fail` routes the buyer back to recovery actions.
  - The order payment sheet now presents handoff state as premium recovery UI, separating `DEV_DUMMY`, prepared launcher state, and manual recovery fallback into distinct panels and next-step guidance instead of relying on one generic status paragraph.
  - Orders, notifications, and activity quiet states now attach only architecture-valid navigation recovery actions such as signed-in return routing or browse recovery, instead of generic retry affordances on cached Firestore read paths.
  - Sell uses `image_picker` plus Firebase Storage upload paths under `users/{uid}/items/{itemId}/gallery/*` and `users/{uid}/auth/{itemId}/*`, then persists draft data through `createOrUpdateItem` before publish.
  - Sell drafts now persist `draftAuction.startPrice`, `draftAuction.buyNowPrice`, and `draftAuction.durationDays` on `items/{itemId}`, so sellers can reload pricing intent before publishing.
  - Activity now reads `orders` and `notifications/{uid}/inbox` directly to highlight pending buyer payments, buyer receipt confirmations, seller shipment work, and unread inbox updates in one screen.
  - Home and search auction cards now reveal with a short stagger and use live countdown text instead of static end timestamps only, while orders show payment deadline and amount together through a live countdown plate.
  - Search, orders, sell drafts, activity cards, bid history, my verification, and startup loading now use shimmer placeholders instead of centered progress spinners where the final layout is already known.
  - Auction cards can now pass a scoped Hero tag into auction detail, and the detail header reuses that same image layer so image-first navigation feels continuous without duplicate-tag collisions across home rails.
  - Auction detail content now reserves additional bottom inset above the sticky action bar so the final bid history and seller summary content stay readable on small safe-area devices.
  - Auction detail stream-join behavior and gallery shrink handling now have dedicated widget and data tests under `test/features/auction/`, so late Phase 3 polish on the detail route is protected by direct regression coverage.
  - Auction detail close-review coverage now also includes a screen-composition widget test under `test/features/auction/presentation/widgets/auction_detail_view_test.dart`, which verifies the description panel and buyer actions, seller-owned action-state swap, and the unavailable fallback layout.
  - Auction detail action-bar coverage now also includes `test/features/auction/presentation/widgets/auction_detail_action_bar_test.dart`, which verifies action-specific pending copy and disabled-state behavior for live buyer mutations.
  - Pre-cutover Phase 3 polish work should prioritize dark mode parity, overflow and keyboard-safety fixes, blur tuning, barrier tuning, async-feedback timing, and route-transition smoothness before any explicit real PG cutover begins.
  - Shared blocking loading states must use `apps/mobile_flutter/assets/lotties/loading.lottie`, with shimmer preferred over modal loading when the destination layout is already known.
- Home, search, auction detail, orders, notifications, and my pages render from live Firestore read paths and fall back to localized empty or unavailable states when documents are missing.
- Read data directly from Firestore and Storage-backed URLs.
- Send mutations through the backend gateway only:
  - prod default: Firebase callable
  - dev default: Render HTTP
- Native Firebase config files live at:
  - `apps/mobile_flutter/ios/Runner/Firebase/dev/GoogleService-Info.plist`
  - `apps/mobile_flutter/ios/Runner/Firebase/prod/GoogleService-Info.plist`
  - `apps/mobile_flutter/android/app/src/dev/google-services.json`
  - `apps/mobile_flutter/android/app/src/prod/google-services.json`

## Localization Contract
- Supported locales are `ko` and `en` only.
- Locale resolution defaults to the device locale, with `ko` fallback when the device locale is unsupported.
- Settings surfaces a read-only language behavior confirmation that reflects this system-locale resolution rule; no in-app language override exists in the current product scope.
- Static user-facing copy must come from generated localizations, not hardcoded strings in widgets.
- Dynamic Firestore content may remain backend-authored text, but fallback labels, badges, and empty/error states must be localized in the app.

## Backend Implementation Notes
- `backend/functions/src/config/runtime.ts` validates backend runtime env such as `APP_ENV`, provider secrets for the active payment adapter, provider API base URL, and the presence of `APP_BASE_URL` when it is required by the active payment mode.
- `backend/render-dev-server` exposes `/healthz`, `/payments/*`, and `/api/*` on a stable public dev URL. It now verifies Firebase ID tokens with Firebase Admin and writes directly to the dev project's Firestore collections, so dev HTTP transport no longer depends on deployed Firebase Functions.
- The stable public dev health endpoint is `/healthz` under `https://auction-market-dev-api.onrender.com/healthz`. `/health` may be intercepted by the hosting edge and must not be treated as the canonical external health probe.
- `backend/functions/src/domain/paymentEngine.ts` owns payment confirmation idempotency helpers, provider webhook normalization, and payment state transitions.
- `backend/functions/eslint.config.mjs` now runs ESLint for `src`, `test`, and `scripts`, while `.prettierrc.json` and package scripts provide a repeatable formatting check for TypeScript files before commit.
- `backend/functions/src/index.ts` now exports the Phase 2 callable and scheduler surface:
  - `bootstrapUserProfile`
  - `createOrUpdateItem`
  - `createAuctionFromItem`
  - `cancelAuction`
  - `relistAuction`
  - `placeBid`
  - `setAutoBid`
  - `buyNow`
  - `createPaymentSession`
  - `confirmOrderPayment`
  - `shipmentUpdate`
  - `confirmReceipt`
  - `markNotificationRead`
  - `sendDebugPushProbe` (`APP_ENV=dev` only)
  - `tossPaymentWebhook`
  - `activateDraftAuctionsScheduler`
  - `finalizeAuctionsScheduler`
  - `expireUnpaidOrdersScheduler`
  - `orderReminderNotificationsScheduler`
  - `settleScheduler`
- Critical transitions now write `auditEvents` records for user bootstrap, item and auction lifecycle, bids, payment confirmation and failure, shipment, receipt confirmation, unpaid expiry, and settlement.
- `createPaymentSession` now returns `mode: "DEV_DUMMY"` plus a deterministic `devPaymentKey` in `dev`, so the mobile app can validate buyer payment progression without pretending to launch a production checkout.
- The `DEV_DUMMY` payment path is emulator-only. If the backend is not running under the Firebase Emulator Suite, `createPaymentSession` falls back to the currently wired real provider mode and requires `APP_BASE_URL` for success and fail return URLs.
- The payment domain normalizes `APP_BASE_URL` before success and fail URLs are built, so trailing slashes or stray query strings do not leak into `/payments/success` and `/payments/fail`, while `runtime.ts` remains responsible only for the base environment validation.
- When `ENABLE_TOSS_SANDBOX=true` is present in the active backend runtime env, emulator-backed `dev` no longer forces `DEV_DUMMY`; it returns a real Toss sandbox session with `checkoutUrl` rooted at `/payments/launch` plus fixed `successUrl` and `failUrl` return routes under the same public Render surface.
- `/payments/launch` is the current public handoff surface for mobile sandbox testing. `/payments/success` plus `/payments/fail` convert public redirects back into `app://payments/...` deep links for the mobile app.
- In `dev` with `ENABLE_TOSS_SANDBOX=true`, the Render payment bridge explicitly opens the `CARD` payment flow in the default integrated window and narrows the visible card list for smoke tests. External app-dependent wallet and app-card paths are not part of the required dev payment smoke path.
- The active provider webhook path verifies the configured webhook secret from the payload, applies idempotent payment transitions through `payment.lastWebhookEventId`, and updates the order instead of relying on a mock payment mutation.
- Current notification delivery status is intentionally split:
  - implemented: inbox document writes with notification metadata, device-token lifecycle, backend Firebase Admin Messaging dispatch for inbox-backed product events, reminder-event scheduler coverage with deterministic inbox ids, debug-only push-probe triggers for callable and Render HTTP in `dev`, Android channel setup, foreground surfaced messages, and tap routing through `getInitialMessage` plus `onMessageOpenedApp`
  - pending: final real-device verification of Android and iOS push behavior
<<<<<<< HEAD
- Render dev server notification copy for currently emitted inbox-backed event types now resolves through centralized `ko`/`en` templates instead of route-level hardcoded strings.
- Render dev server locale resolution priority is:
  - `users/{uid}.preferences.languageCode` when it normalizes to `ko` or `en`
  - active device-token locale metadata under `users/{uid}/deviceTokens/{tokenId}` ordered deterministically by latest token activity metadata
  - fallback `ko`
- Render debug push-probe dispatch now reuses the same localized title and body generated for inbox writes so inbox and push copy remain aligned for the same event.
- Firebase Functions notification copy now resolves through a centralized localization engine keyed by `InboxNotificationType`, covering `ko` and `en` for all currently supported push and inbox event types.
- Functions locale resolution priority is:
  - `users/{uid}.preferences.languageCode` when it normalizes to `ko` or `en`
  - latest deliverable device-token locale from `users/{uid}/deviceTokens/{tokenId}` (`isActive=true` and permission `AUTHORIZED` or `PROVISIONAL`)
  - fallback `ko`
- Functions now pass semantic notification context (for example final price, shipment tracking details, payment-failure reason, settlement order id) into localized template rendering instead of callsite-level hardcoded title and body strings.
- The emulator seed now creates deterministic Auth Emulator accounts plus Firestore documents for `buyer1`, `buyer2`, `seller1`, `seller2`, and `ops1`.
- The seeded auction and order scenarios now cover live bidding, awaiting payment, seller shipment required, buyer receipt confirmed, settled payout, unpaid cancellation, unsold inventory, cancelled listings, and inbox notifications for both buyer and seller paths.
- The default seeded orders now include both `seller1` and `seller2` shipment-required scenarios, plus separate ended-auction records for awaiting-payment, confirmed-receipt, and unpaid-cancelled flows so emulator smoke tests stay internally consistent.

## Dev Emulator Accounts
- `npm run seed` now provisions Auth Emulator users and Firestore seed data together.
- `npm run serve` must start `auth`, `functions`, `firestore`, and `storage`, because the seed script writes fixed email/password users into Auth Emulator before seeding Firestore.
- Seeded sign-in accounts:
  - `buyer1@test.local` with password `buyer-pass-1234`
  - `buyer2@test.local` with password `buyer-pass-1234`
  - `seller1@test.local` with password `seller-pass-1234`
  - `seller2@test.local` with password `seller-pass-1234`
  - `ops1@test.local` with password `ops-pass-1234`
- Key seeded smoke paths:
  - buyer awaiting payment: `order-awaiting`
  - seller shipment required: `order-paid`, `order-paid-seller2`
  - buyer shipped and confirmed receipt: `order-shipped`, `order-confirmed`
  - settled payout and unpaid cancellation: `order-settled`, `order-cancelled-unpaid`
- The mobile login screen surfaces only the buyer and seller quick-login actions only when not in release mode and when `APP_ENV=dev` plus `USE_FIREBASE_EMULATORS=true`.
- Buyer smoke test path for auction actions: sign in as `buyer1`, open a live seeded auction, place a manual bid or save an auto-bid ceiling from the auction detail action bar, or use buy-now and verify the app routes into the created order timeline.
- Buyer payment smoke test path: sign in as `buyer1`, open `order-awaiting`, trigger payment preparation, open the Toss sandbox launcher, complete the integrated card-payment test path, and verify the app returns through `/payments/success` to move the order into `PAID_ESCROW_HOLD`.
- Buyer payment return smoke test path: while signed in as `buyer1`, open `app://payments/success?orderId=order-awaiting&paymentKey=test_key&amount=18000` only as a recovery check and verify the payment return screen attempts the same confirmation path before routing back into the order timeline.
- Buyer payment failure return smoke test path: rerun `npm run seed` first to restore `order-awaiting` to `AWAITING_PAYMENT`, then while signed in as `buyer1`, open `app://payments/fail?orderId=order-awaiting&code=PAY_PROCESS_CANCELED&message=test` and verify the payment failure screen returns the user to payment recovery UI without changing that order from `AWAITING_PAYMENT`.
- Seller smoke test path: sign in as `seller1`, open `order-paid`, submit carrier and tracking information, and confirm the order moves to `SHIPPED`.
- Buyer smoke test path: sign in as `buyer1`, open the same `order-paid`, confirm receipt, and verify the order moves to `CONFIRMED_RECEIPT`.
- Phase 3 close-review checklist:
  - Start or reuse the local emulator suite, then run `npm run seed` so seeded auth and Firestore data are in a known state.
  - Buyer close check: sign in as `buyer1`, browse into a live auction, verify bid or buy-now still routes into an order timeline, then verify `order-awaiting` payment preparation and the `app://payments/success?...` recovery path still advance the order correctly.
  - Seller close check: sign in as `seller1`, save or reopen a draft, publish a live auction, then open `order-paid` and verify shipment submission still advances the order to `SHIPPED`.
  - Shared close check: reopen the same shipped order as `buyer1`, confirm receipt, and verify the order advances to `CONFIRMED_RECEIPT`.
  - April 6, 2026 headless close-review evidence already verified the same state transitions against the running emulator suite through callable paths, including `buyNow`, `createPaymentSession`, `createOrUpdateItem`, `createAuctionFromItem`, `shipmentUpdate`, and `confirmReceipt`.
  - Because that April 6 evidence was headless, the only remaining Phase 3 sign-off is the interactive in-app walkthrough of those buyer and seller flows on a clean seeded run.
  - Phase 3 may move to complete only after those manual smoke steps are reviewed together with the latest automated validation run.
- These accounts are for local emulator checks only. They do not validate Google or Apple browser sign-in, provider linking, redirect handling, or staging and prod auth configuration.


## Navigation Contract

- Public route: `/login`.
- Authenticated tab routes: `/home`, `/search`, `/sell`, `/activity`, `/my`.
- Authenticated detail routes: `/auction/:id`, `/orders`, `/orders/:orderId`, `/payments/success`, `/payments/fail`, `/notifications`, `/settings`.
- The router must:
  - restore session before initial route selection.
  - redirect unauthenticated users to `/login`.
  - preserve tab state when switching between bottom navigation tabs.
  - support inbox deep links such as `app://auction/{auctionId}`, `app://orders/{orderId}`, and payment return links such as `app://payments/success?...`.

## Firestore Contract

### `users/{uid}`
- Purpose: user profile, verification state, trust state, and preferences.
- Required fields:
  - `displayName: string`
  - `photoUrl: string | null`
  - `email: string | null`
  - `phoneNumber: string | null`
  - `authProviders: string[]`
  - `bio: string | null`
  - `preferences.languageCode: string | null`
  - `preferences.pushEnabled: boolean`
  - `preferences.notificationCategories.auctionActivity: boolean`
  - `preferences.notificationCategories.orderPayment: boolean`
  - `preferences.notificationCategories.shippingAndReceipt: boolean`
  - `preferences.notificationCategories.system: boolean`
  - `verification.phone: "UNVERIFIED" | "PENDING" | "VERIFIED" | "REJECTED"`
  - `verification.id: "UNVERIFIED" | "PENDING" | "VERIFIED" | "REJECTED"`
  - `verification.preciousSeller: "UNVERIFIED" | "PENDING" | "VERIFIED" | "REJECTED"`
  - `sellerStats.completedSales: number`
  - `sellerStats.totalAuctions: number`
  - `sellerStats.successRate: number`
  - `sellerStats.reviewAvg: number`
  - `sellerStats.gradeScore: number`
  - `penaltyStats.unpaidCount: number`
  - `penaltyStats.depositForfeitedCount: number`
  - `penaltyStats.trustScore: number`
  - `ops.roles: string[]`
  - `ops.disabledAt: Timestamp | null`
  - `createdAt: Timestamp`
  - `updatedAt: Timestamp`
- Client-readable: all fields except operator-only fields may be rendered if needed.
- Client-writable:
  - `displayName`
  - `photoUrl`
  - `bio`
  - `preferences.pushEnabled`
  - `preferences.notificationCategories.*`
- Server-only fields:
  - `authProviders`
  - `verification.*`
  - `sellerStats.*`
  - `penaltyStats.*`
  - `ops.*`
- Rules:
- `preferences.pushEnabled` remains the master notification switch.
- Category toggles only apply when `preferences.pushEnabled == true`.
- The current Phase 4 settings slices read and write `preferences.pushEnabled` and `preferences.notificationCategories.*`; `preferences.languageCode` remains reserved while `deviceTokens` is now a server-managed push-delivery record.
- Theme mode is local-only UI state stored in `SharedPreferences` under the mobile app and is not part of the Firestore user schema.

### `users/{uid}/deviceTokens/{tokenId}`
- Purpose: signed-in device tokens for push delivery.
- Required fields:
  - `token: string`
  - `platform: "ANDROID" | "IOS"`
  - `locale: string`
  - `timezone: string`
  - `appVersion: string`
  - `permissionStatus: "AUTHORIZED" | "DENIED" | "PROVISIONAL" | "NOT_DETERMINED"`
  - `isActive: boolean`
  - `lastSeenAt: Timestamp`
  - `createdAt: Timestamp`
  - `updatedAt: Timestamp`
- Server-managed through the `registerDeviceToken` and `deactivateDeviceToken` callables only.
- Current mobile behavior:
  - call `registerDeviceToken` after sign-in when permission is `AUTHORIZED` or `PROVISIONAL`
  - refresh locale, timezone, appVersion, and `lastSeenAt` through the same callable when FCM rotates the token
  - call `deactivateDeviceToken` when permission is no longer granted, when push is disabled in settings, or just before sign-out
  - keep the cached token id in local `SharedPreferences` so the next sync can deactivate or replace the same installation token deterministically
- Rules:
  - User can read only their own device tokens.
  - Client must not write tokens directly.
  - Token registration and deactivation go through Functions so server delivery code can trust token ownership and token shape.

### `items/{itemId}`
- Purpose: seller-owned listing draft and item content record.
- Required fields:
  - `sellerId: string`
  - `status: "DRAFT" | "READY" | "ARCHIVED"`
  - `categoryMain: "GOODS" | "PRECIOUS"`
  - `categorySub: string`
  - `title: string`
  - `description: string`
  - `condition: string`
  - `tags: string[]`
  - `imageUrls: string[]`
  - `authImageUrls: string[]`
  - `isOfficialMd: boolean | null`
  - `draftAuction.startPrice: number | null`
  - `draftAuction.buyNowPrice: number | null`
  - `draftAuction.durationDays: number | null`
  - `appraisal.status: "NONE" | "REQUESTED" | "APPROVED" | "REJECTED"`
  - `appraisal.badgeLabel: string | null`
  - `createdAt: Timestamp`
  - `updatedAt: Timestamp`
- Rules:
  - Seller can create and update drafts only through Functions.
  - `authImageUrls` must contain at least one image when `categoryMain` is `GOODS`.
  - Live auctions freeze the item snapshot at publish time.

### `auctions/{auctionId}`
- Purpose: public auction record used by home feed, search results, detail page, and order creation.
- Required fields:
  - `itemId: string`
  - `sellerId: string`
  - `titleSnapshot: string`
  - `heroImageUrl: string`
  - `categoryMain: "GOODS" | "PRECIOUS"`
  - `categorySub: string`
  - `startPrice: number`
  - `buyNowPrice: number | null`
  - `currentPrice: number`
  - `status: "DRAFT" | "LIVE" | "ENDED" | "UNSOLD" | "CANCELLED"`
  - `startAt: Timestamp`
  - `endAt: Timestamp`
  - `extendedCount: number`
  - `bidCount: number`
  - `bidderCount: number`
  - `highestBidderId: string | null`
  - `orderId: string | null`
  - `createdAt: Timestamp`
  - `updatedAt: Timestamp`
- Rules:
  - Public reads are allowed.
  - Client writes are never allowed.
  - Snapshot fields are copied from the item when the auction is created.
  - Detail screen can fetch the full `items/{itemId}` document after reading the auction.

### `auctions/{auctionId}/bids/{bidId}`
- Purpose: immutable bid history.
- Required fields:
  - `bidderId: string`
  - `amount: number`
  - `kind: "MANUAL" | "AUTO"`
  - `createdAt: Timestamp`
- Rules:
  - Server writes only.
  - Client reads allowed for signed-in users.

### `auctions/{auctionId}/autoBids/{uid}`
- Purpose: bidder max price for auto-bid.
- Required fields:
  - `maxAmount: number`
  - `isEnabled: boolean`
  - `createdAt: Timestamp`
  - `updatedAt: Timestamp`
- Rules:
  - User can read only their own config.
  - User writes go through `setAutoBid` only.

### `orders/{orderId}`
- Purpose: payment, shipping, and settlement state.
- Required fields:
  - `auctionId: string`
  - `itemId: string`
  - `buyerId: string`
  - `sellerId: string`
  - `finalPrice: number`
  - `paymentStatus: "UNPAID" | "PENDING" | "PAID" | "FAILED" | "CANCELLED" | "REFUNDED"`
  - `orderStatus: "AWAITING_PAYMENT" | "PAID_ESCROW_HOLD" | "SHIPPED" | "CONFIRMED_RECEIPT" | "SETTLED" | "CANCELLED_UNPAID" | "CANCELLED"`
  - `paymentDueAt: Timestamp`
  - `payment.provider: string`
  - `payment.paymentKey: string | null`
  - `payment.method: string | null`
  - `payment.approvedAt: Timestamp | null`
  - `payment.lastWebhookEventId: string | null`
  - `shipping.carrierCode: string | null`
  - `shipping.carrierName: string | null`
  - `shipping.trackingNumber: string | null`
  - `shipping.trackingUrl: string | null`
  - `shipping.shippedAt: Timestamp | null`
  - `settlement.expectedAt: Timestamp | null`
  - `settlement.settledAt: Timestamp | null`
  - `settlement.payoutBatchId: string | null`
  - `fees.feeRate: number`
  - `fees.feeAmount: number`
  - `fees.sellerReceivable: number`
  - `createdAt: Timestamp`
  - `updatedAt: Timestamp`
- Rules:
  - Buyer and seller can read their own orders.
  - Client writes are never allowed.
  - Payment confirm and webhook handling must be idempotent.

### `notifications/{uid}/inbox/{notificationId}`
- Purpose: in-app inbox.
- Required fields:
  - `type: string`
  - `category: "auctionActivity" | "orderPayment" | "shippingAndReceipt" | "system"`
  - `title: string`
  - `body: string`
  - `deeplink: string`
  - `entityType: "AUCTION" | "ORDER" | "SYSTEM"`
  - `entityId: string | null`
  - `isRead: boolean`
  - `createdAt: Timestamp`
- Rules:
  - User can read and mark their own notifications as read.
  - Server creates notification documents.
  - Phase 4 backend dispatch now uses the same inbox write as the source of truth for push fan-out, so inbox creation must succeed even when push delivery fails.

### Push Delivery
- Backend now evaluates push delivery from the same event that writes `notifications/{uid}/inbox/{notificationId}`.
- Delivery gate:
  - `preferences.pushEnabled == true`
  - the mapped notification category is enabled under `preferences.notificationCategories.*`
  - at least one `users/{uid}/deviceTokens/{tokenId}` record is active and has `permissionStatus` of `AUTHORIZED` or `PROVISIONAL`
- The current backend fan-out covers the inbox-backed event types that already exist:
  - `OUTBID`
  - `AUTO_BID_CEILING_REACHED`
  - `WON`
  - `BUY_NOW_COMPLETED`
  - `ORDER_AWAITING_PAYMENT`
  - `PAYMENT_COMPLETED`
  - `PAYMENT_DUE`
  - `PAYMENT_FAILED`
  - `SHIPMENT_REMINDER`
  - `SHIPPED`
  - `RECEIPT_REMINDER`
  - `RECEIPT_CONFIRMED`
  - `SETTLED`
- Reminder events (`PAYMENT_DUE`, `SHIPMENT_REMINDER`, `RECEIPT_REMINDER`) now use deterministic inbox ids per order so scheduler retries do not duplicate inbox rows or push sends.
- Current push payload data fields:
  - `notificationId`
  - `type`
  - `category`
  - `deeplink`
  - `entityType`
  - `entityId`
  - `timestamp`
- Backend push dispatch is best-effort only. Business mutations and inbox writes must not fail when Firebase Admin Messaging send attempts fail.
  - Every supported push event must have a matching inbox document with the same logical event identity.
- Current mobile handling for those payloads is:
  - `onMessage`: show a surfaced in-app `SnackBar` with an open action
  - `onMessageOpenedApp` and `getInitialMessage`: best-effort mark the linked inbox item as read, then route through the existing app deep-link resolver
  - malformed, missing, or unsupported push deeplinks: fall back to `/notifications` instead of failing navigation
  - Android: use the manifest-declared default Firebase Messaging channel id and create the matching notification channel from `MainActivity` on Android O and above

### `auditEvents/{eventId}`
- Purpose: server-only event trace for payment, auction, order, and scheduler transitions.
- Required fields:
  - `entityType: "AUCTION" | "ORDER" | "PAYMENT" | "USER"`
  - `entityId: string`
  - `eventType: string`
  - `actorId: string | null`
  - `payload: map`
  - `createdAt: Timestamp`
- Rules:
  - Server read and write only.
  - Use for webhook trace, idempotency investigation, and support review.

## Firestore Read Model
- Home ending soon:
  - query `auctions` where `status == "LIVE"` order by `endAt asc`.
- Home hot auctions:
  - query `auctions` where `status == "LIVE"` order by `bidCount desc`.
- Search:
  - query `auctions` where `status == "LIVE"` and filter by category, price range, and buy-now availability.
- Seller activity:
  - query `auctions` where `sellerId == currentUserId` order by `createdAt desc`.
- Buyer orders:
  - query `orders` where `buyerId == currentUserId` order by `createdAt desc`.
- Seller orders:
  - query `orders` where `sellerId == currentUserId` order by `createdAt desc`.
- Inbox:
  - query `notifications/{uid}/inbox` order by `createdAt desc`.
- Bid activity:
  - use `collectionGroup("bids")` filtered by `bidderId == currentUserId`.

## Current Phase 2 Implementation Details
- `backend/functions/src/index.ts` now exports the documented callable write surface for profile bootstrap, item save, auction publish/cancel/relist, bidding, buy-now, payment session creation, payment confirmation, shipment, receipt confirmation, and inbox read state.
- `backend/functions/src/index.ts` also exports the current provider-specific webhook endpoint and scheduler handlers for auction activation, auction finalization, unpaid expiry, reminder notification emission, and settlement.
- `backend/functions/src/domain/paymentEngine.ts` owns webhook normalization, idempotency detection, and order-state mapping for confirmed and cancelled payment events.
- `backend/functions/src/domain/orderEngine.ts` now owns fee calculation in addition to unpaid-order expiry and penalty calculation.
- `backend/emulator-seed/seed.ts` now matches the documented schema for users, items, auctions, bids, orders, and notifications.
- Legacy item payload compatibility remains accepted at the callable boundary:
  - `images` maps to `imageUrls`
  - `goodsAuthImages` maps to `authImageUrls`

## Functions Write Contract
- `bootstrapUserProfile`
  - Create user profile on first login.
  - Sync auth providers and safe profile defaults.
- `createOrUpdateItem`
  - Save or update seller draft item.
- `createAuctionFromItem`
  - Publish an item as an auction.
- `cancelAuction`
  - Cancel a draft or live auction only when no winning order exists.
- `relistAuction`
  - Create a fresh draft auction from an unsold or cancelled auction.
- `placeBid`
  - Validate live auction, increment, anti-sniping, and auto-bid competition.
- `setAutoBid`
  - Enable, update, or disable one bidder auto-bid config.
- `buyNow`
  - End auction immediately and create the order in `AWAITING_PAYMENT`.
- `createPaymentSession`
  - Validate order ownership and status.
  - Return a payment payload with `mode`.
  - In Firebase Emulator `dev`, return `mode: "DEV_DUMMY"` plus deterministic `devPaymentKey: "dev_pay_{orderId}"` only when real sandbox handoff is not enabled.
  - When `ENABLE_TOSS_SANDBOX=true`, return the real Toss sandbox handoff payload with `checkoutUrl` plus fixed bridge `successUrl` and `failUrl` routes from `APP_BASE_URL`.
  - Success and fail bridge routes stay query-free. Toss appends `orderId`, `paymentKey`, and `amount` on redirect.
- `confirmOrderPayment`
  - Accept the deterministic `dev_pay_{orderId}` key only for emulator-backed `DEV_DUMMY` sessions.
  - Otherwise confirm payment against the active provider confirm endpoint.
  - Update the order idempotently and notify the seller on success.
- `shipmentUpdate`
  - Validate seller ownership and shipping state.
- `confirmReceipt`
  - Validate buyer ownership and move order toward settlement.
- `markNotificationRead`
  - Mark one inbox document as read for the current user.
- `sendDebugPushProbe`
  - Trigger one debug-only inbox plus push probe for the current signed-in user.
  - Allowed only when backend runtime `APP_ENV=dev`.
  - Writes `type`, `category`, `entityType`, `entityId`, and `deeplink` compatible with the existing push payload contract.
- `registerDeviceToken`
  - Register or refresh one signed-in device token for the current user.
  - Persist locale, timezone, app version, and permission status for delivery diagnostics.
- `deactivateDeviceToken`
  - Deactivate one device token on sign-out, uninstall signal, or explicit notification disable flow.

## HTTP And Webhook Contract
- `tossPaymentWebhook`
  - Accept current provider webhook events over HTTPS through the current provider-specific endpoint name.
  - Verify the configured webhook secret from the payload.
  - Use an event marker plus `payment.lastWebhookEventId` to avoid double-processing.
  - Transition orders for `DONE`, `CANCELED`, `ABORTED`, and `EXPIRED` payment events.
- Render dev server: `POST /api/notifications/debug/push-probe`
  - Auth required via Firebase ID token bearer auth.
  - Allowed only when server runtime `APP_ENV=dev`.
  - Creates inbox notification and attempts push dispatch using the same preference and token eligibility rules as Functions:
    - `preferences.pushEnabled`
    - `preferences.notificationCategories.system`
    - active token + deliverable permission (`AUTHORIZED` or `PROVISIONAL`)

## Scheduler Contract
- `activateDraftAuctionsScheduler`
  - Move `DRAFT` auctions to `LIVE` when `startAt <= now`.
- `finalizeAuctionsScheduler`
  - Move ended live auctions to `ENDED` or `UNSOLD`.
  - Create winning order when needed.
- `expireUnpaidOrdersScheduler`
  - Move overdue unpaid orders to `CANCELLED_UNPAID`.
  - Apply buyer penalty and write audit event.
- `orderReminderNotificationsScheduler`
  - Emit `PAYMENT_DUE`, `SHIPMENT_REMINDER`, and `RECEIPT_REMINDER` once per order reminder type.
  - Use deterministic inbox ids and transaction preconditions so stale scheduler snapshots do not create or dispatch reminders after status transitions.
  - Query reminders with a bounded lookback window to prevent unbounded re-scan of long-resolved historical orders.
- `settleScheduler`
  - Move `CONFIRMED_RECEIPT` orders to `SETTLED` when settlement window passes.

## Storage Contract
- Seller item gallery uploads:
  - `items/{sellerId}/{itemId}/gallery/{fileId}.jpg`
- Seller item auth uploads:
  - `items/{sellerId}/{itemId}/auth/{fileId}.jpg`
- User profile avatar uploads:
  - `profiles/{uid}/avatar/{fileId}.jpg`
- Rules:
  - Authenticated users can upload only into their own scoped path.
  - Files must have image mime type and enforced size limits.
  - Item mutation payloads reference only files already uploaded for the same owner.

## Notification And Deep Link Contract
- Push-delivery scope, categories, payload rules, and preference behavior are defined in `docs/Notification.md`.
- Every supported push event must also create a Firestore inbox document for the same user-visible event.
- Auction outbid: `app://auction/{auctionId}`
- Auction won: `app://orders/{orderId}`
- Payment completed: `app://orders/{orderId}`
- Shipment started: `app://orders/{orderId}`
- Payment expired: `app://orders/{orderId}`
- The app router must parse these links without a web fallback.

## Security Rules
- Firestore direct writes remain disabled for:
  - `items`
  - `auctions`
  - `bids`
  - `autoBids`
  - `orders`
  - `users/{uid}/deviceTokens/{tokenId}`
  - server-owned user fields
- Add App Check in staging and prod.
- Validate callable inputs centrally before domain logic runs.
- Rate-limit bid and payment endpoints.
- Store structured logs and audit events for critical state changes.

## Deployment And Rollback
- Deploy order:
  1. Update env values in local secret files.
  2. Run backend tests and build.
  3. Run Flutter tests.
  4. Seed or verify staging data.
  5. Deploy Functions and Firestore rules.
  6. Ship mobile build with staging or prod public config.
- Rollback order:
  1. Stop new mobile rollout.
  2. Roll back Functions to last stable version.
  3. Revert rules or indexes only if the last deploy changed them.
  4. Review audit events and structured logs.

## Test Contract
- Backend unit tests:
  - bid increment
  - anti-sniping
  - auto-bid competition
  - buy now
  - unpaid expiration
  - settlement
  - validation errors
  - idempotent payment confirm
- Backend integration tests:
  - rules ownership checks
  - seeded query behavior
  - notification creation
  - payment webhook reflection
  - scheduler transitions
- Flutter tests:
  - auth gate
  - home feed cards
  - auction detail call-to-action states
  - sell form validation
  - orders list states
  - empty, loading, and error states

## Release Gates
- No hardcoded external values.
- No fake repository or production-facing mock payment path. `dev` may use documented server-driven dummy integration payloads when a real third-party handoff is still pending.
- No placeholder screens or disabled primary actions in core flows.
- Shared blocking loading UI uses `apps/mobile_flutter/assets/lotties/loading.lottie`, and dark mode plus overflow-prone layouts are validated on supported device sizes.
- Emulator and staging both boot from documented config only.
- A new engineer can follow docs and run the project without tribal knowledge.
