import 'package:flutter/material.dart';

import '../../../core/l10n/app_localization.dart';
import '../../../core/widgets/app_keyboard_safe_inset.dart';

class ShipmentDraft {
  const ShipmentDraft({
    required this.carrierName,
    required this.trackingNumber,
  });

  final String carrierName;
  final String trackingNumber;
}

Future<ShipmentDraft?> showOrderShipmentDialog(BuildContext context) async {
  return showDialog<ShipmentDraft>(
    context: context,
    builder: (_) => const _OrderShipmentDialog(),
  );
}

class _OrderShipmentDialog extends StatefulWidget {
  const _OrderShipmentDialog();

  @override
  State<_OrderShipmentDialog> createState() => _OrderShipmentDialogState();
}

class _OrderShipmentDialogState extends State<_OrderShipmentDialog> {
  final TextEditingController _carrierController = TextEditingController();
  final TextEditingController _trackingController = TextEditingController();

  @override
  void dispose() {
    _carrierController.dispose();
    _trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AlertDialog(
      scrollable: true,
      insetPadding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      title: Text(context.l10n.ordersShipmentDialogTitle),
      content: AppKeyboardSafeInset(
        useSafeArea: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _carrierController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.l10n.ordersShipmentCarrierLabel,
                hintText: context.l10n.ordersShipmentCarrierHint,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _trackingController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: context.l10n.ordersShipmentTrackingLabel,
                hintText: context.l10n.ordersShipmentTrackingHint,
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
            final carrier = _carrierController.text.trim();
            final trackingNumber = _trackingController.text.trim();
            if (carrier.isEmpty || trackingNumber.isEmpty) {
              return;
            }

            Navigator.of(context).pop(
              ShipmentDraft(
                carrierName: carrier,
                trackingNumber: trackingNumber,
              ),
            );
          },
          child: Text(context.l10n.ordersShipmentSubmit),
        ),
      ],
    );
  }
}
