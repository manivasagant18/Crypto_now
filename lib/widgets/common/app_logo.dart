import 'package:flutter/material.dart';

/// The Crypto Now logo: white rising chart on black, with rounded corners.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 32});

  static const asset = 'assets/logo/logo.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(asset, width: size, height: size, filterQuality: FilterQuality.medium),
    );
  }
}
