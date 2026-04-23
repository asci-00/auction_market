# Auction Market Build Prompt

## Goal
- Build a production-ready mobile-first C2C auction app for iOS and Android (not consider web).
- Use Flutter for the app and Firebase for backend, auth, storage, notifications, and scheduled jobs.
- Ship a product that can run in `dev`, `staging`, and `prod` without fake repositories or fake UI.

## Target Users
- Buyer: browses auctions, bids, buys now, pays, tracks shipment, confirms receipt.
- Seller: creates item drafts, publishes auctions, monitors bids, ships sold items, receives settlement.
- Operator: manages configuration, monitors errors, reviews payment and settlement events, handles support cases.

## Non-Negotiables
- App UI copy supports Korean and English through localization resources. The app defaults to the device locale and may allow an in-app override for supported locales.
- Developer docs, type names, API contracts, and architecture notes stay in plain English.
- Do not hardcode external IDs, tokens, or secrets.
- Secrets live in backend runtime env only.
- Public client values live in app config or build-time defines only.
- The default and preferred dummy data path is backend-owned HTTP APIs backed by Firebase Emulator + seed data that uses the real schema.
- If a third-party handoff is blocked by missing real project values, `dev` may use a documented server-driven fallback only for that exact blocked handoff.
- Do not add fake repositories, fake network layers, fake order states, or placeholder call-to-action buttons.
- Sensitive writes go through server-owned backend APIs. Firestore direct writes stay blocked for auctions, bids, orders, and server-owned user fields.

## Product Scope For v1
- Auth: Apple sign in and Google sign in through Firebase Auth.
- Browse: home feed, search, filters, auction detail, seller summary, inbox notifications, and push-trigger deep links.
- Sell: draft item, upload images, publish auction, edit draft, relist unsold item.
- Buy: manual bid, auto-bid, buy now, payment-provider-backed checkout, order tracking.
- Orders: payment pending, paid, shipped, receipt confirmed, settled.
- Settings: notification preferences, theme mode, language selection, licenses, version, and debug-only developer controls.
- Operations: emulator seed, staging deploy, prod deploy, rollback runbook, release gate checklist.

## Locked Defaults
- State management: Riverpod.
- Routing: `go_router` with auth guard, session restore, deep link support, and tab state preservation.
- Payment integration stays adapter-based until the user explicitly activates the deferred cutover work in `Plan.md`.
- Storage provider: Firebase Storage.
- Push and inbox notifications: Firebase Messaging + backend-owned inbox documents surfaced through HTTP APIs.
- Theme mode default: follow system until the user selects a manual override in settings.
- App design direction: premium resale market, warm neutral base, charcoal surfaces, copper and coral accents.
- Shared loading animation asset: `apps/mobile_flutter/assets/lotties/loading.lottie`.
- Auction anti-sniping rule: bid within last 5 minutes extends end time by 5 minutes, up to 3 times.
- Settlement model for v1: server ledger plus operator-assisted payout release.

## Release Definition
- No hardcoded external values in the repo.
- No fake repository or production-facing mock payment path in app or backend.
- No placeholder screens or disabled primary actions on core flows.
- All screens render from backend HTTP read APIs and server-mediated writes; the backend owns Firestore access for runtime product data.
- Emulator can boot with seed data and exercise the full buyer and seller flow.
- Staging can boot with real Firebase. Deferred external PG cutover is activated only when the user explicitly requests it.
- UI polish such as dark mode, async feedback, overflow fixes, blur tuning, and transition smoothing can ship before deferred external provider handoff work begins.
- Release builds must hide debug-only menus, copy, and diagnostics while keeping production-safe logs for actionable failures.
- External PG cutover planning lives only in `Plan.md` under `Phase Undecided`.
- Docs are sufficient for a new engineer or agent to start `dev` and `staging`.

## Out Of Scope For v1
- Kakao login.
- Naver login.
- Web or desktop client.
- Fully automated seller payout.
- Subscription, premium listing, or appraisal upsell flows beyond existing feature-flag placeholders.
