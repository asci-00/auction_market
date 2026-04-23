import '../events/app_events.dart';

enum BackendRefreshArea {
  home,
  search,
  auctionDetail,
  orders,
  notifications,
  activity,
  myProfile,
  sellDrafts,
  settingsPreferences,
}

class BackendRefreshEvent extends AppEvent {
  const BackendRefreshEvent({
    required this.areas,
    this.auctionId,
    this.orderId,
  });

  final Set<BackendRefreshArea> areas;
  final String? auctionId;
  final String? orderId;

  bool includes(BackendRefreshArea area) => areas.contains(area);

  bool matchesAuction(String id) {
    // When auctionId is null, auction-detail refresh intentionally fans out
    // to all active auction detail view models.
    return includes(BackendRefreshArea.auctionDetail) &&
        (auctionId == null || auctionId == id);
  }

  static BackendRefreshEvent auctionChanged(String auctionId) {
    return BackendRefreshEvent(
      auctionId: auctionId,
      areas: {
        BackendRefreshArea.auctionDetail,
        BackendRefreshArea.home,
        BackendRefreshArea.search,
        BackendRefreshArea.activity,
      },
    );
  }

  static BackendRefreshEvent buyNowCompleted({
    required String auctionId,
    String? orderId,
  }) {
    return BackendRefreshEvent(
      auctionId: auctionId,
      orderId: orderId,
      areas: {
        BackendRefreshArea.auctionDetail,
        BackendRefreshArea.home,
        BackendRefreshArea.search,
        BackendRefreshArea.orders,
        BackendRefreshArea.activity,
      },
    );
  }

  static BackendRefreshEvent ordersChanged({String? orderId}) {
    return BackendRefreshEvent(
      orderId: orderId,
      areas: {BackendRefreshArea.orders, BackendRefreshArea.activity},
    );
  }

  static const notificationsChanged = BackendRefreshEvent(
    areas: {BackendRefreshArea.notifications, BackendRefreshArea.activity},
  );

  static const sellDraftsChanged = BackendRefreshEvent(
    areas: {BackendRefreshArea.sellDrafts, BackendRefreshArea.myProfile},
  );

  static BackendRefreshEvent auctionPublished(String auctionId) {
    return BackendRefreshEvent(
      auctionId: auctionId,
      areas: {
        BackendRefreshArea.auctionDetail,
        BackendRefreshArea.home,
        BackendRefreshArea.search,
        BackendRefreshArea.sellDrafts,
        BackendRefreshArea.myProfile,
      },
    );
  }

  static const settingsChanged = BackendRefreshEvent(
    areas: {BackendRefreshArea.settingsPreferences},
  );
}
