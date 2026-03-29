# Repository Guidelines

## Source Of Truth
- `Prompt.md`: product spec and non-negotiable constraints.
- `Plan.md`: milestone order and current phase scope.
- `Implement.md`: live execution log and validation history.
- `Documentation.md`: implementation contract for schema, routing, and runtime behavior.
- `docs/Design.md`: UI and UX contract.
- `docs/Environment.md`: environment and secret-loading contract.

## Project Structure & Module Organization
This repository is a small monorepo for a mobile-first C2C auction MVP.

- `apps/mobile_flutter/`: Flutter client. App entry points live in `lib/main.dart` and `lib/app/app.dart`.
- `backend/functions/`: Firebase Functions code in TypeScript. Core business logic is under `src/domain/`, feature policy flags under `src/config/`, and exported handlers in `src/index.ts`.
- `backend/functions/test/`: Vitest unit tests for the domain engines.
- `backend/emulator-seed/`: Seed scripts for local Firebase Emulator data.
- Root config includes `.env.example` and `firebase.json`.

## Build, Test, and Development Commands
Run backend commands from `backend/functions`:

- `npm install`: install Functions dependencies.
- `npm run build`: compile TypeScript with `tsc`.
- `npm run lint`: run ESLint and TypeScript no-emit checks.
- `npm run format:check`: verify Prettier formatting for backend TypeScript.
- `npm test`: run Vitest tests once.
- `npm run serve`: start Firebase emulators for Auth, Functions, Firestore, and Storage.
- `npm run seed`: populate emulator data from `backend/emulator-seed/seed.ts`.

Run Flutter commands from `apps/mobile_flutter`:

- `flutter pub get`: install Dart packages.
- `flutter gen-l10n`: regenerate localized app accessors after ARB changes.
- `dart format lib test`: format Flutter source and tests.
- `flutter analyze`: run Flutter static analysis.
- `flutter test`: run Flutter tests.
- `flutter run`: launch the mobile app locally.

## Coding Style & Naming Conventions
Use 2-space indentation in TypeScript and follow the existing ESM style: `.js` import specifiers, `const` by default, and narrow exported surface area through `src/index.ts`. Prefer `camelCase` for variables/functions, `PascalCase` for types and classes, and descriptive engine names such as `auctionEngine.ts`.

Keep policy and state-transition logic inside backend domain modules rather than in handler bodies. Use `npm run lint` before opening a PR.

## Testing Guidelines
Backend tests use Vitest. Add new tests in `backend/functions/test/` with the `*.test.ts` suffix, mirroring the module under test, for example `schedulerEngine.test.ts`.

Cover state transitions, validation, idempotency, and scheduler edge cases. For app flows without automated tests yet, follow the manual emulator scenario in `README.md`.

## Commit & Pull Request Guidelines
Recent history favors short, imperative commit subjects such as `Fix review issues...`, `Refactor...`, and `Implement MVP...`. Keep commits focused and use the subject line to describe the behavior change.

PRs should include:

- a concise summary of user-visible or backend behavior changes
- linked issue or task reference when available
- test evidence (`npm test`, `npm run build`, emulator/manual flow notes)
- screenshots or screen recordings for Flutter UI changes

## Security & Configuration Tips
Do not commit secrets. Start from `.env.example`, and test risky Firestore or scheduler changes against the Firebase Emulator before deploying.
