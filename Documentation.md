# Auction Market Technical Documentation

## Source Of Truth
- This file is the implementation contract for schema, write paths, environment loading, and operations.
- `docs/Design.md` is the visual and UX contract.
- `docs/Environment.md` is the external config contract.
- `Implement.md` is the live execution log.

## Repo Layout
- `apps/mobile_flutter`: mobile app.
- `backend/functions`: Firebase Functions.
- `backend/emulator-seed`: deterministic emulator seed data.
- `backend/firestore.rules`: Firestore read and write policy.
- `backend/firestore.indexes.json`: Firestore query indexes.

## Environment Model
- `dev`: local emulator for Auth, Functions, Firestore, and Storage. Uses seeded data only.
- `staging`: real Firebase project plus Toss test credentials.
- `prod`: real Firebase project plus Toss production credentials.
- The app switches environment only through build-time public config for `APP_ENV`, emulator mode, and other non-secret app settings.
- Backend runtime switches environment only through env variables.
- Flutter mobile boot on iOS and Android reads Firebase app registration from native platform files instead of `dart-define` values.
- Mobile locale selection follows the device locale and falls back to Korean when the device language is unsupported.

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
  - `lib/core/app_config/app_config.dart` validates only non-secret app defines such as `APP_ENV`, emulator mode, and Toss client key.
  - `lib/core/firebase/firebase_bootstrap.dart` initializes Firebase from native iOS and Android config files, then attaches Auth, Firestore, Functions, and Storage emulators when enabled.
  - `lib/core/l10n/app_localization.dart` resolves device locale to `ko` or `en` and exposes generated localization accessors.
  - `lib/core/extensions/build_context_x.dart` centralizes repeated `BuildContext` lookups like `Theme.of`, `ScaffoldMessenger.of`, `MediaQuery.of`, and `Navigator.of`.
  - `lib/core/routing/app_router.dart` owns guarded routing and deep-link normalization.
  - `lib/core/theme/app_theme.dart` applies the warm neutral, charcoal, copper, coral, and sage token system from `docs/Design.md`, including anchored navigation and sticky action sizing.
  - `lib/core/widgets/` owns the shared editorial hero, auction card, shell, page scaffold, panel, badge, section heading, sticky action bar, and empty-state primitives.
  - `apps/mobile_flutter/analysis_options.yaml` now excludes generated localization files from manual lint noise, enables strict analyzer modes for casts, inference, and raw types, and adds a small set of project-wide lint rules for explicit return types, final locals and fields, and redundant lambda cleanup.
- Current mobile UX and localization implementation details:
  - `apps/mobile_flutter/lib/l10n/app_ko.arb` and `apps/mobile_flutter/lib/l10n/app_en.arb` own user-facing mobile copy for `ko` and `en`.
  - `lib/app/app.dart` wires `supportedLocales`, localization delegates, and locale fallback into `MaterialApp`.
  - Login, home, search, auction detail, sell, activity, orders, notifications, and my screens now use localized copy and the shared editorial design primitives.
  - Login now blocks Google and Apple browser sign-in when `USE_FIREBASE_EMULATORS=true`, because the project treats mobile social-login verification as a real-Firebase path rather than an Auth Emulator path.
  - Login also exposes seeded buyer and seller quick-login actions only when `APP_ENV=dev` and `USE_FIREBASE_EMULATORS=true`, so emulator smoke tests can enter authenticated routes without live social login.
  - Login now keeps seeded account constants in `features/auth/data`, auth mutations in `features/auth/application`, and each major visual block in `features/auth/presentation/widgets`.
  - Auction detail now keeps the screen in `presentation`, pushes callable writes through `features/auction/application/auction_detail_action_service.dart`, and maps Firestore documents through `features/auction/data/auction_detail_view_data.dart`.
  - Orders now keeps the screen layout in `presentation`, pushes payment, shipment, and receipt callables through `features/orders/application/order_action_service.dart`, and maps Firestore documents through `features/orders/data/order_summary.dart`.
  - Sell now keeps Functions and Storage writes in `features/sell/application/sell_flow_service.dart`, draft mapping in `features/sell/data`, and section widgets in `features/sell/presentation/widgets`, so the route screen mostly owns form state and composition.
  - Activity now keeps queue summary mapping in `features/activity/data` and composes buyer, seller, and notification stream cards from dedicated widgets instead of using static navigation-only tiles.
  - Home now maps auction rail documents through `features/home/data/home_auction_summary.dart` and keeps reusable rail and action button widgets in `features/home/presentation/widgets`.
  - Search now maps Firestore records through `features/search/data/search_auction_summary.dart`, keeps filtering logic in `features/search/application/search_auction_filter.dart`, and uses dedicated query, filter-chip, and result-grid widgets.
  - My now maps the user document through `features/my/data/my_profile_summary.dart`, keeps verification label logic separate, and composes account and verification blocks from dedicated widgets.
  - Notifications now reuse the shared app deep-link normalizer instead of carrying a screen-local route parser.
  - Auction detail now runs `placeBid`, `setAutoBid`, and `buyNow` from the sticky action bar when the viewer is an eligible buyer on a live auction, and redirects completed buy-now orders into `/orders/{orderId}`.
  - Orders now routes `createPaymentSession`, `confirmOrderPayment`, `shipmentUpdate`, and `confirmReceipt` through `features/orders/application/order_action_service.dart`, and notifications call `markNotificationRead` before deep-link navigation.
  - Buyer order cards now surface `AWAITING_PAYMENT` actions, prepare the Toss payment session in-app, and allow manual payment-key confirmation without introducing a fake checkout flow when final public payment config is still missing.
  - Sell uses `image_picker` plus Firebase Storage upload paths under `users/{uid}/items/{itemId}/gallery/*` and `users/{uid}/auth/{itemId}/*`, then persists draft data through `createOrUpdateItem` before publish.
  - Sell drafts now persist `draftAuction.startPrice`, `draftAuction.buyNowPrice`, and `draftAuction.durationDays` on `items/{itemId}`, so sellers can reload pricing intent before publishing.
  - Activity now reads `orders` and `notifications/{uid}/inbox` directly to highlight pending buyer payments, buyer receipt confirmations, seller shipment work, and unread inbox updates in one screen.
  - Home, search, auction detail, orders, notifications, and my pages render from live Firestore read paths and fall back to localized empty or unavailable states when documents are missing.
- Read data directly from Firestore and Storage-backed URLs.
- Send mutations through Firebase Functions only.
- Native Firebase config files live at:
  - `apps/mobile_flutter/ios/Runner/GoogleService-Info.plist`
  - `apps/mobile_flutter/android/app/google-services.json`

## Localization Contract
- Supported locales are `ko` and `en` only.
- Locale resolution is device-driven. The app does not persist a manual locale override in v1.
- Static user-facing copy must come from generated localizations, not hardcoded strings in widgets.
- Dynamic Firestore content may remain backend-authored text, but fallback labels, badges, and empty/error states must be localized in the app.

## Backend Implementation Notes
- `backend/functions/src/config/runtime.ts` validates backend runtime env such as `APP_ENV`, `GCLOUD_PROJECT`, Toss secrets, Toss API base URL, and `APP_BASE_URL`.
- `backend/functions/src/domain/paymentEngine.ts` owns payment confirmation idempotency helpers, webhook normalization, and payment state transitions.
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
  - `tossPaymentWebhook`
  - `activateDraftAuctionsScheduler`
  - `finalizeAuctionsScheduler`
  - `expireUnpaidOrdersScheduler`
  - `settleScheduler`
- Critical transitions now write `auditEvents` records for user bootstrap, item and auction lifecycle, bids, payment confirmation and failure, shipment, receipt confirmation, unpaid expiry, and settlement.
- The Toss webhook path verifies the configured webhook secret from the payload, applies idempotent payment transitions through `payment.lastWebhookEventId`, and updates the order instead of relying on a mock payment mutation.
- The emulator seed now creates deterministic Auth Emulator accounts plus Firestore documents for `buyer1`, `seller1`, and `ops1`, a live auction with bids and auto-bid config, an ended auction with an awaiting-payment order, and inbox notifications for both sides.
- The default seeded `order-paid` document now starts in `PAID_ESCROW_HOLD` with empty shipping data, so the seller can submit shipment first and the buyer can confirm receipt afterward during emulator smoke tests.

## Dev Emulator Accounts
- `npm run seed` now provisions Auth Emulator users and Firestore seed data together.
- `npm run serve` must start `auth`, `functions`, `firestore`, and `storage`, because the seed script writes fixed email/password users into Auth Emulator before seeding Firestore.
- Seeded accounts for smoke tests:
  - `buyer1@test.local` with password `buyer-pass-1234`
  - `seller1@test.local` with password `seller-pass-1234`
  - `ops1@test.local` with password `ops-pass-1234`
- The mobile login screen surfaces only the buyer and seller quick-login actions in `dev` emulator mode.
- Buyer smoke test path for auction actions: sign in as `buyer1`, open a live seeded auction, place a manual bid or save an auto-bid ceiling from the auction detail action bar, or use buy-now and verify the app routes into the created order timeline.
- Seller smoke test path: sign in as `seller1`, open `order-paid`, submit carrier and tracking information, and confirm the order moves to `SHIPPED`.
- Buyer smoke test path: sign in as `buyer1`, open the same `order-paid`, confirm receipt, and verify the order moves to `CONFIRMED_RECEIPT`.
- These accounts are for local emulator checks only. They do not validate Google or Apple browser sign-in, provider linking, redirect handling, or staging and prod auth configuration.

## Navigation Contract
- Public route: `/login`.
- Authenticated tab routes: `/home`, `/search`, `/sell`, `/activity`, `/my`.
- Authenticated detail routes: `/auction/:id`, `/orders`, `/orders/:orderId`, `/notifications`.
- The router must:
  - restore session before initial route selection.
  - redirect unauthenticated users to `/login`.
  - preserve tab state when switching between bottom navigation tabs.
  - support inbox deep links such as `app://auction/{auctionId}` and `app://orders/{orderId}`.

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
  - `preferences.languageCode: string`
  - `preferences.pushEnabled: boolean`
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
  - `preferences.*`
- Server-only fields:
  - `authProviders`
  - `verification.*`
  - `sellerStats.*`
  - `penaltyStats.*`
  - `ops.*`

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
  - `payment.provider: "TOSS_PAYMENTS"`
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
  - `title: string`
  - `body: string`
  - `deeplink: string`
  - `isRead: boolean`
  - `createdAt: Timestamp`
- Rules:
  - User can read and mark their own notifications as read.
  - Server creates notification documents.

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
- `backend/functions/src/index.ts` now exports the documented callable write surface for profile bootstrap, item save, auction publish/cancel/relist, bidding, buy-now, payment session creation, Toss payment confirmation, shipment, receipt confirmation, and inbox read state.
- `backend/functions/src/index.ts` also exports `tossPaymentWebhook` and the four scheduler handlers with full order-schema writes.
- `backend/functions/src/domain/paymentEngine.ts` owns webhook normalization, idempotency detection, and order-state mapping for confirmed and cancelled Toss payment events.
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
  - Return safe client payment payload for Toss widget or SDK, including success and fail return URLs when `APP_BASE_URL` is configured.
- `confirmOrderPayment`
  - Confirm payment against Toss `/v1/payments/confirm`.
  - Update the order idempotently and notify the seller on success.
- `shipmentUpdate`
  - Validate seller ownership and shipping state.
- `confirmReceipt`
  - Validate buyer ownership and move order toward settlement.
- `markNotificationRead`
  - Mark one inbox document as read for the current user.

## HTTP And Webhook Contract
- `tossPaymentWebhook`
  - Accept Toss payment webhook events over HTTPS.
  - Verify the configured webhook secret from the payload.
  - Use an event marker plus `payment.lastWebhookEventId` to avoid double-processing.
  - Transition orders for `DONE`, `CANCELED`, `ABORTED`, and `EXPIRED` payment events.

## Scheduler Contract
- `activateDraftAuctionsScheduler`
  - Move `DRAFT` auctions to `LIVE` when `startAt <= now`.
- `finalizeAuctionsScheduler`
  - Move ended live auctions to `ENDED` or `UNSOLD`.
  - Create winning order when needed.
- `expireUnpaidOrdersScheduler`
  - Move overdue unpaid orders to `CANCELLED_UNPAID`.
  - Apply buyer penalty and write audit event.
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
- No fake repository or mock payment path.
- No placeholder screens or disabled primary actions in core flows.
- Emulator and staging both boot from documented config only.
- A new engineer can follow docs and run the project without tribal knowledge.
