import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_config/app_config.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../data/order_payment_session.dart';

final orderPaymentLauncherServiceProvider =
    Provider<OrderPaymentLauncherService>((ref) {
      final config = ref.watch(appBootstrapProvider).requireValue.config;
      return OrderPaymentLauncherService(config);
    });

class OrderPaymentLauncherService {
  const OrderPaymentLauncherService(this._config);

  final AppConfig _config;

  Uri buildCheckoutUri(OrderPaymentSession session) {
    final checkoutBase = session.checkoutUrl?.trim();
    if (checkoutBase == null || checkoutBase.isEmpty) {
      throw StateError('checkoutUrl is required to launch Toss checkout.');
    }

    final baseUri = Uri.parse(checkoutBase);
    final queryParameters = <String, String>{
      ...baseUri.queryParameters,
      'clientKey': _config.tossClientKey!.trim(),
      'customerKey': session.customerKey!.trim(),
      'orderId': session.orderId,
      'amount': session.amount.toString(),
      'orderName': session.orderName,
      'successUrl': session.successUrl!.trim(),
      'failUrl': session.failUrl!.trim(),
    };

    final customerName = session.customerName?.trim();
    if (customerName != null && customerName.isNotEmpty) {
      queryParameters['customerName'] = customerName;
    }

    final customerEmail = session.customerEmail?.trim();
    if (customerEmail != null && customerEmail.isNotEmpty) {
      queryParameters['customerEmail'] = customerEmail;
    }

    return baseUri.replace(queryParameters: queryParameters);
  }

  Future<void> launchCheckout(OrderPaymentSession session) async {
    final uri = buildCheckoutUri(session);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw StateError('Failed to open Toss checkout.');
    }
  }
}
