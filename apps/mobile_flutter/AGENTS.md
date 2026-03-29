# Repository Guidelines

## Scope
This file is for agents working inside `apps/mobile_flutter`. Prefer concrete, repo-specific decisions over generic Flutter advice.

## First Read
Before editing, inspect these files first:

- `lib/main.dart`: app bootstrap, global error capture, `ProviderScope`
- `lib/app/app.dart`: top-level app composition
- `lib/core/routing/app_router.dart`: navigation and auth redirect rules
- `lib/core/firebase/firebase_bootstrap.dart`: Firebase init and emulator wiring
- `lib/core/app_config/app_config.dart`: `dart-define` contract
- `test/widget_test.dart`: current testing style and copy assertions

## Current Structure
The app currently follows `core + features/*/presentation`.

- `lib/core/`: shared infrastructure and shared UI primitives
- `lib/features/<feature>/presentation/`: screens and feature-local presentation logic
- `lib/l10n/*.arb`: localization sources
- `test/`: widget and regression tests

There is not yet a full clean-architecture split per feature. Do not force one unless the change needs it.

## Architecture Rule
Default to MVVM-style feature code when logic is simple.

Use only `presentation/` when:
- state is local to one screen
- Firebase reads/writes are straightforward
- logic is mostly UI orchestration
- no reuse across multiple features is expected

Introduce deeper layers only when complexity justifies them:

- add `domain/` when business rules or state transitions need isolated tests
- add `data/` when mapping, repository logic, or multiple data sources appear
- add `usecases/` or `application/` only when orchestration becomes non-trivial and re-used

Keep shared concerns in `core/`. Examples: Firebase providers, app config, routing, theme tokens, reusable widgets, app-wide error handling.

## Event Propagation Rule
When backend updates are not delivered by Firebase realtime listeners (for example REST-only mutation flows), use the shared app event bus instead of direct ViewModel-to-ViewModel calls.

- event bus utility: `lib/core/events/event_bus.dart`
- typed event models: `lib/core/events/app_events.dart`
- publish from mutating side: `sendToEventBus(EventType(...))`
- subscribe from dependent state owner: `listenEvent<EventType>(onEvent: ...)`

Guidelines:
- Keep the event bus global and private to the utility module.
- Use typed events with minimal payload (`entityId`, `mutation`, required metadata only).
- Emit events only after backend write success.
- Store the returned `StreamSubscription` in the owner (ViewModel/screen) and cancel in `dispose` / `ref.onDispose`.
- Do not replace Firebase streams with event bus when realtime listeners already solve the propagation problem with acceptable latency.

## Editing Heuristics
When adding a new screen:
- place the screen under `lib/features/<feature>/presentation/`
- keep view-specific helpers private in the same file unless the file becomes difficult to scan
- move repeated UI pieces to `core/widgets/` only after at least 2 real reuse points

When adding state:
- prefer Riverpod providers close to the feature that uses them
- do not add a heavyweight abstraction if a `Provider`, `FutureProvider`, or local `ConsumerStatefulWidget` is enough
- do not embed long business rules directly in widget build methods

When touching navigation:
- update `lib/core/routing/app_router.dart`
- preserve existing auth redirect behavior and deep-link normalization

When touching Firebase usage:
- prefer shared providers from `lib/core/firebase/firebase_providers.dart`
- keep bootstrap and emulator configuration in `core/firebase`, not in feature screens

## Commands
Run commands from `apps/mobile_flutter`.

- `flutter pub get`: install dependencies
- `dart format lib test`: format source and tests
- `flutter analyze`: static analysis
- `flutter test`: run all tests
- `flutter test test/widget_test.dart`: fast regression pass for localization and startup UI
- `flutter run --dart-define-from-file=dart_defines.json`: local app run

Use `dart_defines.example.json` as the template for `dart_defines.json`.

## Quality Gate
For any non-trivial change, aim to finish with this loop:

1. `dart format lib test`
2. `flutter analyze`
3. `flutter test`

If you change only copy, localization, or startup/auth presentation, at minimum run:

1. `dart format` on touched files
2. `flutter test test/widget_test.dart`

If you cannot run one of these, state that explicitly in the final handoff.

## Testing Strategy
Follow the existing test style in `test/widget_test.dart`.

- add widget tests for visible behavior, not implementation details
- verify Korean/English copy when editing localized entry points
- add regression tests for environment-dependent UI such as emulator-only login affordances
- if you extract business logic from UI, add focused unit-style tests around that logic rather than only broad widget coverage

## Localization
Localization is real app behavior here, not polish.

- edit `lib/l10n/app_ko.arb` and `lib/l10n/app_en.arb`
- do not manually edit generated `app_localizations*.dart` files
- if copy changes affect onboarding, login, startup failure, or empty states, update tests accordingly

## UI System
Follow the existing visual system instead of introducing ad hoc styles.

- use `AppTheme`, `AppColors`, and `context.tokens`
- prefer existing shared widgets such as `AppPageScaffold`, `AppPanel`, `AppEditorialHero`, `AppEmptyState`
- keep new UI consistent with the current editorial, card-based style

## Firebase and Environment Notes
The app expects native Firebase setup and environment values.

- Android config: `android/app/google-services.json`
- iOS config: `ios/Runner/GoogleService-Info.plist`
- environment parsing lives in `lib/core/app_config/app_config.dart`

`dev` builds default to Firebase Emulator usage. Do not hardcode hosts or config in feature code.

## Avoid
- do not edit generated or build output under `build/`, `.dart_tool/`, or generated localization files
- do not move shared app rules into widgets just to avoid creating a small helper class
- do not introduce repository/usecase layers for trivial reads and UI-only state
- do not bypass existing theme tokens with unexplained magic numbers when a token already fits
