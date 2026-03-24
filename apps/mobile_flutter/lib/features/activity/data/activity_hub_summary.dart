import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityHubSummary {
  const ActivityHubSummary({
    required this.pendingPaymentCount,
    required this.awaitingReceiptCount,
    required this.awaitingShipmentCount,
    required this.unreadNotificationCount,
  });

  final int pendingPaymentCount;
  final int awaitingReceiptCount;
  final int awaitingShipmentCount;
  final int unreadNotificationCount;

  factory ActivityHubSummary.fromBuyerOrders(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) {
    var pendingPaymentCount = 0;
    var awaitingReceiptCount = 0;

    for (final document in documents) {
      final data = document.data();
      switch (data['orderStatus'] as String? ?? '') {
        case 'AWAITING_PAYMENT':
          pendingPaymentCount += 1;
        case 'SHIPPED':
          awaitingReceiptCount += 1;
      }
    }

    return ActivityHubSummary(
      pendingPaymentCount: pendingPaymentCount,
      awaitingReceiptCount: awaitingReceiptCount,
      awaitingShipmentCount: 0,
      unreadNotificationCount: 0,
    );
  }

  factory ActivityHubSummary.fromSellerOrders(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) {
    var awaitingShipmentCount = 0;

    for (final document in documents) {
      final data = document.data();
      if ((data['orderStatus'] as String? ?? '') == 'PAID_ESCROW_HOLD') {
        awaitingShipmentCount += 1;
      }
    }

    return ActivityHubSummary(
      pendingPaymentCount: 0,
      awaitingReceiptCount: 0,
      awaitingShipmentCount: awaitingShipmentCount,
      unreadNotificationCount: 0,
    );
  }

  factory ActivityHubSummary.fromNotifications(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) {
    var unreadNotificationCount = 0;

    for (final document in documents) {
      final data = document.data();
      if ((data['isRead'] as bool?) != true) {
        unreadNotificationCount += 1;
      }
    }

    return ActivityHubSummary(
      pendingPaymentCount: 0,
      awaitingReceiptCount: 0,
      awaitingShipmentCount: 0,
      unreadNotificationCount: unreadNotificationCount,
    );
  }
}
