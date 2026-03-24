import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/l10n/app_formatters.dart';
import '../../../core/l10n/app_localization.dart';

Future<int?> showAuctionBidAmountDialog(
  BuildContext context, {
  required int minimumBid,
}) async {
  return _showAuctionAmountDialog(
    context,
    minimumBid: minimumBid,
    title: context.l10n.auctionDetailBidDialogTitle,
    description: context.l10n.auctionDetailBidMinimum(
      formatKrw(context, minimumBid),
    ),
    labelText: context.l10n.auctionDetailBidAmountLabel,
    hintText: context.l10n.auctionDetailBidAmountHint,
    submitLabel: context.l10n.auctionDetailDialogSubmitBid,
  );
}

Future<int?> showAuctionAutoBidDialog(
  BuildContext context, {
  required int minimumBid,
}) async {
  return _showAuctionAmountDialog(
    context,
    minimumBid: minimumBid,
    title: context.l10n.auctionDetailAutoBidDialogTitle,
    description: context.l10n.auctionDetailAutoBidHint(
      formatKrw(context, minimumBid),
    ),
    labelText: context.l10n.auctionDetailAutoBidAmountLabel,
    hintText: context.l10n.auctionDetailAutoBidAmountHint,
    submitLabel: context.l10n.auctionDetailDialogSubmitAutoBid,
  );
}

Future<int?> _showAuctionAmountDialog(
  BuildContext context, {
  required int minimumBid,
  required String title,
  required String description,
  required String labelText,
  required String hintText,
  required String submitLabel,
}) async {
  final controller = TextEditingController(text: '$minimumBid');
  final validationMessage = context.l10n.auctionDetailBidMinimum(
    formatKrw(context, minimumBid),
  );

  try {
    return await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: dialogContext.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: labelText,
                  hintText: hintText,
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
                  dialogContext.showErrorSnackBar(validationMessage);
                  return;
                }

                Navigator.of(dialogContext).pop(parsedAmount);
              },
              child: Text(submitLabel),
            ),
          ],
        );
      },
    );
  } finally {
    controller.dispose();
  }
}
