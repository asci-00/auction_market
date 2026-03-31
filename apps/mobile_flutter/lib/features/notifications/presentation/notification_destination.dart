import '../../../core/l10n/app_localization.dart';

String describeNotificationDestination(
  AppLocalizations l10n,
  String? deeplink,
) {
  final raw = deeplink?.trim();
  if (raw == null || raw.isEmpty) {
    return l10n.notificationsDestinationUnknown;
  }

  final uri = Uri.tryParse(raw);
  if (uri == null) {
    return l10n.notificationsDestinationUnknown;
  }

  if (uri.scheme == 'app') {
    switch (uri.host) {
      case 'auction':
        return l10n.notificationsDestinationAuction;
      case 'orders':
        return l10n.notificationsDestinationOrder;
      case 'notifications':
        return l10n.notificationsDestinationInbox;
      case 'payments':
        return l10n.notificationsDestinationPayment;
      default:
        return l10n.notificationsDestinationUnknown;
    }
  }

  if (uri.pathSegments.isEmpty) {
    return l10n.notificationsDestinationUnknown;
  }

  switch (uri.pathSegments.first) {
    case 'auction':
      return l10n.notificationsDestinationAuction;
    case 'orders':
      return l10n.notificationsDestinationOrder;
    case 'notifications':
      return l10n.notificationsDestinationInbox;
    case 'payments':
      return l10n.notificationsDestinationPayment;
    default:
      return l10n.notificationsDestinationUnknown;
  }
}
