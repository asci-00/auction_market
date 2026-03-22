import 'package:cloud_firestore/cloud_firestore.dart';

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.paymentStatus,
    required this.orderStatus,
    required this.finalPrice,
    required this.paymentDueAt,
    required this.carrierName,
    required this.trackingNumber,
  });

  final String id;
  final String paymentStatus;
  final String orderStatus;
  final num finalPrice;
  final DateTime? paymentDueAt;
  final String? carrierName;
  final String? trackingNumber;

  factory OrderSummary.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final shipping = (data['shipping'] as Map<String, dynamic>?) ?? const {};

    return OrderSummary(
      id: document.id,
      paymentStatus: (data['paymentStatus'] as String?) ?? 'PENDING',
      orderStatus: (data['orderStatus'] as String?) ?? 'PENDING',
      finalPrice: (data['finalPrice'] as num?) ?? 0,
      paymentDueAt: (data['paymentDueAt'] as Timestamp?)?.toDate(),
      carrierName: shipping['carrierName'] as String?,
      trackingNumber: shipping['trackingNumber'] as String?,
    );
  }

  bool get hasShipmentSummary =>
      carrierName != null &&
      carrierName!.isNotEmpty &&
      trackingNumber != null &&
      trackingNumber!.isNotEmpty;
}
