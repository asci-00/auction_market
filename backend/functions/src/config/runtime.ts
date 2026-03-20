import { HttpsError } from 'firebase-functions/v2/https';

export type RuntimeEnvironment = 'dev' | 'staging' | 'prod';

export interface RuntimeConfig {
  appEnv: RuntimeEnvironment;
  gcloudProject: string;
  firebaseProjectId: string;
  tossSecretKey: string | null;
  tossWebhookSecret: string | null;
  tossApiBaseUrl: string;
  appBaseUrl: string | null;
  opsAlertEmails: string[];
}

export function readRuntimeConfig(): RuntimeConfig {
  const appEnv = readEnvironment('APP_ENV', 'dev');
  return {
    appEnv,
    gcloudProject: readRequired('GCLOUD_PROJECT'),
    firebaseProjectId: readRequired('FIREBASE_PROJECT_ID'),
    tossSecretKey: readOptional('TOSS_SECRET_KEY'),
    tossWebhookSecret: readOptional('TOSS_WEBHOOK_SECRET'),
    tossApiBaseUrl:
      readOptional('TOSS_API_BASE_URL') ?? 'https://api.tosspayments.com',
    appBaseUrl: readOptional('APP_BASE_URL'),
    opsAlertEmails: (readOptional('OPS_ALERT_EMAILS') ?? '')
      .split(',')
      .map((value) => value.trim())
      .filter(Boolean),
  };
}

export function requireMeaningfulConfig(
  value: string | null,
  fieldName: string,
  message: string,
): string {
  if (!isMeaningful(value)) {
    throw new HttpsError('failed-precondition', `${fieldName}: ${message}`);
  }

  return value!.trim();
}

export function isMeaningful(value: string | null | undefined): boolean {
  if (!value) {
    return false;
  }

  const normalized = value.trim();
  return (
    normalized.length > 0 &&
    !normalized.startsWith('TODO_') &&
    !normalized.startsWith('TODO_FROM_')
  );
}

function readEnvironment(
  fieldName: string,
  fallback: RuntimeEnvironment,
): RuntimeEnvironment {
  const rawValue = readOptional(fieldName);
  switch (rawValue ?? fallback) {
    case 'dev':
    case 'staging':
    case 'prod':
      return (rawValue ?? fallback) as RuntimeEnvironment;
    default:
      throw new HttpsError(
        'failed-precondition',
        `${fieldName} must be one of dev, staging, or prod.`,
      );
  }
}

function readRequired(fieldName: string): string {
  const value = readOptional(fieldName);
  if (!isMeaningful(value)) {
    throw new HttpsError(
      'failed-precondition',
      `${fieldName} is missing from backend runtime config.`,
    );
  }

  return value!.trim();
}

function readOptional(fieldName: string): string | null {
  const rawValue = process.env[fieldName]?.trim();
  return rawValue && rawValue.length > 0 ? rawValue : null;
}
