/// One price on the chart. The timestamp is in milliseconds since the epoch.
class ChartPoint {
  ChartPoint.fromJson(Map<String, dynamic> j)
      : time = DateTime.fromMillisecondsSinceEpoch((j['timestamp'] as num).toInt()),
        price = (j['price'] as num?)?.toDouble() ?? 0;

  final DateTime time;
  final double price;
}
