import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/features/sell/presentation/sell_validation_state.dart';
import 'package:auction_market_mobile/features/sell/presentation/widgets/sell_action_panel.dart';
import 'package:auction_market_mobile/features/sell/presentation/widgets/sell_image_picker_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  testWidgets('sell action panel renders validation summary near submit', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        child: SellActionPanel(
          itemId: 'draft-42',
          isSavingDraft: false,
          isPublishing: false,
          onSaveDraft: _noop,
          onPublish: _noop,
          validationMode: SellValidationMode.publish,
          validationSummary: [
            'Enter a valid start price before publishing.',
            'Publishing requires at least one gallery image.',
          ],
        ),
      ),
    );

    await tester.pump();

    expect(
      find.text('Complete these details before publishing the auction'),
      findsOneWidget,
    );
    expect(
      find.text('Enter a valid start price before publishing.'),
      findsOneWidget,
    );
    expect(
      find.text('Publishing requires at least one gallery image.'),
      findsOneWidget,
    );
  });

  testWidgets('sell image picker panel renders inline error text', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        child: SellImagePickerPanel(
          title: 'Authentication images',
          description: 'Upload proof before saving.',
          buttonLabel: 'Choose authentication images',
          existingUrls: <String>[],
          newFiles: <XFile>[],
          onPickPressed: _noop,
          errorText: 'Goods drafts need at least one authentication image.',
        ),
      ),
    );

    await tester.pump();

    expect(
      find.text('Goods drafts need at least one authentication image.'),
      findsOneWidget,
    );
  });
}

void _noop() {}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedAppLocales,
      localeResolutionCallback: resolveAppLocale,
      home: Scaffold(body: Center(child: child)),
    );
  }
}
