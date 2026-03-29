# Mobile Event Bus Guide

## Goal
- Keep Firebase realtime listeners as the primary sync mechanism.
- Add an in-app event propagation path for flows where one screen mutates data via REST/callable and other screens must refresh immediately.
- Avoid direct ViewModel-to-ViewModel calls.

## Added Utilities
- `apps/mobile_flutter/lib/core/events/app_event_bus.dart`
  - `sendToEventBus(ref, event)`: publish an event.
  - `listenEvent<EventType>(ref, onEvent: ...)`: subscribe inside Riverpod providers/ViewModels with automatic `ref.onDispose` cleanup.
  - `watchEvent<EventType>(ref)`: raw stream access when needed.
- `apps/mobile_flutter/lib/core/events/app_domain_events.dart`
  - Shared base `AppDomainEvent`.
  - Example typed events:
    - `AuctionChangedEvent`
    - `ItemChangedEvent`
    - `OrderChangedEvent`

## Usage Pattern
1. Mutating side publishes event after server write succeeds.
2. Dependent ViewModel listens to event type and refreshes local state.
3. Listener must remain idempotent (safe if duplicate events arrive).

## Example
```dart
// publisher (service / action handler)
sendToEventBus(
  ref,
  const OrderChangedEvent(
    entityId: orderId,
    mutation: EntityMutationType.updated,
  ),
);

// subscriber (view model)
listenEvent<OrderChangedEvent>(
  ref,
  onEvent: (event) async {
    // refresh query/state for impacted order
    await reloadOrder(event.entityId);
  },
);
```

## Rules
- Do not publish before backend success.
- Use typed events per domain instead of `dynamic` payloads.
- Keep payload small: id + mutation type + only required metadata.
- Prefer one-way flow: mutation -> event -> subscriber refresh.
- If Firebase `snapshots()` already covers the scenario with acceptable latency, do not add event bus just for duplication.
