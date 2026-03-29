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
- App UI copy supports Korean and English through localization resources, and the app follows the device locale without an in-app language switch for v1.
- Developer docs, type names, API contracts, and architecture notes stay in plain English.
- Do not hardcode external IDs, tokens, or secrets.
- Secrets live in backend runtime env only.
- Public client values live in app config or build-time defines only.
- The default and preferred dummy data path is Firebase Emulator + seed data that uses the real schema.
- If a third-party handoff is blocked by missing real external values, `dev` may use a documented server-driven fallback only for that exact blocked handoff until the real cutover is wired.
- Do not add fake repositories, fake network layers, fake order states, or placeholder call-to-action buttons.
- Sensitive writes go through Firebase Functions. Firestore direct writes stay blocked for auctions, bids, orders, and server-owned user fields.

## Product Scope For v1
- Auth: Apple sign in and Google sign in through Firebase Auth.
- Browse: home feed, search, filters, auction detail, seller summary, notifications.
- Sell: draft item, upload images, publish auction, edit draft, relist unsold item.
- Buy: manual bid, auto-bid, buy now, TossPayments payment, order tracking.
- Orders: payment pending, paid, shipped, receipt confirmed, settled.
- Operations: emulator seed, staging deploy, prod deploy, rollback runbook, release gate checklist.

## Locked Defaults
- State management: Riverpod.
- Routing: `go_router` with auth guard, session restore, deep link support, and tab state preservation.
- Payment provider: TossPayments.
- Storage provider: Firebase Storage.
- Push and inbox notifications: Firebase Messaging + Firestore inbox documents.
- App design direction: premium resale market, warm neutral base, charcoal surfaces, copper and coral accents.
- Shared loading animation asset: `apps/mobile_flutter/assets/lotties/loading.lottie`.
- Auction anti-sniping rule: bid within last 5 minutes extends end time by 5 minutes, up to 3 times.
- Settlement model for v1: server ledger plus operator-assisted payout release.

## Release Definition
- No hardcoded external values in the repo.
- No fake repository or mock payment path in app or backend.
- No placeholder screens or disabled primary actions on core flows.
- All screens render from Firestore reads and Functions writes.
- Emulator can boot with seed data and exercise the full buyer and seller flow.
- Staging can boot with real Firebase and Toss test credentials.
- Pre-cutover UI polish such as dark mode, async feedback, overflow fixes, blur tuning, and transition smoothing can ship before the final real Toss launcher handoff, as long as the blocked handoff remains clearly documented.
- Docs are sufficient for a new engineer or agent to start `dev` and `staging`.

## Out Of Scope For v1
- Kakao login.
- Naver login.
- Web or desktop client.
- Fully automated seller payout.
- Subscription, premium listing, or appraisal upsell flows beyond existing feature-flag placeholders.
