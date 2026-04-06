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

  test(
    'provider falls back to defaults when user document has no preferences payload',
    () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('existing-user').set({
        'email': 'existing-user@test.local',
      });
      final container = ProviderContainer(
        overrides: [firestoreProvider.overrideWith((ref) => firestore)],
      );
      addTearDown(container.dispose);

      final preferences = await container.read(
        settingsPreferencesProvider('existing-user').future,
      );

      expect(preferences.pushEnabled, isTrue);
      for (final category in SettingsNotificationCategory.values) {
        expect(preferences.isCategoryEnabled(category), isTrue);
      }
    },
  );

  test(
    'provider keeps pushEnabled and defaults missing category values',
    () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('partial-user').set({
        'preferences': {'pushEnabled': false},
      });
      final container = ProviderContainer(
        overrides: [firestoreProvider.overrideWith((ref) => firestore)],
      );
      addTearDown(container.dispose);

      final preferences = await container.read(
        settingsPreferencesProvider('partial-user').future,
      );

      expect(preferences.pushEnabled, isFalse);
      for (final category in SettingsNotificationCategory.values) {
        expect(preferences.isCategoryEnabled(category), isTrue);
      }
    },
  );

  test(
    'provider merges partial notification categories with defaults',
    () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('partial-categories').set({
        'preferences': {
          'notificationCategories': {'orderPayment': false},
        },
      });
      final container = ProviderContainer(
        overrides: [firestoreProvider.overrideWith((ref) => firestore)],
      );
      addTearDown(container.dispose);

      final preferences = await container.read(
        settingsPreferencesProvider('partial-categories').future,
      );

      expect(
        preferences.isCategoryEnabled(
          SettingsNotificationCategory.orderPayment,
        ),
        isFalse,
      );
      expect(
        preferences.isCategoryEnabled(
          SettingsNotificationCategory.auctionActivity,
        ),
        isTrue,
      );
      expect(
        preferences.isCategoryEnabled(
          SettingsNotificationCategory.shippingAndReceipt,
        ),
        isTrue,
      );
      expect(
        preferences.isCategoryEnabled(SettingsNotificationCategory.system),
        isTrue,
      );
    },
  );

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

  test(
    'theme preference provider falls back to system on unknown value',
    () async {
      SharedPreferences.setMockInitialValues({'settings.themeMode': 'INVALID'});
      final sharedPreferences = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(themeModePreferenceProvider),
        SettingsThemeModePreference.system,
      );
    },
  );
}
