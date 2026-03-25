import 'package:flutter/material.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/l10n/app_formatters.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/widgets/app_keyboard_safe_inset.dart';

class OrderPaymentConfirmDraft {
  const OrderPaymentConfirmDraft({required this.paymentKey});

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
        final bottomInset = MediaQuery.viewInsetsOf(dialogContext).bottom;
        var showValidationError = false;

        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              scrollable: true,
              insetPadding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
              title: Text(context.l10n.ordersPaymentConfirmTitle),
              content: AppKeyboardSafeInset(
                useSafeArea: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.ordersPaymentConfirmDescription,
                      style: dialogContext.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.ordersPaymentAmountLabel(
                        formatKrw(context, amount),
                      ),
                      style: dialogContext.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) {
                        if (!showValidationError) {
                          return;
                        }
                        setState(() => showValidationError = false);
                      },
                      decoration: InputDecoration(
                        labelText: context.l10n.ordersPaymentKeyLabel,
                        hintText: context.l10n.ordersPaymentKeyHint,
                        errorText: showValidationError
                            ? context.l10n.ordersPaymentKeyRequiredError
                            : null,
                      ),
                    ),
                  ],
                ),
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
                      setState(() => showValidationError = true);
                      return;
                    }
                    Navigator.of(
                      dialogContext,
                    ).pop(OrderPaymentConfirmDraft(paymentKey: paymentKey));
                  },
                  child: Text(context.l10n.ordersPaymentConfirmAction),
                ),
              ],
            );
          },
        );
      },
    );
  } finally {
    controller.dispose();
  }
}
