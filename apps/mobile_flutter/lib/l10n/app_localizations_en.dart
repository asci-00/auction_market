// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Auction Market';

  @override
  String get retry => 'Try again';

  @override
  String get loadingApp => 'Preparing your marketplace';

  @override
  String get configRequiredTitle => 'Setup required';

  @override
  String get bootstrapFailedTitle => 'We couldn\'t start the app';

  @override
  String get unknownStartupTitle => 'Something unexpected happened';

  @override
  String get configRequiredDetails =>
      'Check your dart_defines.json values and reopen the app.';

  @override
  String get unknownStartupMessage =>
      'There was a problem while opening the app. Check your configuration and network, then try again.';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navSell => 'Sell';

  @override
  String get navActivity => 'Activity';

  @override
  String get navMy => 'My';

  @override
  String get badgeLive => 'LIVE';

  @override
  String get badgeEndingSoon => 'ENDING SOON';

  @override
  String get badgeBuyNow => 'BUY NOW';

  @override
  String get badgePaid => 'PAID';

  @override
  String get badgeSettled => 'SETTLED';

  @override
  String get badgePending => 'PENDING';

  @override
  String get badgeVerified => 'VERIFIED';

  @override
  String get badgeUnread => 'NEW';

  @override
  String get homeLargeTitle => 'Curated auctions';

  @override
  String get homeHeroEyebrow => 'Premium resale';

  @override
  String get homeHeroTitle =>
      'Move quickly on trusted auctions without losing the calm.';

  @override
  String get homeHeroDescription =>
      'Track the pieces ending first, the sellers drawing momentum, and the categories worth revisiting today.';

  @override
  String get homeHeroChipUrgency => 'Timed bidding';

  @override
  String get homeHeroChipQuality => 'Verified listings';

  @override
  String get homeEndingSoonTitle => 'Ending soon';

  @override
  String get homeEndingSoonSubtitle =>
      'Stay on top of auctions with the shortest remaining time.';

  @override
  String get homeHotTitle => 'Hot right now';

  @override
  String get homeHotSubtitle =>
      'See the listings collecting bids and attention first.';

  @override
  String get homeOpenNotifications => 'Notifications';

  @override
  String get homeEmptyTitle => 'New auctions will appear here';

  @override
  String get homeEmptyDescription =>
      'Live listings will surface in this space as soon as they are published.';

  @override
  String get homeEmptyAction => 'Refresh feed';

  @override
  String get homeSectionViewAll => 'See all';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHeroEyebrow => 'Refined discovery';

  @override
  String get searchHeroTitle => 'Search by taste, not only by keywords.';

  @override
  String get searchHeroDescription =>
      'Use focused filters to narrow down price, urgency, and instant-purchase availability in one pass.';

  @override
  String get searchFieldLabel => 'Search query';

  @override
  String get searchFieldHint => 'Brand, model, or seller';

  @override
  String get searchFilterCategory => 'Category';

  @override
  String get searchFilterPrice => 'Price';

  @override
  String get searchFilterEndingSoon => 'Ending soon';

  @override
  String get searchFilterBuyNow => 'Buy now';

  @override
  String get searchResultsTitle => 'Results';

  @override
  String get searchResultsSubtitle =>
      'Live auctions are filtered in real time from your current query.';

  @override
  String get searchEmptyTitle => 'No auctions match yet';

  @override
  String get searchEmptyDescription =>
      'Try widening your search or return when more listings go live.';

  @override
  String get searchResetAction => 'Clear query';

  @override
  String get loginHeroEyebrow => 'Trusted access';

  @override
  String get loginHeroTitle =>
      'Enter a quieter marketplace for serious bidding.';

  @override
  String get loginHeroDescription =>
      'Sign in with a supported provider to restore your session, inbox, orders, and selling tools securely.';

  @override
  String get loginContinueGoogle => 'Continue with Google';

  @override
  String get loginContinueApple => 'Continue with Apple';

  @override
  String get loginSubmitting => 'Signing you in...';

  @override
  String get loginReturnNotice =>
      'After sign-in, you\'ll go back to the screen you requested.';

  @override
  String get loginTrustNote =>
      'Only Apple and Google sign-in are available in v1.';

  @override
  String get loginEmulatorWarning =>
      'When Firebase Emulator mode is on, this build does not run the mobile Google or Apple browser sign-in flow. Run with USE_FIREBASE_EMULATORS=false to verify real social sign-in.';

  @override
  String get loginEmulatorUnsupportedProvider =>
      'This build is connected to Firebase Auth Emulator, so it cannot complete the mobile Google or Apple browser sign-in flow. Run again with USE_FIREBASE_EMULATORS=false to verify real social sign-in.';

  @override
  String get loginGenericError =>
      'Sign-in failed. Check your Firebase project setup and try again.';

  @override
  String get loginErrorNetwork => 'Check your connection and try again.';

  @override
  String get loginErrorProviderDisabled =>
      'That sign-in provider is not enabled in Firebase Auth yet.';

  @override
  String get loginErrorAccountExists =>
      'This account already exists with a different sign-in method.';

  @override
  String get activityTitle => 'Activity';

  @override
  String get activityHeroEyebrow => 'At-a-glance status';

  @override
  String get activityHeroTitle =>
      'Keep payment, shipping, and inbox movement in one place.';

  @override
  String get activityHeroDescription =>
      'Jump to the next operational step quickly instead of hunting across screens.';

  @override
  String get activityOrdersTitle => 'Orders and payments';

  @override
  String get activityOrdersSubtitle =>
      'Track what needs payment, shipment, or confirmation next.';

  @override
  String get activityNotificationsTitle => 'Inbox and alerts';

  @override
  String get activityNotificationsSubtitle =>
      'Open bid, payment, and delivery updates from your inbox.';

  @override
  String get activityBuyerCardTitle => 'Buyer queue';

  @override
  String get activityBuyerCardDescription =>
      'Keep up with payment and receipt actions from one place.';

  @override
  String activityBuyerPendingPaymentSubtitle(Object count) {
    return '$count orders still need payment confirmation.';
  }

  @override
  String activityBuyerAwaitingReceiptSubtitle(Object count) {
    return '$count delivered orders still need receipt confirmation.';
  }

  @override
  String get activityBuyerMetricLabel => 'buyer actions pending';

  @override
  String get activitySellerCardTitle => 'Seller queue';

  @override
  String get activitySellerCardDescription =>
      'Stay on top of shipment handoff after payment clears.';

  @override
  String activitySellerAwaitingShipmentSubtitle(Object count) {
    return '$count paid orders are waiting for shipment details.';
  }

  @override
  String get activitySellerMetricLabel => 'seller actions pending';

  @override
  String get activityNotificationsCardTitle => 'Unread updates';

  @override
  String get activityNotificationsCardDescription =>
      'Open the inbox when bids, payment, or delivery events need attention.';

  @override
  String activityNotificationsUnreadSubtitle(Object count) {
    return '$count unread updates are waiting in your inbox.';
  }

  @override
  String get activityNotificationsMetricLabel => 'unread alerts';

  @override
  String get activitySignedOutDescription =>
      'Sign in to see your live order and inbox activity.';

  @override
  String get auctionDetailTitle => 'Auction detail';

  @override
  String get auctionDetailGalleryEyebrow => 'Listing overview';

  @override
  String get auctionDetailFallbackTitle => 'Listing details are on the way';

  @override
  String get auctionDetailFallbackDescription =>
      'When this auction document is available, images, seller trust, and bid history will appear in this layout.';

  @override
  String get auctionDetailCurrentBid => 'Current bid';

  @override
  String get auctionDetailBuyNow => 'Buy now';

  @override
  String get auctionDetailSellerSummary => 'Seller summary';

  @override
  String get auctionDetailSellerDescription =>
      'Trust signals, category fit, and shipping readiness stay visible before you place a bid.';

  @override
  String get auctionDetailBidHistory => 'Bid history';

  @override
  String get auctionDetailBidHistorySubtitle =>
      'Recent price movement is presented without extra noise.';

  @override
  String get auctionDetailNoBidHistory =>
      'Bid updates will appear after the first accepted bid.';

  @override
  String get auctionDetailActionHint =>
      'Bidding and instant purchase actions appear here as soon as a live auction record is available.';

  @override
  String get auctionDetailBrowseAction => 'Browse live auctions';

  @override
  String auctionDetailLiveActionHint(Object minimumBid, Object endAt) {
    return 'Next accepted bid starts at $minimumBid. Auction closes $endAt.';
  }

  @override
  String auctionDetailSellerOwnedHint(Object endAt) {
    return 'Your listing is live until $endAt. Buyer actions stay active on this screen.';
  }

  @override
  String get auctionDetailSellerOwnedFallback =>
      'Your listing is live. Order and settlement updates will appear when a buyer closes the auction.';

  @override
  String get auctionDetailSellerOwnedAction => 'Review orders';

  @override
  String get auctionDetailOrderReadyHint =>
      'This auction already has an order. Open the order timeline to continue payment or fulfillment.';

  @override
  String get auctionDetailEndedHint =>
      'This auction is no longer open for bidding. Browse other live listings instead.';

  @override
  String get auctionDetailViewOrder => 'Open order timeline';

  @override
  String get auctionDetailLoginHint =>
      'Sign in to place bids, set an auto-bid ceiling, or complete buy now.';

  @override
  String get auctionDetailSignInAction => 'Sign in to bid';

  @override
  String auctionDetailBidAction(Object amount) {
    return 'Bid from $amount';
  }

  @override
  String auctionDetailBuyNowAction(Object amount) {
    return 'Buy now $amount';
  }

  @override
  String get auctionDetailAutoBidAction => 'Set auto-bid ceiling';

  @override
  String get auctionDetailBidDialogTitle => 'Place a bid';

  @override
  String get auctionDetailBidAmountLabel => 'Bid amount';

  @override
  String get auctionDetailBidAmountHint => 'Enter your offer in KRW';

  @override
  String get auctionDetailAutoBidDialogTitle => 'Set auto-bid ceiling';

  @override
  String get auctionDetailAutoBidAmountLabel => 'Maximum auto-bid';

  @override
  String get auctionDetailAutoBidAmountHint =>
      'Highest amount you want the system to defend';

  @override
  String auctionDetailBidMinimum(Object amount) {
    return 'Minimum accepted amount: $amount';
  }

  @override
  String auctionDetailAutoBidHint(Object amount) {
    return 'The auto-bid ceiling must start at or above $amount. The system raises only as needed.';
  }

  @override
  String get auctionDetailDialogCancel => 'Cancel';

  @override
  String get auctionDetailDialogSubmitBid => 'Submit bid';

  @override
  String get auctionDetailDialogSubmitAutoBid => 'Save auto-bid';

  @override
  String get auctionDetailActionSuccessBid => 'Your bid was submitted.';

  @override
  String get auctionDetailActionSuccessAutoBid =>
      'Your auto-bid ceiling was saved.';

  @override
  String get auctionDetailActionSuccessBuyNow =>
      'Buy now is complete. Continue in the order timeline.';

  @override
  String get auctionDetailActionFailed =>
      'We couldn\'t complete that auction action. Try again.';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get ordersBuyerTitle => 'Buying';

  @override
  String get ordersSellerTitle => 'Selling';

  @override
  String get ordersBuyerSubtitle =>
      'Payments, shipments, and confirmations for purchases you made.';

  @override
  String get ordersSellerSubtitle =>
      'Shipment and settlement progress for the auctions you sold.';

  @override
  String get ordersEmptyTitle => 'No order activity yet';

  @override
  String get ordersEmptyDescription =>
      'Once a payment starts or a sale closes, the timeline will appear here.';

  @override
  String get ordersHighlightedLabel => 'Focused order';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsHeroEyebrow => 'Inbox';

  @override
  String get notificationsHeroTitle =>
      'Important changes, without noisy blue alerts.';

  @override
  String get notificationsHeroDescription =>
      'Unread updates stay visible so you can move straight to the next relevant screen.';

  @override
  String get notificationsEmptyTitle => 'Your inbox is quiet';

  @override
  String get notificationsEmptyDescription =>
      'Bid, payment, and shipment updates will land here as soon as activity begins.';

  @override
  String get myTitle => 'My';

  @override
  String get myHeroEyebrow => 'Profile and trust';

  @override
  String get myHeroTitle => 'Keep your profile ready for buying and selling.';

  @override
  String get myHeroDescription =>
      'Verification, seller momentum, and account preferences should feel close at hand, not buried in settings.';

  @override
  String get mySignedInAs => 'Signed in as';

  @override
  String get myVerificationTitle => 'Verification status';

  @override
  String get myVerificationDescription =>
      'Review the trust checks that shape how confidently others trade with you.';

  @override
  String get myVerificationPhone => 'Phone';

  @override
  String get myVerificationIdentity => 'Identity';

  @override
  String get myVerificationSeller => 'Seller';

  @override
  String get mySessionUnavailable => 'We couldn\'t load profile details yet.';

  @override
  String myEnvironmentLabel(Object environment, Object platform) {
    return '$environment · $platform';
  }

  @override
  String get mySignOut => 'Sign out';

  @override
  String get sellTitle => 'Start selling';

  @override
  String get sellHeroEyebrow => 'Seller studio';

  @override
  String get sellHeroTitle =>
      'Shape a listing that feels deliberate before it goes live.';

  @override
  String get sellHeroDescription =>
      'Walk through the item story, pricing, schedule, and images with a cleaner publishing rhythm.';

  @override
  String get sellPolicyTitle => 'Auction timing policy';

  @override
  String get sellPolicyDescription =>
      'A bid placed within the last five minutes extends the closing time by five minutes, up to three times.';

  @override
  String get sellStepCategoryTitle => 'Choose a category';

  @override
  String get sellStepCategoryDescription =>
      'Start in the right path for goods or precious items so the required fields stay aligned.';

  @override
  String get sellStepDetailsTitle => 'Describe the item clearly';

  @override
  String get sellStepDetailsDescription =>
      'Title, condition, tags, and description should make the listing easy to trust at a glance.';

  @override
  String get sellStepPricingTitle => 'Set price and schedule';

  @override
  String get sellStepPricingDescription =>
      'Start price, buy-now price, and closing time need to communicate urgency without confusion.';

  @override
  String get sellStepImagesTitle => 'Prepare image coverage';

  @override
  String get sellStepImagesDescription =>
      'Main photos and any required authentication images should feel complete before publishing.';

  @override
  String get sellStepPublishTitle => 'Preview and publish';

  @override
  String get sellStepPublishDescription =>
      'Check the story, pricing, and urgency cues together before you send the auction live.';

  @override
  String get sellDraftsTitle => 'Recent drafts';

  @override
  String get sellDraftsSubtitle =>
      'Return to saved item content before you publish a live auction.';

  @override
  String get sellDraftEmptyTitle => 'No saved drafts yet';

  @override
  String get sellDraftEmptyDescription =>
      'Your saved item drafts will appear here when they are written to Firestore.';

  @override
  String get sellDraftLoadAction => 'Load';

  @override
  String get sellDraftUntitled => 'Untitled item';

  @override
  String sellDraftUpdatedAt(Object time) {
    return 'Updated $time';
  }

  @override
  String get sellDraftNoTimestamp => 'Timestamp unavailable';

  @override
  String sellCurrentDraftLabel(Object itemId) {
    return 'Editing draft #$itemId';
  }

  @override
  String get sellCategoryGoods => 'Goods';

  @override
  String get sellCategoryPrecious => 'Precious';

  @override
  String get sellFormCategoryMainLabel => 'Main category';

  @override
  String get sellFormCategorySubLabel => 'Category detail';

  @override
  String get sellFormTitleLabel => 'Item title';

  @override
  String get sellFormConditionLabel => 'Condition';

  @override
  String get sellFormTagsLabel => 'Tags';

  @override
  String get sellFormTagsHint => 'Brand, material, size';

  @override
  String get sellFormDescriptionLabel => 'Description';

  @override
  String get sellFormAppraisalLabel => 'Request appraisal workflow';

  @override
  String get sellFormStartPriceLabel => 'Start price';

  @override
  String get sellFormBuyNowPriceLabel => 'Buy now price';

  @override
  String get sellFormDurationLabel => 'Auction duration';

  @override
  String sellDurationDays(int count) {
    return '$count day window';
  }

  @override
  String get sellImageMainTitle => 'Listing gallery';

  @override
  String get sellImageMainDescription =>
      'Upload up to 10 main images for the public auction card and detail page.';

  @override
  String get sellImageMainAction => 'Choose gallery images';

  @override
  String get sellImageAuthTitle => 'Authentication images';

  @override
  String get sellImageAuthDescription =>
      'Goods listings require at least one authentication image before draft save and publish.';

  @override
  String get sellImageAuthAction => 'Choose authentication images';

  @override
  String get sellImagesEmptyState => 'No images selected yet.';

  @override
  String get sellSaveDraftAction => 'Save draft';

  @override
  String get sellPublishAction => 'Publish auction';

  @override
  String get sellSavingDraft => 'Saving draft...';

  @override
  String get sellPublishing => 'Publishing...';

  @override
  String get sellActionSaved => 'Draft saved to your seller workspace.';

  @override
  String get sellActionPublished =>
      'Auction published. Opening the live listing now.';

  @override
  String get sellActionFailed =>
      'We couldn\'t complete that seller action. Check the form and try again.';

  @override
  String get sellValidationCategorySub =>
      'Add a category detail before saving the draft.';

  @override
  String get sellValidationTitle =>
      'Add an item title before saving the draft.';

  @override
  String get sellValidationCondition =>
      'Add the item condition before saving the draft.';

  @override
  String get sellValidationDescription =>
      'Add the item description before saving the draft.';

  @override
  String get sellValidationAuthImages =>
      'Goods drafts need at least one authentication image.';

  @override
  String get sellValidationImages =>
      'Publishing requires at least one gallery image.';

  @override
  String get sellValidationStartPrice =>
      'Enter a valid start price before publishing.';

  @override
  String get sellValidationBuyNowPrice =>
      'Buy now price must be greater than the start price.';

  @override
  String get genericUnavailable => 'Unavailable';

  @override
  String get genericUnknownSeller => 'Seller';

  @override
  String get genericUnknownUser => 'Member';

  @override
  String get genericStateVerified => 'Verified';

  @override
  String get genericStatePending => 'Pending review';

  @override
  String get genericStateRejected => 'Rejected';

  @override
  String get genericStateUnverified => 'Not verified';

  @override
  String get genericOrderAwaitingPayment => 'Awaiting payment';

  @override
  String get genericOrderPaid => 'Paid and held';

  @override
  String get genericOrderShipped => 'Shipped';

  @override
  String get genericOrderConfirmedReceipt => 'Receipt confirmed';

  @override
  String get genericOrderSettled => 'Settled';

  @override
  String get genericOrderCancelled => 'Cancelled';

  @override
  String get genericOrderProcessing => 'In progress';

  @override
  String genericCountBids(int count) {
    return '$count bids';
  }

  @override
  String genericEndsAt(Object time) {
    return 'Ends $time';
  }

  @override
  String get genericCountdownExpired => 'Expired';

  @override
  String get genericCountdownLessThanMinute => 'under 1m left';

  @override
  String genericCountdownMinutesRemaining(int minutes) {
    return '${minutes}m left';
  }

  @override
  String genericCountdownHoursRemaining(int hours, int minutes) {
    return '${hours}h ${minutes}m left';
  }

  @override
  String genericCountdownDaysRemaining(int days, int hours) {
    return '${days}d ${hours}h left';
  }

  @override
  String genericUnreadCount(int count) {
    return '$count unread';
  }

  @override
  String get loginDevAccessTitle => 'Quick access for emulator checks';

  @override
  String get loginDevAccessDescription =>
      'Use the seeded buyer and seller accounts only for local smoke tests in dev emulator mode.';

  @override
  String get loginDevBuyer => 'Sign in as seeded buyer';

  @override
  String get loginDevSeller => 'Sign in as seeded seller';

  @override
  String get loginErrorSeedAccountUnavailable =>
      'The seeded emulator account is unavailable. Start the emulators and run npm run seed again.';

  @override
  String get ordersActionAddShipment => 'Add shipment';

  @override
  String get ordersActionPreparePayment => 'Continue payment';

  @override
  String get ordersActionConfirmReceipt => 'Confirm receipt';

  @override
  String get ordersPaymentSheetTitle => 'Complete payment';

  @override
  String get ordersPaymentSheetDevDescription =>
      'This dev order can complete payment entirely through the server-driven dummy flow. Confirm once to move the order into paid escrow hold.';

  @override
  String get ordersPaymentSheetReadyDescription =>
      'This order already has the payment return path prepared. Review the session details before you continue outside the app.';

  @override
  String get ordersPaymentSheetBlockedDescription =>
      'This order can still be confirmed from a returned payment result. If you already completed Toss checkout elsewhere, enter the payment key below.';

  @override
  String get ordersPaymentSheetStatusDev => 'Dev dummy payment';

  @override
  String get ordersPaymentSheetStatusReady => 'Return path prepared';

  @override
  String get ordersPaymentSheetStatusBlocked => 'Manual recovery path';

  @override
  String get ordersPaymentSheetNextStepTitle => 'Next step';

  @override
  String get ordersPaymentSheetNextStepDev =>
      'Complete payment in-app once, then move to shipping and receipt from the order timeline.';

  @override
  String get ordersPaymentSheetNextStepReady =>
      'Finish Toss checkout outside this build, then return with the payment result so the order can be confirmed here.';

  @override
  String get ordersPaymentSheetNextStepBlocked =>
      'Keep the order timeline open as your recovery point. When Toss checkout finishes elsewhere, come back with the returned payment key to confirm the order here.';

  @override
  String get ordersPaymentFallbackHint =>
      'If Toss checkout finished outside the app, return with the payment key and continue from this order card.';

  @override
  String get ordersPaymentReturnPendingTitle => 'Finalizing payment';

  @override
  String get ordersPaymentReturnPendingDescription =>
      'We\'re validating the returned payment result and moving the order into the paid timeline.';

  @override
  String get ordersPaymentReturnSuccessTitle => 'Payment confirmed';

  @override
  String get ordersPaymentReturnSuccessDescription =>
      'The order is now in paid escrow hold. Continue in the order timeline for shipping and receipt updates.';

  @override
  String get ordersPaymentReturnFailTitle => 'Payment was not completed';

  @override
  String get ordersPaymentReturnFailDescription =>
      'Return to the order timeline to retry payment or review the latest status.';

  @override
  String get ordersPaymentReturnInvalidTitle =>
      'Payment return data is incomplete';

  @override
  String get ordersPaymentReturnInvalidDescription =>
      'This return route needs order, payment, and amount details before the order can be confirmed.';

  @override
  String ordersPaymentReturnCodeLabel(Object code) {
    return 'Return code · $code';
  }

  @override
  String get ordersPaymentReturnActionOpenOrder => 'Open order timeline';

  @override
  String get ordersPaymentReturnActionBackToOrders => 'Back to orders';

  @override
  String get ordersPaymentCompleteDevAction => 'Complete dev payment';

  @override
  String get ordersPaymentEnterKeyAction => 'Enter payment key';

  @override
  String get ordersPaymentConfirmTitle => 'Confirm payment';

  @override
  String get ordersPaymentConfirmDescription =>
      'Enter the Toss payment key that came back from checkout to move the order into paid escrow hold.';

  @override
  String get ordersPaymentConfirmAction => 'Confirm payment';

  @override
  String get ordersPaymentKeyLabel => 'Payment key';

  @override
  String get ordersPaymentKeyHint => 'pay_...';

  @override
  String get ordersPaymentKeyRequiredError =>
      'Enter the payment key to continue.';

  @override
  String ordersPaymentAmountLabel(Object amount) {
    return 'Amount · $amount';
  }

  @override
  String get ordersPaymentProviderLabel => 'Provider';

  @override
  String get ordersPaymentEmailLabel => 'Buyer email';

  @override
  String ordersPaymentDueIn(Object remaining) {
    return 'Payment due in $remaining';
  }

  @override
  String get ordersPaymentExpired => 'Payment window expired';

  @override
  String ordersPaymentDevKeyLabel(Object paymentKey) {
    return 'Dev payment key · $paymentKey';
  }

  @override
  String ordersPaymentSuccessUrlLabel(Object url) {
    return 'Success URL · $url';
  }

  @override
  String ordersPaymentFailUrlLabel(Object url) {
    return 'Fail URL · $url';
  }

  @override
  String get ordersShipmentDialogTitle => 'Shipment details';

  @override
  String get ordersShipmentCarrierLabel => 'Carrier';

  @override
  String get ordersShipmentCarrierHint => 'CJ Logistics';

  @override
  String get ordersShipmentTrackingLabel => 'Tracking number';

  @override
  String get ordersShipmentTrackingHint => '1234567890';

  @override
  String get ordersShipmentSubmit => 'Save shipment';

  @override
  String get ordersDialogCancel => 'Cancel';

  @override
  String get ordersActionSuccessShipped => 'Shipment details were saved.';

  @override
  String get ordersActionSuccessPayment =>
      'Payment confirmed. The order is now held in escrow.';

  @override
  String get ordersActionSuccessReceipt =>
      'Receipt confirmed. Settlement can proceed next.';

  @override
  String get ordersActionFailed =>
      'We couldn\'t complete that order action. Try again.';

  @override
  String ordersShipmentSummary(Object carrierName, Object trackingNumber) {
    return '$carrierName · $trackingNumber';
  }
}
