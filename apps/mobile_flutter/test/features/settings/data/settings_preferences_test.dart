import 'package:auction_market_mobile/features/settings/application/settings_preferences_service.dart';
import 'package:auction_market_mobile/features/settings/data/settings_preferences.dart';
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

  test('map parsing falls back to defaults when preferences are missing', () {
    final preferences = SettingsPreferences.fromMap(const {});

    expect(preferences.pushEnabled, isTrue);
    for (final category in SettingsNotificationCategory.values) {
      expect(preferences.isCategoryEnabled(category), isTrue);
    }
  });

  test('map parsing keeps notification category overrides', () {
    final preferences = SettingsPreferences.fromMap({
      'preferences': {
        'notificationCategories': {'system': false},
      },
    });

    expect(
      preferences.isCategoryEnabled(SettingsNotificationCategory.system),
      isFalse,
    );
  });

  test(
    'map parsing keeps pushEnabled and defaults missing category values',
    () {
      final preferences = SettingsPreferences.fromMap({
        'preferences': {'pushEnabled': false},
      });

      expect(preferences.pushEnabled, isFalse);
      for (final category in SettingsNotificationCategory.values) {
        expect(preferences.isCategoryEnabled(category), isTrue);
      }
    },
  );

  test('map parsing merges partial notification categories with defaults', () {
    final preferences = SettingsPreferences.fromMap({
      'preferences': {
        'notificationCategories': {'orderPayment': false},
      },
    });

    expect(
      preferences.isCategoryEnabled(SettingsNotificationCategory.orderPayment),
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
