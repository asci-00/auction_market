import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_config/app_config.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../data/order_payment_session.dart';

enum OrderPaymentHandoffMode { devDummy, launcherReady, manualConfirm }

class OrderPaymentHandoffPlan {
  const OrderPaymentHandoffPlan({
    required this.mode,
    this.paymentKey,
    this.checkoutUrl,
  }) : assert(
         mode != OrderPaymentHandoffMode.devDummy ||
             (paymentKey != null && paymentKey != ''),
         'devDummy mode requires a paymentKey',
       ),
       assert(
         mode != OrderPaymentHandoffMode.launcherReady ||
             (checkoutUrl != null && checkoutUrl != ''),
         'launcherReady mode requires a checkoutUrl',
       );

  final OrderPaymentHandoffMode mode;
  final String? paymentKey;
  final String? checkoutUrl;

  bool get isDevDummy => mode == OrderPaymentHandoffMode.devDummy;
  bool get isLauncherReady => mode == OrderPaymentHandoffMode.launcherReady;
  bool get usesManualFallback => mode == OrderPaymentHandoffMode.manualConfirm;
  bool get requiresManualConfirmation => !isDevDummy;
}

final orderPaymentHandoffServiceProvider = Provider<OrderPaymentHandoffService>(
  (ref) {
    final bootstrap = ref.watch(appBootstrapProvider).requireValue;
    // Keep this provider bound to bootstrap completion before exposing service.
    return OrderPaymentHandoffService(bootstrap.config);
  },
);

class OrderPaymentHandoffService {
  const OrderPaymentHandoffService(this._config);

  final AppConfig _config;

  OrderPaymentHandoffPlan buildPlan(OrderPaymentSession session) {
    final devPaymentKey = session.devPaymentKey?.trim();
    if (session.isDevDummyMode && devPaymentKey?.isNotEmpty == true) {
      return OrderPaymentHandoffPlan(
        mode: OrderPaymentHandoffMode.devDummy,
        paymentKey: devPaymentKey,
      );
    }

    final tossClientKey = _config.tossClientKey?.trim();
    if (session.isRealTossReady &&
        tossClientKey != null &&
        tossClientKey.isNotEmpty) {
      return OrderPaymentHandoffPlan(
        mode: OrderPaymentHandoffMode.launcherReady,
        checkoutUrl: session.checkoutUrl,
      );
    }

    return const OrderPaymentHandoffPlan(
      mode: OrderPaymentHandoffMode.manualConfirm,
    );
  }
}
