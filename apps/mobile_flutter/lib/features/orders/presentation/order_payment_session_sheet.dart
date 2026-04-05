import 'package:flutter/material.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/l10n/app_formatters.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_keyboard_safe_inset.dart';
import '../../../core/widgets/app_modal.dart';
import '../../../core/widgets/app_panel.dart';
import '../application/order_payment_handoff_service.dart';
import '../data/order_payment_session.dart';

class OrderPaymentSheetResult {
  const OrderPaymentSheetResult._({
    required this.useManualEntry,
    required this.launchCheckout,
    this.paymentKey,
  }) : assert(
         !(useManualEntry && launchCheckout),
         'manual entry and checkout launch are mutually exclusive',
       );

  const OrderPaymentSheetResult.manualEntry()
    : this._(useManualEntry: true, launchCheckout: false);

  const OrderPaymentSheetResult.directConfirm(String paymentKey)
    : this._(
        useManualEntry: false,
        launchCheckout: false,
        paymentKey: paymentKey,
      );

  const OrderPaymentSheetResult.launchCheckout()
    : this._(useManualEntry: false, launchCheckout: true);

  final bool useManualEntry;
  final bool launchCheckout;
  final String? paymentKey;
}

Future<OrderPaymentSheetResult?> showOrderPaymentSessionSheet(
  BuildContext context, {
  required OrderPaymentSession session,
  required OrderPaymentHandoffPlan handoffPlan,
}) {
  return showAppModalBottomSheet<OrderPaymentSheetResult>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final tokens = sheetContext.tokens;
      final devPaymentKey = handoffPlan.paymentKey;
      final canDirectDevConfirm =
          handoffPlan.isDevDummy && (devPaymentKey?.isNotEmpty ?? false);
      final statusColor = switch (handoffPlan.mode) {
        OrderPaymentHandoffMode.devDummy => AppColors.accentSuccess,
        OrderPaymentHandoffMode.launcherReady => AppColors.accentPrimary,
        OrderPaymentHandoffMode.manualConfirm => AppColors.accentUrgent,
      };
      final statusLabel = switch (handoffPlan.mode) {
        OrderPaymentHandoffMode.devDummy =>
          context.l10n.ordersPaymentSheetStatusDev,
        OrderPaymentHandoffMode.launcherReady =>
          context.l10n.ordersPaymentSheetStatusReady,
        OrderPaymentHandoffMode.manualConfirm =>
          context.l10n.ordersPaymentSheetStatusBlocked,
      };
      final nextStepDescription = switch (handoffPlan.mode) {
        OrderPaymentHandoffMode.devDummy =>
          context.l10n.ordersPaymentSheetNextStepDev,
        OrderPaymentHandoffMode.launcherReady =>
          context.l10n.ordersPaymentSheetNextStepReady,
        OrderPaymentHandoffMode.manualConfirm =>
          context.l10n.ordersPaymentSheetNextStepBlocked,
      };
      final description = switch (handoffPlan.mode) {
        OrderPaymentHandoffMode.devDummy =>
          context.l10n.ordersPaymentSheetDevDescription,
        OrderPaymentHandoffMode.launcherReady =>
          context.l10n.ordersPaymentSheetReadyDescription,
        OrderPaymentHandoffMode.manualConfirm =>
          context.l10n.ordersPaymentSheetBlockedDescription,
      };

      return AppKeyboardSafeInset(
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
            _OrderPaymentRoutePanel(
              statusLabel: statusLabel,
              description: description,
              nextStepDescription: nextStepDescription,
              accentColor: statusColor,
            ),
            SizedBox(height: tokens.space4),
            _OrderPaymentInfoPanel(session: session),
            SizedBox(height: tokens.space4),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (canDirectDevConfirm) {
                    Navigator.of(sheetContext).pop(
                      OrderPaymentSheetResult.directConfirm(devPaymentKey!),
                    );
                    return;
                  }

                  if (handoffPlan.isLauncherReady) {
                    Navigator.of(
                      sheetContext,
                    ).pop(const OrderPaymentSheetResult.launchCheckout());
                    return;
                  }

                  Navigator.of(
                    sheetContext,
                  ).pop(const OrderPaymentSheetResult.manualEntry());
                },
                child: Text(
                  canDirectDevConfirm
                      ? context.l10n.ordersPaymentCompleteDevAction
                      : handoffPlan.isLauncherReady
                      ? context.l10n.ordersPaymentLaunchAction
                      : context.l10n.ordersPaymentEnterKeyAction,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _OrderPaymentInfoPanel extends StatelessWidget {
  const _OrderPaymentInfoPanel({required this.session});

  final OrderPaymentSession session;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final devPaymentKey = session.devPaymentKey?.trim();

    return AppPanel(
      tone: AppPanelTone.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(session.orderName, style: context.textTheme.titleMedium),
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
          if (session.isDevDummyMode &&
              (devPaymentKey?.isNotEmpty ?? false)) ...[
            SizedBox(height: tokens.space2),
            Text(
              context.l10n.ordersPaymentDevKeyLabel(devPaymentKey!),
              style: context.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderPaymentRoutePanel extends StatelessWidget {
  const _OrderPaymentRoutePanel({
    required this.statusLabel,
    required this.description,
    required this.nextStepDescription,
    required this.accentColor,
  });

  final String statusLabel;
  final String description;
  final String nextStepDescription;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space3,
              vertical: tokens.space2,
            ),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusLabel,
              style: context.textTheme.labelLarge?.copyWith(color: accentColor),
            ),
          ),
          SizedBox(height: tokens.space3),
          Text(description, style: context.textTheme.bodyMedium),
          SizedBox(height: tokens.space4),
          Text(
            context.l10n.ordersPaymentSheetNextStepTitle,
            style: context.textTheme.titleSmall,
          ),
          SizedBox(height: tokens.space2),
          Text(nextStepDescription, style: context.textTheme.bodySmall),
        ],
      ),
    );
  }
}
