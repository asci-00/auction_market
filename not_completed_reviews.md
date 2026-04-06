# Not Completed Review Follow-ups

## PR #21

### Review `#3039760948` (sell_flow_service unit tests)
- Reason deferred: the request is valid but out of scope for the Phase 4 settings foundation PR.
- Why tracked here: current planning docs do not include a scheduled task for this exact test-hardening slice.
- Follow-up change to implement:
  - Add dedicated tests for `apps/mobile_flutter/lib/features/sell/application/sell_flow_service.dart`.
  - Cover success and failure paths for draft save/load, image upload, and callable invocation.
  - Use fake or mocked Firebase dependencies so tests run deterministically in CI.
