# Not Completed Review Follow-ups

## PR #21

### Review `#3039760948` (sell_flow_service unit tests)
- Reason deferred: the request is valid but out of scope for the Phase 4 settings foundation PR.
- Why tracked here: current planning docs do not include a scheduled task for this exact test-hardening slice.
- Follow-up change to implement:
  - Add dedicated tests for `apps/mobile_flutter/lib/features/sell/application/sell_flow_service.dart`.
  - Cover success and failure paths for `saveDraft()` and `publishAuction()` public methods.
  - Verify image upload integration via `_uploadImages()` and callable invocation behavior inside those flows.
  - Use fake or mocked Firebase dependencies so tests run deterministically in CI.

## PR #23

### Review `#3073682608` (login emulator unsupported-provider test coverage)
- Reason deferred: valid test hardening suggestion, but this PR already includes high-risk notification/push/runtime fixes plus CI recovery and keeping this extra widget-level branch test in the same patch would dilute review scope.
- Why tracked here: current planning docs do not schedule this exact login emulator negative-path test slice.
- Follow-up change to implement:
  - Add a focused login screen test that verifies `loginEmulatorUnsupportedProvider` appears when emulator mode is enabled and Google/Apple sign-in is attempted.

### Review `#3073682766` (seed_dev helper unit tests)
- Reason deferred: valid regression-hardening suggestion, but adding script-specific test harness in this PR would expand scope beyond the current runtime and contract fixes.
- Why tracked here: current planning docs do not include a dedicated seed script helper-test task.
- Follow-up change to implement:
  - Add unit tests for `parseEnvFile`, `resolveRequiredEnv`, and `parseServiceAccountJson` helper behavior in `backend/functions/scripts/seed_dev.ts`.

### Review `#3073682821` (render-dev notification metadata and push fan-out parity)
- Reason deferred: valid direction, but it is a broader architecture alignment task across render-dev and Functions paths and exceeds this PR's targeted safety fixes.
- Why tracked here: current planning docs do not yet contain a scoped task for render-dev notification contract parity and fan-out integration.
- Follow-up change to implement:
  - Align render-dev `createInboxNotification` payload fields (`category`, `entityType`, `entityId`) with Functions contract.
  - Add a shared or equivalent best-effort push dispatch path for render-dev HTTP mutations.

### Review `#3079214821` (notification docs strict constant-level sync)
- Reason deferred: valid documentation-hardening direction, but this PR is scoped to runtime reliability and CI stabilization, not broad spec rewrites across multiple docs.
- Why tracked here: current planning docs do not schedule a dedicated pass for strict constant-level synchronization between `Documentation.md` and `docs/Notification.md`.
- Follow-up change to implement:
  - Add an explicit event-constant table to `docs/Notification.md` with backend event identifiers.
  - Align preference gate wording to explicit runtime fields (`preferences.pushEnabled`, `preferences.notificationCategories.*`, permission status values).
  - Document deterministic reminder inbox-id behavior in the delivery preconditions section using the same terminology as runtime docs.

## PR #29

### Review `#3117730155` (HTTP transport exception normalization scope)
- Reason deferred: direction is reasonable (improve transient error normalization for dev HTTP transport), but this PR is scoped to foreground refresh, locale/template parity, and immediate review regressions.
- Why tracked here: current planning docs do not include a dedicated hardening slice for `backend_gateway.dart` exception taxonomy.
- Follow-up change to implement:
  - Expand `_sendPost` exception mapping in `apps/mobile_flutter/lib/core/backend/backend_gateway.dart` to normalize additional `dart:io` failures (`HttpException`, TLS/socket-level client exceptions) into `FirebaseFunctionsException('unavailable')`.
  - Add unit tests for exception mapping and retry behavior.

### Review `#3117730178` (AuctionDetailHttpDataSource edge-case test matrix)
- Reason deferred: valid test-depth request, but this PR already includes behavior fixes across mobile/backend notification and route refresh logic.
- Why tracked here: current planning docs do not schedule a dedicated edge-case suite expansion for this data source.
- Follow-up change to implement:
  - Add tests for non-2xx responses, null/missing `detail`, empty/malformed `bidHistory`, and duplicate image URL normalization in `auction_detail_http_data_source_test.dart`.

### Review `#3117730228` (render auction-detail endpoint negative-path tests)
- Reason deferred: valid backend test-hardening request, but implementing the full failure-matrix in the same PR would substantially expand backend test scope.
- Why tracked here: current planning docs do not contain a dedicated render-dev endpoint robustness test slice.
- Follow-up change to implement:
  - Add focused tests for missing auction/item docs, empty bids, and timestamp-type variation handling in `backend/render-dev-server/test/auction-detail.test.js`.
