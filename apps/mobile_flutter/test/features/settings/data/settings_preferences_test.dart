import 'package:auction_market_mobile/core/firebase/firebase_providers.dart';
import 'package:auction_market_mobile/features/settings/application/settings_preferences_service.dart';
import 'package:auction_market_mobile/features/settings/data/settings_preferences.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults enable push and all notification categories', () {
    const preferences = SettingsPreferences.defaults();

    expect(preferences.pushEnabled, isTrue);

    for (final category in SettingsNotificationCategory.values) {
      expect(preferences.isCategoryEnabled(category), isTrue);
    }
  });

  test('push payload keeps master flag under preferences', () {
    final payload = SettingsPreferencesService.pushEnabledPayload(false);

    expect(payload['updatedAt'], isNotNull);
    expect(payload['preferences'], {'pushEnabled': false});
  });

  test('category payload keeps nested category key under preferences', () {
    final payload = SettingsPreferencesService.categoryEnabledPayload(
      SettingsNotificationCategory.shippingAndReceipt,
      false,
    );

    expect(payload['updatedAt'], isNotNull);
    expect(payload['preferences'], {
      'notificationCategories': {'shippingAndReceipt': false},
    });
  });

  test(
    'provider falls back to defaults when the user document is missing',
    () async {
      final firestore = FakeFirebaseFirestore();
      final container = ProviderContainer(
        overrides: [firestoreProvider.overrideWith((ref) => firestore)],
      );
      addTearDown(container.dispose);

      final preferences = await container.read(
        settingsPreferencesProvider('missing-user').future,
      );

      expect(preferences.pushEnabled, isTrue);
      for (final category in SettingsNotificationCategory.values) {
        expect(preferences.isCategoryEnabled(category), isTrue);
      }
    },
  );

  test('document parsing keeps notification category overrides', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('users').doc('user-1').set({
      'preferences': {
        'notificationCategories': {'system': false},
      },
    });

    final snap = await firestore.collection('users').doc('user-1').get();
    final preferences = SettingsPreferences.fromDocument(snap);

    expect(
      preferences.isCategoryEnabled(SettingsNotificationCategory.system),
      isFalse,
    );
  });

  test('theme preference provider reads the locally stored theme', () async {
    SharedPreferences.setMockInitialValues({'settings.themeMode': 'DARK'});
    final sharedPreferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(themeModePreferenceProvider),
      SettingsThemeModePreference.dark,
    );
  });
}
