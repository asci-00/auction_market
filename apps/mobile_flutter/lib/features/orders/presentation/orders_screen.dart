import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../core/l10n/app_formatters.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_panel.dart';
import '../../../core/widgets/app_section_heading.dart';
import '../../../core/widgets/app_status_badge.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({
    super.key,
    this.highlightedOrderId,
  });

  final String? highlightedOrderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final user = ref.watch(firebaseAuthProvider).currentUser;

    return AppPageScaffold(
      title: l10n.ordersTitle,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space4,
          tokens.screenPadding,
          tokens.space8,
        ),
        children: [
          if (highlightedOrderId != null) ...[
            AppPanel(
              tone: AppPanelTone.elevated,
              child: Row(
                children: [
                  const AppStatusBadge(kind: AppStatusKind.pending),
                  SizedBox(width: tokens.space3),
                  Expanded(
                    child: Text(
                      '${l10n.ordersHighlightedLabel} · #$highlightedOrderId',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.space5),
          ],
          AppSectionHeading(
            title: l10n.ordersBuyerTitle,
            subtitle: l10n.ordersBuyerSubtitle,
          ),
          SizedBox(height: tokens.space4),
          _OrderSection(
            fieldName: 'buyerId',
            userId: user?.uid,
            role: _OrderSectionRole.buyer,
          ),
          SizedBox(height: tokens.space7),
          AppSectionHeading(
            title: l10n.ordersSellerTitle,
            subtitle: l10n.ordersSellerSubtitle,
          ),
          SizedBox(height: tokens.space4),
          _OrderSection(
            fieldName: 'sellerId',
            userId: user?.uid,
            role: _OrderSectionRole.seller,
          ),
        ],
      ),
    );
  }
}

enum _OrderSectionRole {
  buyer,
  seller,
}

class _OrderSection extends ConsumerStatefulWidget {
  const _OrderSection({
    required this.fieldName,
    required this.userId,
    required this.role,
  });

  final String fieldName;
  final String? userId;
  final _OrderSectionRole role;

  @override
  ConsumerState<_OrderSection> createState() => _OrderSectionState();
}

class _OrderSectionState extends ConsumerState<_OrderSection> {
  final Set<String> _submittingOrderIds = <String>{};

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
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where(widget.fieldName, isEqualTo: widget.userId)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: context.l10n.genericUnavailable,
            description: context.l10n.ordersEmptyDescription,
          );
        }

        final docs = snapshot.data?.docs ?? const [];
        if (docs.isEmpty) {
          return AppEmptyState(
            icon: Icons.inventory_2_outlined,
            title: context.l10n.ordersEmptyTitle,
            description: context.l10n.ordersEmptyDescription,
          );
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data();
            final paymentStatus =
                (data['paymentStatus'] as String?) ?? 'PENDING';
            final orderStatus = (data['orderStatus'] as String?) ?? 'PENDING';
            final dueAt = (data['paymentDueAt'] as Timestamp?)?.toDate();
            final shipping =
                (data['shipping'] as Map<String, dynamic>?) ?? const {};
            final carrierName = shipping['carrierName'] as String?;
            final trackingNumber = shipping['trackingNumber'] as String?;
            final isSubmitting = _submittingOrderIds.contains(doc.id);
            final canShip = widget.role == _OrderSectionRole.seller &&
                orderStatus == 'PAID_ESCROW_HOLD';
            final canConfirmReceipt = widget.role == _OrderSectionRole.buyer &&
                orderStatus == 'SHIPPED';

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
                          kind: paymentStatus == 'PAID'
                              ? AppStatusKind.paid
                              : AppStatusKind.pending,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '#${doc.id}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          formatKrw(context, (data['finalPrice'] as num?) ?? 0),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _localizedOrderStatus(context, orderStatus),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (carrierName != null &&
                        carrierName.isNotEmpty &&
                        trackingNumber != null &&
                        trackingNumber.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          context.l10n.ordersShipmentSummary(
                            carrierName,
                            trackingNumber,
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    if (dueAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          context.l10n.genericEndsAt(
                            formatCompactDateTime(context, dueAt),
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    if (canShip || canConfirmReceipt) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (canShip)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => _openShipmentDialog(doc.id),
                                child:
                                    Text(context.l10n.ordersActionAddShipment),
                              ),
                            ),
                          if (canShip && canConfirmReceipt)
                            const SizedBox(width: 12),
                          if (canConfirmReceipt)
                            Expanded(
                              child: FilledButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => _confirmReceipt(doc.id),
                                child: Text(
                                  context.l10n.ordersActionConfirmReceipt,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _openShipmentDialog(String orderId) async {
    final l10n = context.l10n;
    final carrierController = TextEditingController();
    final trackingController = TextEditingController();

    try {
      final draft = await showDialog<_ShipmentDraft>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(l10n.ordersShipmentDialogTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: carrierController,
                  decoration: InputDecoration(
                    labelText: l10n.ordersShipmentCarrierLabel,
                    hintText: l10n.ordersShipmentCarrierHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: trackingController,
                  decoration: InputDecoration(
                    labelText: l10n.ordersShipmentTrackingLabel,
                    hintText: l10n.ordersShipmentTrackingHint,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.ordersDialogCancel),
              ),
              FilledButton(
                onPressed: () {
                  final carrier = carrierController.text.trim();
                  final trackingNumber = trackingController.text.trim();
                  if (carrier.isEmpty || trackingNumber.isEmpty) {
                    return;
                  }

                  Navigator.of(dialogContext).pop(
                    _ShipmentDraft(
                      carrierName: carrier,
                      trackingNumber: trackingNumber,
                    ),
                  );
                },
                child: Text(l10n.ordersShipmentSubmit),
              ),
            ],
          );
        },
      );

      if (!mounted || draft == null) {
        return;
      }

      await _runOrderAction(
        orderId,
        () => ref.read(functionsProvider).httpsCallable('shipmentUpdate').call({
          'orderId': orderId,
          'carrierName': draft.carrierName,
          'trackingNumber': draft.trackingNumber,
        }),
        successMessage: l10n.ordersActionSuccessShipped,
      );
    } finally {
      carrierController.dispose();
      trackingController.dispose();
    }
  }

  Future<void> _confirmReceipt(String orderId) {
    return _runOrderAction(
      orderId,
      () => ref.read(functionsProvider).httpsCallable('confirmReceipt').call({
        'orderId': orderId,
      }),
      successMessage: context.l10n.ordersActionSuccessReceipt,
    );
  }

  Future<void> _runOrderAction(
    String orderId,
    Future<dynamic> Function() action, {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? context.l10n.ordersActionFailed),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.ordersActionFailed)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submittingOrderIds.remove(orderId);
        });
      }
    }
  }
}

class _ShipmentDraft {
  const _ShipmentDraft({
    required this.carrierName,
    required this.trackingNumber,
  });

  final String carrierName;
  final String trackingNumber;
}

String _localizedOrderStatus(BuildContext context, String value) {
  final l10n = context.l10n;

  switch (value) {
    case 'AWAITING_PAYMENT':
      return l10n.genericOrderAwaitingPayment;
    case 'PAID_ESCROW_HOLD':
      return l10n.genericOrderPaid;
    case 'SHIPPED':
      return l10n.genericOrderShipped;
    case 'CONFIRMED_RECEIPT':
      return l10n.genericOrderConfirmedReceipt;
    case 'SETTLED':
      return l10n.genericOrderSettled;
    case 'CANCELLED_UNPAID':
    case 'CANCELLED':
      return l10n.genericOrderCancelled;
    default:
      return l10n.genericOrderProcessing;
  }
}
