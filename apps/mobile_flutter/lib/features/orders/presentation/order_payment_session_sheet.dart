import 'package:flutter/material.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/l10n/app_formatters.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_panel.dart';
import '../data/order_payment_session.dart';

Future<bool?> showOrderPaymentSessionSheet(
  BuildContext context, {
  required OrderPaymentSession session,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final tokens = sheetContext.tokens;

      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.screenPadding,
            tokens.space4,
            tokens.screenPadding,
            tokens.space6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.ordersPaymentSheetTitle,
                style: sheetContext.textTheme.headlineSmall,
              ),
              SizedBox(height: tokens.space2),
              Text(
                session.hasCheckoutHandoff
                    ? context.l10n.ordersPaymentSheetReadyDescription
                    : context.l10n.ordersPaymentSheetBlockedDescription,
                style: sheetContext.textTheme.bodyMedium,
              ),
              SizedBox(height: tokens.space4),
              _OrderPaymentInfoPanel(session: session),
              SizedBox(height: tokens.space4),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: Text(context.l10n.ordersPaymentEnterKeyAction),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _OrderPaymentInfoPanel extends StatelessWidget {
  const _OrderPaymentInfoPanel({
    required this.session,
  });

  final OrderPaymentSession session;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session.orderName,
            style: context.textTheme.titleMedium,
          ),
          SizedBox(height: tokens.space2),
          Text(
            context.l10n.ordersPaymentAmountLabel(
              formatKrw(context, session.amount),
            ),
            style: context.textTheme.bodyMedium,
          ),
          SizedBox(height: tokens.space2),
          Text(
            '${context.l10n.ordersPaymentProviderLabel}: ${session.provider}',
            style: context.textTheme.bodySmall,
          ),
          if (session.customerEmail?.isNotEmpty ?? false) ...[
            SizedBox(height: tokens.space2),
            Text(
              '${context.l10n.ordersPaymentEmailLabel}: ${session.customerEmail}',
              style: context.textTheme.bodySmall,
            ),
          ],
          if (session.successUrl?.isNotEmpty ?? false) ...[
            SizedBox(height: tokens.space2),
            Text(
              context.l10n.ordersPaymentSuccessUrlLabel(session.successUrl!),
              style: context.textTheme.bodySmall,
            ),
          ],
          if (session.failUrl?.isNotEmpty ?? false) ...[
            SizedBox(height: tokens.space2),
            Text(
              context.l10n.ordersPaymentFailUrlLabel(session.failUrl!),
              style: context.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
