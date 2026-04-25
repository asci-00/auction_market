import 'package:auction_market_mobile/core/app_config/app_config.dart';
import 'package:auction_market_mobile/core/error/app_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dev defaults to http backend contract', () {
    final config = AppConfig.fromValues(
      environment: AppEnvironment.dev,
      apiBaseUrl: 'https://dev.example.com',
      tossClientKey: 'test_ck_example',
    );

    expect(config.backendTransport, AppBackendTransport.http);
    expect(config.usesHttpBackend, isTrue);
    expect(config.useFirebaseEmulators, isFalse);
  });

  test('prod also uses the same http backend contract', () {
    final config = AppConfig.fromValues(
      environment: AppEnvironment.prod,
      apiBaseUrl: 'https://api.example.com',
      tossClientKey: 'live_ck_example',
    );

    expect(config.backendTransport, AppBackendTransport.http);
    expect(config.usesHttpBackend, isTrue);
  });

  test('firebase callable transport is rejected', () {
    expect(
      () => AppConfig.fromValues(
        environment: AppEnvironment.prod,
        backendTransportRawValue: 'firebase_callable',
        apiBaseUrl: 'https://api.example.com',
        tossClientKey: 'live_ck_example',
      ),
      throwsA(
        isA<AppConfigurationException>().having(
          (error) => error.message,
          'message',
          contains('firebase_callable is no longer supported'),
        ),
      ),
    );
  });

  test('http backend rejects malformed api base url', () {
    expect(
      () => AppConfig.fromValues(
        environment: AppEnvironment.dev,
        backendTransportRawValue: 'http',
        apiBaseUrl: 'not-a-url',
        tossClientKey: 'test_ck_example',
      ),
      throwsA(
        isA<AppConfigurationException>().having(
          (error) => error.message,
          'message',
          contains('must be a valid http or https URL'),
        ),
      ),
    );
  });

  test('http backend requires an api base url', () {
    expect(
      () => AppConfig.fromValues(
        environment: AppEnvironment.dev,
        backendTransportRawValue: 'http',
        tossClientKey: 'test_ck_example',
      ),
      throwsA(
        isA<AppConfigurationException>().having(
          (error) => error.message,
          'message',
          contains('APP_API_BASE_URL'),
        ),
      ),
    );
  });

  test('http backend requires toss client key', () {
    expect(
      () => AppConfig.fromValues(
        environment: AppEnvironment.dev,
        backendTransportRawValue: 'http',
        apiBaseUrl: 'https://dev.example.com',
      ),
      throwsA(
        isA<AppConfigurationException>().having(
          (error) => error.message,
          'message',
          contains('TOSS_CLIENT_KEY'),
        ),
      ),
    );
  });

  test('local emulator can use the same http backend contract', () {
    final config = AppConfig.fromValues(
      environment: AppEnvironment.dev,
      backendTransportRawValue: 'http',
      apiBaseUrl: 'http://127.0.0.1:8765',
      useFirebaseEmulatorsRawValue: 'true',
      tossClientKey: 'test_ck_example',
    );

    expect(config.backendTransport, AppBackendTransport.http);
    expect(config.usesHttpBackend, isTrue);
    expect(config.useFirebaseEmulators, isTrue);
  });
}
