import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_config/app_config.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../data/order_payment_session.dart';

enum OrderPaymentHandoffMode {
  devDummy,
  launcherReady,
  manualConfirm,
}

class OrderPaymentHandoffPlan {
  const OrderPaymentHandoffPlan({
    required this.mode,
    this.paymentKey,
  }) : assert(
          mode != OrderPaymentHandoffMode.devDummy ||
              (paymentKey != null && paymentKey != ''),
          'devDummy mode requires a paymentKey',
        );

  final OrderPaymentHandoffMode mode;
  final String? paymentKey;

  bool get isDevDummy => mode == OrderPaymentHandoffMode.devDummy;
  bool get isLauncherReady => mode == OrderPaymentHandoffMode.launcherReady;
  bool get usesManualFallback => mode == OrderPaymentHandoffMode.manualConfirm;
  bool get requiresManualConfirmation => !isDevDummy;
}

final orderPaymentHandoffServiceProvider =
    Provider<OrderPaymentHandoffService>((ref) {
  final config = ref.watch(appBootstrapProvider).requireValue.config;
  return OrderPaymentHandoffService(config);
});

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

    if (session.isRealTossReady && _config.hasMeaningfulTossClientKey) {
      return const OrderPaymentHandoffPlan(
        mode: OrderPaymentHandoffMode.launcherReady,
      );
    }

    return const OrderPaymentHandoffPlan(
      mode: OrderPaymentHandoffMode.manualConfirm,
    );
  }
}
