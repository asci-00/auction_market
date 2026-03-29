import 'package:flutter/material.dart';

import '../../../core/l10n/app_localization.dart';
import '../../../core/widgets/app_keyboard_safe_inset.dart';
import '../../../core/widgets/app_modal.dart';

class ShipmentDraft {
  const ShipmentDraft({
    required this.carrierName,
    required this.trackingNumber,
  });

  final String carrierName;
  final String trackingNumber;
}

Future<ShipmentDraft?> showOrderShipmentDialog(BuildContext context) async {
  return showAppDialog<ShipmentDraft>(
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
  bool _showCarrierError = false;
  bool _showTrackingError = false;

  @override
  void dispose() {
    _carrierController.dispose();
    _trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      title: Text(context.l10n.ordersShipmentDialogTitle),
      content: AppKeyboardSafeInset(
        useSafeArea: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _carrierController,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (!_showCarrierError) {
                  return;
                }
                setState(() => _showCarrierError = false);
              },
              decoration: InputDecoration(
                labelText: context.l10n.ordersShipmentCarrierLabel,
                hintText: context.l10n.ordersShipmentCarrierHint,
                errorText: _showCarrierError
                    ? context.l10n.ordersShipmentCarrierRequiredError
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _trackingController,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (!_showTrackingError) {
                  return;
                }
                setState(() => _showTrackingError = false);
              },
              decoration: InputDecoration(
                labelText: context.l10n.ordersShipmentTrackingLabel,
                hintText: context.l10n.ordersShipmentTrackingHint,
                errorText: _showTrackingError
                    ? context.l10n.ordersShipmentTrackingRequiredError
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
            final carrier = _carrierController.text.trim();
            final trackingNumber = _trackingController.text.trim();
            final carrierEmpty = carrier.isEmpty;
            final trackingEmpty = trackingNumber.isEmpty;
            if (carrierEmpty || trackingEmpty) {
              setState(() {
                _showCarrierError = carrierEmpty;
                _showTrackingError = trackingEmpty;
              });
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
