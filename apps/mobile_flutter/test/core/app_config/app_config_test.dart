import 'package:auction_market_mobile/core/app_config/app_config.dart';
import 'package:auction_market_mobile/core/error/app_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dev defaults to http transport without emulators', () {
    final config = AppConfig.fromValues(
      environment: AppEnvironment.dev,
      apiBaseUrl: 'https://dev.example.com',
    );

    expect(config.backendTransport, AppBackendTransport.http);
    expect(config.useFirebaseEmulators, isFalse);
  });

  test('http transport requires an api base url', () {
    expect(
      () => AppConfig.fromValues(
        environment: AppEnvironment.dev,
        backendTransportRawValue: 'http',
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

  test('prod requires toss client key', () {
    expect(
      () => AppConfig.fromValues(
        environment: AppEnvironment.prod,
        backendTransportRawValue: 'firebase_callable',
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

  test('prod callable config accepts empty api base url', () {
    final config = AppConfig.fromValues(
      environment: AppEnvironment.prod,
      backendTransportRawValue: 'firebase_callable',
      tossClientKey: 'live_ck_example',
    );

    expect(config.usesHttpBackend, isFalse);
    expect(config.apiBaseUrl, isNull);
  });
}
