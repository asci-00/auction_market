import 'dart:io';

import 'package:flutter/foundation.dart';

import '../error/app_error.dart';

enum AppEnvironment {
  dev,
  staging,
  prod;

  static AppEnvironment parse(String rawValue) {
    switch (rawValue) {
      case 'dev':
        return AppEnvironment.dev;
      case 'staging':
        return AppEnvironment.staging;
      case 'prod':
        return AppEnvironment.prod;
      default:
        throw const AppConfigurationException(
          'APP_ENV must be one of dev, staging, or prod.',
        );
    }
  }
}

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.useFirebaseEmulators,
    required this.tossClientKey,
  });

  factory AppConfig.fromEnvironment() {
    final environment = AppEnvironment.parse(_readRequired('APP_ENV'));
    final useFirebaseEmulators = _readBool(
      'USE_FIREBASE_EMULATORS',
      defaultValue: environment == AppEnvironment.dev,
    );

    final config = AppConfig(
      environment: environment,
      useFirebaseEmulators: useFirebaseEmulators,
      tossClientKey: _readOptional('TOSS_CLIENT_KEY'),
    );

    if (environment != AppEnvironment.dev &&
        !config.hasMeaningfulTossClientKey) {
      throw const AppConfigurationException(
        'TOSS_CLIENT_KEY is required outside dev builds.',
      );
    }

    return config;
  }

  final AppEnvironment environment;
  final bool useFirebaseEmulators;
  final String? tossClientKey;

  bool get hasMeaningfulTossClientKey => _isMeaningful(tossClientKey);

  String get platformLabel {
    if (kIsWeb) {
      return 'web';
    }
    if (Platform.isIOS) {
      return 'ios';
    }
    if (Platform.isAndroid) {
      return 'android';
    }
    return Platform.operatingSystem;
  }

  String get emulatorHost {
    if (kIsWeb) {
      return '127.0.0.1';
    }
    if (Platform.isAndroid) {
      return '10.0.2.2';
    }
    return '127.0.0.1';
  }

  static String _readRequired(String key) {
    final value = _readOptional(key);
    if (!_isMeaningful(value)) {
      throw AppConfigurationException(
        '$key is missing. Provide it in dart_defines.json before launching the app.',
      );
    }
    return value!.trim();
  }

  static String? _readOptional(String key) {
    const values = <String, String>{
      'APP_ENV': String.fromEnvironment('APP_ENV'),
      'USE_FIREBASE_EMULATORS': String.fromEnvironment(
        'USE_FIREBASE_EMULATORS',
      ),
      'TOSS_CLIENT_KEY': String.fromEnvironment('TOSS_CLIENT_KEY'),
    };
    final value = values[key];
    return value == null || value.trim().isEmpty ? null : value.trim();
  }

  static bool _readBool(String key, {required bool defaultValue}) {
    final value = _readOptional(key);
    if (value == null) {
      return defaultValue;
    }
    switch (value.toLowerCase()) {
      case 'true':
        return true;
      case 'false':
        return false;
      default:
        throw AppConfigurationException('$key must be true or false.');
    }
  }
}

bool _isMeaningful(String? value) {
  if (value == null) {
    return false;
  }

  final normalized = value.trim();
  return normalized.isNotEmpty &&
      !normalized.startsWith('TODO_') &&
      !normalized.startsWith('TODO_FROM_');
}
