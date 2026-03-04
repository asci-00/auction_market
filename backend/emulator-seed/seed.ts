import * as admin from 'firebase-admin';

process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080';
admin.initializeApp({ projectId: process.env.GCLOUD_PROJECT ?? 'auction-market-local' });
const db = admin.firestore();

async function run() {
  const userRef = db.collection('users').doc('seller1');
  await userRef.set({
    displayName: 'Seller One',
    email: 'seller1@test.local',
    authProviders: ['google'],
    phoneVerifyStatus: 'VERIFIED',
    idVerifyStatus: 'VERIFIED',
    preciousSellerVerifyStatus: 'PENDING',
    sellerStats: { completedSales: 10, totalAuctions: 20, successRate: 0.8, reviewAvg: 4.8, gradeScore: 88 },
    penaltyStats: { unpaidCount: 0, depositForfeitedCount: 0 },
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  await db.collection('items').doc('item1').set({
    sellerId: 'seller1',
    categoryMain: 'GOODS',
    categorySub: 'IDOL_MD',
    title: 'Signed Album',
    description: 'Mint condition',
    condition: 'LIKE_NEW',
    isOfficialMd: true,
    tags: ['idol', 'kpop'],
    images: ['https://picsum.photos/300'],
    goodsAuthImages: ['https://picsum.photos/301'],
    appraisal: { status: 'NONE', badgeLabel: null },
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  console.log('Seed complete');
}

run().then(() => process.exit(0));
