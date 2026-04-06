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

export function buildDeviceTokenId(token: string): string {
  return encodeURIComponent(token);
}

export function buildRegisterDeviceTokenRecord(
  input: RegisterDeviceTokenInput,
  serverTimestamp: unknown,
  options: { includeCreatedAt: boolean },
): DeviceTokenRecord {
  return {
    token: input.token,
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
