import 'dart:ui' show FontFeature;

import 'package:intl/intl.dart';

/// Tabular digits, so prices don't shift width when they update.
final kTabular = [const FontFeature.tabularFigures()];

final _price2 = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
final _price4 = NumberFormat.currency(symbol: r'$', decimalDigits: 4);
final _price6 = NumberFormat.currency(symbol: r'$', decimalDigits: 6);
final _compactUsd = NumberFormat.compactCurrency(symbol: r'$', decimalDigits: 2)
  ..minimumFractionDigits = 2;
final _compact = NumberFormat.compact();
final _int = NumberFormat('#,##0');
final _wholePercent = NumberFormat('+#,##0;-#,##0');
final _date = DateFormat('MMM d, yyyy');
final _chartTime = DateFormat('MMM d, h:mm a');

/// Coins at $1 and above get 2 decimals. Cheaper coins get more precision.
String formatPrice(double v) {
  if (v >= 1) return _price2.format(v);
  if (v >= 0.01) return _price4.format(v);
  return _price6.format(v);
}

/// Money in short form: $1.33T, $68.00B, $4.10M.
String compactUsd(double v) => _compactUsd.format(v);

/// Counts and supply in short form: 19.8M, 14.8K.
String compactNumber(num v) => _compact.format(v);

/// Supply with the coin's symbol: "19.8M BTC".
String formatSupply(num v, String symbol) => '${compactNumber(v)} $symbol';

/// Whole numbers with separators: 14,812.
String formatInt(num v) => _int.format(v);

/// Signed percent with one decimal: +2.4%, -1.1%.
String percent(double v) => '${v >= 0 ? '+' : ''}${v.toStringAsFixed(1)}%';

/// Signed percent for very large changes: +99,325%.
String percentWhole(double v) => '${_wholePercent.format(v)}%';

/// Formats an ISO date such as 2024-03-14 as "Mar 14, 2024".
String formatDate(String iso) {
  final d = DateTime.tryParse(iso)?.toUtc();
  return d == null ? '—' : _date.format(d);
}

/// Tooltip time on the chart: "Jun 7, 5:19 AM".
String formatChartTime(DateTime t) => _chartTime.format(t);

/// "4m ago", "2h ago".
String timeAgo(DateTime? t) {
  if (t == null) return 'just now';
  final d = DateTime.now().toUtc().difference(t.toUtc());
  if (d.inMinutes < 1) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  return '${d.inDays}d ago';
}
