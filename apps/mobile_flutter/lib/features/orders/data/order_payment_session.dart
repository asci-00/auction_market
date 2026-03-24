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
    return OrderPaymentSession(
      provider: (data['provider'] as String?) ?? 'TOSS_PAYMENTS',
      orderId: (data['orderId'] as String?) ?? '',
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      orderName: (data['orderName'] as String?) ?? '',
      customerName: data['customerName'] as String?,
      customerEmail: data['customerEmail'] as String?,
      successUrl: data['successUrl'] as String?,
      failUrl: data['failUrl'] as String?,
    );
  }

  bool get hasCheckoutHandoff =>
      (successUrl?.isNotEmpty ?? false) && (failUrl?.isNotEmpty ?? false);
}
