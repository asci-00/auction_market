// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters, constant_identifier_names

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader {
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String, dynamic> _en = {
    "app": {"title": "Auction Market"},
    "common": {
      "language": "Language",
      "korean": "Korean",
      "english": "English"
    },
    "nav": {
      "home": "Home",
      "search": "Search",
      "sell": "Sell",
      "activity": "Activity",
      "my": "My"
    },
    "login": {
      "title": "Auction Market Sign In",
      "google": "Sign in with Google (MVP)",
      "apple": "Sign in with Apple (MVP)",
      "kakao": "Kakao sign-in (Stub)",
      "naver": "Naver sign-in (Stub)"
    },
    "home": {
      "title": "Ending Soon / Hot Auctions",
      "auctionTitle": "Auction #{{id}}",
      "priceSummary": "Current price: KRW 100,000 / Buy now available",
      "timer": "00:12:08"
    },
    "search": {
      "title": "Search / Filters",
      "keyword": "Keyword",
      "category": "Category",
      "priceRange": "Price range",
      "endingSoon": "Ending soon",
      "buyNow": "Buy now"
    },
    "sell": {
      "title": "Sell Step Form",
      "step1": "1) Choose category (GOODS / PRECIOUS)",
      "step2": "2) Enter item details and tags",
      "step3":
          "3) Set starting price / buy now price / duration (1,3,5,7 days)",
      "step4":
          "4) Upload up to 10 photos + at least 1 GOODS verification photo",
      "step5": "5) PRECIOUS appraisal request stub",
      "step6": "6) Preview / publish",
      "antiSniping":
          "Anti-sniping: bids in the last 5 minutes extend the auction by 5 minutes (up to 3 times)"
    },
    "activity": {
      "title": "Activity",
      "orders": "Orders / Payments",
      "bids": "My bids",
      "tracking": "Shipment tracking"
    },
    "auction": {
      "title": "Auction Detail #{{id}}",
      "summary":
          "Current highest bid KRW 120,000 / 4 bidders / time left 00:14:20",
      "bid": "Place bid",
      "buyNow": "Buy now",
      "autoBid": "Auto-bid settings (Flag)",
      "bidAuthReason": "Bid authentication",
      "bidAmount": "Bid amount",
      "placeBid": "Call placeBid (integration point)"
    },
    "orders": {
      "title": "Orders / Payments (Mock)",
      "paymentFlow": "AWAITING_PAYMENT → PAID_ESCROW_HOLD",
      "shippingFlow": "SHIPPED → CONFIRMED_RECEIPT → SETTLED"
    },
    "notifications": {
      "title": "Notification Center",
      "outbid": "OUTBID alert #{{id}}",
      "deeplink": "app://auction/123"
    },
    "my": {
      "title": "My",
      "verificationTitle": "Identity / precious seller verification status",
      "verificationStatus":
          "phone: VERIFIED / id: PENDING / precious: UNVERIFIED"
    }
  };
  static const Map<String, dynamic> _ko = {
    "app": {"title": "옥션마켓"},
    "common": {"language": "언어", "korean": "한국어", "english": "영어"},
    "nav": {
      "home": "홈",
      "search": "검색",
      "sell": "판매",
      "activity": "활동",
      "my": "마이"
    },
    "login": {
      "title": "옥션마켓 로그인",
      "google": "Google 로그인 (MVP)",
      "apple": "Apple 로그인 (MVP)",
      "kakao": "카카오 로그인 (Stub)",
      "naver": "네이버 로그인 (Stub)"
    },
    "home": {
      "title": "마감임박 / 인기 경매",
      "auctionTitle": "경매 #{{id}}",
      "priceSummary": "현재가: 100,000원 / 즉시구매 가능",
      "timer": "00:12:08"
    },
    "search": {
      "title": "검색 / 필터",
      "keyword": "키워드",
      "category": "카테고리",
      "priceRange": "가격대",
      "endingSoon": "종료임박",
      "buyNow": "즉시구매"
    },
    "sell": {
      "title": "출품 Step Form",
      "step1": "1) 카테고리 선택 (GOODS / PRECIOUS)",
      "step2": "2) 상품 정보 입력 + 태그",
      "step3": "3) 시작가 / 즉시구매가 / 기간(1,3,5,7일)",
      "step4": "4) 사진 업로드 최대 10장 + GOODS 인증사진 최소 1장",
      "step5": "5) PRECIOUS 감정요청 스텁",
      "step6": "6) 미리보기 / 등록",
      "antiSniping": "스나이핑 방지: 종료 5분 전 입찰 시 +5분(최대 3회)"
    },
    "activity": {
      "title": "활동",
      "orders": "주문 / 결제",
      "bids": "내 입찰 현황",
      "tracking": "배송 추적"
    },
    "auction": {
      "title": "경매 상세 #{{id}}",
      "summary": "현재 최고가 120,000원 / 입찰자 4명 / 남은시간 00:14:20",
      "bid": "입찰하기",
      "buyNow": "즉시구매",
      "autoBid": "자동입찰 설정(Flag)",
      "bidAuthReason": "입찰 인증",
      "bidAmount": "입찰 금액",
      "placeBid": "placeBid 호출(연동 포인트)"
    },
    "orders": {
      "title": "주문 / 결제 (Mock)",
      "paymentFlow": "AWAITING_PAYMENT → PAID_ESCROW_HOLD",
      "shippingFlow": "SHIPPED → CONFIRMED_RECEIPT → SETTLED"
    },
    "notifications": {
      "title": "알림센터",
      "outbid": "OUTBID 알림 #{{id}}",
      "deeplink": "app://auction/123"
    },
    "my": {
      "title": "마이",
      "verificationTitle": "본인인증 / 귀중품 판매자 인증 상태",
      "verificationStatus":
          "phone: VERIFIED / id: PENDING / precious: UNVERIFIED"
    }
  };
  static const Map<String, Map<String, dynamic>> mapLocales = {
    "en": _en,
    "ko": _ko
  };
}
