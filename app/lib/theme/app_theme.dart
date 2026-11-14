import 'package:flutter/material.dart';

import '../models/phase_type.dart';

/// Phase colors inspired by Okabe-Ito (work vermilion, rest blue, standby green).
class PhaseColors {
  static const standby = Color(0xFF009E73);
  static const work = Color(0xFFD55E00);
  static const rest = Color(0xFF0072B2);
  static const complete = Color(0xFF111111);

  static Color of(PhaseType type) {
    switch (type) {
      case PhaseType.standby:
        return standby;
      case PhaseType.work:
        return work;
      case PhaseType.rest:
        return rest;
    }
  }
}

class AppTheme {
  static const bg = Color(0xFF0B0B0C);
  static const surface = Color(0xFF161618);
  static const line = Color(0xFF2A2A2E);
  static const fg = Color(0xFFF4F4F5);
  static const mute = Color(0xFF9A9AA3);
  static const accent = Color(0xFFD55E00);

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: accent,
        onPrimary: fg,
        onSurface: fg,
        outline: line,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: 'PlusJakartaSans',
        bodyColor: fg,
        displayColor: fg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'HeptaSlab',
          fontWeight: FontWeight.w600,
          fontSize: 22,
          color: fg,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: line),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: fg,
      ),
      dividerColor: line,
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          color: fg,
        ),
      ),
    );
  }

  static const digits = TextStyle(
    fontFamily: 'HeptaSlab',
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
    height: 1,
    letterSpacing: -2,
  );

  static const header = TextStyle(
    fontFamily: 'HeptaSlab',
    fontWeight: FontWeight.w600,
  );
}
