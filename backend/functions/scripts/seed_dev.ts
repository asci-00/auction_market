import { cert, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

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
const skipAuthUsers = process.argv.includes('--skip-auth-users');

if (envFileArg) {
  const envFilePath = envFileArg.slice('--env-file='.length);
  loadEnvFile(resolve(process.cwd(), envFilePath));
}

const projectId = resolveRequiredEnv('FIREBASE_PROJECT_ID');
const serviceAccountJson = parseServiceAccountJson(
  resolveRequiredEnv('FIREBASE_SERVICE_ACCOUNT_JSON'),
);

const app = initializeApp({
  credential: cert(serviceAccountJson),
  projectId,
});
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
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    result[key] = value;
  }
  return result;
}

function resolveRequiredEnv(key: string): string {
  const value = process.env[key]?.trim();
  if (!value) {
    throw new Error(`${key} is required.`);
  }
  return value;
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
