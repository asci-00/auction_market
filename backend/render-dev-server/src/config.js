function meaningfulString(value) {
  if (typeof value !== 'string') {
    return null;
  }

  const normalized = value.trim();
  if (
    normalized.length === 0 ||
    normalized.startsWith('TODO_') ||
    normalized.startsWith('TODO_FROM_')
  ) {
    return null;
  }

  return normalized;
}

function parsePort(rawValue) {
  const parsed = Number.parseInt(rawValue ?? '3000', 10);
  return Number.isNaN(parsed) ? 3000 : parsed;
}

function normalizeBaseUrl(rawValue, fieldName, { required = true } = {}) {
  const normalized = meaningfulString(rawValue);
  if (!normalized) {
    if (required) {
      throw new Error(`${fieldName} is required.`);
    }
    return null;
  }

  const url = new URL(normalized);
  url.pathname = url.pathname.replace(/\/+$/, '');
  url.search = '';
  url.hash = '';
  return url.toString().replace(/\/+$/, '');
}

function parseServiceAccountJson(rawValue) {
  const normalized = meaningfulString(rawValue);
  if (!normalized) {
    return null;
  }

  try {
    const parsed = JSON.parse(normalized);
    if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
      throw new Error('not an object');
    }
    return parsed;
  } catch (error) {
    throw new Error(
      `FIREBASE_SERVICE_ACCOUNT_JSON must be valid JSON: ${String(error)}`,
    );
  }
}

export function readConfig(env = process.env) {
  const appEnv = meaningfulString(env.APP_ENV) ?? 'dev';
  if (!['dev', 'prod'].includes(appEnv)) {
    throw new Error('APP_ENV must be dev or prod.');
  }

  return {
    port: parsePort(env.PORT),
    appEnv,
    appBaseUrl: normalizeBaseUrl(env.APP_BASE_URL, 'APP_BASE_URL', {
      required: false,
    }),
    tossSecretKey: meaningfulString(env.TOSS_SECRET_KEY),
    tossWebhookSecret: meaningfulString(env.TOSS_WEBHOOK_SECRET),
    tossApiBaseUrl: normalizeBaseUrl(
      env.TOSS_API_BASE_URL ?? 'https://api.tosspayments.com',
      'TOSS_API_BASE_URL',
    ),
    firebaseProjectId: meaningfulString(env.FIREBASE_PROJECT_ID),
    firebaseServiceAccountJson: parseServiceAccountJson(
      env.FIREBASE_SERVICE_ACCOUNT_JSON,
    ),
    enableTossSandbox:
      meaningfulString(env.ENABLE_TOSS_SANDBOX)?.toLowerCase() === 'true',
  };
}
