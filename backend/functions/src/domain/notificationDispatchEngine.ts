export type NotificationCategory =
  | 'auctionActivity'
  | 'orderPayment'
  | 'shippingAndReceipt'
  | 'system';

export type InboxNotificationType =
  | 'OUTBID'
  | 'AUTO_BID_CEILING_REACHED'
  | 'WON'
  | 'BUY_NOW_COMPLETED'
  | 'ORDER_AWAITING_PAYMENT'
  | 'PAYMENT_COMPLETED'
  | 'PAYMENT_DUE'
  | 'PAYMENT_FAILED'
  | 'SHIPPED'
  | 'RECEIPT_CONFIRMED'
  | 'SETTLED';

export interface NotificationPreferences {
  pushEnabled: boolean;
  notificationCategories: Record<NotificationCategory, boolean>;
}

export interface DeviceTokenCandidate {
  token: string | null;
  isActive: boolean;
  permissionStatus: string | null;
}

const DEFAULT_NOTIFICATION_CATEGORIES: Record<NotificationCategory, boolean> = {
  auctionActivity: true,
  orderPayment: true,
  shippingAndReceipt: true,
  system: true,
};

const CATEGORY_BY_NOTIFICATION_TYPE: Record<
  InboxNotificationType,
  NotificationCategory
> = {
  OUTBID: 'auctionActivity',
  AUTO_BID_CEILING_REACHED: 'auctionActivity',
  WON: 'orderPayment',
  BUY_NOW_COMPLETED: 'orderPayment',
  ORDER_AWAITING_PAYMENT: 'orderPayment',
  PAYMENT_COMPLETED: 'orderPayment',
  PAYMENT_DUE: 'orderPayment',
  PAYMENT_FAILED: 'orderPayment',
  SHIPPED: 'shippingAndReceipt',
  RECEIPT_CONFIRMED: 'shippingAndReceipt',
  SETTLED: 'shippingAndReceipt',
};

function isObject(value: unknown): value is Record<string, unknown> {
  return !!value && typeof value === 'object' && !Array.isArray(value);
}

export function getNotificationCategoryForType(
  type: InboxNotificationType,
): NotificationCategory {
  return CATEGORY_BY_NOTIFICATION_TYPE[type];
}

export function normalizeNotificationPreferences(
  userData: unknown,
): NotificationPreferences {
  const root = isObject(userData) ? userData : {};
  const preferences = isObject(root.preferences) ? root.preferences : {};
  const notificationCategories = isObject(preferences.notificationCategories)
    ? preferences.notificationCategories
    : {};

  return {
    pushEnabled:
      typeof preferences.pushEnabled === 'boolean'
        ? preferences.pushEnabled
        : true,
    notificationCategories: {
      auctionActivity:
        typeof notificationCategories.auctionActivity === 'boolean'
          ? notificationCategories.auctionActivity
          : DEFAULT_NOTIFICATION_CATEGORIES.auctionActivity,
      orderPayment:
        typeof notificationCategories.orderPayment === 'boolean'
          ? notificationCategories.orderPayment
          : DEFAULT_NOTIFICATION_CATEGORIES.orderPayment,
      shippingAndReceipt:
        typeof notificationCategories.shippingAndReceipt === 'boolean'
          ? notificationCategories.shippingAndReceipt
          : DEFAULT_NOTIFICATION_CATEGORIES.shippingAndReceipt,
      system:
        typeof notificationCategories.system === 'boolean'
          ? notificationCategories.system
          : DEFAULT_NOTIFICATION_CATEGORIES.system,
    },
  };
}

function isDeliverablePermissionStatus(status: unknown): boolean {
  return status === 'AUTHORIZED' || status === 'PROVISIONAL';
}

export function getDeliverableTokens(
  candidates: DeviceTokenCandidate[],
): string[] {
  const seen = new Set<string>();
  const tokens: string[] = [];

  for (const candidate of candidates) {
    const token = candidate.token?.trim();
    if (!token || seen.has(token)) {
      continue;
    }
    if (!candidate.isActive) {
      continue;
    }
    if (!isDeliverablePermissionStatus(candidate.permissionStatus)) {
      continue;
    }
    seen.add(token);
    tokens.push(token);
  }

  return tokens;
}

export function shouldDispatchPush(
  preferences: NotificationPreferences,
  category: NotificationCategory,
  tokenCount: number,
): boolean {
  if (!preferences.pushEnabled) {
    return false;
  }
  if (!preferences.notificationCategories[category]) {
    return false;
  }
  return tokenCount > 0;
}

export function buildPushDataPayload(input: {
  notificationId: string;
  type: InboxNotificationType;
  category: NotificationCategory;
  deeplink: string;
  entityType: 'AUCTION' | 'ORDER';
  entityId: string;
  timestamp: string;
}): Record<string, string> {
  return {
    notificationId: input.notificationId,
    type: input.type,
    category: input.category,
    deeplink: input.deeplink,
    entityType: input.entityType,
    entityId: input.entityId,
    timestamp: input.timestamp,
  };
}
