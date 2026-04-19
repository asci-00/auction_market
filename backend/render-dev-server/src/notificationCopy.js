const supportedNotificationLocales = new Set(['ko', 'en']);

function normalizeNotificationLocale(value) {
  if (typeof value !== 'string') {
    return null;
  }

  const normalized = value.trim().toLowerCase().replaceAll('_', '-');
  if (!normalized) {
    return null;
  }

  if (normalized === 'ko' || normalized.startsWith('ko-')) {
    return 'ko';
  }
  if (normalized === 'en' || normalized.startsWith('en-')) {
    return 'en';
  }

  return null;
}

function resolveNotificationLocale(input = {}) {
  const userLocale = normalizeNotificationLocale(input.userLanguageCode);
  if (userLocale) {
    return userLocale;
  }

  const tokenLocales = Array.isArray(input.tokenLocales) ? input.tokenLocales : [];
  for (const locale of tokenLocales) {
    const normalized = normalizeNotificationLocale(locale);
    if (normalized && supportedNotificationLocales.has(normalized)) {
      return normalized;
    }
  }

  return 'ko';
}

function ensureNumber(value) {
  return typeof value === 'number' && Number.isFinite(value) ? value : 0;
}

function ensureNonEmptyString(value) {
  return typeof value === 'string' && value.trim() ? value.trim() : null;
}

const notificationTemplates = {
  SYSTEM_TEST: {
    ko: () => ({
      title: '개발용 푸시 점검',
      body: '실기기 푸시 수신 경로 점검용 테스트 알림입니다.',
    }),
    en: () => ({
      title: 'Dev Push Probe',
      body: 'Test notification for real-device push delivery checks.',
    }),
  },
  AUTO_BID_CEILING_REACHED: {
    ko: ({ finalPrice }) => ({
      title: '자동입찰 한도에 도달했습니다',
      body: `현재 최고가 ${ensureNumber(finalPrice)}원으로 자동입찰 상한을 넘었습니다.`,
    }),
    en: ({ finalPrice }) => ({
      title: 'Auto-bid ceiling reached',
      body: `Your auto-bid ceiling was exceeded at KRW ${ensureNumber(finalPrice)}.`,
    }),
  },
  OUTBID: {
    ko: ({ finalPrice }) => ({
      title: '입찰가가 갱신되었습니다',
      body: `현재 최고가 ${ensureNumber(finalPrice)}원`,
    }),
    en: ({ finalPrice }) => ({
      title: 'You were outbid',
      body: `Current highest bid: KRW ${ensureNumber(finalPrice)}.`,
    }),
  },
  WON: {
    ko: () => ({
      title: '낙찰되었습니다',
      body: '결제 기한 내 결제를 진행해주세요.',
    }),
    en: () => ({
      title: 'You won the auction',
      body: 'Please complete payment before the deadline.',
    }),
  },
  BUY_NOW_COMPLETED: {
    ko: () => ({
      title: '즉시 구매가 완료되었습니다',
      body: '결제 기한 내 결제를 진행해주세요.',
    }),
    en: () => ({
      title: 'Buy now completed',
      body: 'Please complete payment before the deadline.',
    }),
  },
  ORDER_AWAITING_PAYMENT: {
    ko: () => ({
      title: '새 주문이 결제 대기 중입니다',
      body: '구매자 결제 완료 후 배송 정보를 등록해주세요.',
    }),
    en: () => ({
      title: 'New order awaiting payment',
      body: 'Please register shipment info after buyer payment is completed.',
    }),
  },
  PAYMENT_FAILED: {
    ko: () => ({
      title: '결제가 완료되지 않았습니다',
      body: '결제 정보를 확인한 뒤 다시 시도해주세요.',
    }),
    en: () => ({
      title: 'Payment was not completed',
      body: 'Check your payment details and try again.',
    }),
  },
  PAYMENT_COMPLETED: {
    ko: () => ({
      title: '결제 완료',
      body: '구매자 결제가 완료되었습니다.',
    }),
    en: () => ({
      title: 'Payment completed',
      body: 'The buyer payment has been completed.',
    }),
  },
  PAYMENT_DUE: {
    ko: () => ({
      title: '결제 기한이 곧 만료됩니다',
      body: '결제 기한 전에 결제를 완료해주세요.',
    }),
    en: () => ({
      title: 'Payment deadline approaching',
      body: 'Please complete payment before the deadline.',
    }),
  },
  SHIPPED: {
    ko: ({ carrierName, trackingNumber }) => ({
      title: '배송이 시작되었습니다',
      body: `${ensureNonEmptyString(carrierName) ?? ''} ${ensureNonEmptyString(trackingNumber) ?? ''}`.trim(),
    }),
    en: ({ carrierName, trackingNumber }) => ({
      title: 'Shipment is on the way',
      body: `${ensureNonEmptyString(carrierName) ?? ''} ${ensureNonEmptyString(trackingNumber) ?? ''}`.trim(),
    }),
  },
  SHIPMENT_REMINDER: {
    ko: () => ({
      title: '배송 등록이 필요합니다',
      body: '결제 완료 주문의 배송 정보를 등록해주세요.',
    }),
    en: () => ({
      title: 'Shipment registration required',
      body: 'Please register shipment info for paid orders.',
    }),
  },
  RECEIPT_REMINDER: {
    ko: () => ({
      title: '수령 확인이 필요합니다',
      body: '배송 완료 주문의 수령 확인을 진행해주세요.',
    }),
    en: () => ({
      title: 'Receipt confirmation required',
      body: 'Please confirm receipt for shipped orders.',
    }),
  },
  RECEIPT_CONFIRMED: {
    ko: () => ({
      title: '구매자가 수령을 확인했습니다',
      body: '정산 예정 일정을 확인해주세요.',
    }),
    en: () => ({
      title: 'Buyer confirmed receipt',
      body: 'Please check the settlement schedule.',
    }),
  },
  SETTLED: {
    ko: ({ orderId }) => ({
      title: '정산 완료',
      body: ensureNonEmptyString(orderId)
        ? `주문 ${ensureNonEmptyString(orderId)} 정산이 완료되었습니다.`
        : '정산이 완료되었습니다.',
    }),
    en: ({ orderId }) => ({
      title: 'Settlement completed',
      body: ensureNonEmptyString(orderId)
        ? `Settlement completed for order ${ensureNonEmptyString(orderId)}.`
        : 'Settlement has been completed.',
    }),
  },
};

function buildNotificationCopy(type, locale, context = {}) {
  const templates = notificationTemplates[type];
  if (!templates) {
    return null;
  }

  const normalizedLocale = normalizeNotificationLocale(locale) ?? 'ko';
  const render =
    templates[normalizedLocale] ??
    templates.ko ??
    templates.en;
  return render ? render(context) : null;
}

export {
  buildNotificationCopy,
  normalizeNotificationLocale,
  resolveNotificationLocale,
};
