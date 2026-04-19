import type { InboxNotificationType } from './notificationDispatchEngine.js';

export type NotificationLocale = 'ko' | 'en';

type PaymentFailedReason =
  | 'FAILED'
  | 'CANCELLED'
  | 'EXPIRED'
  | 'EXPIRED_WITH_PENALTY';

export interface NotificationLocaleCandidate {
  tokenId: string;
  locale: string | null;
  isActive: boolean;
  permissionStatus: string | null;
  lastSeenAtMs: number | null;
}

export interface InboxNotificationCopyContext {
  finalPrice?: number | null;
  paymentFailedReason?: PaymentFailedReason | null;
  carrierName?: string | null;
  trackingNumber?: string | null;
  orderId?: string | null;
}

interface NotificationCopy {
  title: string;
  body: string;
}

function isObject(value: unknown): value is Record<string, unknown> {
  return !!value && typeof value === 'object' && !Array.isArray(value);
}

function normalizeLocale(
  locale: string | null | undefined,
): NotificationLocale | null {
  if (!locale) {
    return null;
  }
  const normalized = locale.trim().toLowerCase();
  if (!normalized) {
    return null;
  }
  const base = normalized.split(/[-_]/)[0];
  if (base === 'ko' || base === 'en') {
    return base;
  }
  return null;
}

function isDeliverablePermissionStatus(status: string | null): boolean {
  return status === 'AUTHORIZED' || status === 'PROVISIONAL';
}

function resolveUserPreferredLocale(
  userData: unknown,
): NotificationLocale | null {
  const root = isObject(userData) ? userData : {};
  const preferences = isObject(root.preferences) ? root.preferences : {};
  const languageCode =
    typeof preferences.languageCode === 'string'
      ? preferences.languageCode
      : null;
  return normalizeLocale(languageCode);
}

function resolveTokenLocale(
  tokenCandidates: NotificationLocaleCandidate[],
): NotificationLocale | null {
  const eligible = tokenCandidates
    .filter(
      (candidate) =>
        candidate.isActive &&
        isDeliverablePermissionStatus(candidate.permissionStatus),
    )
    .map((candidate) => ({
      ...candidate,
      normalizedLocale: normalizeLocale(candidate.locale),
      sortSeenAt: candidate.lastSeenAtMs ?? -1,
    }))
    .filter(
      (
        candidate,
      ): candidate is NotificationLocaleCandidate & {
        normalizedLocale: NotificationLocale;
        sortSeenAt: number;
      } => !!candidate.normalizedLocale,
    )
    .sort((a, b) => {
      if (a.sortSeenAt !== b.sortSeenAt) {
        return b.sortSeenAt - a.sortSeenAt;
      }
      return a.tokenId.localeCompare(b.tokenId);
    });

  return eligible[0]?.normalizedLocale ?? null;
}

export function resolveNotificationLocale(input: {
  userData: unknown;
  tokenCandidates: NotificationLocaleCandidate[];
  fallbackLocale?: NotificationLocale;
}): NotificationLocale {
  const userLocale = resolveUserPreferredLocale(input.userData);
  if (userLocale) {
    return userLocale;
  }

  const tokenLocale = resolveTokenLocale(input.tokenCandidates);
  if (tokenLocale) {
    return tokenLocale;
  }

  return input.fallbackLocale ?? 'ko';
}

function formatPrice(locale: NotificationLocale, amount: number): string {
  const rounded = Math.round(amount);
  return locale === 'ko'
    ? rounded.toLocaleString('ko-KR')
    : rounded.toLocaleString('en-US');
}

function formatShippingDetail(input: {
  carrierName: string | null | undefined;
  trackingNumber: string | null | undefined;
}): string | null {
  const carrierName =
    typeof input.carrierName === 'string' && input.carrierName.trim()
      ? input.carrierName.trim()
      : null;
  const trackingNumber =
    typeof input.trackingNumber === 'string' && input.trackingNumber.trim()
      ? input.trackingNumber.trim()
      : null;
  if (carrierName && trackingNumber) {
    return `${carrierName} ${trackingNumber}`;
  }
  if (carrierName) {
    return carrierName;
  }
  if (trackingNumber) {
    return trackingNumber;
  }
  return null;
}

function buildKoCopy(
  type: InboxNotificationType,
  context: InboxNotificationCopyContext,
): NotificationCopy {
  switch (type) {
    case 'OUTBID':
      return {
        title: '입찰가가 갱신되었습니다',
        body:
          typeof context.finalPrice === 'number'
            ? `현재 최고가 ${formatPrice('ko', context.finalPrice)}원`
            : '현재 최고가가 갱신되었습니다.',
      };
    case 'AUTO_BID_CEILING_REACHED':
      return {
        title: '자동입찰 한도에 도달했습니다',
        body:
          typeof context.finalPrice === 'number'
            ? `현재 최고가 ${formatPrice('ko', context.finalPrice)}원으로 자동입찰 상한을 넘었습니다.`
            : '현재 최고가가 자동입찰 상한을 넘었습니다.',
      };
    case 'WON':
      return {
        title: '낙찰되었습니다',
        body: '결제 기한 내 결제를 진행해주세요.',
      };
    case 'BUY_NOW_COMPLETED':
      return {
        title: '즉시 구매가 완료되었습니다',
        body: '결제 기한 내 결제를 진행해주세요.',
      };
    case 'ORDER_AWAITING_PAYMENT':
      return {
        title: '새 주문이 결제 대기 중입니다',
        body: '구매자 결제 완료 후 배송 정보를 등록해주세요.',
      };
    case 'PAYMENT_COMPLETED':
      return {
        title: '결제 완료',
        body: '구매자 결제가 완료되었습니다.',
      };
    case 'PAYMENT_DUE':
      return {
        title: '결제 기한이 곧 만료됩니다',
        body: '결제 기한 전에 결제를 완료해주세요.',
      };
    case 'PAYMENT_FAILED':
      if (context.paymentFailedReason === 'EXPIRED') {
        return {
          title: '결제 기한이 만료되었습니다',
          body: '미결제로 주문이 취소되었습니다.',
        };
      }
      if (context.paymentFailedReason === 'CANCELLED') {
        return {
          title: '결제가 취소되었습니다',
          body: '결제가 완료되지 않아 주문이 취소되었습니다.',
        };
      }
      if (context.paymentFailedReason === 'EXPIRED_WITH_PENALTY') {
        return {
          title: '결제 기한이 만료되었습니다',
          body: '미결제로 주문이 취소되었고 패널티가 반영되었습니다.',
        };
      }
      return {
        title: '결제가 완료되지 않았습니다',
        body: '결제 정보를 확인한 뒤 다시 시도해주세요.',
      };
    case 'SHIPMENT_REMINDER':
      return {
        title: '배송 등록이 필요합니다',
        body: '결제 완료 주문의 배송 정보를 등록해주세요.',
      };
    case 'SHIPPED':
      return {
        title: '배송이 시작되었습니다',
        body:
          formatShippingDetail({
            carrierName: context.carrierName,
            trackingNumber: context.trackingNumber,
          }) ?? '배송 정보가 등록되었습니다.',
      };
    case 'RECEIPT_REMINDER':
      return {
        title: '수령 확인이 필요합니다',
        body: '배송 완료 주문의 수령 확인을 진행해주세요.',
      };
    case 'RECEIPT_CONFIRMED':
      return {
        title: '구매자가 수령을 확인했습니다',
        body: '정산 예정 일정을 확인해주세요.',
      };
    case 'SETTLED':
      return {
        title: '정산 완료',
        body: context.orderId
          ? `주문 ${context.orderId} 정산이 완료되었습니다.`
          : '정산이 완료되었습니다.',
      };
    case 'SYSTEM_TEST':
      return {
        title: '푸시 수신 점검',
        body: '푸시 알림 수신 경로 점검용 테스트 알림입니다.',
      };
  }
}

function buildEnCopy(
  type: InboxNotificationType,
  context: InboxNotificationCopyContext,
): NotificationCopy {
  switch (type) {
    case 'OUTBID':
      return {
        title: 'You have been outbid',
        body:
          typeof context.finalPrice === 'number'
            ? `Current highest bid is KRW ${formatPrice('en', context.finalPrice)}.`
            : 'The highest bid has been updated.',
      };
    case 'AUTO_BID_CEILING_REACHED':
      return {
        title: 'Auto-bid limit reached',
        body:
          typeof context.finalPrice === 'number'
            ? `Current highest bid is KRW ${formatPrice('en', context.finalPrice)}, above your auto-bid limit.`
            : 'The highest bid is now above your auto-bid limit.',
      };
    case 'WON':
      return {
        title: 'You won the auction',
        body: 'Please complete payment before the deadline.',
      };
    case 'BUY_NOW_COMPLETED':
      return {
        title: 'Buy now completed',
        body: 'Please complete payment before the deadline.',
      };
    case 'ORDER_AWAITING_PAYMENT':
      return {
        title: 'New order awaiting payment',
        body: 'Please register shipment info after buyer payment is completed.',
      };
    case 'PAYMENT_COMPLETED':
      return {
        title: 'Payment completed',
        body: 'Buyer payment has been completed.',
      };
    case 'PAYMENT_DUE':
      return {
        title: 'Payment deadline approaching',
        body: 'Please complete payment before the deadline.',
      };
    case 'PAYMENT_FAILED':
      if (context.paymentFailedReason === 'EXPIRED') {
        return {
          title: 'Payment deadline expired',
          body: 'The order was cancelled due to non-payment.',
        };
      }
      if (context.paymentFailedReason === 'CANCELLED') {
        return {
          title: 'Payment was cancelled',
          body: 'The order was cancelled because payment was not completed.',
        };
      }
      if (context.paymentFailedReason === 'EXPIRED_WITH_PENALTY') {
        return {
          title: 'Payment deadline expired',
          body: 'The order was cancelled and a penalty was applied for non-payment.',
        };
      }
      return {
        title: 'Payment did not complete',
        body: 'Please verify payment details and try again.',
      };
    case 'SHIPMENT_REMINDER':
      return {
        title: 'Shipment registration required',
        body: 'Please register shipment info for paid orders.',
      };
    case 'SHIPPED':
      return {
        title: 'Shipment started',
        body:
          formatShippingDetail({
            carrierName: context.carrierName,
            trackingNumber: context.trackingNumber,
          }) ?? 'Shipment information has been registered.',
      };
    case 'RECEIPT_REMINDER':
      return {
        title: 'Receipt confirmation required',
        body: 'Please confirm receipt for shipped orders.',
      };
    case 'RECEIPT_CONFIRMED':
      return {
        title: 'Buyer confirmed receipt',
        body: 'Please check the settlement schedule.',
      };
    case 'SETTLED':
      return {
        title: 'Settlement completed',
        body: context.orderId
          ? `Settlement completed for order ${context.orderId}.`
          : 'Settlement has been completed.',
      };
    case 'SYSTEM_TEST':
      return {
        title: 'Push delivery check',
        body: 'Test notification for push delivery verification.',
      };
  }
}

export function buildInboxNotificationCopy(input: {
  type: InboxNotificationType;
  locale: string | null | undefined;
  context?: InboxNotificationCopyContext;
}): NotificationCopy {
  const locale = normalizeLocale(input.locale) ?? 'ko';
  const context = input.context ?? {};
  if (locale === 'en') {
    return buildEnCopy(input.type, context);
  }
  return buildKoCopy(input.type, context);
}
