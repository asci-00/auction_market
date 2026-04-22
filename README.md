# 경마(가칭) MVP Monorepo

모바일 퍼스트 C2C 경매 MVP(Flutter + Firebase)입니다.

## Detailed Docs
- `Prompt.md`: product guardrails and release bar
- `Plan.md`: build order and completion criteria
- `Implement.md`: live execution log
- `Documentation.md`: schema, contracts, environment, and ops
- `docs/Design.md`: UI system and screen rules
- `docs/Environment.md`: external config contract and TODO inventory

## 1) 아키텍처 제안

### 폴더 구조
- `apps/mobile_flutter`: Flutter 앱 (go_router + Riverpod)
- `backend/functions`: Firebase Functions (핵심 상태 전이 로직)
- `backend/firestore.rules`: 민감 write 차단
- `backend/firestore.indexes.json`: 홈/검색/내역 인덱스
- `backend/emulator-seed`: 에뮬레이터 시드

### 상태 머신
- 인증: `UNVERIFIED -> PENDING -> VERIFIED|REJECTED`
- 경매: `DRAFT -> LIVE -> ENDED|UNSOLD|CANCELLED`
- 주문: `AWAITING_PAYMENT -> PAID_ESCROW_HOLD -> SHIPPED -> CONFIRMED_RECEIPT -> SETTLED`
- 미결제 타임아웃: `AWAITING_PAYMENT -> CANCELLED_UNPAID`

### 서버 원칙
- items/bids/orders/auctions 핵심 값은 Cloud Functions에서만 변경
- Firestore rules에서 클라이언트 direct write 차단
- 스케줄러(activate/finalize/expire/settle)로 경매개시/종료/미결제만료/정산전이를 자동 처리

## 2) 기능 플래그
`backend/functions/src/config/policy.ts`
- `autoBid`
- `premiumListing`
- `subscription`
- `appraisal`

## 3) 정책 Config (PO 확정 필요)
문서에 확정되지 않은 정책은 서버 config로 분리했습니다.
- **입찰 단위 테이블**(`bidIncrementTable`) → 가격 구간별 step 임시값
- **보증금/패널티 정책**(`depositPolicy`) → 비율/상하한/신뢰도 감점 임시값

> 위 정책 수치는 MVP 임시값이며, PO/운영 정책 확정 필요.

## 4) 로컬 실행

### 4.1 Functions
```bash
cd backend/functions
npm install
npm test
npm run build
```

### 4.2 Firebase Emulator
```bash
npm install -g firebase-tools
firebase emulators:start
```

### 4.3 Seed
```bash
cd backend/functions
npm run seed
```

### 4.4 Flutter 앱
```bash
cd apps/mobile_flutter
flutter pub get
./scripts/bootstrap_render_dev.sh
flutter run --flavor dev --dart-define-from-file=dart_defines.dev.json
```

### 4.5 실기기 dev 실행 기본 경로
- 기본 dev 경로는 로컬 emulator가 아니라 실 Firebase dev 프로젝트 + Render dev 서버입니다.
- Render dev backend:
  - `https://auction-market-dev-api.onrender.com`
- Render health check:
  - `https://auction-market-dev-api.onrender.com/healthz`
- 필요한 로컬 파일:
  - `apps/mobile_flutter/android/app/src/dev/google-services.json`
  - `apps/mobile_flutter/ios/Runner/Firebase/dev/GoogleService-Info.plist`
- `TOSS_CLIENT_KEY`는 결제 실험이 필요할 때만 `apps/mobile_flutter/dart_defines.dev.json`에 채우면 됩니다.

### 4.6 로컬 Firebase Emulator 실행 경로
```bash
cd backend/functions
npm run serve
```

새 터미널에서:
```bash
cd apps/mobile_flutter
flutter run --flavor dev --dart-define-from-file=dart_defines.local-emulator.json
```

- `dart_defines.local-emulator.json`은 dev flavor를 유지한 채 동일한 HTTP backend contract를 로컬 API URL로 연결합니다.
- Android 실기기는 `adb reverse` 기준으로 `FIREBASE_EMULATOR_HOST=127.0.0.1`을 사용합니다.

## 5) E2E 수동 검증 시나리오
1. 로그인(구글/애플 버튼)
2. Sell 플로우로 상품 등록(굿즈 인증사진 포함)
3. Home에서 경매 상세 진입
4. 입찰(local_auth 인증 후) 수행
5. 종료 5분 전 입찰로 `endAt +5분` 연장 확인(최대 3회)
6. 경매 종료 스케줄러로 낙찰 주문 생성
7. 결제(Mock) 성공 처리
8. 판매자 운송장 입력(`shipmentUpdate`)
9. 구매자 수령확인(`confirmReceipt`)
10. 정산 스케줄러에서 `SETTLED` 전이 확인

## 6) 구현 범위 메모
- 카카오/네이버 로그인, 감정 연계, 프리미엄 리스팅, 구독은 MVP 스텁/플래그 중심
- Auto-bid는 플래그로 ON/OFF 가능하며 OFF여도 기본 입찰 동작
- activateDraftAuctionsScheduler / finalizeAuctionsScheduler / expireUnpaidOrdersScheduler / settleScheduler는 실제 상태전이 로직 포함
