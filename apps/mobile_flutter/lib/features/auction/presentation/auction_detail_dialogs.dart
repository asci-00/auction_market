import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/l10n/app_formatters.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/widgets/app_keyboard_safe_inset.dart';

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
  return showDialog<int>(
    context: context,
    builder: (_) => _AuctionAmountDialog(
      minimumBid: minimumBid,
      title: title,
      description: description,
      labelText: labelText,
      hintText: hintText,
      submitLabel: submitLabel,
    ),
  );
}

class _AuctionAmountDialog extends StatefulWidget {
  const _AuctionAmountDialog({
    required this.minimumBid,
    required this.title,
    required this.description,
    required this.labelText,
    required this.hintText,
    required this.submitLabel,
  });

  final int minimumBid;
  final String title;
  final String description;
  final String labelText;
  final String hintText;
  final String submitLabel;

  @override
  State<_AuctionAmountDialog> createState() => _AuctionAmountDialogState();
}

class _AuctionAmountDialogState extends State<_AuctionAmountDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: '${widget.minimumBid}');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final validationMessage = context.l10n.auctionDetailBidMinimum(
      formatKrw(context, widget.minimumBid),
    );

    return AlertDialog(
      scrollable: true,
      insetPadding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      title: Text(widget.title),
      content: AppKeyboardSafeInset(
        useSafeArea: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.description,
              style: context.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: widget.labelText,
                hintText: widget.hintText,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.auctionDetailDialogCancel),
        ),
        FilledButton(
          onPressed: () {
            final parsedAmount = int.tryParse(_controller.text.trim());
            if (parsedAmount == null || parsedAmount < widget.minimumBid) {
              context.showErrorSnackBar(validationMessage);
              return;
            }

            Navigator.of(context).pop(parsedAmount);
          },
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}
