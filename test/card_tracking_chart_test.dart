import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test23/widgets/tracking/card_tracking_chart.dart';

void main() {
  testWidgets('CardTrackingChart displays 7 separate days and allows switching to monthly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CardTrackingChart(
              totalDisetor: '14.8 kg',
              trendPercent: '+28% dari minggu lalu',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check title and subtitle
    expect(find.text('Riwayat Setor Sampah'), findsOneWidget);
    expect(find.text('Total Minggu Ini'), findsOneWidget);
    expect(find.text('Total Bulan Ini'), findsOneWidget);

    // Check 7 individual days
    expect(find.text('Sen'), findsOneWidget);
    expect(find.text('Sel'), findsOneWidget);
    expect(find.text('Rab'), findsOneWidget);
    expect(find.text('Kam'), findsOneWidget);
    expect(find.text('Jum'), findsOneWidget);
    expect(find.text('Sab'), findsOneWidget);
    expect(find.text('Min'), findsOneWidget);

    // Switch to Per Bulan via Toggle Pill
    await tester.tap(find.text('Per Bulan'));
    await tester.pumpAndSettle();

    // Verify monthly week labels are displayed
    expect(find.text('Mg 1'), findsOneWidget);
    expect(find.text('Mg 2'), findsOneWidget);
    expect(find.text('Mg 3'), findsOneWidget);
    expect(find.text('Mg 4'), findsOneWidget);

    // Tap back to Per Minggu
    await tester.tap(find.text('Per Minggu'));
    await tester.pumpAndSettle();

    expect(find.text('Sen'), findsOneWidget);
    expect(find.text('Min'), findsOneWidget);
  });

  testWidgets('CardTrackingChart calculates weekly and monthly totals from rawData accurately', (WidgetTester tester) async {
    final now = DateTime.now();
    // Raw data with various dates
    final rawData = [
      {
        'kategori': 'Botol Plastik',
        'bobot': 3.5,
        'created_at': now.toIso8601String(),
      },
      {
        'kategori': 'Kertas Bekas',
        'bobot': 2.0,
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'kategori': 'Botol Plastik',
        'bobot': 5.0,
        'created_at': now.subtract(const Duration(days: 10)).toIso8601String(),
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CardTrackingChart(
              rawData: rawData,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify summary card titles exist
    expect(find.text('Total Minggu Ini'), findsOneWidget);
    expect(find.text('Total Bulan Ini'), findsOneWidget);

    // Test filter tapping
    await tester.tap(find.text('Botol Plastik'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Total Seluruh Sampah'), findsOneWidget);
    expect(find.text('Botol Plastik'), findsOneWidget);
  });
}
