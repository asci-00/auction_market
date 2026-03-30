import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Auction Market'**
  String get appTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @genericSignInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get genericSignInAction;

  /// No description provided for @loadingApp.
  ///
  /// In en, this message translates to:
  /// **'Preparing your marketplace'**
  String get loadingApp;

  /// No description provided for @configRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup required'**
  String get configRequiredTitle;

  /// No description provided for @bootstrapFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t start the app'**
  String get bootstrapFailedTitle;

  /// No description provided for @unknownStartupTitle.
  ///
  /// In en, this message translates to:
  /// **'Something unexpected happened'**
  String get unknownStartupTitle;

  /// No description provided for @configRequiredDetails.
  ///
  /// In en, this message translates to:
  /// **'Check your dart_defines.json values and reopen the app.'**
  String get configRequiredDetails;

  /// No description provided for @unknownStartupMessage.
  ///
  /// In en, this message translates to:
  /// **'There was a problem while opening the app. Check your configuration and network, then try again.'**
  String get unknownStartupMessage;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navSell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get navSell;

  /// No description provided for @navActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get navActivity;

  /// No description provided for @navMy.
  ///
  /// In en, this message translates to:
  /// **'My'**
  String get navMy;

  /// No description provided for @badgeLive.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get badgeLive;

  /// No description provided for @badgeEndingSoon.
  ///
  /// In en, this message translates to:
  /// **'ENDING SOON'**
  String get badgeEndingSoon;

  /// No description provided for @badgeBuyNow.
  ///
  /// In en, this message translates to:
  /// **'BUY NOW'**
  String get badgeBuyNow;

  /// No description provided for @badgePaid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get badgePaid;

  /// No description provided for @badgeSettled.
  ///
  /// In en, this message translates to:
  /// **'SETTLED'**
  String get badgeSettled;

  /// No description provided for @badgePending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get badgePending;

  /// No description provided for @badgeVerified.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED'**
  String get badgeVerified;

  /// No description provided for @badgeUnread.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get badgeUnread;

  /// No description provided for @homeLargeTitle.
  ///
  /// In en, this message translates to:
  /// **'Curated auctions'**
  String get homeLargeTitle;

  /// No description provided for @homeHeroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Premium resale'**
  String get homeHeroEyebrow;

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Move quickly on trusted auctions without losing the calm.'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Track the pieces ending first, the sellers drawing momentum, and the categories worth revisiting today.'**
  String get homeHeroDescription;

  /// No description provided for @homeHeroChipUrgency.
  ///
  /// In en, this message translates to:
  /// **'Timed bidding'**
  String get homeHeroChipUrgency;

  /// No description provided for @homeHeroChipQuality.
  ///
  /// In en, this message translates to:
  /// **'Verified listings'**
  String get homeHeroChipQuality;

  /// No description provided for @homeEndingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Ending soon'**
  String get homeEndingSoonTitle;

  /// No description provided for @homeEndingSoonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay on top of auctions with the shortest remaining time.'**
  String get homeEndingSoonSubtitle;

  /// No description provided for @homeHotTitle.
  ///
  /// In en, this message translates to:
  /// **'Hot right now'**
  String get homeHotTitle;

  /// No description provided for @homeHotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See the listings collecting bids and attention first.'**
  String get homeHotSubtitle;

  /// No description provided for @homeOpenNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get homeOpenNotifications;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'New auctions will appear here'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Live listings will surface in this space as soon as they are published.'**
  String get homeEmptyDescription;

  /// No description provided for @homeEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Refresh feed'**
  String get homeEmptyAction;

  /// No description provided for @homeSectionViewAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSectionViewAll;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchHeroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Refined discovery'**
  String get searchHeroEyebrow;

  /// No description provided for @searchHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Search by taste, not only by keywords.'**
  String get searchHeroTitle;

  /// No description provided for @searchHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Use focused filters to narrow down price, urgency, and instant-purchase availability in one pass.'**
  String get searchHeroDescription;

  /// No description provided for @searchFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Search query'**
  String get searchFieldLabel;

  /// No description provided for @searchFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Brand, model, or seller'**
  String get searchFieldHint;

  /// No description provided for @searchFilterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get searchFilterCategory;

  /// No description provided for @searchFilterPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get searchFilterPrice;

  /// No description provided for @searchFilterCategoryGoods.
  ///
  /// In en, this message translates to:
  /// **'Goods'**
  String get searchFilterCategoryGoods;

  /// No description provided for @searchFilterCategoryPrecious.
  ///
  /// In en, this message translates to:
  /// **'Precious'**
  String get searchFilterCategoryPrecious;

  /// No description provided for @searchFilterPriceUnder50k.
  ///
  /// In en, this message translates to:
  /// **'Under ₩50k'**
  String get searchFilterPriceUnder50k;

  /// No description provided for @searchFilterPrice50kTo200k.
  ///
  /// In en, this message translates to:
  /// **'₩50k to ₩200k'**
  String get searchFilterPrice50kTo200k;

  /// No description provided for @searchFilterPriceOver200k.
  ///
  /// In en, this message translates to:
  /// **'Over ₩200k'**
  String get searchFilterPriceOver200k;

  /// No description provided for @searchFilterEndingSoon.
  ///
  /// In en, this message translates to:
  /// **'Ending soon'**
  String get searchFilterEndingSoon;

  /// No description provided for @searchFilterBuyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy now'**
  String get searchFilterBuyNow;

  /// No description provided for @searchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get searchResultsTitle;

  /// No description provided for @searchResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live auctions are filtered in real time from your current query.'**
  String get searchResultsSubtitle;

  /// No description provided for @searchLayoutGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get searchLayoutGrid;

  /// No description provided for @searchLayoutList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get searchLayoutList;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No auctions match yet'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Try widening your search or return when more listings go live.'**
  String get searchEmptyDescription;

  /// No description provided for @searchErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load search results right now. Try again shortly.'**
  String get searchErrorDescription;

  /// No description provided for @searchResetAction.
  ///
  /// In en, this message translates to:
  /// **'Clear query'**
  String get searchResetAction;

  /// No description provided for @searchResetFiltersAction.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get searchResetFiltersAction;

  /// No description provided for @loginHeroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Trusted access'**
  String get loginHeroEyebrow;

  /// No description provided for @loginHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a quieter marketplace for serious bidding.'**
  String get loginHeroTitle;

  /// No description provided for @loginHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in with a supported provider to restore your session, inbox, orders, and selling tools securely.'**
  String get loginHeroDescription;

  /// No description provided for @loginContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginContinueGoogle;

  /// No description provided for @loginContinueApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get loginContinueApple;

  /// No description provided for @loginSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Signing you in...'**
  String get loginSubmitting;

  /// No description provided for @loginReturnNotice.
  ///
  /// In en, this message translates to:
  /// **'After sign-in, you\'ll go back to the screen you requested.'**
  String get loginReturnNotice;

  /// No description provided for @loginTrustNote.
  ///
  /// In en, this message translates to:
  /// **'Only Apple and Google sign-in are available in v1.'**
  String get loginTrustNote;

  /// No description provided for @loginEmulatorWarning.
  ///
  /// In en, this message translates to:
  /// **'When Firebase Emulator mode is on, this build does not run the mobile Google or Apple browser sign-in flow. Run with USE_FIREBASE_EMULATORS=false to verify real social sign-in.'**
  String get loginEmulatorWarning;

  /// No description provided for @loginEmulatorUnsupportedProvider.
  ///
  /// In en, this message translates to:
  /// **'This build is connected to Firebase Auth Emulator, so it cannot complete the mobile Google or Apple browser sign-in flow. Run again with USE_FIREBASE_EMULATORS=false to verify real social sign-in.'**
  String get loginEmulatorUnsupportedProvider;

  /// No description provided for @loginGenericError.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Check your Firebase project setup and try again.'**
  String get loginGenericError;

  /// No description provided for @loginErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get loginErrorNetwork;

  /// No description provided for @loginErrorProviderDisabled.
  ///
  /// In en, this message translates to:
  /// **'That sign-in provider is not enabled in Firebase Auth yet.'**
  String get loginErrorProviderDisabled;

  /// No description provided for @loginErrorAccountExists.
  ///
  /// In en, this message translates to:
  /// **'This account already exists with a different sign-in method.'**
  String get loginErrorAccountExists;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTitle;

  /// No description provided for @activityHeroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'At-a-glance status'**
  String get activityHeroEyebrow;

  /// No description provided for @activityHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep payment, shipping, and inbox movement in one place.'**
  String get activityHeroTitle;

  /// No description provided for @activityHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Jump to the next operational step quickly instead of hunting across screens.'**
  String get activityHeroDescription;

  /// No description provided for @activityOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders and payments'**
  String get activityOrdersTitle;

  /// No description provided for @activityOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track what needs payment, shipment, or confirmation next.'**
  String get activityOrdersSubtitle;

  /// No description provided for @activityNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Inbox and alerts'**
  String get activityNotificationsTitle;

  /// No description provided for @activityNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open bid, payment, and delivery updates from your inbox.'**
  String get activityNotificationsSubtitle;

  /// No description provided for @activityBuyerCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Buyer queue'**
  String get activityBuyerCardTitle;

  /// No description provided for @activityBuyerCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep up with payment and receipt actions from one place.'**
  String get activityBuyerCardDescription;

  /// No description provided for @activityBuyerPendingPaymentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} orders still need payment confirmation.'**
  String activityBuyerPendingPaymentSubtitle(Object count);

  /// No description provided for @activityBuyerAwaitingReceiptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} delivered orders still need receipt confirmation.'**
  String activityBuyerAwaitingReceiptSubtitle(Object count);

  /// No description provided for @activityBuyerMetricLabel.
  ///
  /// In en, this message translates to:
  /// **'buyer actions pending'**
  String get activityBuyerMetricLabel;

  /// No description provided for @activitySellerCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller queue'**
  String get activitySellerCardTitle;

  /// No description provided for @activitySellerCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Stay on top of shipment handoff after payment clears.'**
  String get activitySellerCardDescription;

  /// No description provided for @activitySellerAwaitingShipmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} paid orders are waiting for shipment details.'**
  String activitySellerAwaitingShipmentSubtitle(Object count);

  /// No description provided for @activitySellerMetricLabel.
  ///
  /// In en, this message translates to:
  /// **'seller actions pending'**
  String get activitySellerMetricLabel;

  /// No description provided for @activityNotificationsCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Unread updates'**
  String get activityNotificationsCardTitle;

  /// No description provided for @activityNotificationsCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Open the inbox when bids, payment, or delivery events need attention.'**
  String get activityNotificationsCardDescription;

  /// No description provided for @activityNotificationsUnreadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} unread updates are waiting in your inbox.'**
  String activityNotificationsUnreadSubtitle(Object count);

  /// No description provided for @activityNotificationsMetricLabel.
  ///
  /// In en, this message translates to:
  /// **'unread alerts'**
  String get activityNotificationsMetricLabel;

  /// No description provided for @activitySignedOutDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your live order and inbox activity.'**
  String get activitySignedOutDescription;

  /// No description provided for @auctionDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Auction detail'**
  String get auctionDetailTitle;

  /// No description provided for @auctionDetailGalleryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Listing overview'**
  String get auctionDetailGalleryEyebrow;

  /// No description provided for @auctionDetailFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Listing details are on the way'**
  String get auctionDetailFallbackTitle;

  /// No description provided for @auctionDetailFallbackDescription.
  ///
  /// In en, this message translates to:
  /// **'When this auction document is available, images, seller trust, and bid history will appear in this layout.'**
  String get auctionDetailFallbackDescription;

  /// No description provided for @auctionDetailCurrentBid.
  ///
  /// In en, this message translates to:
  /// **'Current bid'**
  String get auctionDetailCurrentBid;

  /// No description provided for @auctionDetailBuyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy now'**
  String get auctionDetailBuyNow;

  /// No description provided for @auctionDetailSellerSummary.
  ///
  /// In en, this message translates to:
  /// **'Seller summary'**
  String get auctionDetailSellerSummary;

  /// No description provided for @auctionDetailSellerDescription.
  ///
  /// In en, this message translates to:
  /// **'Trust signals, category fit, and shipping readiness stay visible before you place a bid.'**
  String get auctionDetailSellerDescription;

  /// No description provided for @auctionDetailBidHistory.
  ///
  /// In en, this message translates to:
  /// **'Bid history'**
  String get auctionDetailBidHistory;

  /// No description provided for @auctionDetailBidHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recent price movement is presented without extra noise.'**
  String get auctionDetailBidHistorySubtitle;

  /// No description provided for @auctionDetailNoBidHistory.
  ///
  /// In en, this message translates to:
  /// **'Bid updates will appear after the first accepted bid.'**
  String get auctionDetailNoBidHistory;

  /// No description provided for @auctionDetailActionHint.
  ///
  /// In en, this message translates to:
  /// **'Bidding and instant purchase actions appear here as soon as a live auction record is available.'**
  String get auctionDetailActionHint;

  /// No description provided for @auctionDetailBrowseAction.
  ///
  /// In en, this message translates to:
  /// **'Browse live auctions'**
  String get auctionDetailBrowseAction;

  /// No description provided for @auctionDetailLiveActionHint.
  ///
  /// In en, this message translates to:
  /// **'Next accepted bid starts at {minimumBid}. Auction closes {endAt}.'**
  String auctionDetailLiveActionHint(Object minimumBid, Object endAt);

  /// No description provided for @auctionDetailSellerOwnedHint.
  ///
  /// In en, this message translates to:
  /// **'Your listing is live until {endAt}. Buyer actions stay active on this screen.'**
  String auctionDetailSellerOwnedHint(Object endAt);

  /// No description provided for @auctionDetailSellerOwnedFallback.
  ///
  /// In en, this message translates to:
  /// **'Your listing is live. Order and settlement updates will appear when a buyer closes the auction.'**
  String get auctionDetailSellerOwnedFallback;

  /// No description provided for @auctionDetailSellerOwnedAction.
  ///
  /// In en, this message translates to:
  /// **'Review orders'**
  String get auctionDetailSellerOwnedAction;

  /// No description provided for @auctionDetailOrderReadyHint.
  ///
  /// In en, this message translates to:
  /// **'This auction already has an order. Open the order timeline to continue payment or fulfillment.'**
  String get auctionDetailOrderReadyHint;

  /// No description provided for @auctionDetailEndedHint.
  ///
  /// In en, this message translates to:
  /// **'This auction is no longer open for bidding. Browse other live listings instead.'**
  String get auctionDetailEndedHint;

  /// No description provided for @auctionDetailViewOrder.
  ///
  /// In en, this message translates to:
  /// **'Open order timeline'**
  String get auctionDetailViewOrder;

  /// No description provided for @auctionDetailLoginHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to place bids, set an auto-bid ceiling, or complete buy now.'**
  String get auctionDetailLoginHint;

  /// No description provided for @auctionDetailSignInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in to bid'**
  String get auctionDetailSignInAction;

  /// No description provided for @auctionDetailBidAction.
  ///
  /// In en, this message translates to:
  /// **'Bid from {amount}'**
  String auctionDetailBidAction(Object amount);

  /// No description provided for @auctionDetailBuyNowAction.
  ///
  /// In en, this message translates to:
  /// **'Buy now {amount}'**
  String auctionDetailBuyNowAction(Object amount);

  /// No description provided for @auctionDetailAutoBidAction.
  ///
  /// In en, this message translates to:
  /// **'Set auto-bid ceiling'**
  String get auctionDetailAutoBidAction;

  /// No description provided for @auctionDetailBidDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Place a bid'**
  String get auctionDetailBidDialogTitle;

  /// No description provided for @auctionDetailBidAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Bid amount'**
  String get auctionDetailBidAmountLabel;

  /// No description provided for @auctionDetailBidAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your offer in KRW'**
  String get auctionDetailBidAmountHint;

  /// No description provided for @auctionDetailAutoBidDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Set auto-bid ceiling'**
  String get auctionDetailAutoBidDialogTitle;

  /// No description provided for @auctionDetailAutoBidAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Maximum auto-bid'**
  String get auctionDetailAutoBidAmountLabel;

  /// No description provided for @auctionDetailAutoBidAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Highest amount you want the system to defend'**
  String get auctionDetailAutoBidAmountHint;

  /// No description provided for @auctionDetailBidMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum accepted amount: {amount}'**
  String auctionDetailBidMinimum(Object amount);

  /// No description provided for @auctionDetailAutoBidHint.
  ///
  /// In en, this message translates to:
  /// **'The auto-bid ceiling must start at or above {amount}. The system raises only as needed.'**
  String auctionDetailAutoBidHint(Object amount);

  /// No description provided for @auctionDetailDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get auctionDetailDialogCancel;

  /// No description provided for @auctionDetailDialogSubmitBid.
  ///
  /// In en, this message translates to:
  /// **'Submit bid'**
  String get auctionDetailDialogSubmitBid;

  /// No description provided for @auctionDetailDialogSubmitAutoBid.
  ///
  /// In en, this message translates to:
  /// **'Save auto-bid'**
  String get auctionDetailDialogSubmitAutoBid;

  /// No description provided for @auctionDetailActionSuccessBid.
  ///
  /// In en, this message translates to:
  /// **'Your bid was submitted.'**
  String get auctionDetailActionSuccessBid;

  /// No description provided for @auctionDetailActionSuccessAutoBid.
  ///
  /// In en, this message translates to:
  /// **'Your auto-bid ceiling was saved.'**
  String get auctionDetailActionSuccessAutoBid;

  /// No description provided for @auctionDetailActionSuccessBuyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy now is complete. Continue in the order timeline.'**
  String get auctionDetailActionSuccessBuyNow;

  /// No description provided for @auctionDetailActionFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete that auction action. Try again.'**
  String get auctionDetailActionFailed;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @ordersBuyerTitle.
  ///
  /// In en, this message translates to:
  /// **'Buying'**
  String get ordersBuyerTitle;

  /// No description provided for @ordersSellerTitle.
  ///
  /// In en, this message translates to:
  /// **'Selling'**
  String get ordersSellerTitle;

  /// No description provided for @ordersBuyerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Payments, shipments, and confirmations for purchases you made.'**
  String get ordersBuyerSubtitle;

  /// No description provided for @ordersSellerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shipment and settlement progress for the auctions you sold.'**
  String get ordersSellerSubtitle;

  /// No description provided for @ordersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No order activity yet'**
  String get ordersEmptyTitle;

  /// No description provided for @ordersEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Once a payment starts or a sale closes, the timeline will appear here.'**
  String get ordersEmptyDescription;

  /// No description provided for @ordersErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your orders right now. Try again in a moment.'**
  String get ordersErrorDescription;

  /// No description provided for @ordersHighlightedLabel.
  ///
  /// In en, this message translates to:
  /// **'Focused order'**
  String get ordersHighlightedLabel;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsHeroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get notificationsHeroEyebrow;

  /// No description provided for @notificationsHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Important changes, without noisy blue alerts.'**
  String get notificationsHeroTitle;

  /// No description provided for @notificationsHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Unread updates stay visible so you can move straight to the next relevant screen.'**
  String get notificationsHeroDescription;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your inbox is quiet'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Bid, payment, and shipment updates will land here as soon as activity begins.'**
  String get notificationsEmptyDescription;

  /// No description provided for @myTitle.
  ///
  /// In en, this message translates to:
  /// **'My'**
  String get myTitle;

  /// No description provided for @myHeroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Profile and trust'**
  String get myHeroEyebrow;

  /// No description provided for @myHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your profile ready for buying and selling.'**
  String get myHeroTitle;

  /// No description provided for @myHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Verification, seller momentum, and account preferences should feel close at hand, not buried in settings.'**
  String get myHeroDescription;

  /// No description provided for @mySignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get mySignedInAs;

  /// No description provided for @myVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification status'**
  String get myVerificationTitle;

  /// No description provided for @myVerificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Review the trust checks that shape how confidently others trade with you.'**
  String get myVerificationDescription;

  /// No description provided for @myVerificationPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get myVerificationPhone;

  /// No description provided for @myVerificationIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get myVerificationIdentity;

  /// No description provided for @myVerificationSeller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get myVerificationSeller;

  /// No description provided for @mySessionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load profile details yet.'**
  String get mySessionUnavailable;

  /// No description provided for @myEnvironmentLabel.
  ///
  /// In en, this message translates to:
  /// **'{environment} · {platform}'**
  String myEnvironmentLabel(Object environment, Object platform);

  /// No description provided for @mySignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get mySignOut;

  /// No description provided for @sellTitle.
  ///
  /// In en, this message translates to:
  /// **'Start selling'**
  String get sellTitle;

  /// No description provided for @sellHeroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Seller studio'**
  String get sellHeroEyebrow;

  /// No description provided for @sellHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Shape a listing that feels deliberate before it goes live.'**
  String get sellHeroTitle;

  /// No description provided for @sellHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Walk through the item story, pricing, schedule, and images with a cleaner publishing rhythm.'**
  String get sellHeroDescription;

  /// No description provided for @sellPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Auction timing policy'**
  String get sellPolicyTitle;

  /// No description provided for @sellPolicyDescription.
  ///
  /// In en, this message translates to:
  /// **'A bid placed within the last five minutes extends the closing time by five minutes, up to three times.'**
  String get sellPolicyDescription;

  /// No description provided for @sellStepCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get sellStepCategoryTitle;

  /// No description provided for @sellStepCategoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Start in the right path for goods or precious items so the required fields stay aligned.'**
  String get sellStepCategoryDescription;

  /// No description provided for @sellStepDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Describe the item clearly'**
  String get sellStepDetailsTitle;

  /// No description provided for @sellStepDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'Title, condition, tags, and description should make the listing easy to trust at a glance.'**
  String get sellStepDetailsDescription;

  /// No description provided for @sellStepPricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Set price and schedule'**
  String get sellStepPricingTitle;

  /// No description provided for @sellStepPricingDescription.
  ///
  /// In en, this message translates to:
  /// **'Start price, buy-now price, and closing time need to communicate urgency without confusion.'**
  String get sellStepPricingDescription;

  /// No description provided for @sellStepImagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare image coverage'**
  String get sellStepImagesTitle;

  /// No description provided for @sellStepImagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Main photos and any required authentication images should feel complete before publishing.'**
  String get sellStepImagesDescription;

  /// No description provided for @sellStepPublishTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview and publish'**
  String get sellStepPublishTitle;

  /// No description provided for @sellStepPublishDescription.
  ///
  /// In en, this message translates to:
  /// **'Check the story, pricing, and urgency cues together before you send the auction live.'**
  String get sellStepPublishDescription;

  /// No description provided for @sellDraftsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent drafts'**
  String get sellDraftsTitle;

  /// No description provided for @sellDraftsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Return to saved item content before you publish a live auction.'**
  String get sellDraftsSubtitle;

  /// No description provided for @sellDraftEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved drafts yet'**
  String get sellDraftEmptyTitle;

  /// No description provided for @sellDraftEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Your saved item drafts will appear here when they are written to Firestore.'**
  String get sellDraftEmptyDescription;

  /// No description provided for @sellDraftLoadAction.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get sellDraftLoadAction;

  /// No description provided for @sellDraftUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled item'**
  String get sellDraftUntitled;

  /// No description provided for @sellDraftUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String sellDraftUpdatedAt(Object time);

  /// No description provided for @sellDraftNoTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Timestamp unavailable'**
  String get sellDraftNoTimestamp;

  /// No description provided for @sellCurrentDraftLabel.
  ///
  /// In en, this message translates to:
  /// **'Editing draft #{itemId}'**
  String sellCurrentDraftLabel(Object itemId);

  /// No description provided for @sellCategoryGoods.
  ///
  /// In en, this message translates to:
  /// **'Goods'**
  String get sellCategoryGoods;

  /// No description provided for @sellCategoryPrecious.
  ///
  /// In en, this message translates to:
  /// **'Precious'**
  String get sellCategoryPrecious;

  /// No description provided for @sellFormCategoryMainLabel.
  ///
  /// In en, this message translates to:
  /// **'Main category'**
  String get sellFormCategoryMainLabel;

  /// No description provided for @sellFormCategorySubLabel.
  ///
  /// In en, this message translates to:
  /// **'Category detail'**
  String get sellFormCategorySubLabel;

  /// No description provided for @sellFormTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Item title'**
  String get sellFormTitleLabel;

  /// No description provided for @sellFormConditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get sellFormConditionLabel;

  /// No description provided for @sellFormTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get sellFormTagsLabel;

  /// No description provided for @sellFormTagsHint.
  ///
  /// In en, this message translates to:
  /// **'Brand, material, size'**
  String get sellFormTagsHint;

  /// No description provided for @sellFormDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get sellFormDescriptionLabel;

  /// No description provided for @sellFormAppraisalLabel.
  ///
  /// In en, this message translates to:
  /// **'Request appraisal workflow'**
  String get sellFormAppraisalLabel;

  /// No description provided for @sellFormStartPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Start price'**
  String get sellFormStartPriceLabel;

  /// No description provided for @sellFormBuyNowPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Buy now price'**
  String get sellFormBuyNowPriceLabel;

  /// No description provided for @sellFormDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Auction duration'**
  String get sellFormDurationLabel;

  /// No description provided for @sellDurationDays.
  ///
  /// In en, this message translates to:
  /// **'{count} day window'**
  String sellDurationDays(int count);

  /// No description provided for @sellImageMainTitle.
  ///
  /// In en, this message translates to:
  /// **'Listing gallery'**
  String get sellImageMainTitle;

  /// No description provided for @sellImageMainDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload up to 10 main images for the public auction card and detail page.'**
  String get sellImageMainDescription;

  /// No description provided for @sellImageMainAction.
  ///
  /// In en, this message translates to:
  /// **'Choose gallery images'**
  String get sellImageMainAction;

  /// No description provided for @sellImageAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Authentication images'**
  String get sellImageAuthTitle;

  /// No description provided for @sellImageAuthDescription.
  ///
  /// In en, this message translates to:
  /// **'Goods listings require at least one authentication image before draft save and publish.'**
  String get sellImageAuthDescription;

  /// No description provided for @sellImageAuthAction.
  ///
  /// In en, this message translates to:
  /// **'Choose authentication images'**
  String get sellImageAuthAction;

  /// No description provided for @sellImagesEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No images selected yet.'**
  String get sellImagesEmptyState;

  /// No description provided for @sellSaveDraftAction.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get sellSaveDraftAction;

  /// No description provided for @sellPublishAction.
  ///
  /// In en, this message translates to:
  /// **'Publish auction'**
  String get sellPublishAction;

  /// No description provided for @sellSavingDraft.
  ///
  /// In en, this message translates to:
  /// **'Saving draft...'**
  String get sellSavingDraft;

  /// No description provided for @sellPublishing.
  ///
  /// In en, this message translates to:
  /// **'Publishing...'**
  String get sellPublishing;

  /// No description provided for @sellActionSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved to your seller workspace.'**
  String get sellActionSaved;

  /// No description provided for @sellActionPublished.
  ///
  /// In en, this message translates to:
  /// **'Auction published. Opening the live listing now.'**
  String get sellActionPublished;

  /// No description provided for @sellActionFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete that seller action. Check the form and try again.'**
  String get sellActionFailed;

  /// No description provided for @sellValidationCategorySub.
  ///
  /// In en, this message translates to:
  /// **'Add a category detail before saving the draft.'**
  String get sellValidationCategorySub;

  /// No description provided for @sellValidationTitle.
  ///
  /// In en, this message translates to:
  /// **'Add an item title before saving the draft.'**
  String get sellValidationTitle;

  /// No description provided for @sellValidationCondition.
  ///
  /// In en, this message translates to:
  /// **'Add the item condition before saving the draft.'**
  String get sellValidationCondition;

  /// No description provided for @sellValidationDescription.
  ///
  /// In en, this message translates to:
  /// **'Add the item description before saving the draft.'**
  String get sellValidationDescription;

  /// No description provided for @sellValidationAuthImages.
  ///
  /// In en, this message translates to:
  /// **'Goods drafts need at least one authentication image.'**
  String get sellValidationAuthImages;

  /// No description provided for @sellValidationImages.
  ///
  /// In en, this message translates to:
  /// **'Publishing requires at least one gallery image.'**
  String get sellValidationImages;

  /// No description provided for @sellValidationStartPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid start price before publishing.'**
  String get sellValidationStartPrice;

  /// No description provided for @sellValidationBuyNowPrice.
  ///
  /// In en, this message translates to:
  /// **'Buy now price must be greater than the start price.'**
  String get sellValidationBuyNowPrice;

  /// No description provided for @genericUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get genericUnavailable;

  /// No description provided for @genericUnknownSeller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get genericUnknownSeller;

  /// No description provided for @genericUnknownUser.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get genericUnknownUser;

  /// No description provided for @genericStateVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get genericStateVerified;

  /// No description provided for @genericStatePending.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get genericStatePending;

  /// No description provided for @genericStateRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get genericStateRejected;

  /// No description provided for @genericStateUnverified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get genericStateUnverified;

  /// No description provided for @genericOrderAwaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment'**
  String get genericOrderAwaitingPayment;

  /// No description provided for @genericOrderPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid and held'**
  String get genericOrderPaid;

  /// No description provided for @genericOrderShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get genericOrderShipped;

  /// No description provided for @genericOrderConfirmedReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt confirmed'**
  String get genericOrderConfirmedReceipt;

  /// No description provided for @genericOrderSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get genericOrderSettled;

  /// No description provided for @genericOrderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get genericOrderCancelled;

  /// No description provided for @genericOrderProcessing.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get genericOrderProcessing;

  /// No description provided for @genericCountBids.
  ///
  /// In en, this message translates to:
  /// **'{count} bids'**
  String genericCountBids(int count);

  /// No description provided for @genericEndsAt.
  ///
  /// In en, this message translates to:
  /// **'Ends {time}'**
  String genericEndsAt(Object time);

  /// No description provided for @genericCountdownExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get genericCountdownExpired;

  /// No description provided for @genericCountdownLessThanMinute.
  ///
  /// In en, this message translates to:
  /// **'under 1m left'**
  String get genericCountdownLessThanMinute;

  /// No description provided for @genericCountdownMinutesRemaining.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m left'**
  String genericCountdownMinutesRemaining(int minutes);

  /// No description provided for @genericCountdownHoursRemaining.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m left'**
  String genericCountdownHoursRemaining(int hours, int minutes);

  /// No description provided for @genericCountdownDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days}d {hours}h left'**
  String genericCountdownDaysRemaining(int days, int hours);

  /// No description provided for @genericUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String genericUnreadCount(int count);

  /// No description provided for @loginDevAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick access for emulator checks'**
  String get loginDevAccessTitle;

  /// No description provided for @loginDevAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the seeded buyer and seller accounts only for local smoke tests in dev emulator mode.'**
  String get loginDevAccessDescription;

  /// No description provided for @loginDevBuyer.
  ///
  /// In en, this message translates to:
  /// **'Sign in as seeded buyer'**
  String get loginDevBuyer;

  /// No description provided for @loginDevSeller.
  ///
  /// In en, this message translates to:
  /// **'Sign in as seeded seller'**
  String get loginDevSeller;

  /// No description provided for @loginErrorSeedAccountUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The seeded emulator account is unavailable. Start the emulators and run npm run seed again.'**
  String get loginErrorSeedAccountUnavailable;

  /// No description provided for @ordersActionAddShipment.
  ///
  /// In en, this message translates to:
  /// **'Add shipment'**
  String get ordersActionAddShipment;

  /// No description provided for @ordersActionPreparePayment.
  ///
  /// In en, this message translates to:
  /// **'Continue payment'**
  String get ordersActionPreparePayment;

  /// No description provided for @ordersActionConfirmReceipt.
  ///
  /// In en, this message translates to:
  /// **'Confirm receipt'**
  String get ordersActionConfirmReceipt;

  /// No description provided for @ordersPaymentSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete payment'**
  String get ordersPaymentSheetTitle;

  /// No description provided for @ordersPaymentSheetDevDescription.
  ///
  /// In en, this message translates to:
  /// **'This dev order can complete payment entirely through the server-driven dummy flow. Confirm once to move the order into paid escrow hold.'**
  String get ordersPaymentSheetDevDescription;

  /// No description provided for @ordersPaymentSheetReadyDescription.
  ///
  /// In en, this message translates to:
  /// **'This order already has the payment return path prepared. Review the session details before you continue outside the app.'**
  String get ordersPaymentSheetReadyDescription;

  /// No description provided for @ordersPaymentSheetBlockedDescription.
  ///
  /// In en, this message translates to:
  /// **'This order can still be confirmed from a returned payment result. If you already completed Toss checkout elsewhere, enter the payment key below.'**
  String get ordersPaymentSheetBlockedDescription;

  /// No description provided for @ordersPaymentSheetStatusDev.
  ///
  /// In en, this message translates to:
  /// **'Dev dummy payment'**
  String get ordersPaymentSheetStatusDev;

  /// No description provided for @ordersPaymentSheetStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Return path prepared'**
  String get ordersPaymentSheetStatusReady;

  /// No description provided for @ordersPaymentSheetStatusBlocked.
  ///
  /// In en, this message translates to:
  /// **'Manual recovery path'**
  String get ordersPaymentSheetStatusBlocked;

  /// No description provided for @ordersPaymentSheetNextStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get ordersPaymentSheetNextStepTitle;

  /// No description provided for @ordersPaymentSheetNextStepDev.
  ///
  /// In en, this message translates to:
  /// **'Complete payment in-app once, then move to shipping and receipt from the order timeline.'**
  String get ordersPaymentSheetNextStepDev;

  /// No description provided for @ordersPaymentSheetNextStepReady.
  ///
  /// In en, this message translates to:
  /// **'Finish Toss checkout outside this build, then return with the payment result so the order can be confirmed here.'**
  String get ordersPaymentSheetNextStepReady;

  /// No description provided for @ordersPaymentSheetNextStepBlocked.
  ///
  /// In en, this message translates to:
  /// **'Keep the order timeline open as your recovery point. When Toss checkout finishes elsewhere, come back with the returned payment key to confirm the order here.'**
  String get ordersPaymentSheetNextStepBlocked;

  /// No description provided for @ordersPaymentFallbackHint.
  ///
  /// In en, this message translates to:
  /// **'If Toss checkout finished outside the app, return with the payment key and continue from this order card.'**
  String get ordersPaymentFallbackHint;

  /// No description provided for @ordersPaymentReturnPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Finalizing payment'**
  String get ordersPaymentReturnPendingTitle;

  /// No description provided for @ordersPaymentReturnPendingDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'re validating the returned payment result and moving the order into the paid timeline.'**
  String get ordersPaymentReturnPendingDescription;

  /// No description provided for @ordersPaymentReturnSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed'**
  String get ordersPaymentReturnSuccessTitle;

  /// No description provided for @ordersPaymentReturnSuccessDescription.
  ///
  /// In en, this message translates to:
  /// **'The order is now in paid escrow hold. Continue in the order timeline for shipping and receipt updates.'**
  String get ordersPaymentReturnSuccessDescription;

  /// No description provided for @ordersPaymentReturnFailTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment was not completed'**
  String get ordersPaymentReturnFailTitle;

  /// No description provided for @ordersPaymentReturnFailDescription.
  ///
  /// In en, this message translates to:
  /// **'Return to the order timeline to retry payment or review the latest status.'**
  String get ordersPaymentReturnFailDescription;

  /// No description provided for @ordersPaymentReturnInvalidTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment return data is incomplete'**
  String get ordersPaymentReturnInvalidTitle;

  /// No description provided for @ordersPaymentReturnInvalidDescription.
  ///
  /// In en, this message translates to:
  /// **'This return route needs order, payment, and amount details before the order can be confirmed.'**
  String get ordersPaymentReturnInvalidDescription;

  /// No description provided for @ordersPaymentReturnCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Return code · {code}'**
  String ordersPaymentReturnCodeLabel(Object code);

  /// No description provided for @ordersPaymentReturnActionOpenOrder.
  ///
  /// In en, this message translates to:
  /// **'Open order timeline'**
  String get ordersPaymentReturnActionOpenOrder;

  /// No description provided for @ordersPaymentReturnActionBackToOrders.
  ///
  /// In en, this message translates to:
  /// **'Back to orders'**
  String get ordersPaymentReturnActionBackToOrders;

  /// No description provided for @ordersPaymentCompleteDevAction.
  ///
  /// In en, this message translates to:
  /// **'Complete dev payment'**
  String get ordersPaymentCompleteDevAction;

  /// No description provided for @ordersPaymentEnterKeyAction.
  ///
  /// In en, this message translates to:
  /// **'Enter payment key'**
  String get ordersPaymentEnterKeyAction;

  /// No description provided for @ordersPaymentConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm payment'**
  String get ordersPaymentConfirmTitle;

  /// No description provided for @ordersPaymentConfirmDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the Toss payment key that came back from checkout to move the order into paid escrow hold.'**
  String get ordersPaymentConfirmDescription;

  /// No description provided for @ordersPaymentConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm payment'**
  String get ordersPaymentConfirmAction;

  /// No description provided for @ordersPaymentKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment key'**
  String get ordersPaymentKeyLabel;

  /// No description provided for @ordersPaymentKeyHint.
  ///
  /// In en, this message translates to:
  /// **'pay_...'**
  String get ordersPaymentKeyHint;

  /// No description provided for @ordersPaymentKeyRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Enter the payment key to continue.'**
  String get ordersPaymentKeyRequiredError;

  /// No description provided for @ordersPaymentAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount · {amount}'**
  String ordersPaymentAmountLabel(Object amount);

  /// No description provided for @ordersPaymentProviderLabel.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get ordersPaymentProviderLabel;

  /// No description provided for @ordersPaymentEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer email'**
  String get ordersPaymentEmailLabel;

  /// No description provided for @ordersPaymentDueIn.
  ///
  /// In en, this message translates to:
  /// **'Payment due in {remaining}'**
  String ordersPaymentDueIn(Object remaining);

  /// No description provided for @ordersPaymentExpired.
  ///
  /// In en, this message translates to:
  /// **'Payment window expired'**
  String get ordersPaymentExpired;

  /// No description provided for @ordersPaymentDevKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Dev payment key · {paymentKey}'**
  String ordersPaymentDevKeyLabel(Object paymentKey);

  /// No description provided for @ordersPaymentSuccessUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Success URL · {url}'**
  String ordersPaymentSuccessUrlLabel(Object url);

  /// No description provided for @ordersPaymentFailUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Fail URL · {url}'**
  String ordersPaymentFailUrlLabel(Object url);

  /// No description provided for @ordersShipmentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipment details'**
  String get ordersShipmentDialogTitle;

  /// No description provided for @ordersShipmentCarrierLabel.
  ///
  /// In en, this message translates to:
  /// **'Carrier'**
  String get ordersShipmentCarrierLabel;

  /// No description provided for @ordersShipmentCarrierHint.
  ///
  /// In en, this message translates to:
  /// **'CJ Logistics'**
  String get ordersShipmentCarrierHint;

  /// No description provided for @ordersShipmentCarrierRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Enter a carrier name.'**
  String get ordersShipmentCarrierRequiredError;

  /// No description provided for @ordersShipmentTrackingLabel.
  ///
  /// In en, this message translates to:
  /// **'Tracking number'**
  String get ordersShipmentTrackingLabel;

  /// No description provided for @ordersShipmentTrackingHint.
  ///
  /// In en, this message translates to:
  /// **'1234567890'**
  String get ordersShipmentTrackingHint;

  /// No description provided for @ordersShipmentTrackingRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Enter a tracking number.'**
  String get ordersShipmentTrackingRequiredError;

  /// No description provided for @ordersShipmentSubmit.
  ///
  /// In en, this message translates to:
  /// **'Save shipment'**
  String get ordersShipmentSubmit;

  /// No description provided for @ordersDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get ordersDialogCancel;

  /// No description provided for @ordersActionSuccessShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipment details were saved.'**
  String get ordersActionSuccessShipped;

  /// No description provided for @ordersActionSuccessPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed. The order is now held in escrow.'**
  String get ordersActionSuccessPayment;

  /// No description provided for @ordersActionSuccessReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt confirmed. Settlement can proceed next.'**
  String get ordersActionSuccessReceipt;

  /// No description provided for @ordersActionFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete that order action. Try again.'**
  String get ordersActionFailed;

  /// No description provided for @ordersShipmentSummary.
  ///
  /// In en, this message translates to:
  /// **'{carrierName} · {trackingNumber}'**
  String ordersShipmentSummary(Object carrierName, Object trackingNumber);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ko': return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
