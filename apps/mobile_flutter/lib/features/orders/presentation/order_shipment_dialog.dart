import 'package:flutter/material.dart';

import '../../../core/l10n/app_localization.dart';

class ShipmentDraft {
  const ShipmentDraft({
    required this.carrierName,
    required this.trackingNumber,
  });

  final String carrierName;
  final String trackingNumber;
}

Future<ShipmentDraft?> showOrderShipmentDialog(BuildContext context) async {
  final carrierController = TextEditingController();
  final trackingController = TextEditingController();

  try {
    return showDialog<ShipmentDraft>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.ordersShipmentDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: carrierController,
                decoration: InputDecoration(
                  labelText: context.l10n.ordersShipmentCarrierLabel,
                  hintText: context.l10n.ordersShipmentCarrierHint,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: trackingController,
                decoration: InputDecoration(
                  labelText: context.l10n.ordersShipmentTrackingLabel,
                  hintText: context.l10n.ordersShipmentTrackingHint,
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
                final carrier = carrierController.text.trim();
                final trackingNumber = trackingController.text.trim();
                if (carrier.isEmpty || trackingNumber.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop(
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
      },
    );
  } finally {
    carrierController.dispose();
    trackingController.dispose();
  }
}
