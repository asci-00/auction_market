import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  emulatorAuthAccounts,
  type EmulatorAuthAccount,
  seedEmulator,
} from './seed_data.js';

process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST ?? '127.0.0.1:9099';

const projectId = resolveProjectId();

const app = initializeApp({ projectId });
const db = getFirestore(app);
const auth = getAuth(app);

async function upsertAuthUser(account: EmulatorAuthAccount): Promise<void> {
  try {
    await auth.updateUser(account.uid, {
      displayName: account.displayName,
      email: account.email,
      emailVerified: true,
      password: account.password,
      disabled: false,
    });
  } catch (error) {
    if (
      typeof error === 'object' &&
      error !== null &&
      'code' in error &&
      error.code === 'auth/user-not-found'
    ) {
      await auth.createUser({
        uid: account.uid,
        displayName: account.displayName,
        email: account.email,
        emailVerified: true,
        password: account.password,
      });
      return;
    }

    throw error;
  }
}

async function run(): Promise<void> {
  for (const account of emulatorAuthAccounts) {
    await upsertAuthUser(account);
  }

  await seedEmulator(db, {
    firestore: {
      Timestamp: {
        fromDate(date: Date) {
          return Timestamp.fromDate(date);
        },
      },
    },
  });

  console.log(
    `Seed complete for ${projectId}. Auth users: ${emulatorAuthAccounts
      .map((account) => account.uid)
      .join(', ')}`,
  );
}

function resolveProjectId(): string {
  const fromEnv = process.env.GCLOUD_PROJECT ?? process.env.FIREBASE_PROJECT_ID;
  if (fromEnv && fromEnv.trim().length > 0) {
    return fromEnv.trim();
  }

  try {
    const currentDir = dirname(fileURLToPath(import.meta.url));
    const firebaseRcPath = resolve(currentDir, '../../../.firebaserc');
    const firebaseRc = JSON.parse(readFileSync(firebaseRcPath, 'utf8')) as {
      projects?: { default?: string };
    };
    const defaultProject = firebaseRc.projects?.default?.trim();
    if (defaultProject) {
      return defaultProject;
    }
  } catch (_) {
    // Fall through to the local fallback when the repo config is unavailable.
  }

  return 'auction-market-local';
}

run()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
