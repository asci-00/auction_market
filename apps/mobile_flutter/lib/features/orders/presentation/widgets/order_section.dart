import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/firebase/firebase_providers.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../application/order_action_service.dart';
import '../../data/order_summary.dart';
import '../order_payment_confirm_dialog.dart';
import '../order_payment_session_sheet.dart';
import '../order_section_role.dart';
import '../order_shipment_dialog.dart';
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
  Stream<QuerySnapshot<Map<String, dynamic>>>? _ordersStream;

  @override
  void initState() {
    super.initState();
    _ordersStream = _createOrdersStream();
  }

  @override
  void didUpdateWidget(covariant OrderSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId ||
        oldWidget.fieldName != widget.fieldName) {
      setState(() {
        _ordersStream = _createOrdersStream();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userId == null) {
      return AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: context.l10n.ordersEmptyTitle,
        description: context.l10n.ordersEmptyDescription,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _ordersStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: context.l10n.genericUnavailable,
            description: context.l10n.ordersEmptyDescription,
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final documents = snapshot.data!.docs;
        if (documents.isEmpty) {
          return AppEmptyState(
            icon: Icons.inventory_2_outlined,
            title: context.l10n.ordersEmptyTitle,
            description: context.l10n.ordersEmptyDescription,
          );
        }

        return Column(
          children: documents.map((document) {
            final order = OrderSummary.fromDocument(document);

            return OrderSummaryCard(
              order: order,
              role: widget.role,
              isSubmitting: _submittingOrderIds.contains(order.id),
              onPreparePayment: () => _preparePayment(order),
              onAddShipment: () => _openShipmentDialog(order.id),
              onConfirmReceipt: () => _confirmReceipt(order.id),
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
      action: () => ref.read(orderActionServiceProvider).submitShipment(
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
      if (!mounted) {
        return;
      }

      final shouldConfirm = await showOrderPaymentSessionSheet(
        context,
        session: session,
      );
      if (!mounted || shouldConfirm != true) {
        return;
      }

      final draft = await showOrderPaymentConfirmDialog(
        context,
        amount: order.finalPrice.toInt(),
      );
      if (!mounted || draft == null) {
        return;
      }

      await ref.read(orderActionServiceProvider).confirmPayment(
            orderId: order.id,
            paymentKey: draft.paymentKey,
            amount: order.finalPrice.toInt(),
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
      action: () => ref.read(orderActionServiceProvider).confirmReceipt(
            orderId: orderId,
          ),
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

  Stream<QuerySnapshot<Map<String, dynamic>>>? _createOrdersStream() {
    final userId = widget.userId;
    if (userId == null) {
      return null;
    }

    return ref
        .read(firestoreProvider)
        .collection('orders')
        .where(widget.fieldName.key, isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots();
  }
}
