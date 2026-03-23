import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_panel.dart';
import '../../../core/widgets/app_section_heading.dart';
import 'order_section_role.dart';
import 'widgets/order_section.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({
    super.key,
    this.highlightedOrderId,
  });

  final String? highlightedOrderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final userId = ref.watch(firebaseAuthProvider).currentUser?.uid;

    return AppPageScaffold(
      title: context.l10n.ordersTitle,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space4,
          tokens.screenPadding,
          tokens.space8,
        ),
        children: [
          if (highlightedOrderId != null) ...[
            _HighlightedOrderBanner(orderId: highlightedOrderId!),
            SizedBox(height: tokens.space5),
          ],
          AppSectionHeading(
            title: context.l10n.ordersBuyerTitle,
            subtitle: context.l10n.ordersBuyerSubtitle,
          ),
          SizedBox(height: tokens.space4),
          OrderSection(
            fieldName: OrderSectionField.buyerId,
            userId: userId,
            role: OrderSectionRole.buyer,
          ),
          SizedBox(height: tokens.space7),
          AppSectionHeading(
            title: context.l10n.ordersSellerTitle,
            subtitle: context.l10n.ordersSellerSubtitle,
          ),
          SizedBox(height: tokens.space4),
          OrderSection(
            fieldName: OrderSectionField.sellerId,
            userId: userId,
            role: OrderSectionRole.seller,
          ),
        ],
      ),
    );
  }
}

class _HighlightedOrderBanner extends StatelessWidget {
  const _HighlightedOrderBanner({
    required this.orderId,
  });

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.elevated,
      child: Row(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            color: context.colorScheme.primary,
          ),
          SizedBox(width: tokens.space3),
          Expanded(
            child: Text(
              '${context.l10n.ordersHighlightedLabel} · #$orderId',
              style: context.textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
