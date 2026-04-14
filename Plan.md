# Auction Market Delivery Plan

## Phase 0: Documentation And Config Contracts
Status: complete.
- Create `Prompt.md`, `Plan.md`, `Implement.md`, `Documentation.md`, `docs/Design.md`, `docs/Environment.md`, and `docs/Notification.md`.
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
- Replace mock payment mutation with provider-adapter payment confirmation and webhook handling.
- Add audit events, idempotency markers, and structured logging for critical transitions.
- Expand emulator seed to cover buyer, seller, live auction, ended auction, orders, bids, and notifications.

### Done When
- Emulator and staging use the same schema and write contracts.
- All critical writes run through validated callables or verified webhook handlers.
- Payment and order state changes are idempotent and observable in logs.

## Phase 3: Core Mobile Flows
Status: complete on April 6, 2026.
- Build login, home, search, auction detail, sell, activity, orders, notifications, and my pages with real Firebase reads and localized UI copy.
- Implement image upload, draft save, auction publish, bid flow, auto-bid flow, buy now, order timeline behavior, shipment update, and receipt confirmation.
- Continue UI and UX polish work, including dark mode, overflow and keyboard-safety fixes, async feedback timing, route transition smoothness, tuned blur and barrier behavior, and localized empty or error-state refinement.
- Add loading, empty, error, retry, and permission-denied states for every core screen.
- Remove all placeholder widgets, engineering-status copy, and non-functional primary actions.
- Align the shared design system and screen compositions with the premium editorial direction in `docs/Design.md`.
- Add motion and interaction polish that follows `docs/Design.md`, including page entrance timing, list stagger, bottom-sheet motion, countdown-only animation updates, Hero continuity where it materially improves navigation context, and tuned surface or blur treatment where it improves readability and hierarchy.
- Standardize async loading feedback, including delayed loader entry, barrier behavior, and use of `apps/mobile_flutter/assets/lotties/loading.lottie` for shared modal or full-screen loading states.

### Done When
- Buyer can complete browse, bid, buy-now, and order-timeline entry flows in emulator and staging.
- Seller can complete draft to shipment flow in emulator and staging.
- Every route has a clear state model and actionable error handling.
- All mobile copy is localized for `ko` and `en`, with unsupported locales falling back to `ko`.
- Navigation, empty/loading/error states, and screen compositions match the documented premium editorial direction.
- Motion, page transitions, and high-emphasis surfaces match the documented premium editorial direction without adding decorative blur or animation that harms clarity.
- Dark mode, shared loading overlays, keyboard-safe sheets, and overflow-prone layouts are stabilized on supported mobile form factors.

## Phase 4: Notifications, Settings, And Product Hardening
Status: in progress after Phase 3.
- Add Android and iOS push-notification support with Firebase Messaging permission handling, token registration, foreground presentation, background tap routing, and category-aware delivery rules defined in `docs/Notification.md`.
- Explore current buyer, seller, order, shipment, and inbox flows and support only the push events documented in `docs/Notification.md`.
- Keep inbox documents and push delivery aligned so every supported push event also creates an inbox record and deep link.
- Add app-bar entry points and a persistent `My`-area fallback for user settings and build settings screens for:
  - global app-notification on and off
  - per-category notification on and off
  - theme mode selection
  - system-language behavior confirmation for supported locales
  - open-source licenses
  - app version display
  - debug-only developer settings
- Improve production-app quality with a user-copy pass, release-only hiding of debug text or UI, production-safe error logging, and final UI or UX polish for empty, loading, retry, and failure states.
- Do not start final real-device push-delivery verification until the Firebase Messaging project setup and iOS APNs project setup are available.

### Current Phase 4 State
- Complete:
  - in-app settings route, theme preference, notification preference toggles, OS permission visibility, and token lifecycle
  - dev/prod mobile flavors plus dev Firebase project split
  - Render dev server for physical-device testing and payment redirect pages
  - Android real-device dev path through real Firebase + Render
  - backend Firebase Admin Messaging dispatch for currently emitted inbox-backed product events
  - supported push event-matrix backend coverage, including payment-due, shipment-reminder, and receipt-reminder scheduler emission with idempotent reminder inbox ids
  - Android foreground push presentation, background or terminated tap routing, and default notification-channel setup
- In progress:
  - final Android and iOS real-device verification for supported push behavior
- Deferred debt:
  - iOS APNs key upload and Firebase APNs project wiring
  - final iOS real-device push verification after APNs setup

### Done When
- Android and iOS push-notification behavior matches `docs/Notification.md` for supported event types, categories, deep links, and preference rules.
- Users can manage notification and theme preferences from the in-app settings surface, while language follows supported system locales; the same settings flow also exposes licenses, app-version info, and debug-only developer settings.
- Release builds hide debug-only entry points and copy while keeping a documented developer-settings path for debug builds.
- Production-safe logs exist for actionable client failures and notification-delivery diagnostics without leaking secrets or noisy debug output.
- Any remaining real-device push-delivery prerequisites are recorded explicitly if project-level setup is still pending.

## Phase 5: Quality, Ops, And Release
- Add backend unit tests, emulator integration tests, Flutter widget tests, and end-to-end flow checks.
- Verify release gates: no hardcoded secrets, no fake repositories, no placeholder UI, docs complete.
- Add deploy, rollback, monitoring, and incident response notes.

### Done When
- Test coverage protects core state transitions and auth boundaries.
- Operators can deploy, observe, and roll back without reading source code first.
- Release gate checklist passes in `staging`.

## Phase Undecided

### External Payment Gateway Cutover
Status: blocked until the user explicitly requests cutover work and real provider values are available.
- Keep payment integration extensible until real cutover starts. Product-level docs and phase planning must stay provider-neutral.
- Treat any current provider-oriented scaffold as an adapter detail, not as a permanent product contract.
- Do not continue provider-selection or provider-cutover implementation work unless the user explicitly asks for it.
- Keep this section at the bottom of the plan until the user activates it. Do not move it back into milestone flow before then.
- When this section is activated, record the final provider choice and keep the mobile handoff service, backend payment engine, webhook verification, and order state mapping replaceable.

### Required Inputs Before Cutover
- Client-side launch or checkout key.
- Server-side secret key.
- Webhook verification secret, signature key, or equivalent validation material.
- Public app base URL for success and failure returns or deep-link handoff.
- Staging and production test accounts, callback URLs, and reconciliation expectations.

### Required Work When Activated
- Confirm the final PG provider and document why it was chosen.
- Map provider-specific payment states into the product order and payment states without changing the product contract.
- Define the final provider-specific `createPaymentSession` launch payload, `confirmOrderPayment` server confirm flow, and webhook verification flow before code changes start.
- Define provider-specific success, failure, cancellation, timeout, and refund mapping into:
  - `paymentStatus`
  - `orderStatus`
  - notification copy and recovery CTA behavior
- Define whether the current provider-specific webhook route naming remains acceptable or should be generalized before production cutover.
- Verify client launch, return route handling, server confirmation, webhook verification, idempotency, and failure recovery.
- Verify cancellation, timeout, and refund expectations if the selected provider requires additional order-state handling.
