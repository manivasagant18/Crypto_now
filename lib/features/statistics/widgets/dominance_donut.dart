import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:coinlens/core/format.dart';
import 'package:coinlens/core/theme.dart';

const kEthBlue = Color(0xFF93C5FD);
const kOthersGrey = Color(0xFFCBD5E1);

/// Donut chart of BTC, ETH and other market share, with BTC's share in the middle.
class DominanceDonut extends StatelessWidget {
  const DominanceDonut({super.key, required this.btc, required this.eth, required this.others});

  final double btc;
  final double eth;
  final double others;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 38,
              sections: [
                PieChartSectionData(value: btc, color: kAccent, radius: 18, showTitle: false),
                PieChartSectionData(value: eth, color: kEthBlue, radius: 18, showTitle: false),
                PieChartSectionData(value: others, color: kOthersGrey, radius: 18, showTitle: false),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${btc.toStringAsFixed(1)}%',
                style: TextStyle(color: strongText(context), fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Text('BTC', style: TextStyle(color: mutedText(context), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

/// One legend line next to the donut: colour dot, name and share.
class DominanceLegendRow extends StatelessWidget {
  const DominanceLegendRow({super.key, required this.color, required this.label, required this.pct});

  final Color color;
  final String label;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final strong = strongText(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(color: strong, fontSize: 14))),
          Text(
            '${pct.toStringAsFixed(1)}%',
            style: TextStyle(
              color: strong,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFeatures: kTabular,
            ),
          ),
        ],
      ),
    );
  }
}
