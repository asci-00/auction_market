import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:auction_market_mobile/core/firebase/firebase_providers.dart';
import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/features/auction/application/auction_detail_action_service.dart';
import 'package:auction_market_mobile/features/auction/data/auction_bid_history_entry.dart';
import 'package:auction_market_mobile/features/auction/data/auction_detail_view_data.dart';
import 'package:auction_market_mobile/features/auction/presentation/auction_detail_screen.dart';
import 'package:auction_market_mobile/features/auction/presentation/auction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'buy now shows pending state then navigates with returned order id',
    (tester) async {
      final completer = Completer<String?>();
      final actionService = _FakeAuctionDetailActionService(
        buyNowHandler: ({required auctionId}) => completer.future,
      );

      await tester.pumpWidget(
        _buildScreen(
          actionService: actionService,
          auctionState: _sampleState(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(OutlinedButton).first);
      await tester.pump();

      expect(find.text('Processing buy now...'), findsOneWidget);
      expect(
        find.text(
          'Processing buy now. Other actions will reopen as soon as this step finishes.',
        ),
        findsOneWidget,
      );

      completer.complete('order-123');
      await tester.pumpAndSettle();

      expect(find.text('Order route: order-123'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 2300));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('buy now failure clears pending state and shows error feedback', (
    tester,
  ) async {
    final actionService = _FakeAuctionDetailActionService(
      buyNowHandler: ({required auctionId}) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        throw FirebaseFunctionsException(
          code: 'internal',
          message: 'Please try again',
        );
      },
    );

    await tester.pumpWidget(
      _buildScreen(actionService: actionService, auctionState: _sampleState()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(OutlinedButton).first);
    await tester.pump();
    expect(find.text('Processing buy now...'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Processing buy now...'), findsNothing);
    expect(find.text('Please try again'), findsOneWidget);
    expect(
      find.widgetWithText(OutlinedButton, 'Buy now ₩18,000'),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();
  });
}

Widget _buildScreen({
  required AuctionDetailActionService actionService,
  required AuctionViewState auctionState,
}) {
  return ProviderScope(
    overrides: [
      firebaseAuthProvider.overrideWith(
        (ref) => _FakeFirebaseAuth(_FakeUser('buyer1')),
      ),
      auctionViewModelProvider(
        'auction-live',
      ).overrideWith(() => _FakeAuctionViewModel(auctionState)),
      auctionDetailActionServiceProvider.overrideWith((ref) => actionService),
    ],
    child: MaterialApp.router(
      builder: FToastBuilder(),
      locale: const Locale('en'),
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedAppLocales,
      localeResolutionCallback: resolveAppLocale,
      routerConfig: GoRouter(
        initialLocation: '/auction/auction-live',
        routes: [
          GoRoute(
            path: '/auction/:auctionId',
            builder: (context, state) => AuctionDetailScreen(
              auctionId: state.pathParameters['auctionId']!,
            ),
          ),
          GoRoute(
            path: '/orders/:orderId',
            builder: (context, state) =>
                Text('Order route: ${state.pathParameters['orderId']}'),
          ),
        ],
      ),
    ),
  );
}

class _FakeAuctionViewModel extends AuctionViewModel {
  _FakeAuctionViewModel(this._value);

  final AuctionViewState _value;

  @override
  Future<AuctionViewState> build(String auctionId) async => _value;
}

class _FakeAuctionDetailActionService extends AuctionDetailActionService {
  _FakeAuctionDetailActionService({this.buyNowHandler})
    : super(_FakeFirebaseFunctions());

  final Future<String?> Function({required String auctionId})? buyNowHandler;

  @override
  Future<String?> buyNow({required String auctionId}) async {
    return buyNowHandler?.call(auctionId: auctionId);
  }
}

class _FakeFirebaseFunctions extends Fake implements FirebaseFunctions {}

class _FakeFirebaseAuth extends Fake implements FirebaseAuth {
  _FakeFirebaseAuth(this._user);

  final User? _user;

  @override
  User? get currentUser => _user;
}

class _FakeUser extends Fake implements User {
  _FakeUser(this._uid);

  final String _uid;

  @override
  String get uid => _uid;
}

AuctionViewState _sampleState() {
  return AuctionViewState(
    detail: AuctionDetailViewData(
      id: 'auction-live',
      itemId: 'item-live',
      titleSnapshot: 'Signed Album',
      heroImageUrl: 'https://example.com/1.jpg',
      imageUrls: const <String>[
        'https://example.com/1.jpg',
        'https://example.com/2.jpg',
      ],
      description: 'Factory-sealed with hologram proof.',
      categorySub: 'IDOL_MD',
      condition: 'LIKE_NEW',
      sellerId: 'seller1',
      status: 'LIVE',
      currentPrice: 13200,
      buyNowPrice: 18000,
      orderId: null,
      endAt: DateTime.utc(2026, 4, 1, 18),
    ),
    bidHistory: const [AuctionBidHistoryEntry(amount: 13200, createdAt: null)],
  );
}
