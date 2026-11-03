import 'package:flutter/material.dart';

import 'package:coinlens/core/theme.dart';

/// Pulsing placeholder rows that match the CoinTile layout.
/// Rows that don't fit the available height are clipped, not overflowed.
class LoadingList extends StatefulWidget {
  const LoadingList({super.key, this.rows = 8});

  final int rows;

  @override
  State<LoadingList> createState() => _LoadingListState();
}

class _LoadingListState extends State<LoadingList> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bar(BuildContext context, double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: neutralChipColor(context),
          borderRadius: BorderRadius.circular(6),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_controller),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          widget.rows,
          (_) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _bar(context, 24, 12),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: neutralChipColor(context), shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bar(context, 110, 12),
                      const SizedBox(height: 6),
                      _bar(context, 60, 10),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _bar(context, 70, 12),
                    const SizedBox(height: 6),
                    _bar(context, 50, 10),
                  ],
                ),
                const SizedBox(width: 12),
                _bar(context, 68, 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
