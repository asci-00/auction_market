import 'package:flutter/material.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/l10n/app_formatters.dart';
import '../../../core/l10n/app_localization.dart';

class OrderPaymentConfirmDraft {
  const OrderPaymentConfirmDraft({
    required this.paymentKey,
  });

  final String paymentKey;
}

Future<OrderPaymentConfirmDraft?> showOrderPaymentConfirmDialog(
  BuildContext context, {
  required int amount,
}) async {
  final controller = TextEditingController();

  try {
    return await showDialog<OrderPaymentConfirmDraft>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.ordersPaymentConfirmTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.ordersPaymentConfirmDescription,
                style: dialogContext.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n
                    .ordersPaymentAmountLabel(formatKrw(context, amount)),
                style: dialogContext.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: context.l10n.ordersPaymentKeyLabel,
                  hintText: context.l10n.ordersPaymentKeyHint,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.ordersDialogCancel),
            ),
            FilledButton(
              onPressed: () {
                final paymentKey = controller.text.trim();
                if (paymentKey.isEmpty) {
                  return;
                }
                Navigator.of(dialogContext).pop(
                  OrderPaymentConfirmDraft(paymentKey: paymentKey),
                );
              },
              child: Text(context.l10n.ordersPaymentConfirmAction),
            ),
          ],
        );
      },
    );
  } finally {
    controller.dispose();
  }
}
