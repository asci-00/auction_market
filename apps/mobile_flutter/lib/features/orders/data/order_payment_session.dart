class OrderPaymentSession {
  const OrderPaymentSession({
    required this.provider,
    required this.orderId,
    required this.amount,
    required this.orderName,
    required this.customerName,
    required this.customerEmail,
    required this.successUrl,
    required this.failUrl,
  });

  final String provider;
  final String orderId;
  final int amount;
  final String orderName;
  final String? customerName;
  final String? customerEmail;
  final String? successUrl;
  final String? failUrl;

  factory OrderPaymentSession.fromCallable(Map<dynamic, dynamic> data) {
    String? asNullableString(dynamic value) {
      if (value == null) {
        return null;
      }

      final normalized = value.toString().trim();
      return normalized.isEmpty ? null : normalized;
    }

    int asAmount(dynamic value) {
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value.trim()) ?? 0;
      }
      return 0;
    }

    return OrderPaymentSession(
      provider: asNullableString(data['provider']) ?? 'TOSS_PAYMENTS',
      orderId: asNullableString(data['orderId']) ?? '',
      amount: asAmount(data['amount']),
      orderName: asNullableString(data['orderName']) ?? '',
      customerName: asNullableString(data['customerName']),
      customerEmail: asNullableString(data['customerEmail']),
      successUrl: asNullableString(data['successUrl']),
      failUrl: asNullableString(data['failUrl']),
    );
  }

  bool get hasCheckoutHandoff =>
      (successUrl?.isNotEmpty ?? false) && (failUrl?.isNotEmpty ?? false);
}
