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

  String _requireNonEmpty({required String field, required String? value}) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      throw StateError('$field is required to launch Toss checkout.');
    }
    return normalized;
  }

  Uri buildCheckoutUri(OrderPaymentSession session) {
    final checkoutBase = _requireNonEmpty(
      field: 'checkoutUrl',
      value: session.checkoutUrl,
    );
    final clientKey = _requireNonEmpty(
      field: 'tossClientKey',
      value: _config.tossClientKey,
    );
    final customerKey = _requireNonEmpty(
      field: 'customerKey',
      value: session.customerKey,
    );
    final successUrl = _requireNonEmpty(
      field: 'successUrl',
      value: session.successUrl,
    );
    final failUrl = _requireNonEmpty(field: 'failUrl', value: session.failUrl);

    final baseUri = Uri.parse(checkoutBase);
    final queryParameters = <String, String>{
      ...baseUri.queryParameters,
      'clientKey': clientKey,
      'customerKey': customerKey,
      'orderId': session.orderId,
      'amount': session.amount.toString(),
      'orderName': session.orderName,
      'successUrl': successUrl,
      'failUrl': failUrl,
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
