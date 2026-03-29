# Backend Guidelines

## Scope
This file is for agents working under `backend/`.

## First Read
- `../Prompt.md`
- `../Plan.md`
- `../Implement.md`
- `../Documentation.md`
- `../docs/Environment.md`

## Structure
- `functions/src/index.ts`: exported callable, webhook, and scheduler surface
- `functions/src/domain/`: business rules and payment or auction state transitions
- `functions/src/config/`: runtime validation and environment policy
- `functions/test/`: Vitest coverage for domain modules
- `emulator-seed/`: deterministic local seed path

## Commands
Run from `backend/functions`.

- `npm run format:check`
- `npm run lint`
- `npm run build`
- `npm test`
- `npm run serve`
- `npm run seed`

## Working Rules
- Keep handler bodies thin and push state transitions into `src/domain/`.
- Prefer updating `Documentation.md` for schema or contract changes instead of growing this file.
- Treat Auth, Firestore, Functions, and Storage emulators as the default safe path for dev validation.
- Do not commit secrets. Backend runtime values belong in `backend/functions/.env`.
