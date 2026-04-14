import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_config/app_config.dart';
import '../error/app_error.dart';

class AppBootstrapState {
  const AppBootstrapState({required this.config});

  final AppConfig config;
}

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});

final appBootstrapProvider = FutureProvider<AppBootstrapState>((ref) async {
  final config = ref.watch(appConfigProvider);
  await FirebaseBootstrap.initialize(config);
  return AppBootstrapState(config: config);
});

class FirebaseBootstrap {
  static bool _emulatorsConfigured = false;
  static bool _appCheckConfigured = false;

  static Future<void> initialize(AppConfig config) async {
    try {
      if (kIsWeb) {
        throw const AppConfigurationException(
          'Web is out of scope for this project. Run on iOS or Android.',
        );
      }

      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      if (!_appCheckConfigured) {
        final debugToken = _appCheckDebugToken();
        await FirebaseAppCheck.instance.activate(
          providerAndroid: kReleaseMode
              ? const AndroidPlayIntegrityProvider()
              : AndroidDebugProvider(debugToken: debugToken),
          providerApple: kReleaseMode
              ? const AppleDeviceCheckProvider()
              : AppleDebugProvider(debugToken: debugToken),
        );
        _appCheckConfigured = true;
      }

      if (config.useFirebaseEmulators && !_emulatorsConfigured) {
        await FirebaseAuth.instance.useAuthEmulator(config.emulatorHost, 9099);
        FirebaseFirestore.instance.useFirestoreEmulator(
          config.emulatorHost,
          8080,
        );
        FirebaseFunctions.instance.useFunctionsEmulator(
          config.emulatorHost,
          5001,
        );
        await FirebaseStorage.instance.useStorageEmulator(
          config.emulatorHost,
          9199,
        );
        _emulatorsConfigured = true;
      }

      await FirebaseAuth.instance.authStateChanges().first;
    } on AppConfigurationException {
      rethrow;
    } on FirebaseException catch (error) {
      throw AppBootstrapException(
        'Firebase 초기화에 실패했습니다.',
        details:
            '${error.message ?? '네이티브 Firebase 설정을 읽지 못했습니다.'} iOS는 Runner/GoogleService-Info.plist, Android는 app/google-services.json 파일과 앱 식별자를 확인해 주세요.',
      );
    } catch (error) {
      throw AppBootstrapException(
        '앱 시작 중 알 수 없는 오류가 발생했습니다.',
        details: error.toString(),
      );
    }
  }
}

String? _appCheckDebugToken() {
  const override = String.fromEnvironment('APP_CHECK_DEBUG_TOKEN');
  final value = override.trim();
  return value.isEmpty ? null : value;
}
