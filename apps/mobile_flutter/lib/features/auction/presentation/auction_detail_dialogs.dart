import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/l10n/app_formatters.dart';
import '../../../core/l10n/app_localization.dart';

Future<int?> showAuctionBidAmountDialog(
  BuildContext context, {
  required int minimumBid,
}) async {
  final controller = TextEditingController(text: '$minimumBid');

  try {
    return showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.auctionDetailBidDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.auctionDetailBidMinimum(
                  formatKrw(context, minimumBid),
                ),
                style: dialogContext.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: context.l10n.auctionDetailBidAmountLabel,
                  hintText: context.l10n.auctionDetailBidAmountHint,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.auctionDetailDialogCancel),
            ),
            FilledButton(
              onPressed: () {
                final parsedAmount = int.tryParse(controller.text.trim());
                if (parsedAmount == null || parsedAmount < minimumBid) {
                  return;
                }

                Navigator.of(dialogContext).pop(parsedAmount);
              },
              child: Text(context.l10n.auctionDetailDialogSubmitBid),
            ),
          ],
        );
      },
    );
  } finally {
    controller.dispose();
  }
}

Future<int?> showAuctionAutoBidDialog(
  BuildContext context, {
  required int minimumBid,
}) async {
  final controller = TextEditingController(text: '$minimumBid');

  try {
    return showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.auctionDetailAutoBidDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.auctionDetailAutoBidHint(
                  formatKrw(context, minimumBid),
                ),
                style: dialogContext.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: context.l10n.auctionDetailAutoBidAmountLabel,
                  hintText: context.l10n.auctionDetailAutoBidAmountHint,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.auctionDetailDialogCancel),
            ),
            FilledButton(
              onPressed: () {
                final parsedAmount = int.tryParse(controller.text.trim());
                if (parsedAmount == null || parsedAmount < minimumBid) {
                  return;
                }

                Navigator.of(dialogContext).pop(parsedAmount);
              },
              child: Text(context.l10n.auctionDetailDialogSubmitAutoBid),
            ),
          ],
        );
      },
    );
  } finally {
    controller.dispose();
  }
}
