const supportedNotificationLocales = new Set(['ko', 'en']);

function normalizeNotificationLocale(value) {
  if (typeof value !== 'string') {
    return null;
  }

  const normalized = value.trim().toLowerCase();
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
