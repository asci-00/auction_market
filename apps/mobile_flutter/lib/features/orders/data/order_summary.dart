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
    return OrderSummary.fromMap({'id': document.id, ...document.data()});
  }

  factory OrderSummary.fromMap(Map<String, dynamic> data) {
    final shipping = (data['shipping'] as Map<String, dynamic>?) ?? const {};

    return OrderSummary(
      id: data['id'] as String? ?? '',
      paymentStatus: (data['paymentStatus'] as String?) ?? 'PENDING',
      orderStatus: (data['orderStatus'] as String?) ?? 'PENDING',
      finalPrice: (data['finalPrice'] as num?) ?? 0,
      paymentDueAt: _dateTimeFromPayload(data['paymentDueAt']),
      carrierName: shipping['carrierName'] as String?,
      trackingNumber: shipping['trackingNumber'] as String?,
    );
  }

  bool get hasShipmentSummary =>
      (carrierName?.isNotEmpty ?? false) &&
      (trackingNumber?.isNotEmpty ?? false);
}

DateTime? _dateTimeFromPayload(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  return null;
}
