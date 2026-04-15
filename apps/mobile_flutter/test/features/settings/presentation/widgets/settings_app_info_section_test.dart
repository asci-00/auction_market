import 'package:auction_market_mobile/core/app_config/app_config.dart';
import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/features/settings/presentation/widgets/settings_app_info_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows debug push probe action and invokes callback', (
    tester,
  ) async {
    var tapped = 0;
    await tester.pumpWidget(
      _TestApp(
        child: SettingsAppInfoSection(
          sectionTitle: 'App information',
          sectionDescription: 'Version and licenses',
          versionLabel: 'Version',
          versionValue: '1.0.0 (1)',
          licensesLabel: 'Licenses',
          licensesDescription: 'Open source notices',
          onOpenLicenses: () {},
          config: _debugConfig,
          debugTitle: 'Developer',
          debugDescription: 'Non-release only',
          debugPushProbeTitle: 'Push probe',
          debugPushProbeDescription: 'Trigger push probe',
          debugPushProbeActionLabel: 'Send',
          onDebugPushProbe: () => tapped++,
        ),
      ),
    );

    await tester.pump();

    expect(
      find.byKey(const ValueKey('settings-debug-push-probe-action')),
      findsOneWidget,
    );
    expect(find.text('Push probe'), findsOneWidget);
    expect(find.text('Send'), findsOneWidget);

    await tester.tap(find.text('Send'));
    await tester.pump();

    expect(tapped, 1);
  });

  testWidgets('hides debug push probe action without callback', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: SettingsAppInfoSection(
          sectionTitle: 'App information',
          sectionDescription: 'Version and licenses',
          versionLabel: 'Version',
          versionValue: '1.0.0 (1)',
          licensesLabel: 'Licenses',
          licensesDescription: 'Open source notices',
          onOpenLicenses: () {},
          config: _debugConfig,
          debugTitle: 'Developer',
          debugDescription: 'Non-release only',
          debugPushProbeTitle: 'Push probe',
          debugPushProbeDescription: 'Trigger push probe',
          debugPushProbeActionLabel: 'Send',
        ),
      ),
    );

    await tester.pump();

    expect(
      find.byKey(const ValueKey('settings-debug-push-probe-action')),
      findsNothing,
    );
    expect(find.text('Push probe'), findsNothing);
  });

  testWidgets('shows debug push probe loading state while in flight', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: SettingsAppInfoSection(
          sectionTitle: 'App information',
          sectionDescription: 'Version and licenses',
          versionLabel: 'Version',
          versionValue: '1.0.0 (1)',
          licensesLabel: 'Licenses',
          licensesDescription: 'Open source notices',
          onOpenLicenses: () {},
          config: _debugConfig,
          debugTitle: 'Developer',
          debugDescription: 'Non-release only',
          debugPushProbeTitle: 'Push probe',
          debugPushProbeDescription: 'Trigger push probe',
          debugPushProbeActionLabel: 'Send',
          onDebugPushProbe: () {},
          isDebugPushProbeInFlight: true,
        ),
      ),
    );

    await tester.pump();

    expect(
      find.byKey(const ValueKey('settings-debug-push-probe-action')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('settings-debug-push-probe-progress')),
      findsOneWidget,
    );
    expect(find.text('Send'), findsNothing);

    final button = tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const ValueKey('settings-debug-push-probe-action')),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.onPressed, isNull);
  });
}

const _debugConfig = AppConfig(
  environment: AppEnvironment.dev,
  backendTransport: AppBackendTransport.http,
  apiBaseUrl: 'https://example.com',
  useFirebaseEmulators: false,
  tossClientKey: 'test_client_key',
  firebaseEmulatorHostOverride: null,
);

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedAppLocales,
      localeResolutionCallback: resolveAppLocale,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }
}
