import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_formatters.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_live_countdown_text.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../data/order_summary.dart';
import '../order_section_role.dart';
import '../order_status_label.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.order,
    required this.role,
    required this.isSubmitting,
    required this.onPreparePayment,
    required this.onAddShipment,
    required this.onConfirmReceipt,
  });

  final OrderSummary order;
  final OrderSectionRole role;
  final bool isSubmitting;
  final VoidCallback onPreparePayment;
  final VoidCallback onAddShipment;
  final VoidCallback onConfirmReceipt;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final canShip = role == OrderSectionRole.seller &&
        order.orderStatus == 'PAID_ESCROW_HOLD';
    final canPay = role == OrderSectionRole.buyer &&
        order.orderStatus == 'AWAITING_PAYMENT';
    final canConfirmReceipt =
        role == OrderSectionRole.buyer && order.orderStatus == 'SHIPPED';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppPanel(
        tone: AppPanelTone.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppStatusBadge(
                  kind: order.paymentStatus == 'PAID'
                      ? AppStatusKind.paid
                      : AppStatusKind.pending,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '#${order.id}',
                    style: context.textTheme.titleMedium,
                  ),
                ),
                Text(
                  formatKrw(context, order.finalPrice),
                  style: context.textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: tokens.space3),
            Text(
              localizedOrderStatus(context, order.orderStatus),
              style: context.textTheme.bodyMedium,
            ),
            if (order.orderStatus == 'AWAITING_PAYMENT' &&
                order.paymentDueAt != null) ...[
              SizedBox(height: tokens.space3),
              _PaymentDuePlate(order: order),
            ],
            if (order.hasShipmentSummary)
              Padding(
                padding: EdgeInsets.only(top: tokens.space2),
                child: Text(
                  context.l10n.ordersShipmentSummary(
                    order.carrierName!,
                    order.trackingNumber!,
                  ),
                  style: context.textTheme.bodySmall,
                ),
              ),
            if (canPay || canShip || canConfirmReceipt) ...[
              SizedBox(height: tokens.space4),
              Row(
                children: [
                  if (canPay)
                    Expanded(
                      child: FilledButton(
                        onPressed: isSubmitting ? null : onPreparePayment,
                        child: Text(context.l10n.ordersActionPreparePayment),
                      ),
                    ),
                  if (canShip)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSubmitting ? null : onAddShipment,
                        child: Text(context.l10n.ordersActionAddShipment),
                      ),
                    ),
                  if (canConfirmReceipt)
                    Expanded(
                      child: FilledButton(
                        onPressed: isSubmitting ? null : onConfirmReceipt,
                        child: Text(context.l10n.ordersActionConfirmReceipt),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentDuePlate extends StatelessWidget {
  const _PaymentDuePlate({
    required this.order,
  });

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.space3),
      decoration: BoxDecoration(
        color: AppColors.bgMuted,
        borderRadius: BorderRadius.circular(tokens.cardRadius - 8),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timelapse_rounded,
            color: AppColors.accentUrgent,
            size: 18,
          ),
          SizedBox(width: tokens.space2),
          Expanded(
            child: AppLiveCountdownText(
              targetTime: order.paymentDueAt!,
              builder: (context, label) => Text(
                context.l10n.ordersPaymentDueIn(label),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              expiredBuilder: (context) => Text(
                context.l10n.ordersPaymentExpired,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.accentUrgent,
                ),
              ),
            ),
          ),
          SizedBox(width: tokens.space2),
          Text(
            formatKrw(context, order.finalPrice),
            style: context.textTheme.labelLarge?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
