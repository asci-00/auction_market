import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_formatters.dart';
import '../../../../core/l10n/app_localization.dart';
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
    final canShip = role == OrderSectionRole.seller &&
        order.orderStatus == 'PAID_ESCROW_HOLD';
    final canPay = role == OrderSectionRole.buyer &&
        order.orderStatus == 'AWAITING_PAYMENT';
    final canConfirmReceipt =
        role == OrderSectionRole.buyer && order.orderStatus == 'SHIPPED';
    final actionCount =
        [canPay, canShip, canConfirmReceipt].where((value) => value).length;

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
            const SizedBox(height: 12),
            Text(
              localizedOrderStatus(context, order.orderStatus),
              style: context.textTheme.bodyMedium,
            ),
            if (order.hasShipmentSummary)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  context.l10n.ordersShipmentSummary(
                    order.carrierName!,
                    order.trackingNumber!,
                  ),
                  style: context.textTheme.bodySmall,
                ),
              ),
            if (order.paymentDueAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  context.l10n.genericEndsAt(
                    formatCompactDateTime(context, order.paymentDueAt!),
                  ),
                  style: context.textTheme.bodySmall,
                ),
              ),
            if (canPay || canShip || canConfirmReceipt) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (canPay)
                    Expanded(
                      child: FilledButton(
                        onPressed: isSubmitting ? null : onPreparePayment,
                        child: Text(context.l10n.ordersActionPreparePayment),
                      ),
                    ),
                  if (canPay && actionCount > 1) const SizedBox(width: 12),
                  if (canShip)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSubmitting ? null : onAddShipment,
                        child: Text(context.l10n.ordersActionAddShipment),
                      ),
                    ),
                  if (canShip && canConfirmReceipt) const SizedBox(width: 12),
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
