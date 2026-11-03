import 'package:flutter/material.dart';

import 'package:coinlens/core/theme.dart';
import 'package:coinlens/widgets/common/surface_card.dart';

/// Label, big value and optional caption, e.g. "Market cap / $1.33T".
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.value, this.sub});

  final String label;
  final String value;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: mutedText(context), fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: strongText(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub!, style: TextStyle(color: mutedText(context), fontSize: 11)),
          ],
        ],
      ),
    );
  }
}
