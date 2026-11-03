import 'package:flutter/material.dart';

import 'package:coinlens/core/format.dart';
import 'package:coinlens/core/theme.dart';

/// Green for gains, red for losses, grey for flat. Used for 24h change and ATH/ATL.
class ChangeChip extends StatelessWidget {
  const ChangeChip({super.key, required this.change, this.label, this.compact = false});

  final double change;
  final String? label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color fg;
    final Color bg;
    if (change > 0) {
      fg = kPositive;
      bg = kPositive.withValues(alpha: 0.12);
    } else if (change < 0) {
      fg = kNegative;
      bg = kNegative.withValues(alpha: 0.12);
    } else {
      fg = mutedText(context);
      bg = neutralChipColor(context);
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: compact ? 3 : 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        label ?? percent(change),
        style: TextStyle(
          color: fg,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFeatures: kTabular,
        ),
      ),
    );
  }
}
