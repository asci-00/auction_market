import { describe, expect, it } from 'vitest';
import {
  buildDeactivateDeviceTokenRecord,
  buildDeviceTokenId,
  buildRegisterDeviceTokenRecord,
} from '../src/domain/deviceTokenEngine.js';

describe('device token engine', () => {
  it('encodes token into a firestore-safe document id', () => {
    expect(buildDeviceTokenId('abc/def:ghi')).toBe('abc%2Fdef%3Aghi');
  });

  it('builds active token payload with metadata', () => {
    const timestamp = Symbol('serverTimestamp');
    expect(
      buildRegisterDeviceTokenRecord(
        {
          token: 'token-1',
          platform: 'ANDROID',
          appVersion: '1.0.0',
          locale: 'ko',
          timezone: 'KST',
          permissionStatus: 'AUTHORIZED',
        },
        timestamp,
        { includeCreatedAt: true },
      ),
    ).toEqual({
      token: 'token-1',
      platform: 'ANDROID',
      appVersion: '1.0.0',
      locale: 'ko',
      timezone: 'KST',
      permissionStatus: 'AUTHORIZED',
      isActive: true,
      lastSeenAt: timestamp,
      updatedAt: timestamp,
      createdAt: timestamp,
    });
  });

  it('builds inactive token payload for lifecycle updates', () => {
    const timestamp = Symbol('serverTimestamp');
    expect(buildDeactivateDeviceTokenRecord('DENIED', timestamp)).toEqual({
      isActive: false,
      permissionStatus: 'DENIED',
      lastSeenAt: timestamp,
      updatedAt: timestamp,
    });
  });
});
