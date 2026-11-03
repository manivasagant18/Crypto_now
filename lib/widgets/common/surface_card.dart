import 'package:flutter/material.dart';

import 'package:coinlens/core/theme.dart';

/// Rounded surface used for cards across the app.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: cardColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
