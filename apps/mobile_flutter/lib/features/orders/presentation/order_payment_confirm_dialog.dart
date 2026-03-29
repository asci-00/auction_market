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
  return showDialog<OrderPaymentConfirmDraft>(
    context: context,
    builder: (_) => _OrderPaymentConfirmDialog(amount: amount),
  );
}

class _OrderPaymentConfirmDialog extends StatefulWidget {
  const _OrderPaymentConfirmDialog({required this.amount});

  final int amount;

  @override
  State<_OrderPaymentConfirmDialog> createState() =>
      _OrderPaymentConfirmDialogState();
}

class _OrderPaymentConfirmDialogState
    extends State<_OrderPaymentConfirmDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _showValidationError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      title: Text(context.l10n.ordersPaymentConfirmTitle),
      content: AppKeyboardSafeInset(
        useSafeArea: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.ordersPaymentConfirmDescription,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.ordersPaymentAmountLabel(
                formatKrw(context, widget.amount),
              ),
              style: context.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (!_showValidationError) {
                  return;
                }
                setState(() => _showValidationError = false);
              },
              decoration: InputDecoration(
                labelText: context.l10n.ordersPaymentKeyLabel,
                hintText: context.l10n.ordersPaymentKeyHint,
                errorText: _showValidationError
                    ? context.l10n.ordersPaymentKeyRequiredError
                    : null,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.ordersDialogCancel),
        ),
        FilledButton(
          onPressed: () {
            final paymentKey = _controller.text.trim();
            if (paymentKey.isEmpty) {
              setState(() => _showValidationError = true);
              return;
            }
            Navigator.of(
              context,
            ).pop(OrderPaymentConfirmDraft(paymentKey: paymentKey));
          },
          child: Text(context.l10n.ordersPaymentConfirmAction),
        ),
      ],
    );
  }
}
