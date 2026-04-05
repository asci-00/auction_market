// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '옥션마켓';

  @override
  String get retry => '다시 시도';

  @override
  String get genericSignInAction => '로그인';

  @override
  String get loadingApp => '앱 환경을 준비하고 있습니다';

  @override
  String get configRequiredTitle => '설정이 필요합니다';

  @override
  String get bootstrapFailedTitle => '앱을 시작하지 못했습니다';

  @override
  String get unknownStartupTitle => '예상하지 못한 오류가 발생했습니다';

  @override
  String get configRequiredDetails => 'dart_defines.json 값을 확인한 뒤 다시 실행하세요.';

  @override
  String get unknownStartupMessage =>
      '앱 시작 중 문제가 발생했습니다. 설정과 네트워크 상태를 확인한 뒤 다시 시도해 주세요.';

  @override
  String get navHome => '홈';

  @override
  String get navSearch => '검색';

  @override
  String get navSell => '판매';

  @override
  String get navActivity => '활동';

  @override
  String get navMy => '마이';

  @override
  String get badgeLive => 'LIVE';

  @override
  String get badgeEndingSoon => '마감 임박';

  @override
  String get badgeBuyNow => '즉시 구매';

  @override
  String get badgePaid => '결제 완료';

  @override
  String get badgeSettled => '정산 완료';

  @override
  String get badgePending => '진행 중';

  @override
  String get badgeVerified => '검수 완료';

  @override
  String get badgeUnread => '새 알림';

  @override
  String get homeLargeTitle => '엄선된 경매';

  @override
  String get homeHeroEyebrow => '프리미엄 리셀';

  @override
  String get homeHeroTitle => '차분한 탐색감 속에서 신뢰할 수 있는 경매를 빠르게 잡아보세요.';

  @override
  String get homeHeroDescription =>
      '가장 먼저 끝나는 경매, 주목이 몰리는 셀러, 오늘 다시 볼 만한 카테고리를 한눈에 정리합니다.';

  @override
  String get homeHeroChipUrgency => '시간형 입찰';

  @override
  String get homeHeroChipQuality => '검수된 리스팅';

  @override
  String get homeEndingSoonTitle => '마감 임박';

  @override
  String get homeEndingSoonSubtitle => '남은 시간이 짧은 경매를 먼저 살펴보세요.';

  @override
  String get homeHotTitle => '지금 주목받는 경매';

  @override
  String get homeHotSubtitle => '입찰과 관심이 몰리는 리스팅부터 확인하세요.';

  @override
  String get homeCuratedGoodsTitle => '일반 상품 큐레이션';

  @override
  String get homeCuratedGoodsSubtitle => '빠르게 움직이는 일반 상품을 별도 행에서 차분하게 둘러보세요.';

  @override
  String get homeCuratedPreciousTitle => '귀금속 큐레이션';

  @override
  String get homeCuratedPreciousSubtitle =>
      '귀금속 경매는 따로 모아 더 쉽게 비교할 수 있게 정리합니다.';

  @override
  String get homeOpenNotifications => '알림';

  @override
  String get homeEmptyTitle => '새 경매가 여기에 나타납니다';

  @override
  String get homeEmptyDescription => '라이브 리스팅이 발행되면 이 영역에서 가장 먼저 보여집니다.';

  @override
  String get homeEmptyAction => '피드 새로고침';

  @override
  String get homeSectionViewAll => '전체 보기';

  @override
  String get searchTitle => '검색';

  @override
  String get searchHeroEyebrow => '정제된 탐색';

  @override
  String get searchHeroTitle => '키워드만이 아니라 취향으로도 탐색해 보세요.';

  @override
  String get searchHeroDescription =>
      '가격, 마감 시점, 즉시 구매 가능 여부를 한 번에 좁혀 원하는 경매를 빠르게 찾습니다.';

  @override
  String get searchFieldLabel => '검색어';

  @override
  String get searchFieldHint => '브랜드, 모델, 셀러를 입력해 주세요';

  @override
  String get searchFilterCategory => '카테고리';

  @override
  String get searchFilterPrice => '가격대';

  @override
  String get searchFilterCategoryGoods => '일반 상품';

  @override
  String get searchFilterCategoryPrecious => '귀금속';

  @override
  String get searchFilterPriceUnder50k => '5만원 이하';

  @override
  String get searchFilterPrice50kTo200k => '5만~20만원';

  @override
  String get searchFilterPriceOver200k => '20만원 초과';

  @override
  String get searchFilterEndingSoon => '마감 임박';

  @override
  String get searchFilterBuyNow => '즉시 구매';

  @override
  String get searchResultsTitle => '검색 결과';

  @override
  String get searchResultsSubtitle => '현재 조건에 맞는 라이브 경매를 실시간으로 정리합니다.';

  @override
  String get searchLayoutSwitchToGrid => '그리드 보기로 전환';

  @override
  String get searchLayoutSwitchToList => '리스트 보기로 전환';

  @override
  String get searchEmptyTitle => '아직 맞는 경매가 없습니다';

  @override
  String get searchEmptyDescription => '검색어를 넓히거나 새 리스팅이 올라온 뒤 다시 확인해 보세요.';

  @override
  String get searchErrorDescription => '검색 결과를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.';

  @override
  String get searchResetAction => '검색 초기화';

  @override
  String get searchResetFiltersAction => '필터 초기화';

  @override
  String get loginHeroEyebrow => '안전한 시작';

  @override
  String get loginHeroTitle => '진지한 입찰을 위한 차분한 마켓에 입장하세요.';

  @override
  String get loginHeroDescription =>
      '지원되는 로그인으로 세션, 주문, 알림함, 판매 도구를 안전하게 이어받을 수 있습니다.';

  @override
  String get loginContinueGoogle => 'Google로 계속하기';

  @override
  String get loginContinueApple => 'Apple로 계속하기';

  @override
  String get loginSubmitting => '로그인 중입니다...';

  @override
  String get loginReturnNotice => '로그인 후 요청한 화면으로 자동 이동합니다.';

  @override
  String get loginTrustNote => 'v1에서는 Apple과 Google 로그인만 지원합니다.';

  @override
  String get loginEmulatorWarning =>
      'Firebase Emulator를 사용하는 동안에는 모바일 Google/Apple 브라우저 로그인 플로우를 테스트하지 않습니다. 실제 소셜 로그인을 검증하려면 USE_FIREBASE_EMULATORS=false로 실행하세요.';

  @override
  String get loginEmulatorUnsupportedProvider =>
      '현재 빌드는 Firebase Auth Emulator에 연결되어 있어 모바일 Google/Apple 브라우저 로그인을 완료할 수 없습니다. 실제 소셜 로그인을 확인하려면 USE_FIREBASE_EMULATORS=false로 다시 실행하세요.';

  @override
  String get loginGenericError => '로그인에 실패했습니다. Firebase 프로젝트 설정을 확인해 주세요.';

  @override
  String get loginErrorNetwork => '네트워크 연결을 확인한 뒤 다시 시도해 주세요.';

  @override
  String get loginErrorProviderDisabled =>
      '선택한 로그인 제공자가 Firebase Auth에서 아직 활성화되지 않았습니다.';

  @override
  String get loginErrorAccountExists => '이미 다른 로그인 방식으로 가입된 계정입니다.';

  @override
  String get activityTitle => '활동';

  @override
  String get activityHeroEyebrow => '상태 한눈에 보기';

  @override
  String get activityHeroTitle => '결제, 배송, 알림 흐름을 한 곳에서 정리하세요.';

  @override
  String get activityHeroDescription =>
      '화면을 오가며 찾기보다 지금 해야 할 다음 단계를 바로 여는 흐름에 집중합니다.';

  @override
  String get activityOrdersTitle => '주문과 결제';

  @override
  String get activityOrdersSubtitle => '결제, 배송, 수령 확인이 필요한 거래를 빠르게 확인합니다.';

  @override
  String get activityNotificationsTitle => '알림함과 업데이트';

  @override
  String get activityNotificationsSubtitle => '입찰, 결제, 배송 소식을 알림함에서 바로 엽니다.';

  @override
  String get activityBuyerCardTitle => '구매 작업함';

  @override
  String get activityBuyerCardDescription => '결제와 수령 확인이 필요한 주문을 한 곳에서 정리합니다.';

  @override
  String activityBuyerPendingPaymentSubtitle(Object count) {
    return '$count건의 주문이 아직 결제 확인을 기다리고 있습니다.';
  }

  @override
  String activityBuyerAwaitingReceiptSubtitle(Object count) {
    return '$count건의 배송 완료 주문이 수령 확인을 기다리고 있습니다.';
  }

  @override
  String get activityBuyerMetricLabel => '구매자 액션 대기';

  @override
  String get activitySellerCardTitle => '판매 작업함';

  @override
  String get activitySellerCardDescription =>
      '결제 완료 후 배송 등록이 필요한 주문을 바로 확인합니다.';

  @override
  String activitySellerAwaitingShipmentSubtitle(Object count) {
    return '$count건의 결제 완료 주문이 배송 정보를 기다리고 있습니다.';
  }

  @override
  String get activitySellerMetricLabel => '판매자 액션 대기';

  @override
  String get activityNotificationsCardTitle => '읽지 않은 업데이트';

  @override
  String get activityNotificationsCardDescription =>
      '입찰, 결제, 배송 이벤트가 생기면 알림함에서 바로 엽니다.';

  @override
  String activityNotificationsUnreadSubtitle(Object count) {
    return '$count건의 읽지 않은 업데이트가 알림함에 남아 있습니다.';
  }

  @override
  String get activityNotificationsMetricLabel => '읽지 않은 알림';

  @override
  String get activitySignedOutDescription => '로그인하면 실시간 주문과 알림 활동을 확인할 수 있습니다.';

  @override
  String get auctionDetailTitle => '경매 상세';

  @override
  String get auctionDetailGalleryEyebrow => '리스팅 개요';

  @override
  String get auctionDetailFallbackTitle => '리스팅 정보가 곧 준비됩니다';

  @override
  String get auctionDetailFallbackDescription =>
      '이 경매 문서가 준비되면 이미지, 셀러 신뢰 정보, 입찰 기록이 이 레이아웃에 채워집니다.';

  @override
  String get auctionDetailCurrentBid => '현재 입찰가';

  @override
  String get auctionDetailBuyNow => '즉시 구매가';

  @override
  String get auctionDetailSellerSummary => '셀러 요약';

  @override
  String get auctionDetailSellerDescription =>
      '입찰 전에도 신뢰 신호, 카테고리 적합성, 배송 준비 상태를 바로 확인할 수 있어야 합니다.';

  @override
  String get auctionDetailDescriptionTitle => '상품 상세';

  @override
  String get auctionDetailDescriptionSubtitle =>
      '상태, 카테고리 맥락, 셀러 메모를 액션 전에 바로 확인할 수 있어야 합니다.';

  @override
  String get auctionDetailDescriptionFallback =>
      '연결된 상품 문서가 준비되면 셀러 메모가 이곳에 표시됩니다.';

  @override
  String get auctionDetailMetaCondition => '상태';

  @override
  String get auctionDetailMetaCategory => '카테고리';

  @override
  String get auctionDetailConditionNew => '새 상품';

  @override
  String get auctionDetailConditionLikeNew => '거의 새 상품';

  @override
  String get auctionDetailConditionGood => '좋음';

  @override
  String get auctionDetailConditionFair => '사용감 있음';

  @override
  String get auctionDetailConditionPoor => '상태 낮음';

  @override
  String get auctionDetailCategoryIdolMd => '아이돌 굿즈';

  @override
  String get auctionDetailCategoryWatch => '시계';

  @override
  String get auctionDetailCategorySneakers => '스니커즈';

  @override
  String get auctionDetailCategoryBullion => '불리온';

  @override
  String get auctionDetailCategoryCamera => '카메라';

  @override
  String get auctionDetailCategoryJewelry => '주얼리';

  @override
  String get auctionDetailCategoryPhotoCard => '포토카드';

  @override
  String get auctionDetailCategoryGameConsole => '게임 콘솔';

  @override
  String get auctionDetailCategoryFigure => '피규어';

  @override
  String get auctionDetailBidHistory => '입찰 흐름';

  @override
  String get auctionDetailBidHistorySubtitle => '최근 가격 움직임을 과한 장식 없이 담아냅니다.';

  @override
  String get auctionDetailNoBidHistory => '첫 유효 입찰이 들어오면 여기에 기록이 표시됩니다.';

  @override
  String get auctionDetailActionHint =>
      '라이브 경매가 확인되면 이 자리에서 입찰과 즉시 구매 액션이 열립니다.';

  @override
  String get auctionDetailBrowseAction => '라이브 경매 둘러보기';

  @override
  String auctionDetailLiveActionHint(Object minimumBid, Object endAt) {
    return '다음 유효 입찰가는 $minimumBid부터 시작합니다. 경매 종료 시각은 $endAt입니다.';
  }

  @override
  String auctionDetailSellerOwnedHint(Object endAt) {
    return '내 리스팅은 $endAt까지 라이브 상태입니다. 구매자 액션은 이 화면에서 계속 열립니다.';
  }

  @override
  String get auctionDetailSellerOwnedFallback =>
      '내 리스팅이 라이브 상태입니다. 구매가 성사되면 주문과 정산 흐름이 이어집니다.';

  @override
  String get auctionDetailSellerOwnedAction => '주문 흐름 보기';

  @override
  String get auctionDetailOrderReadyHint =>
      '이 경매에는 이미 주문이 연결되어 있습니다. 결제나 배송을 이어가려면 주문 타임라인을 여세요.';

  @override
  String get auctionDetailEndedHint =>
      '이 경매는 더 이상 입찰을 받지 않습니다. 다른 라이브 경매를 둘러보세요.';

  @override
  String get auctionDetailViewOrder => '주문 타임라인 열기';

  @override
  String get auctionDetailLoginHint => '입찰, 자동입찰, 즉시 구매를 진행하려면 로그인하세요.';

  @override
  String get auctionDetailSignInAction => '로그인하고 입찰하기';

  @override
  String auctionDetailBidAction(Object amount) {
    return '$amount부터 입찰';
  }

  @override
  String auctionDetailBuyNowAction(Object amount) {
    return '즉시 구매 $amount';
  }

  @override
  String get auctionDetailAutoBidAction => '자동입찰 상한 설정';

  @override
  String get auctionDetailSubmittingBidAction => '입찰 제출 중...';

  @override
  String get auctionDetailSubmittingAutoBidAction => '자동입찰 저장 중...';

  @override
  String get auctionDetailSubmittingBuyNowAction => '즉시 구매 처리 중...';

  @override
  String get auctionDetailSubmittingBidSubtitle =>
      '입찰을 접수하고 있습니다. 이 단계가 끝나면 다른 액션도 다시 열립니다.';

  @override
  String get auctionDetailSubmittingAutoBidSubtitle =>
      '자동입찰 상한을 저장하고 있습니다. 이 단계가 끝나면 다른 액션도 다시 열립니다.';

  @override
  String get auctionDetailSubmittingBuyNowSubtitle =>
      '즉시 구매를 처리하고 있습니다. 이 단계가 끝나면 다른 액션도 다시 열립니다.';

  @override
  String get auctionDetailBidDialogTitle => '입찰하기';

  @override
  String get auctionDetailBidAmountLabel => '입찰 금액';

  @override
  String get auctionDetailBidAmountHint => '원 단위 금액을 입력해 주세요';

  @override
  String get auctionDetailAutoBidDialogTitle => '자동입찰 상한 설정';

  @override
  String get auctionDetailAutoBidAmountLabel => '최대 자동입찰 금액';

  @override
  String get auctionDetailAutoBidAmountHint => '시스템이 방어할 최대 금액을 입력해 주세요';

  @override
  String auctionDetailBidMinimum(Object amount) {
    return '최소 유효 금액은 $amount입니다.';
  }

  @override
  String auctionDetailAutoBidHint(Object amount) {
    return '자동입찰 상한은 $amount 이상이어야 하며, 필요한 만큼만 자동으로 올라갑니다.';
  }

  @override
  String get auctionDetailDialogCancel => '취소';

  @override
  String get auctionDetailDialogSubmitBid => '입찰 제출';

  @override
  String get auctionDetailDialogSubmitAutoBid => '자동입찰 저장';

  @override
  String get auctionDetailActionSuccessBid => '입찰이 접수되었습니다.';

  @override
  String get auctionDetailActionSuccessAutoBid => '자동입찰 상한이 저장되었습니다.';

  @override
  String get auctionDetailActionSuccessBuyNow =>
      '즉시 구매가 완료되었습니다. 주문 타임라인으로 이동합니다.';

  @override
  String get auctionDetailActionFailed => '경매 액션을 완료하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get ordersTitle => '주문';

  @override
  String get ordersBuyerTitle => '구매';

  @override
  String get ordersSellerTitle => '판매';

  @override
  String get ordersBuyerSubtitle => '내가 구매한 주문의 결제, 배송, 수령 확인 상태입니다.';

  @override
  String get ordersSellerSubtitle => '판매한 경매의 배송과 정산 진행 상황입니다.';

  @override
  String get ordersEmptyTitle => '아직 주문 활동이 없습니다';

  @override
  String get ordersEmptyDescription => '결제가 시작되거나 판매가 성사되면 거래 타임라인이 여기에 나타납니다.';

  @override
  String get ordersErrorDescription => '주문을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.';

  @override
  String get ordersHighlightedLabel => '집중 주문';

  @override
  String get notificationsTitle => '알림';

  @override
  String get notificationsHeroEyebrow => '알림함';

  @override
  String get notificationsHeroTitle => '과한 강조 없이 중요한 변화만 분명하게 보여줍니다.';

  @override
  String get notificationsHeroDescription =>
      '읽지 않은 업데이트를 또렷하게 남겨 다음 액션으로 바로 이동할 수 있게 합니다.';

  @override
  String get notificationsDestinationAuction => '경매 상세로 이동';

  @override
  String get notificationsDestinationOrder => '주문 타임라인으로 이동';

  @override
  String get notificationsDestinationInbox => '알림함에 머무름';

  @override
  String get notificationsDestinationPayment => '결제 복구 화면으로 이동';

  @override
  String get notificationsDestinationUnknown => '다음 관련 화면으로 이동';

  @override
  String get notificationsEmptyTitle => '알림함이 조용합니다';

  @override
  String get notificationsEmptyDescription =>
      '입찰, 결제, 배송 업데이트가 생기면 이곳에 차곡차곡 쌓입니다.';

  @override
  String get myTitle => '마이';

  @override
  String get myHeroEyebrow => '프로필과 신뢰';

  @override
  String get myHeroTitle => '구매와 판매를 위한 프로필 상태를 가까이 두세요.';

  @override
  String get myHeroDescription =>
      '검증 상태, 셀러 신뢰도, 계정 선호 설정이 깊은 설정 화면에 숨지 않도록 정리합니다.';

  @override
  String get mySignedInAs => '로그인 계정';

  @override
  String get myVerificationTitle => '검증 상태';

  @override
  String get myVerificationDescription =>
      '다른 사용자가 안심하고 거래할 수 있도록 신뢰 상태를 확인합니다.';

  @override
  String get myVerificationPhone => '휴대폰';

  @override
  String get myVerificationIdentity => '신원';

  @override
  String get myVerificationSeller => '셀러';

  @override
  String get mySessionUnavailable => '프로필 정보를 아직 불러오지 못했습니다.';

  @override
  String myEnvironmentLabel(Object environment, Object platform) {
    return '$environment · $platform';
  }

  @override
  String get mySignOut => '로그아웃';

  @override
  String get sellTitle => '판매 시작';

  @override
  String get sellHeroEyebrow => '셀러 스튜디오';

  @override
  String get sellHeroTitle => '라이브 전부터 완성도 있는 리스팅 흐름을 준비하세요.';

  @override
  String get sellHeroDescription =>
      '상품 스토리, 가격, 일정, 이미지를 더 정돈된 리듬으로 점검하며 발행합니다.';

  @override
  String get sellPolicyTitle => '경매 시간 정책';

  @override
  String get sellPolicyDescription =>
      '종료 5분 전 입찰이 들어오면 종료 시간이 5분 연장되며 최대 3회까지 적용됩니다.';

  @override
  String get sellStepCategoryTitle => '카테고리 선택';

  @override
  String get sellStepCategoryDescription =>
      '일반 상품과 귀금속 흐름을 올바른 경로에서 시작해 필요한 입력을 맞춥니다.';

  @override
  String get sellStepDetailsTitle => '상품 정보를 선명하게 정리';

  @override
  String get sellStepDetailsDescription =>
      '제목, 상태, 태그, 설명이 첫인상만으로도 신뢰를 주어야 합니다.';

  @override
  String get sellStepPricingTitle => '가격과 일정 설정';

  @override
  String get sellStepPricingDescription =>
      '시작가, 즉시 구매가, 종료 시점이 경매의 긴장감을 명확하게 전달해야 합니다.';

  @override
  String get sellStepImagesTitle => '이미지 구성 준비';

  @override
  String get sellStepImagesDescription => '대표 이미지와 필요한 인증 이미지를 발행 전에 충분히 갖춥니다.';

  @override
  String get sellStepPublishTitle => '미리보기와 발행';

  @override
  String get sellStepPublishDescription =>
      '스토리, 가격, 긴급도 신호를 함께 점검한 뒤 경매를 라이브로 보냅니다.';

  @override
  String get sellProgressTitle => '발행 진행 상태';

  @override
  String sellProgressSubtitle(int completed, int total) {
    return '$total단계 중 $completed단계 준비됨';
  }

  @override
  String get sellDraftsTitle => '최근 저장한 드래프트';

  @override
  String get sellDraftsSubtitle => '라이브 발행 전, 저장해 둔 상품 초안을 다시 불러올 수 있습니다.';

  @override
  String get sellDraftEmptyTitle => '저장된 드래프트가 아직 없습니다';

  @override
  String get sellDraftEmptyDescription => '상품 기본 정보를 저장하면 드래프트가 이 영역에 나타납니다.';

  @override
  String get sellDraftLoadAction => '불러오기';

  @override
  String get sellDraftUntitled => '제목 없는 상품';

  @override
  String sellDraftUpdatedAt(Object time) {
    return '$time 업데이트';
  }

  @override
  String get sellDraftNoTimestamp => '업데이트 시각 없음';

  @override
  String sellCurrentDraftLabel(Object itemId) {
    return '현재 편집 중인 드래프트 #$itemId';
  }

  @override
  String get sellDraftStatusNotSaved => '아직 저장되지 않았어요';

  @override
  String get sellDraftStatusNotSavedDescription =>
      '상품 기본 정보가 갖춰지면 드래프트를 저장해 진행 상태를 고정하세요.';

  @override
  String get sellDraftStatusUnsaved => '저장되지 않은 변경사항';

  @override
  String get sellDraftStatusUnsavedDescription =>
      '현재 폼 내용이 마지막 저장본보다 앞서 있어요. 발행 전에 한 번 더 저장하세요.';

  @override
  String get sellDraftStatusSaved => '드래프트가 저장되었어요';

  @override
  String sellDraftStatusSavedDescription(Object time) {
    return '최근 저장: $time';
  }

  @override
  String get sellCategoryGoods => '일반 상품';

  @override
  String get sellCategoryPrecious => '귀금속';

  @override
  String get sellFormCategoryMainLabel => '메인 카테고리';

  @override
  String get sellFormCategorySubLabel => '세부 카테고리';

  @override
  String get sellFormTitleLabel => '상품 제목';

  @override
  String get sellFormConditionLabel => '상품 상태';

  @override
  String get sellFormTagsLabel => '태그';

  @override
  String get sellFormTagsHint => '브랜드, 소재, 사이즈';

  @override
  String get sellFormDescriptionLabel => '상품 설명';

  @override
  String get sellFormAppraisalLabel => '감정 요청 흐름 사용';

  @override
  String get sellFormStartPriceLabel => '시작가';

  @override
  String get sellFormBuyNowPriceLabel => '즉시 구매가';

  @override
  String get sellFormDurationLabel => '경매 기간';

  @override
  String sellDurationDays(int count) {
    return '$count일 진행';
  }

  @override
  String get sellImageMainTitle => '대표 이미지';

  @override
  String get sellImageMainDescription =>
      '공개 경매 카드와 상세 화면에 노출될 대표 이미지를 최대 10장까지 올립니다.';

  @override
  String get sellImageMainAction => '대표 이미지 선택';

  @override
  String get sellImageAuthTitle => '인증 이미지';

  @override
  String get sellImageAuthDescription =>
      '일반 상품은 드래프트 저장과 발행 전에 최소 1장의 인증 이미지가 필요합니다.';

  @override
  String get sellImageAuthAction => '인증 이미지 선택';

  @override
  String get sellImagesEmptyState => '아직 선택한 이미지가 없습니다.';

  @override
  String get sellSaveDraftAction => '드래프트 저장';

  @override
  String get sellPublishAction => '경매 발행';

  @override
  String get sellSavingDraft => '드래프트 저장 중...';

  @override
  String get sellPublishing => '발행 중...';

  @override
  String get sellActionSaved => '드래프트가 판매 작업 공간에 저장되었습니다.';

  @override
  String get sellActionPublished => '경매가 발행되었습니다. 라이브 리스팅으로 이동합니다.';

  @override
  String get sellActionFailed => '판매 액션을 완료하지 못했습니다. 입력값을 확인한 뒤 다시 시도해 주세요.';

  @override
  String get sellValidationCategorySub => '드래프트 저장 전에 세부 카테고리를 입력해 주세요.';

  @override
  String get sellValidationTitle => '드래프트 저장 전에 상품 제목을 입력해 주세요.';

  @override
  String get sellValidationCondition => '드래프트 저장 전에 상품 상태를 입력해 주세요.';

  @override
  String get sellValidationDescription => '드래프트 저장 전에 상품 설명을 입력해 주세요.';

  @override
  String get sellValidationAuthImages => '일반 상품 드래프트에는 인증 이미지가 최소 1장 필요합니다.';

  @override
  String get sellValidationCategorySubPublish => '경매 발행 전에 세부 카테고리를 입력해 주세요.';

  @override
  String get sellValidationTitlePublish => '경매 발행 전에 상품 제목을 입력해 주세요.';

  @override
  String get sellValidationConditionPublish => '경매 발행 전에 상품 상태를 입력해 주세요.';

  @override
  String get sellValidationDescriptionPublish => '경매 발행 전에 상품 설명을 입력해 주세요.';

  @override
  String get sellValidationAuthImagesPublish =>
      '일반 상품 경매를 발행하려면 인증 이미지가 최소 1장 필요합니다.';

  @override
  String get sellValidationImages => '경매 발행 전에는 대표 이미지가 최소 1장 필요합니다.';

  @override
  String get sellValidationStartPrice => '발행 전에 올바른 시작가를 입력해 주세요.';

  @override
  String get sellValidationBuyNowPrice => '즉시 구매가는 시작가보다 높아야 합니다.';

  @override
  String get sellValidationBuyNowPriceInvalid =>
      '발행 전에 올바른 정수 즉시 구매가를 입력해 주세요.';

  @override
  String get sellValidationSummaryDraftTitle => '드래프트 저장 전에 아래 항목을 확인해 주세요';

  @override
  String get sellValidationSummaryPublishTitle => '경매 발행 전에 아래 항목을 모두 채워 주세요';

  @override
  String get genericUnavailable => '정보 없음';

  @override
  String get genericUnknownSeller => '셀러';

  @override
  String get genericUnknownUser => '회원';

  @override
  String get genericStateVerified => '검증 완료';

  @override
  String get genericStatePending => '심사 중';

  @override
  String get genericStateRejected => '반려됨';

  @override
  String get genericStateUnverified => '미인증';

  @override
  String get genericOrderAwaitingPayment => '결제 대기';

  @override
  String get genericOrderPaid => '결제 완료';

  @override
  String get genericOrderShipped => '배송 중';

  @override
  String get genericOrderConfirmedReceipt => '수령 확인';

  @override
  String get genericOrderSettled => '정산 완료';

  @override
  String get genericOrderCancelled => '취소됨';

  @override
  String get genericOrderProcessing => '진행 중';

  @override
  String genericCountBids(int count) {
    return '입찰 $count건';
  }

  @override
  String genericEndsAt(Object time) {
    return '$time 종료';
  }

  @override
  String get genericCountdownExpired => '만료';

  @override
  String get genericCountdownLessThanMinute => '1분 미만 남음';

  @override
  String genericCountdownMinutesRemaining(int minutes) {
    return '$minutes분 남음';
  }

  @override
  String genericCountdownHoursRemaining(int hours, int minutes) {
    return '$hours시간 $minutes분 남음';
  }

  @override
  String genericCountdownDaysRemaining(int days, int hours) {
    return '$days일 $hours시간 남음';
  }

  @override
  String genericUnreadCount(int count) {
    return '읽지 않음 $count건';
  }

  @override
  String get loginDevAccessTitle => '에뮬레이터 점검용 빠른 로그인';

  @override
  String get loginDevAccessDescription =>
      'dev 에뮬레이터 모드에서만 사용하는 buyer, seller 시드 계정입니다.';

  @override
  String get loginDevBuyer => '시드 구매자 계정으로 로그인';

  @override
  String get loginDevSeller => '시드 판매자 계정으로 로그인';

  @override
  String get loginErrorSeedAccountUnavailable =>
      '시드된 에뮬레이터 계정을 찾을 수 없습니다. 에뮬레이터를 시작하고 npm run seed를 다시 실행하세요.';

  @override
  String get ordersActionAddShipment => '배송 정보 등록';

  @override
  String get ordersActionPreparePayment => '결제 진행';

  @override
  String get ordersActionConfirmReceipt => '수령 확인';

  @override
  String get ordersPaymentSheetTitle => '결제 진행';

  @override
  String get ordersPaymentSheetDevDescription =>
      '이 dev 주문은 서버 주도 더미 결제 흐름으로 바로 완료할 수 있습니다. 한 번 확인하면 주문이 결제 완료 에스크로 보관 단계로 이동합니다.';

  @override
  String get ordersPaymentSheetReadyDescription =>
      '이 주문은 결제 복귀 경로 준비가 완료되었습니다. 앱 밖에서 계속 진행하기 전에 세션 정보를 확인해 주세요.';

  @override
  String get ordersPaymentSheetBlockedDescription =>
      '복귀한 결제 결과만 있다면 이 주문을 계속 확인할 수 있습니다. 다른 곳에서 Toss checkout을 마쳤다면 아래에서 payment key를 입력해 주세요.';

  @override
  String get ordersPaymentSheetStatusDev => 'dev 더미 결제';

  @override
  String get ordersPaymentSheetStatusReady => '복귀 경로 준비 완료';

  @override
  String get ordersPaymentSheetStatusBlocked => '수동 복구 경로';

  @override
  String get ordersPaymentSheetNextStepTitle => '다음 단계';

  @override
  String get ordersPaymentSheetNextStepDev =>
      '앱 안에서 한 번 결제를 마치고, 주문 타임라인에서 배송과 수령 확인으로 이어가세요.';

  @override
  String get ordersPaymentSheetNextStepReady =>
      '이 빌드 밖에서 Toss checkout을 마친 뒤 결제 결과와 함께 돌아오면 이 화면에서 주문을 확인할 수 있습니다.';

  @override
  String get ordersPaymentSheetNextStepBlocked =>
      '주문 타임라인을 복귀 지점으로 두고 진행하세요. 다른 곳에서 Toss checkout이 끝나면 돌아온 payment key로 이 화면에서 주문을 확인할 수 있습니다.';

  @override
  String get ordersPaymentFallbackHint =>
      '앱 밖에서 Toss checkout을 마쳤다면 payment key와 함께 돌아와 이 주문 카드에서 이어가세요.';

  @override
  String get ordersPaymentReturnPendingTitle => '결제를 마무리하고 있습니다';

  @override
  String get ordersPaymentReturnPendingDescription =>
      '복귀한 결제 결과를 확인하고 주문을 결제 완료 타임라인으로 이동합니다.';

  @override
  String get ordersPaymentReturnSuccessTitle => '결제가 확인되었습니다';

  @override
  String get ordersPaymentReturnSuccessDescription =>
      '주문이 결제 완료 에스크로 보관 단계로 이동했습니다. 배송과 수령 확인은 주문 타임라인에서 이어갈 수 있습니다.';

  @override
  String get ordersPaymentReturnFailTitle => '결제가 완료되지 않았습니다';

  @override
  String get ordersPaymentReturnFailDescription =>
      '주문 타임라인으로 돌아가 결제를 다시 진행하거나 최신 상태를 확인해 주세요.';

  @override
  String get ordersPaymentReturnInvalidTitle => '결제 복귀 정보가 부족합니다';

  @override
  String get ordersPaymentReturnInvalidDescription =>
      '주문을 확인하려면 order, payment, amount 정보가 모두 필요합니다.';

  @override
  String ordersPaymentReturnCodeLabel(Object code) {
    return '복귀 코드 · $code';
  }

  @override
  String get ordersPaymentReturnActionOpenOrder => '주문 타임라인 열기';

  @override
  String get ordersPaymentReturnActionBackToOrders => '주문으로 돌아가기';

  @override
  String get ordersPaymentCompleteDevAction => 'dev 결제 완료';

  @override
  String get ordersPaymentLaunchAction => 'Toss 결제 열기';

  @override
  String get ordersPaymentEnterKeyAction => 'payment key 입력';

  @override
  String get ordersPaymentLaunchingOverlay => 'Toss 결제창을 준비하고 있습니다.';

  @override
  String get ordersPaymentLaunchStarted => '브라우저에서 Toss 결제를 계속 진행해 주세요.';

  @override
  String get ordersPaymentConfirmTitle => '결제 확인';

  @override
  String get ordersPaymentConfirmDescription =>
      'checkout에서 돌아온 Toss payment key를 입력하면 주문 상태를 결제 완료 에스크로 보관 단계로 전환합니다.';

  @override
  String get ordersPaymentConfirmAction => '결제 확인';

  @override
  String get ordersPaymentKeyLabel => 'payment key';

  @override
  String get ordersPaymentKeyHint => 'pay_...';

  @override
  String get ordersPaymentKeyRequiredError => '계속하려면 payment key를 입력해 주세요.';

  @override
  String ordersPaymentAmountLabel(Object amount) {
    return '결제 금액 · $amount';
  }

  @override
  String get ordersPaymentProviderLabel => '결제사';

  @override
  String get ordersPaymentEmailLabel => '구매자 이메일';

  @override
  String ordersPaymentDueIn(Object remaining) {
    return '$remaining 내 결제 필요';
  }

  @override
  String get ordersPaymentExpired => '결제 기한이 지났습니다';

  @override
  String ordersPaymentDevKeyLabel(Object paymentKey) {
    return 'dev payment key · $paymentKey';
  }

  @override
  String ordersPaymentSuccessUrlLabel(Object url) {
    return '성공 URL · $url';
  }

  @override
  String ordersPaymentFailUrlLabel(Object url) {
    return '실패 URL · $url';
  }

  @override
  String get ordersShipmentDialogTitle => '배송 정보';

  @override
  String get ordersShipmentCarrierLabel => '택배사';

  @override
  String get ordersShipmentCarrierHint => 'CJ Logistics';

  @override
  String get ordersShipmentCarrierRequiredError => '택배사를 입력해 주세요.';

  @override
  String get ordersShipmentTrackingLabel => '운송장 번호';

  @override
  String get ordersShipmentTrackingHint => '1234567890';

  @override
  String get ordersShipmentTrackingRequiredError => '운송장 번호를 입력해 주세요.';

  @override
  String get ordersShipmentSubmit => '배송 정보 저장';

  @override
  String get ordersDialogCancel => '취소';

  @override
  String get ordersActionSuccessShipped => '배송 정보가 저장되었습니다.';

  @override
  String get ordersActionSuccessPayment =>
      '결제가 확인되었습니다. 주문이 에스크로 보관 단계로 이동했습니다.';

  @override
  String get ordersActionSuccessReceipt =>
      '수령 확인이 완료되었습니다. 다음 정산 단계로 넘어갈 수 있습니다.';

  @override
  String get ordersActionFailed => '주문 액션을 완료하지 못했습니다. 다시 시도하세요.';

  @override
  String ordersShipmentSummary(Object carrierName, Object trackingNumber) {
    return '$carrierName · $trackingNumber';
  }
}
