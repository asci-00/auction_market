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
  {
    uid: 'buyer2',
    email: 'buyer2@test.local',
    password: 'buyer2-pass-1234',
    displayName: 'Buyer Two',
  },
  {
    uid: 'seller2',
    email: 'seller2@test.local',
    password: 'seller2-pass-1234',
    displayName: 'Seller Two',
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
  const nowMs = Date.now();
  const hours = (value: number) => value * 60 * 60 * 1000;
  const mins = (value: number) => value * 60 * 1000;
  const ago = (value: number) => new Date(nowMs - hours(value));
  const ahead = (value: number) => new Date(nowMs + hours(value));
  const agoMins = (value: number) => new Date(nowMs - mins(value));

  const asTimestamp = (date: Date) => admin.firestore.Timestamp.fromDate(date);
  const productImagesBySeed: Record<string, string[]> = {
    'item-live': [
      'https://loremflickr.com/640/800/kpop,album?lock=1101',
      'https://loremflickr.com/640/800/cd,collection?lock=1102',
    ],
    'item-live-watch': [
      'https://loremflickr.com/640/800/luxury,watch?lock=1201',
      'https://loremflickr.com/640/800/diver,watch?lock=1202',
    ],
    'item-live-sneakers': [
      'https://loremflickr.com/640/800/sneakers,shoe?lock=1301',
      'https://loremflickr.com/640/800/streetwear,sneakers?lock=1302',
    ],
    'item-live-goldbar': [
      'https://loremflickr.com/640/800/gold,bar?lock=1401',
      'https://loremflickr.com/640/800/bullion,investment?lock=1402',
    ],
    'item-live-camera': [
      'https://loremflickr.com/640/800/mirrorless,camera?lock=1501',
      'https://loremflickr.com/640/800/photography,camera?lock=1502',
    ],
    'item-ended': [
      'https://loremflickr.com/640/800/vintage,ring?lock=1601',
      'https://loremflickr.com/640/800/jewelry,ring?lock=1602',
    ],
    'item-ended-shipped': [
      'https://loremflickr.com/640/800/anime,figure?lock=1701',
      'https://loremflickr.com/640/800/collector,toy?lock=1702',
    ],
    'item-ended-settled': [
      'https://loremflickr.com/640/800/diamond,pendant?lock=1801',
      'https://loremflickr.com/640/800/necklace,jewelry?lock=1802',
    ],
    'item-unsold': [
      'https://loremflickr.com/640/800/photocard,collection?lock=1901',
      'https://loremflickr.com/640/800/trading,card?lock=1902',
    ],
    'item-cancelled': [
      'https://loremflickr.com/640/800/handheld,console?lock=2001',
      'https://loremflickr.com/640/800/gaming,console?lock=2002',
    ],
  };
  const authImagesBySeed: Record<string, string[]> = {
    'item-live-auth': [
      'https://loremflickr.com/640/800/certificate,document?lock=2101',
      'https://loremflickr.com/640/800/receipt,proof?lock=2102',
    ],
    'item-live-sneakers-auth': [
      'https://loremflickr.com/640/800/shoebox,label?lock=2201',
      'https://loremflickr.com/640/800/shoe,tag?lock=2202',
    ],
    'item-live-camera-auth': [
      'https://loremflickr.com/640/800/camera,serial?lock=2301',
      'https://loremflickr.com/640/800/manual,camera?lock=2302',
    ],
    'item-ended-shipped-auth': [
      'https://loremflickr.com/640/800/figure,box?lock=2401',
      'https://loremflickr.com/640/800/product,seal?lock=2402',
    ],
    'item-unsold-auth': [
      'https://loremflickr.com/640/800/card,sleeve?lock=2501',
      'https://loremflickr.com/640/800/collector,album?lock=2502',
    ],
    'item-cancelled-auth': [
      'https://loremflickr.com/640/800/console,serial?lock=2601',
      'https://loremflickr.com/640/800/warranty,card?lock=2602',
    ],
  };
  const fallbackProductImage = (seed: string) =>
    `https://loremflickr.com/640/800/product,market?lock=${seed.length * 97}`;
  const writeDoc = async (
    collection: string,
    id: string,
    payload: Record<string, unknown>,
  ) => {
    await db.collection(collection).doc(id).set(payload);
  };

  await writeDoc(
    'users',
    'seller1',
    profile('seller1', {
      displayName: 'Seller One',
      email: 'seller1@test.local',
      completedSales: 124,
      totalAuctions: 173,
      successRate: 0.91,
      reviewAvg: 4.9,
      gradeScore: 96,
    }),
  );
  await writeDoc(
    'users',
    'seller2',
    profile('seller2', {
      displayName: 'Seller Two',
      email: 'seller2@test.local',
      completedSales: 41,
      totalAuctions: 68,
      successRate: 0.78,
      reviewAvg: 4.5,
      gradeScore: 82,
    }),
  );
  await writeDoc(
    'users',
    'buyer1',
    profile('buyer1', {
      displayName: 'Buyer One',
      email: 'buyer1@test.local',
    }),
  );
  await writeDoc(
    'users',
    'buyer2',
    profile('buyer2', {
      displayName: 'Buyer Two',
      email: 'buyer2@test.local',
    }),
  );
  await writeDoc(
    'users',
    'ops1',
    profile('ops1', {
      displayName: 'Ops One',
      email: 'ops1@test.local',
      roles: ['OPERATOR'],
    }),
  );

  const items: Array<{
    id: string;
    sellerId: string;
    categoryMain: 'GOODS' | 'PRECIOUS';
    categorySub: string;
    title: string;
    description: string;
    condition: string;
    tags: string[];
    imageSeed: string;
    authImageSeed?: string;
    isOfficialMd: boolean | null;
    appraisalStatus: 'NONE' | 'REQUESTED' | 'APPROVED' | 'REJECTED';
    appraisalLabel: string | null;
  }> = [
    {
      id: 'item-live',
      sellerId: 'seller1',
      categoryMain: 'GOODS',
      categorySub: 'IDOL_MD',
      title: 'Signed Album (Limited Press)',
      description:
        'Factory-sealed signed album with hologram proof and scratch-free casing.',
      condition: 'LIKE_NEW',
      tags: ['idol', 'album', 'signed'],
      imageSeed: 'item-live',
      authImageSeed: 'item-live-auth',
      isOfficialMd: true,
      appraisalStatus: 'NONE',
      appraisalLabel: null,
    },
    {
      id: 'item-live-watch',
      sellerId: 'seller2',
      categoryMain: 'PRECIOUS',
      categorySub: 'WATCH',
      title: 'Automatic Diver Watch',
      description:
        '42mm diver watch with original box and service card, tested in 2025.',
      condition: 'GOOD',
      tags: ['watch', 'diver', 'automatic'],
      imageSeed: 'item-live-watch',
      isOfficialMd: null,
      appraisalStatus: 'APPROVED',
      appraisalLabel: '감정 완료',
    },
    {
      id: 'item-live-sneakers',
      sellerId: 'seller1',
      categoryMain: 'GOODS',
      categorySub: 'SNEAKERS',
      title: 'Deadstock Retro Sneakers',
      description:
        'US 270 size, unopened laces and all accessories included from launch batch.',
      condition: 'NEW',
      tags: ['sneakers', 'retro', 'deadstock'],
      imageSeed: 'item-live-sneakers',
      authImageSeed: 'item-live-sneakers-auth',
      isOfficialMd: true,
      appraisalStatus: 'REQUESTED',
      appraisalLabel: null,
    },
    {
      id: 'item-live-goldbar',
      sellerId: 'seller2',
      categoryMain: 'PRECIOUS',
      categorySub: 'BULLION',
      title: '1oz Gold Bar',
      description:
        'Mint-certified 1oz bar with serial card and tamper-evident packaging.',
      condition: 'LIKE_NEW',
      tags: ['gold', 'bullion', 'investment'],
      imageSeed: 'item-live-goldbar',
      isOfficialMd: null,
      appraisalStatus: 'APPROVED',
      appraisalLabel: '정품 보증',
    },
    {
      id: 'item-live-camera',
      sellerId: 'seller1',
      categoryMain: 'GOODS',
      categorySub: 'CAMERA',
      title: 'Mirrorless Camera Body',
      description:
        'Low shutter count body only, sensor cleaned recently, includes two batteries.',
      condition: 'GOOD',
      tags: ['camera', 'mirrorless', 'creator'],
      imageSeed: 'item-live-camera',
      authImageSeed: 'item-live-camera-auth',
      isOfficialMd: false,
      appraisalStatus: 'NONE',
      appraisalLabel: null,
    },
    {
      id: 'item-ended',
      sellerId: 'seller1',
      categoryMain: 'PRECIOUS',
      categorySub: 'JEWELRY',
      title: 'Vintage Ring',
      description: 'Auction ended after competitive bidding.',
      condition: 'GOOD',
      tags: ['ring', 'vintage'],
      imageSeed: 'item-ended',
      isOfficialMd: null,
      appraisalStatus: 'APPROVED',
      appraisalLabel: '감정 완료',
    },
    {
      id: 'item-ended-awaiting',
      sellerId: 'seller1',
      categoryMain: 'GOODS',
      categorySub: 'IDOL_MD',
      title: 'Signed Album (Awaiting Payment)',
      description:
        'Auction ended and is waiting for buyer payment confirmation.',
      condition: 'LIKE_NEW',
      tags: ['idol', 'album', 'payment-due'],
      imageSeed: 'item-live',
      authImageSeed: 'item-live-auth',
      isOfficialMd: true,
      appraisalStatus: 'NONE',
      appraisalLabel: null,
    },
    {
      id: 'item-ended-shipped',
      sellerId: 'seller2',
      categoryMain: 'GOODS',
      categorySub: 'FIGURE',
      title: 'Collector Figure Set',
      description: 'Payment complete and already shipped to buyer.',
      condition: 'LIKE_NEW',
      tags: ['figure', 'collector'],
      imageSeed: 'item-ended-shipped',
      authImageSeed: 'item-ended-shipped-auth',
      isOfficialMd: true,
      appraisalStatus: 'NONE',
      appraisalLabel: null,
    },
    {
      id: 'item-ended-paid-seller2',
      sellerId: 'seller2',
      categoryMain: 'GOODS',
      categorySub: 'FIGURE',
      title: 'Artist Figure Bust',
      description: 'Payment complete and waiting for seller shipment.',
      condition: 'LIKE_NEW',
      tags: ['figure', 'shipment'],
      imageSeed: 'item-ended-shipped',
      authImageSeed: 'item-ended-shipped-auth',
      isOfficialMd: true,
      appraisalStatus: 'NONE',
      appraisalLabel: null,
    },
    {
      id: 'item-ended-confirmed',
      sellerId: 'seller2',
      categoryMain: 'GOODS',
      categorySub: 'FIGURE',
      title: 'Collector Figure Set (Confirmed)',
      description: 'Buyer already confirmed receipt and settlement is pending.',
      condition: 'LIKE_NEW',
      tags: ['figure', 'confirmed'],
      imageSeed: 'item-ended-shipped',
      authImageSeed: 'item-ended-shipped-auth',
      isOfficialMd: true,
      appraisalStatus: 'NONE',
      appraisalLabel: null,
    },
    {
      id: 'item-ended-settled',
      sellerId: 'seller1',
      categoryMain: 'PRECIOUS',
      categorySub: 'JEWELRY',
      title: 'Diamond Pendant',
      description: 'Completed transaction and settled payout.',
      condition: 'GOOD',
      tags: ['diamond', 'pendant'],
      imageSeed: 'item-ended-settled',
      isOfficialMd: null,
      appraisalStatus: 'APPROVED',
      appraisalLabel: '감정 완료',
    },
    {
      id: 'item-ended-cancelled-unpaid',
      sellerId: 'seller1',
      categoryMain: 'GOODS',
      categorySub: 'PHOTO_CARD',
      title: 'Limited Photo Card (Unpaid Cancelled)',
      description: 'Auction ended but the winning order expired unpaid.',
      condition: 'GOOD',
      tags: ['idol', 'collector', 'cancelled'],
      imageSeed: 'item-unsold',
      authImageSeed: 'item-unsold-auth',
      isOfficialMd: true,
      appraisalStatus: 'NONE',
      appraisalLabel: null,
    },
    {
      id: 'item-unsold',
      sellerId: 'seller1',
      categoryMain: 'GOODS',
      categorySub: 'PHOTO_CARD',
      title: 'Limited Photo Card',
      description: 'Auction ended without bids.',
      condition: 'GOOD',
      tags: ['idol', 'collector'],
      imageSeed: 'item-unsold',
      authImageSeed: 'item-unsold-auth',
      isOfficialMd: true,
      appraisalStatus: 'NONE',
      appraisalLabel: null,
    },
    {
      id: 'item-cancelled',
      sellerId: 'seller2',
      categoryMain: 'GOODS',
      categorySub: 'GAME_CONSOLE',
      title: 'Handheld Game Console',
      description: 'Seller cancelled before order creation.',
      condition: 'GOOD',
      tags: ['console', 'gaming'],
      imageSeed: 'item-cancelled',
      authImageSeed: 'item-cancelled-auth',
      isOfficialMd: false,
      appraisalStatus: 'NONE',
      appraisalLabel: null,
    },
  ];

  for (const item of items) {
    await writeDoc('items', item.id, {
      sellerId: item.sellerId,
      status: 'READY',
      categoryMain: item.categoryMain,
      categorySub: item.categorySub,
      title: item.title,
      description: item.description,
      condition: item.condition,
      tags: item.tags,
      imageUrls: productImagesBySeed[item.imageSeed] ?? [
        fallbackProductImage(item.imageSeed),
      ],
      authImageUrls:
        item.authImageSeed == null
          ? []
          : (authImagesBySeed[item.authImageSeed] ?? []),
      isOfficialMd: item.isOfficialMd,
      appraisal: {
        status: item.appraisalStatus,
        badgeLabel: item.appraisalLabel,
      },
      createdAt: ago(96),
      updatedAt: ago(1),
    });
  }

  const auctions: Array<{
    id: string;
    itemId: string;
    sellerId: string;
    titleSnapshot: string;
    heroImageSeed: string;
    categoryMain: 'GOODS' | 'PRECIOUS';
    categorySub: string;
    startPrice: number;
    buyNowPrice: number | null;
    currentPrice: number;
    status: 'DRAFT' | 'LIVE' | 'ENDED' | 'UNSOLD' | 'CANCELLED';
    startAt: Date;
    endAt: Date;
    extendedCount: number;
    bidCount: number;
    bidderCount: number;
    highestBidderId: string | null;
    orderId: string | null;
    createdAt: Date;
    updatedAt: Date;
  }> = [
    {
      id: 'auction-live',
      itemId: 'item-live',
      sellerId: 'seller1',
      titleSnapshot: 'Signed Album (Limited Press)',
      heroImageSeed: 'item-live',
      categoryMain: 'GOODS',
      categorySub: 'IDOL_MD',
      startPrice: 10000,
      buyNowPrice: 18000,
      currentPrice: 13200,
      status: 'LIVE',
      startAt: ago(4),
      endAt: ahead(2),
      extendedCount: 1,
      bidCount: 4,
      bidderCount: 2,
      highestBidderId: 'buyer2',
      orderId: null,
      createdAt: ago(28),
      updatedAt: agoMins(8),
    },
    {
      id: 'auction-live-watch',
      itemId: 'item-live-watch',
      sellerId: 'seller2',
      titleSnapshot: 'Automatic Diver Watch',
      heroImageSeed: 'item-live-watch',
      categoryMain: 'PRECIOUS',
      categorySub: 'WATCH',
      startPrice: 620000,
      buyNowPrice: 890000,
      currentPrice: 710000,
      status: 'LIVE',
      startAt: ago(8),
      endAt: ahead(7),
      extendedCount: 0,
      bidCount: 3,
      bidderCount: 2,
      highestBidderId: 'buyer1',
      orderId: null,
      createdAt: ago(38),
      updatedAt: agoMins(22),
    },
    {
      id: 'auction-live-sneakers',
      itemId: 'item-live-sneakers',
      sellerId: 'seller1',
      titleSnapshot: 'Deadstock Retro Sneakers',
      heroImageSeed: 'item-live-sneakers',
      categoryMain: 'GOODS',
      categorySub: 'SNEAKERS',
      startPrice: 170000,
      buyNowPrice: 240000,
      currentPrice: 196000,
      status: 'LIVE',
      startAt: ago(2),
      endAt: ahead(14),
      extendedCount: 0,
      bidCount: 2,
      bidderCount: 1,
      highestBidderId: 'buyer1',
      orderId: null,
      createdAt: ago(26),
      updatedAt: agoMins(40),
    },
    {
      id: 'auction-live-goldbar',
      itemId: 'item-live-goldbar',
      sellerId: 'seller2',
      titleSnapshot: '1oz Gold Bar',
      heroImageSeed: 'item-live-goldbar',
      categoryMain: 'PRECIOUS',
      categorySub: 'BULLION',
      startPrice: 3600000,
      buyNowPrice: null,
      currentPrice: 3810000,
      status: 'LIVE',
      startAt: ago(10),
      endAt: ahead(5),
      extendedCount: 2,
      bidCount: 5,
      bidderCount: 2,
      highestBidderId: 'buyer2',
      orderId: null,
      createdAt: ago(52),
      updatedAt: agoMins(5),
    },
    {
      id: 'auction-live-camera',
      itemId: 'item-live-camera',
      sellerId: 'seller1',
      titleSnapshot: 'Mirrorless Camera Body',
      heroImageSeed: 'item-live-camera',
      categoryMain: 'GOODS',
      categorySub: 'CAMERA',
      startPrice: 540000,
      buyNowPrice: 670000,
      currentPrice: 540000,
      status: 'LIVE',
      startAt: ago(1),
      endAt: ahead(31),
      extendedCount: 0,
      bidCount: 0,
      bidderCount: 0,
      highestBidderId: null,
      orderId: null,
      createdAt: ago(18),
      updatedAt: ago(1),
    },
    {
      id: 'auction-draft-upcoming',
      itemId: 'item-live-camera',
      sellerId: 'seller1',
      titleSnapshot: 'Mirrorless Camera Body',
      heroImageSeed: 'item-live-camera',
      categoryMain: 'GOODS',
      categorySub: 'CAMERA',
      startPrice: 520000,
      buyNowPrice: 650000,
      currentPrice: 520000,
      status: 'DRAFT',
      startAt: ahead(12),
      endAt: ahead(48),
      extendedCount: 0,
      bidCount: 0,
      bidderCount: 0,
      highestBidderId: null,
      orderId: null,
      createdAt: ago(3),
      updatedAt: ago(2),
    },
    {
      id: 'auction-ended-awaiting',
      itemId: 'item-ended-awaiting',
      sellerId: 'seller1',
      titleSnapshot: 'Signed Album (Awaiting Payment)',
      heroImageSeed: 'item-live',
      categoryMain: 'GOODS',
      categorySub: 'IDOL_MD',
      startPrice: 10000,
      buyNowPrice: 18000,
      currentPrice: 18000,
      status: 'ENDED',
      startAt: ago(16),
      endAt: ago(2),
      extendedCount: 0,
      bidCount: 4,
      bidderCount: 2,
      highestBidderId: 'buyer1',
      orderId: 'order-awaiting',
      createdAt: ago(28),
      updatedAt: ago(1),
    },
    {
      id: 'auction-ended',
      itemId: 'item-ended',
      sellerId: 'seller1',
      titleSnapshot: 'Vintage Ring',
      heroImageSeed: 'item-ended',
      categoryMain: 'PRECIOUS',
      categorySub: 'JEWELRY',
      startPrice: 200000,
      buyNowPrice: null,
      currentPrice: 255000,
      status: 'ENDED',
      startAt: ago(72),
      endAt: ago(28),
      extendedCount: 1,
      bidCount: 3,
      bidderCount: 2,
      highestBidderId: 'buyer1',
      orderId: 'order-paid',
      createdAt: ago(90),
      updatedAt: ago(25),
    },
    {
      id: 'auction-ended-paid-seller2',
      itemId: 'item-ended-paid-seller2',
      sellerId: 'seller2',
      titleSnapshot: 'Artist Figure Bust',
      heroImageSeed: 'item-ended-shipped',
      categoryMain: 'GOODS',
      categorySub: 'FIGURE',
      startPrice: 160000,
      buyNowPrice: 214000,
      currentPrice: 214000,
      status: 'ENDED',
      startAt: ago(40),
      endAt: ago(24),
      extendedCount: 0,
      bidCount: 3,
      bidderCount: 2,
      highestBidderId: 'buyer2',
      orderId: 'order-paid-seller2',
      createdAt: ago(52),
      updatedAt: ago(23),
    },
    {
      id: 'auction-ended-shipped',
      itemId: 'item-ended-shipped',
      sellerId: 'seller2',
      titleSnapshot: 'Collector Figure Set',
      heroImageSeed: 'item-ended-shipped',
      categoryMain: 'GOODS',
      categorySub: 'FIGURE',
      startPrice: 80000,
      buyNowPrice: 128000,
      currentPrice: 116000,
      status: 'ENDED',
      startAt: ago(60),
      endAt: ago(26),
      extendedCount: 0,
      bidCount: 4,
      bidderCount: 2,
      highestBidderId: 'buyer1',
      orderId: 'order-shipped',
      createdAt: ago(88),
      updatedAt: ago(10),
    },
    {
      id: 'auction-ended-confirmed',
      itemId: 'item-ended-confirmed',
      sellerId: 'seller2',
      titleSnapshot: 'Collector Figure Set (Confirmed)',
      heroImageSeed: 'item-ended-shipped',
      categoryMain: 'GOODS',
      categorySub: 'FIGURE',
      startPrice: 86000,
      buyNowPrice: 132000,
      currentPrice: 124000,
      status: 'ENDED',
      startAt: ago(96),
      endAt: ago(80),
      extendedCount: 0,
      bidCount: 3,
      bidderCount: 2,
      highestBidderId: 'buyer2',
      orderId: 'order-confirmed',
      createdAt: ago(118),
      updatedAt: ago(8),
    },
    {
      id: 'auction-ended-settled',
      itemId: 'item-ended-settled',
      sellerId: 'seller1',
      titleSnapshot: 'Diamond Pendant',
      heroImageSeed: 'item-ended-settled',
      categoryMain: 'PRECIOUS',
      categorySub: 'JEWELRY',
      startPrice: 950000,
      buyNowPrice: 1150000,
      currentPrice: 1040000,
      status: 'ENDED',
      startAt: ago(160),
      endAt: ago(120),
      extendedCount: 0,
      bidCount: 2,
      bidderCount: 1,
      highestBidderId: 'buyer2',
      orderId: 'order-settled',
      createdAt: ago(188),
      updatedAt: ago(70),
    },
    {
      id: 'auction-ended-cancelled-unpaid',
      itemId: 'item-ended-cancelled-unpaid',
      sellerId: 'seller1',
      titleSnapshot: 'Limited Photo Card (Unpaid Cancelled)',
      heroImageSeed: 'item-unsold',
      categoryMain: 'GOODS',
      categorySub: 'PHOTO_CARD',
      startPrice: 15000,
      buyNowPrice: null,
      currentPrice: 15000,
      status: 'ENDED',
      startAt: ago(44),
      endAt: ago(30),
      extendedCount: 0,
      bidCount: 1,
      bidderCount: 1,
      highestBidderId: 'buyer1',
      orderId: 'order-cancelled-unpaid',
      createdAt: ago(58),
      updatedAt: ago(29),
    },
    {
      id: 'auction-unsold',
      itemId: 'item-unsold',
      sellerId: 'seller1',
      titleSnapshot: 'Limited Photo Card',
      heroImageSeed: 'item-unsold',
      categoryMain: 'GOODS',
      categorySub: 'PHOTO_CARD',
      startPrice: 15000,
      buyNowPrice: null,
      currentPrice: 15000,
      status: 'UNSOLD',
      startAt: ago(60),
      endAt: ago(20),
      extendedCount: 0,
      bidCount: 0,
      bidderCount: 0,
      highestBidderId: null,
      orderId: null,
      createdAt: ago(82),
      updatedAt: ago(20),
    },
    {
      id: 'auction-cancelled',
      itemId: 'item-cancelled',
      sellerId: 'seller2',
      titleSnapshot: 'Handheld Game Console',
      heroImageSeed: 'item-cancelled',
      categoryMain: 'GOODS',
      categorySub: 'GAME_CONSOLE',
      startPrice: 120000,
      buyNowPrice: 180000,
      currentPrice: 120000,
      status: 'CANCELLED',
      startAt: ago(16),
      endAt: ahead(8),
      extendedCount: 0,
      bidCount: 0,
      bidderCount: 0,
      highestBidderId: null,
      orderId: null,
      createdAt: ago(40),
      updatedAt: ago(12),
    },
  ];

  for (const auction of auctions) {
    await writeDoc('auctions', auction.id, {
      itemId: auction.itemId,
      sellerId: auction.sellerId,
      titleSnapshot: auction.titleSnapshot,
      heroImageUrl: (productImagesBySeed[auction.heroImageSeed] ?? [
        fallbackProductImage(auction.heroImageSeed),
      ])[0],
      categoryMain: auction.categoryMain,
      categorySub: auction.categorySub,
      startPrice: auction.startPrice,
      buyNowPrice: auction.buyNowPrice,
      currentPrice: auction.currentPrice,
      status: auction.status,
      startAt: asTimestamp(auction.startAt),
      endAt: asTimestamp(auction.endAt),
      extendedCount: auction.extendedCount,
      bidCount: auction.bidCount,
      bidderCount: auction.bidderCount,
      highestBidderId: auction.highestBidderId,
      orderId: auction.orderId,
      createdAt: auction.createdAt,
      updatedAt: auction.updatedAt,
    });
  }

  const bidRows: Array<{
    auctionId: string;
    id: string;
    bidderId: string;
    amount: number;
    kind: 'MANUAL' | 'AUTO';
    createdAt: Date;
  }> = [
    {
      auctionId: 'auction-live',
      id: 'bid-1',
      bidderId: 'buyer1',
      amount: 11000,
      kind: 'MANUAL',
      createdAt: agoMins(85),
    },
    {
      auctionId: 'auction-live',
      id: 'bid-2',
      bidderId: 'buyer2',
      amount: 11800,
      kind: 'AUTO',
      createdAt: agoMins(56),
    },
    {
      auctionId: 'auction-live',
      id: 'bid-3',
      bidderId: 'buyer1',
      amount: 12600,
      kind: 'MANUAL',
      createdAt: agoMins(32),
    },
    {
      auctionId: 'auction-live',
      id: 'bid-4',
      bidderId: 'buyer2',
      amount: 13200,
      kind: 'AUTO',
      createdAt: agoMins(8),
    },
    {
      auctionId: 'auction-live-watch',
      id: 'bid-1',
      bidderId: 'buyer2',
      amount: 680000,
      kind: 'MANUAL',
      createdAt: agoMins(170),
    },
    {
      auctionId: 'auction-live-watch',
      id: 'bid-2',
      bidderId: 'buyer1',
      amount: 695000,
      kind: 'AUTO',
      createdAt: agoMins(120),
    },
    {
      auctionId: 'auction-live-watch',
      id: 'bid-3',
      bidderId: 'buyer1',
      amount: 710000,
      kind: 'AUTO',
      createdAt: agoMins(22),
    },
    {
      auctionId: 'auction-live-sneakers',
      id: 'bid-1',
      bidderId: 'buyer1',
      amount: 184000,
      kind: 'MANUAL',
      createdAt: agoMins(70),
    },
    {
      auctionId: 'auction-live-sneakers',
      id: 'bid-2',
      bidderId: 'buyer1',
      amount: 196000,
      kind: 'AUTO',
      createdAt: agoMins(40),
    },
    {
      auctionId: 'auction-live-goldbar',
      id: 'bid-1',
      bidderId: 'buyer1',
      amount: 3680000,
      kind: 'MANUAL',
      createdAt: agoMins(200),
    },
    {
      auctionId: 'auction-live-goldbar',
      id: 'bid-2',
      bidderId: 'buyer2',
      amount: 3720000,
      kind: 'MANUAL',
      createdAt: agoMins(170),
    },
    {
      auctionId: 'auction-live-goldbar',
      id: 'bid-3',
      bidderId: 'buyer1',
      amount: 3770000,
      kind: 'AUTO',
      createdAt: agoMins(140),
    },
    {
      auctionId: 'auction-ended-awaiting',
      id: 'bid-1',
      bidderId: 'buyer2',
      amount: 12400,
      kind: 'MANUAL',
      createdAt: ago(6),
    },
    {
      auctionId: 'auction-ended-awaiting',
      id: 'bid-2',
      bidderId: 'buyer1',
      amount: 14800,
      kind: 'AUTO',
      createdAt: ago(5),
    },
    {
      auctionId: 'auction-ended-awaiting',
      id: 'bid-3',
      bidderId: 'buyer2',
      amount: 16400,
      kind: 'MANUAL',
      createdAt: ago(4),
    },
    {
      auctionId: 'auction-ended-awaiting',
      id: 'bid-4',
      bidderId: 'buyer1',
      amount: 18000,
      kind: 'AUTO',
      createdAt: ago(2),
    },
    {
      auctionId: 'auction-ended-paid-seller2',
      id: 'bid-1',
      bidderId: 'buyer1',
      amount: 178000,
      kind: 'MANUAL',
      createdAt: ago(30),
    },
    {
      auctionId: 'auction-ended-paid-seller2',
      id: 'bid-2',
      bidderId: 'buyer2',
      amount: 196000,
      kind: 'MANUAL',
      createdAt: ago(28),
    },
    {
      auctionId: 'auction-ended-paid-seller2',
      id: 'bid-3',
      bidderId: 'buyer2',
      amount: 214000,
      kind: 'AUTO',
      createdAt: ago(24),
    },
    {
      auctionId: 'auction-ended-confirmed',
      id: 'bid-1',
      bidderId: 'buyer1',
      amount: 98000,
      kind: 'MANUAL',
      createdAt: ago(84),
    },
    {
      auctionId: 'auction-ended-confirmed',
      id: 'bid-2',
      bidderId: 'buyer2',
      amount: 112000,
      kind: 'MANUAL',
      createdAt: ago(82),
    },
    {
      auctionId: 'auction-ended-confirmed',
      id: 'bid-3',
      bidderId: 'buyer2',
      amount: 124000,
      kind: 'AUTO',
      createdAt: ago(80),
    },
    {
      auctionId: 'auction-ended-cancelled-unpaid',
      id: 'bid-1',
      bidderId: 'buyer1',
      amount: 15000,
      kind: 'MANUAL',
      createdAt: ago(32),
    },
    {
      auctionId: 'auction-live-goldbar',
      id: 'bid-4',
      bidderId: 'buyer2',
      amount: 3790000,
      kind: 'AUTO',
      createdAt: agoMins(64),
    },
    {
      auctionId: 'auction-live-goldbar',
      id: 'bid-5',
      bidderId: 'buyer2',
      amount: 3810000,
      kind: 'AUTO',
      createdAt: agoMins(5),
    },
  ];

  for (const bid of bidRows) {
    await db
      .collection('auctions')
      .doc(bid.auctionId)
      .collection('bids')
      .doc(bid.id)
      .set({
        bidderId: bid.bidderId,
        amount: bid.amount,
        kind: bid.kind,
        createdAt: bid.createdAt,
      });
  }

  const autoBidRows: Array<{
    auctionId: string;
    bidderId: string;
    maxAmount: number;
    isEnabled: boolean;
    createdAt: Date;
    updatedAt: Date;
  }> = [
    {
      auctionId: 'auction-live',
      bidderId: 'buyer1',
      maxAmount: 15000,
      isEnabled: true,
      createdAt: agoMins(70),
      updatedAt: agoMins(32),
    },
    {
      auctionId: 'auction-live',
      bidderId: 'buyer2',
      maxAmount: 16500,
      isEnabled: true,
      createdAt: agoMins(58),
      updatedAt: agoMins(8),
    },
    {
      auctionId: 'auction-live-watch',
      bidderId: 'buyer1',
      maxAmount: 740000,
      isEnabled: true,
      createdAt: agoMins(124),
      updatedAt: agoMins(22),
    },
    {
      auctionId: 'auction-live-sneakers',
      bidderId: 'buyer1',
      maxAmount: 210000,
      isEnabled: true,
      createdAt: agoMins(68),
      updatedAt: agoMins(40),
    },
    {
      auctionId: 'auction-live-goldbar',
      bidderId: 'buyer2',
      maxAmount: 3900000,
      isEnabled: true,
      createdAt: agoMins(180),
      updatedAt: agoMins(5),
    },
  ];

  for (const autoBid of autoBidRows) {
    await db
      .collection('auctions')
      .doc(autoBid.auctionId)
      .collection('autoBids')
      .doc(autoBid.bidderId)
      .set({
        maxAmount: autoBid.maxAmount,
        isEnabled: autoBid.isEnabled,
        createdAt: autoBid.createdAt,
        updatedAt: autoBid.updatedAt,
      });
  }

  const orders: Array<{
    id: string;
    auctionId: string;
    itemId: string;
    buyerId: string;
    sellerId: string;
    finalPrice: number;
    paymentStatus: 'UNPAID' | 'PAID' | 'FAILED' | 'CANCELLED';
    orderStatus:
      | 'AWAITING_PAYMENT'
      | 'PAID_ESCROW_HOLD'
      | 'SHIPPED'
      | 'CONFIRMED_RECEIPT'
      | 'SETTLED'
      | 'CANCELLED_UNPAID';
    paymentDueAt: Date;
    paymentKey: string | null;
    method: string | null;
    approvedAt: Date | null;
    lastWebhookEventId: string | null;
    carrierCode: string | null;
    carrierName: string | null;
    trackingNumber: string | null;
    trackingUrl: string | null;
    shippedAt: Date | null;
    settlementExpectedAt: Date | null;
    settlementSettledAt: Date | null;
    payoutBatchId: string | null;
    feeRate: number;
    feeAmount: number;
    sellerReceivable: number;
    createdAt: Date;
    updatedAt: Date;
  }> = [
    {
      id: 'order-paid',
      auctionId: 'auction-ended',
      itemId: 'item-ended',
      buyerId: 'buyer1',
      sellerId: 'seller1',
      finalPrice: 255000,
      paymentStatus: 'PAID',
      orderStatus: 'PAID_ESCROW_HOLD',
      paymentDueAt: ago(27),
      paymentKey: 'pay_test_paid',
      method: 'CARD',
      approvedAt: ago(26),
      lastWebhookEventId: 'evt_paid_auction-ended',
      carrierCode: null,
      carrierName: null,
      trackingNumber: null,
      trackingUrl: null,
      shippedAt: null,
      settlementExpectedAt: ahead(36),
      settlementSettledAt: null,
      payoutBatchId: null,
      feeRate: 0.05,
      feeAmount: 12750,
      sellerReceivable: 242250,
      createdAt: ago(27),
      updatedAt: ago(25),
    },
    {
      id: 'order-awaiting',
      auctionId: 'auction-ended-awaiting',
      itemId: 'item-ended-awaiting',
      buyerId: 'buyer1',
      sellerId: 'seller1',
      finalPrice: 18000,
      paymentStatus: 'UNPAID',
      orderStatus: 'AWAITING_PAYMENT',
      paymentDueAt: ahead(6),
      paymentKey: null,
      method: null,
      approvedAt: null,
      lastWebhookEventId: null,
      carrierCode: null,
      carrierName: null,
      trackingNumber: null,
      trackingUrl: null,
      shippedAt: null,
      settlementExpectedAt: null,
      settlementSettledAt: null,
      payoutBatchId: null,
      feeRate: 0.05,
      feeAmount: 900,
      sellerReceivable: 17100,
      createdAt: ago(2),
      updatedAt: ago(1),
    },
    {
      id: 'order-paid-seller2',
      auctionId: 'auction-ended-paid-seller2',
      itemId: 'item-ended-paid-seller2',
      buyerId: 'buyer2',
      sellerId: 'seller2',
      finalPrice: 214000,
      paymentStatus: 'PAID',
      orderStatus: 'PAID_ESCROW_HOLD',
      paymentDueAt: ago(23),
      paymentKey: 'pay_test_paid_seller2',
      method: 'CARD',
      approvedAt: ago(22),
      lastWebhookEventId: 'evt_paid_auction-ended-paid-seller2',
      carrierCode: null,
      carrierName: null,
      trackingNumber: null,
      trackingUrl: null,
      shippedAt: null,
      settlementExpectedAt: ahead(40),
      settlementSettledAt: null,
      payoutBatchId: null,
      feeRate: 0.05,
      feeAmount: 10700,
      sellerReceivable: 203300,
      createdAt: ago(23),
      updatedAt: ago(22),
    },
    {
      id: 'order-shipped',
      auctionId: 'auction-ended-shipped',
      itemId: 'item-ended-shipped',
      buyerId: 'buyer1',
      sellerId: 'seller2',
      finalPrice: 116000,
      paymentStatus: 'PAID',
      orderStatus: 'SHIPPED',
      paymentDueAt: ago(24),
      paymentKey: 'pay_test_shipped',
      method: 'CARD',
      approvedAt: ago(23),
      lastWebhookEventId: 'evt_paid_auction-ended-shipped',
      carrierCode: 'CJ',
      carrierName: 'CJ Logistics',
      trackingNumber: 'CJ-1234-5678',
      trackingUrl: 'https://example.com/track/CJ-1234-5678',
      shippedAt: ago(10),
      settlementExpectedAt: ahead(48),
      settlementSettledAt: null,
      payoutBatchId: null,
      feeRate: 0.05,
      feeAmount: 5800,
      sellerReceivable: 110200,
      createdAt: ago(24),
      updatedAt: ago(9),
    },
    {
      id: 'order-confirmed',
      auctionId: 'auction-ended-confirmed',
      itemId: 'item-ended-confirmed',
      buyerId: 'buyer2',
      sellerId: 'seller2',
      finalPrice: 124000,
      paymentStatus: 'PAID',
      orderStatus: 'CONFIRMED_RECEIPT',
      paymentDueAt: ago(80),
      paymentKey: 'pay_test_confirmed',
      method: 'CARD',
      approvedAt: ago(79),
      lastWebhookEventId: 'evt_confirmed_auction-ended-confirmed',
      carrierCode: 'HANJIN',
      carrierName: 'Hanjin',
      trackingNumber: 'HJ-9988-7766',
      trackingUrl: 'https://example.com/track/HJ-9988-7766',
      shippedAt: ago(74),
      settlementExpectedAt: ahead(6),
      settlementSettledAt: null,
      payoutBatchId: null,
      feeRate: 0.05,
      feeAmount: 6200,
      sellerReceivable: 117800,
      createdAt: ago(80),
      updatedAt: ago(8),
    },
    {
      id: 'order-settled',
      auctionId: 'auction-ended-settled',
      itemId: 'item-ended-settled',
      buyerId: 'buyer2',
      sellerId: 'seller1',
      finalPrice: 1040000,
      paymentStatus: 'PAID',
      orderStatus: 'SETTLED',
      paymentDueAt: ago(120),
      paymentKey: 'pay_test_settled',
      method: 'CARD',
      approvedAt: ago(119),
      lastWebhookEventId: 'evt_settled_auction-ended-settled',
      carrierCode: 'LOTTE',
      carrierName: 'Lotte Global',
      trackingNumber: 'LG-1111-2222',
      trackingUrl: 'https://example.com/track/LG-1111-2222',
      shippedAt: ago(116),
      settlementExpectedAt: ago(84),
      settlementSettledAt: ago(72),
      payoutBatchId: 'payout_batch_20260325_01',
      feeRate: 0.05,
      feeAmount: 52000,
      sellerReceivable: 988000,
      createdAt: ago(120),
      updatedAt: ago(72),
    },
    {
      id: 'order-cancelled-unpaid',
      auctionId: 'auction-ended-cancelled-unpaid',
      itemId: 'item-ended-cancelled-unpaid',
      buyerId: 'buyer1',
      sellerId: 'seller1',
      finalPrice: 15000,
      paymentStatus: 'CANCELLED',
      orderStatus: 'CANCELLED_UNPAID',
      paymentDueAt: ago(30),
      paymentKey: null,
      method: null,
      approvedAt: null,
      lastWebhookEventId: 'evt_cancel_unpaid_auction-ended-cancelled-unpaid',
      carrierCode: null,
      carrierName: null,
      trackingNumber: null,
      trackingUrl: null,
      shippedAt: null,
      settlementExpectedAt: null,
      settlementSettledAt: null,
      payoutBatchId: null,
      feeRate: 0.05,
      feeAmount: 750,
      sellerReceivable: 14250,
      createdAt: ago(32),
      updatedAt: ago(29),
    },
  ];

  for (const order of orders) {
    await writeDoc('orders', order.id, {
      auctionId: order.auctionId,
      itemId: order.itemId,
      buyerId: order.buyerId,
      sellerId: order.sellerId,
      finalPrice: order.finalPrice,
      paymentStatus: order.paymentStatus,
      orderStatus: order.orderStatus,
      paymentDueAt: asTimestamp(order.paymentDueAt),
      payment: {
        provider: 'TOSS_PAYMENTS',
        paymentKey: order.paymentKey,
        method: order.method,
        approvedAt:
          order.approvedAt == null ? null : asTimestamp(order.approvedAt),
        lastWebhookEventId: order.lastWebhookEventId,
      },
      shipping: {
        carrierCode: order.carrierCode,
        carrierName: order.carrierName,
        trackingNumber: order.trackingNumber,
        trackingUrl: order.trackingUrl,
        shippedAt:
          order.shippedAt == null ? null : asTimestamp(order.shippedAt),
      },
      settlement: {
        expectedAt:
          order.settlementExpectedAt == null
            ? null
            : asTimestamp(order.settlementExpectedAt),
        settledAt:
          order.settlementSettledAt == null
            ? null
            : asTimestamp(order.settlementSettledAt),
        payoutBatchId: order.payoutBatchId,
      },
      fees: {
        feeRate: order.feeRate,
        feeAmount: order.feeAmount,
        sellerReceivable: order.sellerReceivable,
      },
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
    });
  }

  const notifications: Array<{
    uid: string;
    id: string;
    type: string;
    title: string;
    body: string;
    deeplink: string;
    isRead: boolean;
    createdAt: Date;
  }> = [
    {
      uid: 'buyer1',
      id: 'notification-1',
      type: 'OUTBID',
      title: '입찰가가 갱신되었습니다',
      body: 'Signed Album 경매에서 다른 사용자가 더 높은 금액을 제시했습니다.',
      deeplink: 'app://auction/auction-live',
      isRead: false,
      createdAt: agoMins(10),
    },
    {
      uid: 'buyer1',
      id: 'notification-2',
      type: 'PAYMENT_DUE_SOON',
      title: '결제 마감이 임박했습니다',
      body: 'order-awaiting 주문의 결제 마감까지 6시간 남았습니다.',
      deeplink: 'app://orders/order-awaiting',
      isRead: false,
      createdAt: agoMins(40),
    },
    {
      uid: 'buyer1',
      id: 'notification-3',
      type: 'ORDER_SHIPPED',
      title: '판매자가 상품을 발송했습니다',
      body: 'Collector Figure Set 운송장 정보가 등록되었습니다.',
      deeplink: 'app://orders/order-shipped',
      isRead: false,
      createdAt: ago(9),
    },
    {
      uid: 'buyer1',
      id: 'notification-4',
      type: 'ORDER_CANCELLED_UNPAID',
      title: '미결제로 주문이 취소되었습니다',
      body: '결제 시간이 초과되어 order-cancelled-unpaid 주문이 취소되었습니다.',
      deeplink: 'app://orders/order-cancelled-unpaid',
      isRead: true,
      createdAt: ago(28),
    },
    {
      uid: 'seller1',
      id: 'notification-1',
      type: 'PAYMENT_COMPLETED',
      title: '결제 완료',
      body: 'Vintage Ring 낙찰 주문 결제가 완료되었습니다.',
      deeplink: 'app://orders/order-paid',
      isRead: false,
      createdAt: ago(25),
    },
    {
      uid: 'seller1',
      id: 'notification-2',
      type: 'SETTLEMENT_COMPLETED',
      title: '정산 완료',
      body: 'Diamond Pendant 거래 정산이 완료되었습니다.',
      deeplink: 'app://orders/order-settled',
      isRead: false,
      createdAt: ago(72),
    },
    {
      uid: 'seller1',
      id: 'notification-3',
      type: 'UNSOLD',
      title: '유찰 알림',
      body: 'Limited Photo Card 경매가 유찰 처리되었습니다.',
      deeplink: 'app://auction/auction-unsold',
      isRead: true,
      createdAt: ago(20),
    },
    {
      uid: 'seller2',
      id: 'notification-1',
      type: 'SHIPMENT_REQUIRED',
      title: '발송 대기 주문이 있습니다',
      body: 'order-paid-seller2 주문을 발송 처리해 주세요.',
      deeplink: 'app://orders/order-paid-seller2',
      isRead: false,
      createdAt: ago(24),
    },
    {
      uid: 'seller2',
      id: 'notification-2',
      type: 'RECEIPT_CONFIRMED',
      title: '구매자가 수령을 확인했습니다',
      body: 'order-confirmed 주문이 수령 확인 단계로 전환되었습니다.',
      deeplink: 'app://orders/order-confirmed',
      isRead: false,
      createdAt: ago(8),
    },
    {
      uid: 'buyer2',
      id: 'notification-1',
      type: 'BID_ACCEPTED',
      title: '자동입찰이 반영되었습니다',
      body: '1oz Gold Bar 경매에서 현재 최고가로 유지 중입니다.',
      deeplink: 'app://auction/auction-live-goldbar',
      isRead: false,
      createdAt: agoMins(5),
    },
    {
      uid: 'buyer2',
      id: 'notification-2',
      type: 'SETTLED',
      title: '거래가 최종 완료되었습니다',
      body: 'order-settled 주문이 최종 완료 상태입니다.',
      deeplink: 'app://orders/order-settled',
      isRead: true,
      createdAt: ago(70),
    },
  ];

  for (const notification of notifications) {
    await db
      .collection('notifications')
      .doc(notification.uid)
      .collection('inbox')
      .doc(notification.id)
      .set({
        type: notification.type,
        title: notification.title,
        body: notification.body,
        deeplink: notification.deeplink,
        isRead: notification.isRead,
        createdAt: notification.createdAt,
      });
  }
}
