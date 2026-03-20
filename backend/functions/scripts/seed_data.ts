export interface EmulatorAuthAccount {
  uid: string;
  email: string;
  password: string;
  displayName: string;
}

export const emulatorAuthAccounts: EmulatorAuthAccount[] = [
  {
    uid: 'buyer1',
    email: 'buyer1@test.local',
    password: 'buyer-pass-1234',
    displayName: 'Buyer One',
  },
  {
    uid: 'seller1',
    email: 'seller1@test.local',
    password: 'seller-pass-1234',
    displayName: 'Seller One',
  },
  {
    uid: 'ops1',
    email: 'ops1@test.local',
    password: 'ops-pass-1234',
    displayName: 'Ops One',
  },
];

interface SeedAdminLike {
  firestore: {
    Timestamp: {
      fromDate(date: Date): unknown;
    };
  };
}

type SeedDatabaseLike = any;

function profile(
  id: string,
  input: {
    displayName: string;
    email: string;
    roles?: string[];
    completedSales?: number;
    totalAuctions?: number;
    reviewAvg?: number;
    successRate?: number;
    gradeScore?: number;
  },
) {
  return {
    displayName: input.displayName,
    photoUrl: null,
    email: input.email,
    phoneNumber: null,
    authProviders: ['password'],
    bio: `${input.displayName} bio`,
    preferences: {
      languageCode: 'ko',
      pushEnabled: true,
    },
    verification: {
      phone: 'VERIFIED',
      id: 'VERIFIED',
      preciousSeller: id === 'seller1' ? 'PENDING' : 'UNVERIFIED',
    },
    sellerStats: {
      completedSales: input.completedSales ?? 0,
      totalAuctions: input.totalAuctions ?? 0,
      successRate: input.successRate ?? 0,
      reviewAvg: input.reviewAvg ?? 0,
      gradeScore: input.gradeScore ?? 0,
    },
    penaltyStats: {
      unpaidCount: 0,
      depositForfeitedCount: 0,
      trustScore: 100,
    },
    ops: {
      roles: input.roles ?? [],
      disabledAt: null,
    },
    createdAt: new Date(),
    updatedAt: new Date(),
  };
}

export async function seedEmulator(
  db: SeedDatabaseLike,
  admin: SeedAdminLike,
): Promise<void> {
  await db.collection('users').doc('seller1').set(
    profile('seller1', {
      displayName: 'Seller One',
      email: 'seller1@test.local',
      completedSales: 10,
      totalAuctions: 20,
      successRate: 0.8,
      reviewAvg: 4.8,
      gradeScore: 88,
    }),
  );
  await db.collection('users').doc('buyer1').set(
    profile('buyer1', {
      displayName: 'Buyer One',
      email: 'buyer1@test.local',
    }),
  );
  await db.collection('users').doc('ops1').set(
    profile('ops1', {
      displayName: 'Ops One',
      email: 'ops1@test.local',
      roles: ['OPERATOR'],
    }),
  );

  await db.collection('items').doc('item-live').set({
    sellerId: 'seller1',
    status: 'READY',
    categoryMain: 'GOODS',
    categorySub: 'IDOL_MD',
    title: 'Signed Album',
    description: 'Mint condition signed album',
    condition: 'LIKE_NEW',
    tags: ['idol', 'kpop'],
    imageUrls: ['https://picsum.photos/seed/item-live/640/800'],
    authImageUrls: ['https://picsum.photos/seed/item-live-auth/640/800'],
    isOfficialMd: true,
    appraisal: { status: 'NONE', badgeLabel: null },
    createdAt: new Date(),
    updatedAt: new Date(),
  });
  await db.collection('items').doc('item-ended').set({
    sellerId: 'seller1',
    status: 'READY',
    categoryMain: 'PRECIOUS',
    categorySub: 'JEWELRY',
    title: 'Vintage Ring',
    description: 'Auction already ended with a winner',
    condition: 'GOOD',
    tags: ['ring', 'vintage'],
    imageUrls: ['https://picsum.photos/seed/item-ended/640/800'],
    authImageUrls: [],
    isOfficialMd: null,
    appraisal: { status: 'APPROVED', badgeLabel: '감정 완료' },
    createdAt: new Date(),
    updatedAt: new Date(),
  });
  await db.collection('items').doc('item-unsold').set({
    sellerId: 'seller1',
    status: 'READY',
    categoryMain: 'GOODS',
    categorySub: 'PHOTO_CARD',
    title: 'Limited Photo Card',
    description: 'Recently ended without bids',
    condition: 'GOOD',
    tags: ['idol', 'collector'],
    imageUrls: ['https://picsum.photos/seed/item-unsold/640/800'],
    authImageUrls: ['https://picsum.photos/seed/item-unsold-auth/640/800'],
    isOfficialMd: true,
    appraisal: { status: 'NONE', badgeLabel: null },
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  await db.collection('auctions').doc('auction-live').set({
    itemId: 'item-live',
    sellerId: 'seller1',
    titleSnapshot: 'Signed Album',
    heroImageUrl: 'https://picsum.photos/seed/item-live/640/800',
    categoryMain: 'GOODS',
    categorySub: 'IDOL_MD',
    startPrice: 10000,
    buyNowPrice: 18000,
    currentPrice: 12000,
    status: 'LIVE',
    startAt: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 60 * 60 * 1000),
    ),
    endAt: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 2 * 60 * 60 * 1000),
    ),
    extendedCount: 0,
    bidCount: 2,
    bidderCount: 1,
    highestBidderId: 'buyer1',
    orderId: null,
    createdAt: new Date(),
    updatedAt: new Date(),
  });
  await db.collection('auctions').doc('auction-ended').set({
    itemId: 'item-ended',
    sellerId: 'seller1',
    titleSnapshot: 'Vintage Ring',
    heroImageUrl: 'https://picsum.photos/seed/item-ended/640/800',
    categoryMain: 'PRECIOUS',
    categorySub: 'JEWELRY',
    startPrice: 200000,
    buyNowPrice: null,
    currentPrice: 255000,
    status: 'ENDED',
    startAt: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 48 * 60 * 60 * 1000),
    ),
    endAt: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 24 * 60 * 60 * 1000),
    ),
    extendedCount: 1,
    bidCount: 3,
    bidderCount: 2,
    highestBidderId: 'buyer1',
    orderId: 'order-paid',
    createdAt: new Date(),
    updatedAt: new Date(),
  });
  await db.collection('auctions').doc('auction-unsold').set({
    itemId: 'item-unsold',
    sellerId: 'seller1',
    titleSnapshot: 'Limited Photo Card',
    heroImageUrl: 'https://picsum.photos/seed/item-unsold/640/800',
    categoryMain: 'GOODS',
    categorySub: 'PHOTO_CARD',
    startPrice: 15000,
    buyNowPrice: null,
    currentPrice: 15000,
    status: 'UNSOLD',
    startAt: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 48 * 60 * 60 * 1000),
    ),
    endAt: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 12 * 60 * 60 * 1000),
    ),
    extendedCount: 0,
    bidCount: 0,
    bidderCount: 0,
    highestBidderId: null,
    orderId: null,
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  await db
    .collection('auctions')
    .doc('auction-live')
    .collection('bids')
    .doc('bid-1')
    .set({
      bidderId: 'buyer1',
      amount: 11000,
      kind: 'MANUAL',
      createdAt: new Date(Date.now() - 30 * 60 * 1000),
    });
  await db
    .collection('auctions')
    .doc('auction-live')
    .collection('bids')
    .doc('bid-2')
    .set({
      bidderId: 'buyer1',
      amount: 12000,
      kind: 'AUTO',
      createdAt: new Date(Date.now() - 20 * 60 * 1000),
    });

  await db
    .collection('auctions')
    .doc('auction-live')
    .collection('autoBids')
    .doc('buyer1')
    .set({
      maxAmount: 16000,
      isEnabled: true,
      createdAt: new Date(Date.now() - 30 * 60 * 1000),
      updatedAt: new Date(Date.now() - 20 * 60 * 1000),
    });

  await db.collection('orders').doc('order-paid').set({
    auctionId: 'auction-ended',
    itemId: 'item-ended',
    buyerId: 'buyer1',
    sellerId: 'seller1',
    finalPrice: 255000,
    paymentStatus: 'PAID',
    orderStatus: 'PAID_ESCROW_HOLD',
    paymentDueAt: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 23 * 60 * 60 * 1000),
    ),
    payment: {
      provider: 'TOSS_PAYMENTS',
      paymentKey: 'pay_test_paid',
      method: 'CARD',
      approvedAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() - 22 * 60 * 60 * 1000),
      ),
      lastWebhookEventId: null,
    },
    shipping: {
      carrierCode: null,
      carrierName: null,
      trackingNumber: null,
      trackingUrl: null,
      shippedAt: null,
    },
    settlement: {
      expectedAt: null,
      settledAt: null,
      payoutBatchId: null,
    },
    fees: {
      feeRate: 0.05,
      feeAmount: 12750,
      sellerReceivable: 242250,
    },
    createdAt: new Date(),
    updatedAt: new Date(),
  });
  await db.collection('orders').doc('order-awaiting').set({
    auctionId: 'auction-live',
    itemId: 'item-live',
    buyerId: 'buyer1',
    sellerId: 'seller1',
    finalPrice: 18000,
    paymentStatus: 'UNPAID',
    orderStatus: 'AWAITING_PAYMENT',
    paymentDueAt: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 6 * 60 * 60 * 1000),
    ),
    payment: {
      provider: 'TOSS_PAYMENTS',
      paymentKey: null,
      method: null,
      approvedAt: null,
      lastWebhookEventId: null,
    },
    shipping: {
      carrierCode: null,
      carrierName: null,
      trackingNumber: null,
      trackingUrl: null,
      shippedAt: null,
    },
    settlement: {
      expectedAt: null,
      settledAt: null,
      payoutBatchId: null,
    },
    fees: {
      feeRate: 0.05,
      feeAmount: 900,
      sellerReceivable: 17100,
    },
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  await db
    .collection('notifications')
    .doc('buyer1')
    .collection('inbox')
    .doc('notification-1')
    .set({
      type: 'OUTBID',
      title: '입찰가가 갱신되었습니다',
      body: '새로운 최고가가 등록되었습니다.',
      deeplink: 'app://auction/auction-live',
      isRead: false,
      createdAt: new Date(),
    });
  await db
    .collection('notifications')
    .doc('seller1')
    .collection('inbox')
    .doc('notification-2')
    .set({
      type: 'PAYMENT_COMPLETED',
      title: '결제 완료',
      body: '구매자 결제가 완료되었습니다.',
      deeplink: 'app://orders/order-paid',
      isRead: false,
      createdAt: new Date(),
    });
}
