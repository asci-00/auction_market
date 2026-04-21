import { applicationDefault, cert, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { existsSync, readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import {
  emulatorAuthAccounts,
  type EmulatorAuthAccount,
  seedEmulator,
} from './seed_data.js';

interface EnvMap {
  [key: string]: string | undefined;
}

const envFileArg = process.argv
  .slice(2)
  .find((arg) => arg.startsWith('--env-file='));
const projectArg = process.argv
  .slice(2)
  .find((arg) => arg.startsWith('--project='));
const skipAuthUsers = process.argv.includes('--skip-auth-users');

if (envFileArg) {
  const envFilePath = envFileArg.slice('--env-file='.length);
  loadEnvFile(resolve(process.cwd(), envFilePath));
}

const confirmWriteToReal =
  process.argv.includes('--yes') || process.env.CONFIRM_WRITE_TO_REAL === '1';

const projectId = resolveProjectId(projectArg);
const credential = resolveCredential();
const isEmulatorTarget =
  (process.env.FIRESTORE_EMULATOR_HOST?.trim().length ?? 0) > 0 ||
  (process.env.FIREBASE_AUTH_EMULATOR_HOST?.trim().length ?? 0) > 0;

console.warn(
  `[seed_dev] target projectId=${projectId} mode=${isEmulatorTarget ? 'EMULATOR' : 'REAL'}`,
);
if (!isEmulatorTarget && !confirmWriteToReal) {
  throw new Error(
    `Refusing to seed real Firebase project "${projectId}" without explicit confirmation. Pass --yes or set CONFIRM_WRITE_TO_REAL=1.`,
  );
}

const app = initializeApp({ credential, projectId });
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
  if (skipAuthUsers) {
    console.warn('Skipping Auth user upserts (--skip-auth-users).');
    for (const account of emulatorAuthAccounts) {
      try {
        await auth.getUser(account.uid);
      } catch (error) {
        if (
          typeof error === 'object' &&
          error !== null &&
          'code' in error &&
          error.code === 'auth/user-not-found'
        ) {
          throw new Error(
            `Cannot use --skip-auth-users: missing Auth user "${account.uid}". Seed auth users first.`,
          );
        }
        throw error;
      }
    }
  } else {
    for (const account of emulatorAuthAccounts) {
      await upsertAuthUser(account);
    }
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
    `Dev seed complete for ${projectId}. Auth users ${
      skipAuthUsers
        ? 'were skipped'
        : `seeded: ${emulatorAuthAccounts.map((account) => account.uid).join(', ')}`
    }`,
  );
}

function loadEnvFile(envFilePath: string): void {
  const envFileContent = readFileSync(envFilePath, 'utf8');
  const parsed = parseEnvFile(envFileContent);
  for (const [key, value] of Object.entries(parsed)) {
    if (value != null && process.env[key] == null) {
      process.env[key] = value;
    }
  }
}

function parseEnvFile(content: string): EnvMap {
  const result: EnvMap = {};
  for (const line of content.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) {
      continue;
    }
    const separatorIndex = trimmed.indexOf('=');
    if (separatorIndex <= 0) {
      continue;
    }
    const key = trimmed.slice(0, separatorIndex).trim();
    let value = trimmed.slice(separatorIndex + 1);
    const isQuoted =
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"));
    if (isQuoted) {
      value = value.slice(1, -1);
    } else {
      value = value.trim();
    }
    result[key] = value;
  }
  return result;
}

function resolveProjectId(projectArgValue?: string): string {
  const fromArg = projectArgValue?.slice('--project='.length).trim();
  if (fromArg) {
    return fromArg;
  }

  const fromEnv =
    process.env.FIREBASE_PROJECT_ID?.trim() ??
    process.env.GCLOUD_PROJECT?.trim();
  if (fromEnv) {
    return fromEnv;
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
  } catch (error) {
    if (
      typeof error === 'object' &&
      error !== null &&
      'code' in error &&
      error.code === 'ENOENT'
    ) {
      // Fall through and raise explicit error below.
    } else {
      throw error;
    }
  }

  throw new Error(
    'FIREBASE_PROJECT_ID is required (or pass --project=<firebase-project-id>).',
  );
}

function resolveCredential() {
  const serviceAccountRaw = process.env.FIREBASE_SERVICE_ACCOUNT_JSON?.trim();
  if (serviceAccountRaw) {
    return cert(parseServiceAccountJson(serviceAccountRaw));
  }

  const serviceAccountFile =
    process.env.FIREBASE_SERVICE_ACCOUNT_JSON_FILE?.trim();
  if (serviceAccountFile) {
    const absolutePath = resolve(process.cwd(), serviceAccountFile);
    const raw = readFileSync(absolutePath, 'utf8');
    return cert(parseServiceAccountJson(raw));
  }

  const adcPath =
    process.env.GOOGLE_APPLICATION_CREDENTIALS?.trim() ||
    resolve(homedir(), '.config/gcloud/application_default_credentials.json');
  if (!existsSync(adcPath)) {
    throw new Error(
      'Missing credentials. Set FIREBASE_SERVICE_ACCOUNT_JSON, or set FIREBASE_SERVICE_ACCOUNT_JSON_FILE=<path>, or run "gcloud auth application-default login".',
    );
  }

  return applicationDefault();
}

function parseServiceAccountJson(rawValue: string): Record<string, unknown> {
  try {
    const parsed = JSON.parse(rawValue) as Record<string, unknown>;
    if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
      throw new Error('service account json must be an object');
    }
    return parsed;
  } catch (error) {
    throw new Error(
      `FIREBASE_SERVICE_ACCOUNT_JSON must be valid JSON: ${String(error)}`,
    );
  }
}

run()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
