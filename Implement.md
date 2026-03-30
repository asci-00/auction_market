# Auction Market Execution Log

## Current Task
- Phase 3 mobile flow work is active.
- The focus is UI and UX polish: dark mode parity, overflow and keyboard-safety fixes, async feedback timing, blur and barrier tuning, shared loading overlay consistency, and route or sheet transition quality.
- Deferred external payment-gateway cutover remains outside milestone flow and lives only in `Plan.md` under `Phase Undecided`.

## Locked Decisions
- All developer-facing docs use plain English.
- App UI supports Korean and English. The app defaults to the device locale, and a manual language override may be added later through settings.
- Payment integration stays adapter-based until the user explicitly activates the deferred cutover work in `Plan.md`.
- Apple sign in and Google sign in are the only login providers for v1.
- Emulator seed is the default dummy data path. Dependency-blocked integrations may use server-driven dummy responses only in `dev`.
- Shared blocking loading states use `apps/mobile_flutter/assets/lotties/loading.lottie`.
- Push delivery and inbox alignment must follow `docs/Notification.md` once Phase 4 starts.
- Secrets never live in repo files. Only example files are committed.

## Open Blockers
- Real payment-provider client key, server secret, webhook secret, and app base URL are not available in this repo yet.
- Final real-device push delivery will require Firebase Messaging project setup and iOS APNs project setup.

## Validation Status
- Mobile foundation folders, guarded routing, Firebase bootstrap, localized core screens, and shared editorial design primitives exist.
- Firestore read paths and Functions write paths cover login, browse, auction detail, sell, orders, notifications, and activity flows.
- Phase 3 polish already includes dark-theme groundwork, shared loading overlays, keyboard-safe modal handling, Hero-enabled auction continuity, and localized empty or error states.
- Phase 3 quiet states now expose only concrete recovery actions that the current architecture can honor, such as sign-in return paths and browse recovery, instead of generic retry affordances on cached Firestore reads.
- Search filter chips now affect live result filtering for category, price band, ending-soon urgency, and buy-now availability instead of remaining decorative UI.
- The search route now keeps the query field pinned while results scroll, so users can refine live search results without losing the primary input control.
- Backend callables cover bootstrap, draft lifecycle, bid and auto-bid, buy now, payment-session preparation, payment confirmation, shipment update, receipt confirmation, and notification read state.
- `cd backend/functions && npm run format:check` passed on March 25, 2026.
- `cd backend/functions && npm run lint` passed on March 25, 2026.
- `cd backend/functions && npm test` passed on March 25, 2026.
- `cd backend/functions && npm run build` passed on March 25, 2026.
- `cd apps/mobile_flutter && flutter gen-l10n` passed on March 26, 2026.
- `cd apps/mobile_flutter && dart format --output=none --set-exit-if-changed lib test` passed on March 26, 2026.
- `cd apps/mobile_flutter && flutter analyze` passed on March 26, 2026.
- `cd apps/mobile_flutter && flutter test` passed on March 26, 2026.

## Next Commands
1. `cd backend/functions && npm run serve`
2. `cd backend/functions && npm run seed`
3. `cd apps/mobile_flutter && flutter run --dart-define-from-file=dart_defines.json`
4. Finish Phase 3 UI and UX polish and rerun the Phase 3 smoke tests.
5. Start Phase 4 notification, settings, and product-hardening work after Phase 3 is complete.
6. Start deferred payment-provider cutover only when the user explicitly activates it.

## Update Rules
- Keep this file short.
- Keep only current task, locked decisions, blockers, validation status, and next commands.
- Replace completed items instead of appending long history.
- Before a commit, run the relevant format, lint, test, and build gates for the touched stack.
