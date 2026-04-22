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
  String get genericSignInAction => 'Sign in';

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
  String get homeCuratedGoodsTitle => 'Goods spotlight';

  @override
  String get homeCuratedGoodsSubtitle =>
      'Browse fast-moving general goods in a tighter lane.';

  @override
  String get homeCuratedPreciousTitle => 'Precious spotlight';

  @override
  String get homeCuratedPreciousSubtitle =>
      'Keep precious pieces in a separate, easier-to-scan row.';

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
  String get searchFilterCategoryGoods => 'Goods';

  @override
  String get searchFilterCategoryPrecious => 'Precious';

  @override
  String get searchFilterPriceUnder50k => 'Under ₩50k';

  @override
  String get searchFilterPrice50kTo200k => '₩50k to ₩200k';

  @override
  String get searchFilterPriceOver200k => 'Over ₩200k';

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
  String get searchLayoutSwitchToGrid => 'Show grid view';

  @override
  String get searchLayoutSwitchToList => 'Show list view';

  @override
  String get searchEmptyTitle => 'No auctions match yet';

  @override
  String get searchEmptyDescription =>
      'Try widening your search or return when more listings go live.';

  @override
  String get searchErrorDescription =>
      'We couldn\'t load search results right now. Try again shortly.';

  @override
  String get searchResetAction => 'Clear query';

  @override
  String get searchResetFiltersAction => 'Reset filters';

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
  String get auctionDetailDescriptionTitle => 'Item details';

  @override
  String get auctionDetailDescriptionSubtitle =>
      'Condition, category fit, and seller notes stay visible before you act.';

  @override
  String get auctionDetailDescriptionFallback =>
      'Seller notes will appear here as soon as the linked item record is available.';

  @override
  String get auctionDetailMetaCondition => 'Condition';

  @override
  String get auctionDetailMetaCategory => 'Category';

  @override
  String get auctionDetailConditionNew => 'New';

  @override
  String get auctionDetailConditionLikeNew => 'Like new';

  @override
  String get auctionDetailConditionGood => 'Good';

  @override
  String get auctionDetailConditionFair => 'Fair';

  @override
  String get auctionDetailConditionPoor => 'Poor';

  @override
  String get auctionDetailCategoryIdolMd => 'Idol merchandise';

  @override
  String get auctionDetailCategoryWatch => 'Watch';

  @override
  String get auctionDetailCategorySneakers => 'Sneakers';

  @override
  String get auctionDetailCategoryBullion => 'Bullion';

  @override
  String get auctionDetailCategoryCamera => 'Camera';

  @override
  String get auctionDetailCategoryJewelry => 'Jewelry';

  @override
  String get auctionDetailCategoryPhotoCard => 'Photo card';

  @override
  String get auctionDetailCategoryGameConsole => 'Game console';

  @override
  String get auctionDetailCategoryFigure => 'Figure';

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
  String get auctionDetailSubmittingBidAction => 'Submitting bid...';

  @override
  String get auctionDetailSubmittingAutoBidAction => 'Saving auto-bid...';

  @override
  String get auctionDetailSubmittingBuyNowAction => 'Processing buy now...';

  @override
  String get auctionDetailSubmittingBidSubtitle =>
      'Submitting your bid now. Other actions will reopen as soon as this step finishes.';

  @override
  String get auctionDetailSubmittingAutoBidSubtitle =>
      'Saving your auto-bid ceiling now. Other actions will reopen as soon as this step finishes.';

  @override
  String get auctionDetailSubmittingBuyNowSubtitle =>
      'Processing buy now. Other actions will reopen as soon as this step finishes.';

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
  String get ordersErrorDescription =>
      'We couldn\'t load your orders right now. Try again in a moment.';

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
  String get notificationsDestinationAuction => 'Opens auction detail';

  @override
  String get notificationsDestinationOrder => 'Opens order timeline';

  @override
  String get notificationsDestinationInbox => 'Stays in inbox';

  @override
  String get notificationsDestinationPayment => 'Opens payment recovery';

  @override
  String get notificationsDestinationUnknown =>
      'Opens the next relevant screen';

  @override
  String get notificationsEmptyTitle => 'Your inbox is quiet';

  @override
  String get notificationsEmptyDescription =>
      'Bid, payment, and shipment updates will land here as soon as activity begins.';

  @override
  String get notificationsOpenAction => 'Open';

  @override
  String get notificationsForegroundFallbackTitle => 'New notification';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle =>
      'Keep alerts and app information within reach.';

  @override
  String get settingsHeroEyebrow => 'Preferences';

  @override
  String get settingsHeroTitle =>
      'Shape alerts around the moments that actually need your attention.';

  @override
  String get settingsHeroDescription =>
      'Notification controls should feel operational, clear, and easy to revisit from anywhere in the app.';

  @override
  String get settingsSignedOutTitle => 'Sign in to manage preferences';

  @override
  String get settingsSignedOutDescription =>
      'Your notification preferences and app information become available after sign-in.';

  @override
  String get settingsUnavailableTitle => 'Settings are not ready yet';

  @override
  String get settingsUnavailableDescription =>
      'We couldn\'t prepare your settings right now. Try again shortly.';

  @override
  String get settingsOpenAction => 'Open settings';

  @override
  String get settingsNotificationsMasterTitle => 'Push notifications';

  @override
  String get settingsNotificationsMasterDescription =>
      'Turn marketplace push updates on or off for this account.';

  @override
  String get settingsNotificationsPermissionTitle => 'Device permission';

  @override
  String get settingsNotificationsPermissionDescription =>
      'The device permission still needs to allow notifications before alerts can reach this phone.';

  @override
  String get settingsRequestPermission => 'Allow notifications';

  @override
  String get settingsOpenSystemSettings => 'Open system settings';

  @override
  String get settingsPermissionStatusAuthorized =>
      'Notifications are allowed on this device.';

  @override
  String get settingsPermissionStatusDenied =>
      'Notifications are blocked in system settings.';

  @override
  String get settingsPermissionStatusNotDetermined =>
      'Notification permission has not been requested yet.';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageDescription =>
      'The app language automatically follows your system language settings.';

  @override
  String get settingsLanguageCurrentLabel => 'Current app language';

  @override
  String get settingsLanguageSupportedLabel => 'Supported languages';

  @override
  String get settingsLanguageSupportedValue =>
      'Korean and English (fallback: Korean).';

  @override
  String get settingsLanguageKoreanLabel => 'Korean';

  @override
  String get settingsLanguageEnglishLabel => 'English';

  @override
  String get settingsPermissionStatusProvisional =>
      'Notifications are temporarily allowed with limited presentation.';

  @override
  String get settingsNotificationsCategoriesTitle => 'Alert categories';

  @override
  String get settingsNotificationsCategoriesDescription =>
      'Keep only the updates that help you move to the next action.';

  @override
  String get settingsCategoryAuctionActivity => 'Auction activity';

  @override
  String get settingsCategoryAuctionActivityDescription =>
      'Bid momentum, ending-soon reminders, and watchlist movement.';

  @override
  String get settingsCategoryOrderPayment => 'Orders and payment';

  @override
  String get settingsCategoryOrderPaymentDescription =>
      'Buy now completion, payment handoff, and order timeline updates.';

  @override
  String get settingsCategoryShippingAndReceipt => 'Shipping and receipt';

  @override
  String get settingsCategoryShippingAndReceiptDescription =>
      'Shipment registration, delivery progress, and receipt confirmation.';

  @override
  String get settingsCategorySystem => 'System notices';

  @override
  String get settingsCategorySystemDescription =>
      'Policy updates, operational notices, and service interruptions.';

  @override
  String get settingsAppearanceTitle => 'Appearance';

  @override
  String get settingsAppearanceDescription =>
      'Choose how the marketplace looks.';

  @override
  String get settingsThemeSystemTitle => 'System';

  @override
  String get settingsThemeLightTitle => 'Light';

  @override
  String get settingsThemeDarkTitle => 'Dark';

  @override
  String settingsThemeUpdatedToast(String theme) {
    return 'Appearance updated to $theme.';
  }

  @override
  String get settingsNotificationsEnabledToast =>
      'Push notifications are now on.';

  @override
  String get settingsNotificationsDisabledToast =>
      'Push notifications are now off.';

  @override
  String get settingsUpdateFailed =>
      'We couldn\'t update that setting. Try again.';

  @override
  String get settingsPermissionRequestFailed =>
      'We couldn\'t request notification permission right now.';

  @override
  String settingsCategoryEnabledToast(Object category) {
    return '$category notifications are now on.';
  }

  @override
  String settingsCategoryDisabledToast(Object category) {
    return '$category notifications are now off.';
  }

  @override
  String get settingsSystemSettingsOpened => 'System settings opened.';

  @override
  String get settingsSystemSettingsUnavailable =>
      'We couldn\'t open system settings on this device.';

  @override
  String get settingsAppInfoTitle => 'App information';

  @override
  String get settingsAppInfoDescription =>
      'Version, licenses, and environment details stay tucked into a quieter section.';

  @override
  String get settingsVersionLabel => 'Version';

  @override
  String get settingsVersionLoading => 'Preparing version information...';

  @override
  String get settingsLicensesTitle => 'Open-source licenses';

  @override
  String get settingsLicensesDescription =>
      'Review package attributions and license notices.';

  @override
  String get settingsDeveloperTitle => 'Developer context';

  @override
  String get settingsDeveloperDescription =>
      'Shown only in non-release builds to confirm local environment assumptions.';

  @override
  String get settingsDebugPushProbeTitle => 'Push probe';

  @override
  String get settingsDebugPushProbeDescription =>
      'Trigger a server push probe for the signed-in account.';

  @override
  String get settingsDebugPushProbeAction => 'Send';

  @override
  String get settingsDebugPushProbeSending => 'Sending...';

  @override
  String get settingsDebugPushProbeSuccess =>
      'Push probe requested. Check your notifications in a few seconds.';

  @override
  String settingsDebugPushProbeSkipped(int tokenCount) {
    return 'Push probe was created but push dispatch was skipped (eligible tokens: $tokenCount). Check notification preference and token status.';
  }

  @override
  String get settingsDebugPushProbeFailure =>
      'Push probe failed. Verify token registration and backend availability.';

  @override
  String settingsDebugPushProbeFailureWithReason(String reason) {
    return 'Push probe failed: $reason';
  }

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
  String get sellProgressTitle => 'Publishing progress';

  @override
  String sellProgressSubtitle(int completed, int total) {
    return '$completed of $total steps ready';
  }

  @override
  String get sellDraftsTitle => 'Recent drafts';

  @override
  String get sellDraftsSubtitle =>
      'Return to saved item content before you publish a live auction.';

  @override
  String get sellDraftEmptyTitle => 'No saved drafts yet';

  @override
  String get sellDraftEmptyDescription =>
      'Your saved item drafts will appear here after you save item details.';

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
  String get sellDraftStatusNotSaved => 'Not saved yet';

  @override
  String get sellDraftStatusNotSavedDescription =>
      'Save the draft once the item basics feel ready to keep your progress anchored.';

  @override
  String get sellDraftStatusUnsaved => 'Unsaved changes';

  @override
  String get sellDraftStatusUnsavedDescription =>
      'The current form is ahead of the latest saved draft. Save again before you publish.';

  @override
  String get sellDraftStatusSaved => 'Draft saved';

  @override
  String sellDraftStatusSavedDescription(Object time) {
    return 'Latest save: $time';
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
  String get sellValidationCategorySubPublish =>
      'Add a category detail before publishing the auction.';

  @override
  String get sellValidationTitlePublish =>
      'Add an item title before publishing the auction.';

  @override
  String get sellValidationConditionPublish =>
      'Add the item condition before publishing the auction.';

  @override
  String get sellValidationDescriptionPublish =>
      'Add the item description before publishing the auction.';

  @override
  String get sellValidationAuthImagesPublish =>
      'Goods auctions need at least one authentication image before publishing.';

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
  String get sellValidationBuyNowPriceInvalid =>
      'Enter a valid whole-number buy now price before publishing.';

  @override
  String get sellValidationSummaryDraftTitle =>
      'Complete these details before saving the draft';

  @override
  String get sellValidationSummaryPublishTitle =>
      'Complete these details before publishing the auction';

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
      'This order is ready to open the Toss checkout flow. Review the session details before continuing outside the app.';

  @override
  String get ordersPaymentSheetBlockedDescription =>
      'This order can still be confirmed from a returned payment result. If you already completed Toss checkout elsewhere, enter the payment key below.';

  @override
  String get ordersPaymentSheetStatusDev => 'Dev dummy payment';

  @override
  String get ordersPaymentSheetStatusReady => 'Toss checkout ready';

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
  String get ordersPaymentLaunchAction => 'Open Toss checkout';

  @override
  String get ordersPaymentEnterKeyAction => 'Enter payment key';

  @override
  String get ordersPaymentLaunchingOverlay => 'Preparing Toss checkout.';

  @override
  String get ordersPaymentLaunchStarted =>
      'Continue Toss payment in the browser.';

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
  String get ordersShipmentCarrierRequiredError => 'Enter a carrier name.';

  @override
  String get ordersShipmentTrackingLabel => 'Tracking number';

  @override
  String get ordersShipmentTrackingHint => '1234567890';

  @override
  String get ordersShipmentTrackingRequiredError => 'Enter a tracking number.';

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
