# Auction Market Delivery Plan

## Phase 0: Documentation And Config Contracts
Status: complete.
- Create `Prompt.md`, `Plan.md`, `Implement.md`, `Documentation.md`, `docs/Design.md`, and `docs/Environment.md`.
- Expand root `.env.example` into a full local inventory summary.
- Add `backend/functions/.env.example` for backend runtime secrets and service settings.
- Add `apps/mobile_flutter/dart_defines.example.json` for public mobile config.
- Add ignore rules for local secret files and generated outputs.

### Done When
- Every required document exists.
- Every external value has an exact variable name and load location.
- Missing values are marked only where the real value cannot be known yet.

## Phase 1: Platform Foundation
Status: complete.
- Add mobile app core folders: `app_config`, `firebase`, `routing`, `theme`, `error`, `widgets`.
- Add Firebase bootstrap for app startup, auth state restore, emulator switch, and crash-safe startup errors.
- Replace basic router with guarded routes, deep links, and persistent tab navigation.
- Replace default theme with a documented token system that matches `docs/Design.md`.

### Done When
- App can boot in emulator mode and real project mode from build-time defines.
- Login state controls route access.
- Base theme, typography, spacing, and core components are shared across all screens.

## Phase 2: Backend Hardening
Status: complete on March 17, 2026.
- Lock the Firestore schema from `Documentation.md`.
- Split user-editable fields from server-owned trust, verification, and penalty fields.
- Add missing callable functions for bootstrap, draft lifecycle, cancel and relist, payment session creation, payment confirmation, and notification read state.
- Replace mock payment mutation with TossPayments confirm and webhook handling.
- Add audit events, idempotency markers, and structured logging for critical transitions.
- Expand emulator seed to cover buyer, seller, live auction, ended auction, orders, bids, and notifications.

### Done When
- Emulator and staging use the same schema and write contracts.
- All critical writes run through validated callables or verified webhook handlers.
- Payment and order state changes are idempotent and observable in logs.

## Phase 3: Core Mobile Flows
Status: next unfinished milestone.
- Build login, home, search, auction detail, sell, activity, orders, notifications, and my pages with real Firebase reads and localized UI copy.
- Implement image upload, draft save, auction publish, bid flow, auto-bid flow, buy now, payment, shipment update, and receipt confirmation.
- For dependency-heavy external integrations, keep the app testable in `dev` through server-side dummy responses or emulator-backed payloads until the real integration values are available.
- Schedule the final real external-integration handoff work last within the phase, after the rest of the app flow is testable in `dev`.
- Add loading, empty, error, retry, and permission-denied states for every core screen.
- Remove all placeholder widgets, engineering-status copy, and non-functional primary actions.
- Align the shared design system and screen compositions with the premium editorial direction in `docs/Design.md`.
- Add motion and interaction polish that follows `docs/Design.md`, including page entrance timing, list stagger, bottom-sheet motion, countdown-only animation updates, and tuned surface or blur treatment where it materially improves readability and hierarchy.

### Done When
- Buyer can complete browse to settlement flow in emulator and staging.
- Seller can complete draft to shipment flow in emulator and staging.
- Every route has a clear state model and actionable error handling.
- All mobile copy is localized for `ko` and `en`, with unsupported locales falling back to `ko`.
- Navigation, empty/loading/error states, and screen compositions match the documented premium editorial direction.
- Motion, page transitions, and high-emphasis surfaces match the documented premium editorial direction without adding decorative blur or animation that harms clarity.
- External dependency handoffs that require real third-party values are the last remaining work inside the phase, not a blocker for earlier `dev` app validation.

## Phase 4: Quality, Ops, And Release
- Add backend unit tests, emulator integration tests, Flutter widget tests, and end-to-end flow checks.
- Verify release gates: no hardcoded secrets, no fake repositories, no placeholder UI, docs complete.
- Add deploy, rollback, monitoring, and incident response notes.
- Keep real third-party cutover and production-only integration checks after `dev` server-driven validation paths are already in place.

### Done When
- Test coverage protects core state transitions and auth boundaries.
- Operators can deploy, observe, and roll back without reading source code first.
- Release gate checklist passes in `staging`.
