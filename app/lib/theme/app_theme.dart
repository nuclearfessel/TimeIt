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

/// App chrome colors that switch with Appearance (Light / Dark).
class TimedColors extends ThemeExtension<TimedColors> {
  const TimedColors({
    required this.bg,
    required this.surface,
    required this.line,
    required this.fg,
    required this.mute,
    required this.accent,
  });

  final Color bg;
  final Color surface;
  final Color line;
  final Color fg;
  final Color mute;
  final Color accent;

  static const dark = TimedColors(
    bg: Color(0xFF0B0B0C),
    surface: Color(0xFF161618),
    line: Color(0xFF2A2A2E),
    fg: Color(0xFFF4F4F5),
    mute: Color(0xFF9A9AA3),
    accent: Color(0xFFD55E00),
  );

  static const light = TimedColors(
    bg: Color(0xFFF7F6F3),
    surface: Color(0xFFFFFFFF),
    line: Color(0xFFD9D6CF),
    fg: Color(0xFF161618),
    mute: Color(0xFF6B6B76),
    accent: Color(0xFFD55E00),
  );

  static TimedColors of(BuildContext context) {
    return Theme.of(context).extension<TimedColors>() ?? TimedColors.dark;
  }

  @override
  TimedColors copyWith({
    Color? bg,
    Color? surface,
    Color? line,
    Color? fg,
    Color? mute,
    Color? accent,
  }) {
    return TimedColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      line: line ?? this.line,
      fg: fg ?? this.fg,
      mute: mute ?? this.mute,
      accent: accent ?? this.accent,
    );
  }

  @override
  TimedColors lerp(ThemeExtension<TimedColors>? other, double t) {
    if (other is! TimedColors) return this;
    return TimedColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      line: Color.lerp(line, other.line, t)!,
      fg: Color.lerp(fg, other.fg, t)!,
      mute: Color.lerp(mute, other.mute, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}

class AppTheme {
  static ThemeData dark() => _build(Brightness.dark, TimedColors.dark);

  static ThemeData light() => _build(Brightness.light, TimedColors.light);

  static ThemeData _build(Brightness brightness, TimedColors colors) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.accent,
        onPrimary: Colors.white,
        secondary: colors.accent,
        onSecondary: Colors.white,
        error: const Color(0xFFB00020),
        onError: Colors.white,
        surface: colors.surface,
        onSurface: colors.fg,
        outline: colors.line,
      ),
      extensions: [colors],
    );

    final body = base.textTheme.apply(
      fontFamily: 'PlusJakartaSans',
      bodyColor: colors.fg,
      displayColor: colors.fg,
    );
    // Body / UI copy one step up (regular → medium). Headers stay Hepta Slab.
    TextStyle medium(TextStyle? s) =>
        (s ?? const TextStyle()).copyWith(fontWeight: FontWeight.w500);

    return base.copyWith(
      textTheme: body.copyWith(
        bodyLarge: medium(body.bodyLarge),
        bodyMedium: medium(body.bodyMedium),
        bodySmall: medium(body.bodySmall),
        labelLarge: medium(body.labelLarge),
        labelMedium: medium(body.labelMedium),
        labelSmall: medium(body.labelSmall),
        titleSmall: medium(body.titleSmall),
        titleMedium: medium(body.titleMedium),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'HeptaSlab',
          fontWeight: FontWeight.w600,
          fontSize: 22,
          color: colors.fg,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.line),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.accent,
        foregroundColor: Colors.white,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 22),
        extendedIconLabelSpacing: 10,
        extendedTextStyle: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 0.1,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        labelStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.w500,
          color: colors.fg,
        ),
      ),
      dividerColor: colors.line,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surface,
        contentTextStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.w500,
          color: colors.fg,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.fg,
        textColor: colors.fg,
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
