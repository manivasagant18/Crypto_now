import 'package:flutter/material.dart';

import 'package:coinlens/core/format.dart';
import 'package:coinlens/core/theme.dart';

/// Slim banner shown when a refresh failed and an older cached copy is on screen.
class StaleBanner extends StatelessWidget {
  const StaleBanner({super.key, required this.updated, required this.onRefresh});

  final DateTime? updated;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final muted = mutedText(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
      decoration: BoxDecoration(color: cardColor(context), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(Icons.history, size: 16, color: muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing cached data · Last updated ${timeAgo(updated)}',
              style: TextStyle(color: muted, fontSize: 12),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, size: 18, color: kAccent),
            onPressed: onRefresh,
          ),
        ],
      ),
    );
  }
}
