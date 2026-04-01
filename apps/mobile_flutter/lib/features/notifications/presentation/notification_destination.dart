import '../../../core/l10n/app_localization.dart';
import '../../../core/routing/app_deeplink.dart';

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

  final normalizedPath = uri.scheme == 'app' ? normalizeAppDeepLink(uri) : raw;
  if (normalizedPath == null) {
    return l10n.notificationsDestinationUnknown;
  }

  final normalizedUri = Uri.tryParse(normalizedPath);
  if (normalizedUri == null || normalizedUri.pathSegments.isEmpty) {
    return l10n.notificationsDestinationUnknown;
  }

  switch (normalizedUri.pathSegments.first) {
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
