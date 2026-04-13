import 'dart:io';

import 'package:flutter/foundation.dart';

import '../error/app_error.dart';

enum AppEnvironment {
  dev,
  prod;

  static AppEnvironment parse(String rawValue) {
    switch (rawValue) {
      case 'dev':
        return AppEnvironment.dev;
      case 'prod':
        return AppEnvironment.prod;
      default:
        throw const AppConfigurationException(
          'APP_ENV must be one of dev or prod.',
        );
    }
  }
}

enum AppBackendTransport {
  firebaseCallable,
  http;

  static AppBackendTransport parse(String rawValue) {
    switch (rawValue) {
      case 'firebase_callable':
        return AppBackendTransport.firebaseCallable;
      case 'http':
        return AppBackendTransport.http;
      default:
        throw const AppConfigurationException(
          'APP_BACKEND_TRANSPORT must be one of firebase_callable or http.',
        );
    }
  }
}

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.backendTransport,
    required this.apiBaseUrl,
    required this.useFirebaseEmulators,
    required this.tossClientKey,
    required this.firebaseEmulatorHostOverride,
  });

  factory AppConfig.fromEnvironment() {
    final environment = AppEnvironment.parse(_readRequired('APP_ENV'));
    return AppConfig.fromValues(
      environment: environment,
      backendTransportRawValue: _readOptional('APP_BACKEND_TRANSPORT'),
      apiBaseUrl: _readOptional('APP_API_BASE_URL'),
      useFirebaseEmulatorsRawValue: _readOptional('USE_FIREBASE_EMULATORS'),
      tossClientKey: _readOptional('TOSS_CLIENT_KEY'),
      firebaseEmulatorHostOverride: _readOptional('FIREBASE_EMULATOR_HOST'),
    );
  }

  factory AppConfig.fromValues({
    required AppEnvironment environment,
    String? backendTransportRawValue,
    String? apiBaseUrl,
    String? useFirebaseEmulatorsRawValue,
    String? tossClientKey,
    String? firebaseEmulatorHostOverride,
  }) {
    final backendTransport = AppBackendTransport.parse(
      backendTransportRawValue ??
          (environment == AppEnvironment.dev ? 'http' : 'firebase_callable'),
    );
    final useFirebaseEmulators = _readBoolValue(
      useFirebaseEmulatorsRawValue,
      'USE_FIREBASE_EMULATORS',
      defaultValue: false,
    );

    final config = AppConfig(
      environment: environment,
      backendTransport: backendTransport,
      apiBaseUrl: _meaningfulOrNull(apiBaseUrl),
      useFirebaseEmulators: useFirebaseEmulators,
      tossClientKey: _meaningfulOrNull(tossClientKey),
      firebaseEmulatorHostOverride: _meaningfulOrNull(
        firebaseEmulatorHostOverride,
      ),
    );

    if (config.backendTransport == AppBackendTransport.http &&
        !config.hasApiBaseUrl) {
      throw const AppConfigurationException(
        'APP_API_BASE_URL is required when APP_BACKEND_TRANSPORT=http.',
      );
    }
    if (config.backendTransport == AppBackendTransport.http &&
        !_isValidHttpBaseUrl(config.apiBaseUrl!)) {
      throw const AppConfigurationException(
        'APP_API_BASE_URL must be a valid http or https URL.',
      );
    }

    if (config.isProd && !config.hasMeaningfulTossClientKey) {
      throw const AppConfigurationException(
        'TOSS_CLIENT_KEY is required in prod builds.',
      );
    }

    return config;
  }

  final AppEnvironment environment;
  final AppBackendTransport backendTransport;
  final String? apiBaseUrl;
  final bool useFirebaseEmulators;
  final String? tossClientKey;
  final String? firebaseEmulatorHostOverride;

  bool get isDev => environment == AppEnvironment.dev;

  bool get isProd => environment == AppEnvironment.prod;

  bool get usesHttpBackend => backendTransport == AppBackendTransport.http;

  bool get hasApiBaseUrl => _isMeaningful(apiBaseUrl);

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
    final overrideHost = firebaseEmulatorHostOverride;
    if (_isMeaningful(overrideHost)) {
      return overrideHost!.trim();
    }
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
        '$key is missing. Provide it in the active dart_defines.<flavor>.json before launching the app.',
      );
    }
    return value!.trim();
  }

  static String? _readOptional(String key) {
    const values = <String, String>{
      'APP_ENV': String.fromEnvironment('APP_ENV'),
      'APP_BACKEND_TRANSPORT': String.fromEnvironment('APP_BACKEND_TRANSPORT'),
      'APP_API_BASE_URL': String.fromEnvironment('APP_API_BASE_URL'),
      'USE_FIREBASE_EMULATORS': String.fromEnvironment(
        'USE_FIREBASE_EMULATORS',
      ),
      'FIREBASE_EMULATOR_HOST': String.fromEnvironment(
        'FIREBASE_EMULATOR_HOST',
      ),
      'TOSS_CLIENT_KEY': String.fromEnvironment('TOSS_CLIENT_KEY'),
    };
    final value = values[key];
    return value == null || value.trim().isEmpty ? null : value.trim();
  }

  static bool _readBoolValue(
    String? value,
    String key, {
    required bool defaultValue,
  }) {
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

String? _meaningfulOrNull(String? value) {
  return _isMeaningful(value) ? value!.trim() : null;
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

bool _isValidHttpBaseUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null) {
    return false;
  }
  if (!uri.isAbsolute || uri.host.isEmpty) {
    return false;
  }
  return uri.scheme == 'http' || uri.scheme == 'https';
}
