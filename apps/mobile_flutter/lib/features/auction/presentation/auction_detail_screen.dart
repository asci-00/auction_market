import 'package:fl_chart/fl_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/l10n/locale_menu_action.dart';

class AuctionDetailScreen extends StatelessWidget {
  final String auctionId;
  const AuctionDetailScreen({super.key, required this.auctionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('auction.title'.tr(namedArgs: {'id': auctionId})),
        actions: const [AppLocaleMenuAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 200, child: Placeholder()),
          Text('auction.summary'.tr()),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 10),
                      FlSpot(1, 11),
                      FlSpot(2, 13),
                      FlSpot(3, 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => _openBid(context),
                child: Text('auction.bid'.tr()),
              ),
              OutlinedButton(
                onPressed: () {},
                child: Text('auction.buyNow'.tr()),
              ),
              OutlinedButton(
                onPressed: () {},
                child: Text('auction.autoBid'.tr()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openBid(BuildContext context) async {
    final auth = LocalAuthentication();
    bool ok = false;
    try {
      ok = await auth.authenticate(
        localizedReason: 'auction.bidAuthReason'.tr(),
      );
    } catch (_) {
      ok = true;
    }
    if (!context.mounted) return;
    if (!ok) return;

    await showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'auction.bidAmount'.tr()),
            ),
            const SizedBox(height: 8),
            FilledButton(onPressed: null, child: Text('auction.placeBid'.tr())),
          ],
        ),
      ),
    );
  }
}
