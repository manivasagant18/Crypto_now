import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:coinlens/core/format.dart';
import 'package:coinlens/core/theme.dart';
import 'package:coinlens/models/chart_point.dart';

/// Interactive line chart: touch tooltip with a crosshair, high and low labels.
class PriceChart extends StatelessWidget {
  const PriceChart({super.key, required this.points, this.height = 200});

  final List<ChartPoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    final muted = mutedText(context);
    if (points.length < 2) {
      return Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: cardColor(context), borderRadius: BorderRadius.circular(12)),
        child: Text('No chart data for this range', style: TextStyle(color: muted)),
      );
    }

    final prices = points.map((p) => p.price).toList();
    final hi = prices.reduce(max);
    final lo = prices.reduce(min);
    final pad = (hi - lo) == 0 ? 1.0 : (hi - lo) * 0.08;
    final spots = [
      for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].price),
    ];

    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      decoration: BoxDecoration(color: cardColor(context), borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Positioned.fill(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (points.length - 1).toDouble(),
                minY: lo - pad,
                maxY: hi + pad,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touched) => touched.map((s) {
                      final p = points[s.spotIndex];
                      return LineTooltipItem(
                        '${formatPrice(p.price)}\n${formatChartTime(p.time)}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                  getTouchedSpotIndicator: (barData, indexes) => indexes
                      .map(
                        (_) => TouchedSpotIndicatorData(
                          FlLine(color: muted, strokeWidth: 1, dashArray: [4, 4]),
                          FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                              radius: 4,
                              color: kAccent,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.2,
                    barWidth: 2,
                    color: kAccent,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: kAccent.withValues(alpha: 0.08)),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 4,
            child: Text('High ${formatPrice(hi)}', style: TextStyle(color: muted, fontSize: 11)),
          ),
          Positioned(
            bottom: 2,
            left: 4,
            child: Text('Low ${formatPrice(lo)}', style: TextStyle(color: muted, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
