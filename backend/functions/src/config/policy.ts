export const featureFlags = {
  autoBid: true,
  premiumListing: false,
  subscription: false,
  appraisal: true,
};

export const bidIncrementTable = [
  { min: 0, max: 99999, step: 1000 },
  { min: 100000, max: 499999, step: 5000 },
  { min: 500000, max: 999999, step: 10000 },
  { min: 1000000, max: Number.MAX_SAFE_INTEGER, step: 50000 },
];

export const antiSnipingPolicy = {
  triggerSecondsBeforeEnd: 300,
  extensionSeconds: 300,
  maxExtensions: 3,
};

export const depositPolicy = {
  percent: 0.05,
  min: 5000,
  max: 300000,
  trustScorePenalty: 10,
};

export const sellerGradeWeights = {
  completedSales: 0.35,
  successRate: 0.35,
  reviewAvg: 0.3,
};

export function minIncrementFor(price: number): number {
  const band = bidIncrementTable.find((row) => price >= row.min && price <= row.max);
  return band?.step ?? 1000;
}

export function calcDepositForfeit(finalPrice: number): number {
  return Math.max(depositPolicy.min, Math.min(depositPolicy.max, Math.floor(finalPrice * depositPolicy.percent)));
}
