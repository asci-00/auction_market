import 'package:flutter/material.dart';

import '../../../core/l10n/app_localization.dart';

String localizedOrderStatus(BuildContext context, String value) {
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
