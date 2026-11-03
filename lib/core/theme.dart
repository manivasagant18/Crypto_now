import 'package:flutter/material.dart';

// Design tokens from the approved Crypto Now design.
const kAccent = Color(0xFF2563EB);
const kPositive = Color(0xFF16A34A);
const kNegative = Color(0xFFDC2626);

ThemeData buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final background = isDark ? const Color(0xFF0F1115) : Colors.white;
  final scheme = ColorScheme.fromSeed(seedColor: kAccent, brightness: brightness)
      .copyWith(primary: kAccent, surface: background);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
  );
}

bool _isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

Color cardColor(BuildContext c) =>
    _isDark(c) ? const Color(0xFF1A1D24) : const Color(0xFFF5F7FA);

Color mutedText(BuildContext c) =>
    _isDark(c) ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

Color strongText(BuildContext c) =>
    _isDark(c) ? const Color(0xFFF9FAFB) : const Color(0xFF111827);

Color dividerColor(BuildContext c) =>
    _isDark(c) ? const Color(0xFF2A2E37) : const Color(0xFFE5E7EB);

Color neutralChipColor(BuildContext c) =>
    _isDark(c) ? const Color(0xFF262A33) : const Color(0xFFF1F3F6);
