String? normalizeAppDeepLink(Uri uri) {
  if (uri.scheme != 'app') {
    return null;
  }

  switch (uri.host) {
    case 'auction':
      if (uri.pathSegments.isNotEmpty) {
        return '/auction/${uri.pathSegments.first}';
      }
      return '/home';
    case 'orders':
      if (uri.pathSegments.isNotEmpty) {
        return '/orders/${uri.pathSegments.first}';
      }
      return '/orders';
    case 'notifications':
      return '/notifications';
    default:
      return '/home';
  }
}

String resolveAppDeepLinkPath(String raw) {
  final uri = Uri.tryParse(raw);
  if (uri == null) {
    return raw;
  }

  return normalizeAppDeepLink(uri) ?? raw;
}
