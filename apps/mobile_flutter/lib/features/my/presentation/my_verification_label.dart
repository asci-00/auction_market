import 'package:flutter/widgets.dart';

import '../../../core/l10n/app_localization.dart';

String myVerificationLabel(BuildContext context, String value) {
  final l10n = context.l10n;

  switch (value) {
    case 'VERIFIED':
      return l10n.genericStateVerified;
    case 'PENDING':
      return l10n.genericStatePending;
    case 'REJECTED':
      return l10n.genericStateRejected;
    default:
      return l10n.genericStateUnverified;
  }
}
