import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class AuctionDetailScreen extends StatelessWidget {
  final String auctionId;
  const AuctionDetailScreen({super.key, required this.auctionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('경매 상세 #$auctionId')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 200, child: Placeholder()),
          const Text('현재 최고가 120,000원 / 입찰자 4명 / 남은시간 00:14:20'),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(LineChartData(lineBarsData: [LineChartBarData(spots: const [FlSpot(0, 10), FlSpot(1, 11), FlSpot(2, 13), FlSpot(3, 16)])])),
          ),
          const SizedBox(height: 16),
          Wrap(spacing: 8, children: [
            ElevatedButton(onPressed: () => _openBid(context), child: const Text('입찰하기')),
            OutlinedButton(onPressed: () {}, child: const Text('즉시구매')),
            OutlinedButton(onPressed: () {}, child: const Text('자동입찰 설정(Flag)')),
          ]),
        ],
      ),
    );
  }

  Future<void> _openBid(BuildContext context) async {
    final auth = LocalAuthentication();
    bool ok = false;
    try {
      ok = await auth.authenticate(localizedReason: '입찰 인증');
    } catch (_) {
      ok = true;
    }
    if (!context.mounted) return;
    if (!ok) return;

    await showModalBottomSheet(
      context: context,
      builder: (_) => const Padding(
        padding: EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(decoration: InputDecoration(labelText: '입찰 금액')),
          SizedBox(height: 8),
          FilledButton(onPressed: null, child: Text('placeBid 호출(연동 포인트)')),
        ]),
      ),
    );
  }
}
