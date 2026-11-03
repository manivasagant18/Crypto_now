import 'package:flutter/material.dart';

import 'package:coinlens/widgets/common/pill_chip.dart';

const kTimeframes = [
  (label: '1D', days: 1),
  (label: '7D', days: 7),
  (label: '30D', days: 30),
  (label: '1Y', days: 365),
];

/// Row of chart range chips: 1D, 7D, 30D, 1Y.
class TimeframeSelector extends StatelessWidget {
  const TimeframeSelector({super.key, required this.days, required this.onSelected});

  final int days;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final t in kTimeframes)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: PillChip(
                label: t.label,
                selected: days == t.days,
                onTap: () => onSelected(t.days),
              ),
            ),
          ),
      ],
    );
  }
}
