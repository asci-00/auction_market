import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum SettingsThemeModePreference {
  system('SYSTEM', ThemeMode.system),
  light('LIGHT', ThemeMode.light),
  dark('DARK', ThemeMode.dark);

  const SettingsThemeModePreference(
    this.firestoreValue,
    this.materialThemeMode,
  );

  final String firestoreValue;
  final ThemeMode materialThemeMode;

  static SettingsThemeModePreference parse(String? rawValue) {
    return SettingsThemeModePreference.values.firstWhere(
      (value) => value.firestoreValue == rawValue,
      orElse: () => SettingsThemeModePreference.system,
    );
  }
}

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
    required this.categories,
  });

  const SettingsPreferences.defaults()
    : pushEnabled = true,
      themeMode = SettingsThemeModePreference.system,
      categories = const {
        SettingsNotificationCategory.auctionActivity: true,
        SettingsNotificationCategory.orderPayment: true,
        SettingsNotificationCategory.shippingAndReceipt: true,
        SettingsNotificationCategory.system: true,
      };

  final bool pushEnabled;
  final SettingsThemeModePreference themeMode;
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
      themeMode: SettingsThemeModePreference.parse(
        preferences['themeMode'] as String?,
      ),
      categories: {
        for (final category in SettingsNotificationCategory.values)
          category:
              (notificationCategories[category.firestoreKey] as bool?) ?? true,
      },
    );
  }
}
