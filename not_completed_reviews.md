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
