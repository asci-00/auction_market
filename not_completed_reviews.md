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
