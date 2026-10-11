import 'package:flutter/material.dart';
import 'package:test23/widgets/tracking/card_tracking_chart.dart';

class CardRiwayatSampah extends StatelessWidget {
  final String totalWeight;
  final String targetWeight;
  final String trendBadge;
  final List<dynamic>? rawData;
  final List<Map<String, dynamic>>? chartData;

  const CardRiwayatSampah({
    super.key,
    this.totalWeight = '0.0',
    this.targetWeight = 'Target: 20 kg',
    this.trendBadge = '+0 setoran',
    this.rawData,
    this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    return CardTrackingChart(
      isBeranda: true,
      targetWeight: targetWeight,
      totalDisetor: '$totalWeight kg',
      trendPercent: trendBadge,
      rawData: rawData,
    );
  }
}
