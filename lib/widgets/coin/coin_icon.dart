import 'package:flutter/material.dart';

/// Coin logo from the network, or a coloured letter avatar when there is no image.
class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, required this.symbol, required this.imageUrl, this.size = 32});

  final String symbol;
  final String imageUrl;
  final double size;

  static const _palette = <int>[
    0xFF2563EB,
    0xFF7C3AED,
    0xFF0D9488,
    0xFFD97706,
    0xFF9333EA,
    0xFF0369A1,
    0xFF475569,
    0xFFB45309,
  ];

  @override
  Widget build(BuildContext context) {
    final sum = symbol.codeUnits.fold<int>(0, (a, b) => a + b);
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(_palette[sum % _palette.length]),
        shape: BoxShape.circle,
      ),
      child: Text(
        symbol.isEmpty ? '?' : symbol[0].toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.42,
        ),
      ),
    );
    if (imageUrl.isEmpty) return fallback;
    return ClipOval(
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}
