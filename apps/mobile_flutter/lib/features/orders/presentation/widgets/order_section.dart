import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../application/order_action_service.dart';
import '../../application/order_payment_handoff_service.dart';
import '../../data/order_summary.dart';
import '../order_payment_confirm_dialog.dart';
import '../order_payment_session_sheet.dart';
import '../order_section_role.dart';
import '../order_shipment_dialog.dart';
import '../order_view_model.dart';
import 'order_summary_card.dart';

enum OrderSectionField {
  buyerId('buyerId'),
  sellerId('sellerId');

  const OrderSectionField(this.key);

  final String key;
}

class OrderSection extends ConsumerStatefulWidget {
  const OrderSection({
    super.key,
    required this.fieldName,
    required this.userId,
    required this.role,
  });

  final OrderSectionField fieldName;
  final String? userId;
  final OrderSectionRole role;

  @override
  ConsumerState<OrderSection> createState() => _OrderSectionState();
}

class _OrderSectionState extends ConsumerState<OrderSection> {
  final Set<String> _submittingOrderIds = <String>{};

  @override
  Widget build(BuildContext context) {
    if (widget.userId == null) {
      return AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: context.l10n.ordersEmptyTitle,
        description: context.l10n.ordersEmptyDescription,
        action: TextButton(
          onPressed: () =>
              context.go('/login?from=${Uri.encodeComponent('/orders')}'),
          child: Text(context.l10n.genericSignInAction),
        ),
      );
    }

    final query = OrderQuery(
      userId: widget.userId!,
      fieldKey: widget.fieldName.key,
    );
    final ordersAsync = ref.watch(ordersViewModelProvider(query));

    return ordersAsync.when(
      error: (_, __) => AppEmptyState(
        icon: Icons.error_outline_rounded,
        title: context.l10n.genericUnavailable,
        description: context.l10n.ordersErrorDescription,
      ),
      loading: () =>
          const AppShimmerListPlaceholder(itemCount: 3, itemHeight: 172),
      data: (state) {
        if (state.orders.isEmpty) {
          return AppEmptyState(
            icon: Icons.inventory_2_outlined,
            title: context.l10n.ordersEmptyTitle,
            description: context.l10n.ordersEmptyDescription,
            action: TextButton(
              onPressed: () => context.go('/search'),
              child: Text(context.l10n.auctionDetailBrowseAction),
            ),
          );
        }

        return Column(
          children: state.orders.indexed.map((entry) {
            final index = entry.$1;
            final order = entry.$2;

            return AppStaggeredReveal(
              index: index,
              child: OrderSummaryCard(
                order: order,
                role: widget.role,
                isSubmitting: _submittingOrderIds.contains(order.id),
                onPreparePayment: () => _preparePayment(order),
                onAddShipment: () => _openShipmentDialog(order.id),
                onConfirmReceipt: () => _confirmReceipt(order.id),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _openShipmentDialog(String orderId) async {
    final draft = await showOrderShipmentDialog(context);
    if (!mounted || draft == null) {
      return;
    }

    await _runOrderAction(
      orderId: orderId,
      action: () => ref
          .read(orderActionServiceProvider)
          .submitShipment(
            orderId: orderId,
            carrierName: draft.carrierName,
            trackingNumber: draft.trackingNumber,
          ),
      successMessage: context.l10n.ordersActionSuccessShipped,
    );
  }

  Future<void> _preparePayment(OrderSummary order) async {
    setState(() {
      _submittingOrderIds.add(order.id);
    });

    try {
      final session = await ref
          .read(orderActionServiceProvider)
          .createPaymentSession(orderId: order.id);
      final handoffPlan = ref
          .read(orderPaymentHandoffServiceProvider)
          .buildPlan(session);
      if (!mounted) {
        return;
      }

      final sheetResult = await showOrderPaymentSessionSheet(
        context,
        session: session,
        handoffPlan: handoffPlan,
      );
      if (!mounted || sheetResult == null) {
        return;
      }

      var paymentKey = sheetResult.paymentKey;
      if (sheetResult.useManualEntry) {
        final draft = await showOrderPaymentConfirmDialog(
          context,
          amount: session.amount,
        );
        if (!mounted || draft == null) {
          return;
        }
        paymentKey = draft.paymentKey;
      }

      if (paymentKey == null || paymentKey.isEmpty) {
        if (mounted) {
          context.showErrorSnackBar(context.l10n.ordersActionFailed);
        }
        return;
      }

      await ref
          .read(orderActionServiceProvider)
          .confirmPayment(
            orderId: order.id,
            paymentKey: paymentKey,
            amount: session.amount,
          );
      if (!mounted) {
        return;
      }

      context.showSnackBarMessage(context.l10n.ordersActionSuccessPayment);
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorSnackBar(
        error.message ?? context.l10n.ordersActionFailed,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      context.showErrorSnackBar(context.l10n.ordersActionFailed);
    } finally {
      if (mounted) {
        setState(() {
          _submittingOrderIds.remove(order.id);
        });
      }
    }
  }

  Future<void> _confirmReceipt(String orderId) {
    return _runOrderAction(
      orderId: orderId,
      action: () =>
          ref.read(orderActionServiceProvider).confirmReceipt(orderId: orderId),
      successMessage: context.l10n.ordersActionSuccessReceipt,
    );
  }

  Future<void> _runOrderAction({
    required String orderId,
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    setState(() {
      _submittingOrderIds.add(orderId);
    });

    try {
      await action();
      if (!mounted) {
        return;
      }
      context.showSnackBarMessage(successMessage);
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorSnackBar(
        error.message ?? context.l10n.ordersActionFailed,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      context.showErrorSnackBar(context.l10n.ordersActionFailed);
    } finally {
      if (mounted) {
        setState(() {
          _submittingOrderIds.remove(orderId);
        });
      }
    }
  }
}
