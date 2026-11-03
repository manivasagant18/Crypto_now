import 'package:flutter/material.dart';

import 'package:coinlens/core/theme.dart';

/// Rounded selectable chip used for sort options, filters and timeframes.
class PillChip extends StatelessWidget {
  const PillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.showCheck = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : strongText(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? kAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? kAccent : dividerColor(context)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCheck && selected) ...[
                Icon(Icons.check, size: 16, color: fg),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
