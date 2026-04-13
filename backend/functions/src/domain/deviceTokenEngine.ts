type DeviceTokenPermissionStatus =
  | 'AUTHORIZED'
  | 'DENIED'
  | 'PROVISIONAL'
  | 'NOT_DETERMINED';

type DeviceTokenPlatform = 'ANDROID' | 'IOS';

interface RegisterDeviceTokenInput {
  token: string;
  platform: DeviceTokenPlatform;
  appVersion: string;
  locale: string;
  timezone: string;
  permissionStatus: DeviceTokenPermissionStatus;
}

interface DeviceTokenRecord {
  token: string;
  platform: DeviceTokenPlatform;
  appVersion: string;
  locale: string;
  timezone: string;
  permissionStatus: DeviceTokenPermissionStatus;
  isActive: boolean;
  lastSeenAt: unknown;
  updatedAt: unknown;
  createdAt?: unknown;
}

function normalizeToken(token: string): string {
  const normalized = token.trim();
  if (!normalized) {
    throw new Error('device token must be non-empty');
  }
  return normalized;
}

export function buildDeviceTokenId(token: string): string {
  return encodeURIComponent(normalizeToken(token));
}

export function buildRegisterDeviceTokenRecord(
  input: RegisterDeviceTokenInput,
  serverTimestamp: unknown,
  options: { includeCreatedAt: boolean },
): DeviceTokenRecord {
  const normalizedToken = normalizeToken(input.token);
  return {
    token: normalizedToken,
    platform: input.platform,
    appVersion: input.appVersion,
    locale: input.locale,
    timezone: input.timezone,
    permissionStatus: input.permissionStatus,
    isActive: true,
    lastSeenAt: serverTimestamp,
    updatedAt: serverTimestamp,
    ...(options.includeCreatedAt ? { createdAt: serverTimestamp } : {}),
  };
}

export function buildDeactivateDeviceTokenRecord(
  permissionStatus: DeviceTokenPermissionStatus,
  serverTimestamp: unknown,
) {
  return {
    isActive: false,
    permissionStatus,
    lastSeenAt: serverTimestamp,
    updatedAt: serverTimestamp,
  };
}
