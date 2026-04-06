import 'package:cloud_firestore/cloud_firestore.dart';

enum SettingsNotificationCategory {
  auctionActivity('auctionActivity'),
  orderPayment('orderPayment'),
  shippingAndReceipt('shippingAndReceipt'),
  system('system');

  const SettingsNotificationCategory(this.firestoreKey);

  final String firestoreKey;
}

class SettingsPreferences {
  const SettingsPreferences({
    required this.pushEnabled,
    required this.themeMode,
    required this.languageCode,
    required this.categories,
  });

  const SettingsPreferences.defaults()
    : pushEnabled = true,
      themeMode = 'SYSTEM',
      languageCode = 'ko',
      categories = const {
        SettingsNotificationCategory.auctionActivity: true,
        SettingsNotificationCategory.orderPayment: true,
        SettingsNotificationCategory.shippingAndReceipt: true,
        SettingsNotificationCategory.system: true,
      };

  final bool pushEnabled;
  final String themeMode;
  final String languageCode;
  final Map<SettingsNotificationCategory, bool> categories;

  bool isCategoryEnabled(SettingsNotificationCategory category) {
    return categories[category] ?? true;
  }

  factory SettingsPreferences.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final preferences =
        (data['preferences'] as Map<String, dynamic>?) ?? const {};
    final notificationCategories =
        (preferences['notificationCategories'] as Map<String, dynamic>?) ??
        const {};

    return SettingsPreferences(
      pushEnabled: (preferences['pushEnabled'] as bool?) ?? true,
      themeMode: (preferences['themeMode'] as String?) ?? 'SYSTEM',
      languageCode: (preferences['languageCode'] as String?) ?? 'ko',
      categories: {
        for (final category in SettingsNotificationCategory.values)
          category:
              (notificationCategories[category.firestoreKey] as bool?) ?? true,
      },
    );
  }
}
