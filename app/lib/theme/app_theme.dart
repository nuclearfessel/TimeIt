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
class TimeItColors extends ThemeExtension<TimeItColors> {
  const TimeItColors({
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

  static const dark = TimeItColors(
    bg: Color(0xFF0B0B0C),
    surface: Color(0xFF161618),
    line: Color(0xFF2A2A2E),
    fg: Color(0xFFF4F4F5),
    mute: Color(0xFF9A9AA3),
    accent: Color(0xFFD55E00),
  );

  static const light = TimeItColors(
    bg: Color(0xFFF7F6F3),
    surface: Color(0xFFFFFFFF),
    line: Color(0xFFD9D6CF),
    fg: Color(0xFF161618),
    mute: Color(0xFF6B6B76),
    accent: Color(0xFFD55E00),
  );

  static TimeItColors of(BuildContext context) {
    return Theme.of(context).extension<TimeItColors>() ?? TimeItColors.dark;
  }

  @override
  TimeItColors copyWith({
    Color? bg,
    Color? surface,
    Color? line,
    Color? fg,
    Color? mute,
    Color? accent,
  }) {
    return TimeItColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      line: line ?? this.line,
      fg: fg ?? this.fg,
      mute: mute ?? this.mute,
      accent: accent ?? this.accent,
    );
  }

  @override
  TimeItColors lerp(ThemeExtension<TimeItColors>? other, double t) {
    if (other is! TimeItColors) return this;
    return TimeItColors(
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
  static ThemeData dark() => _build(Brightness.dark, TimeItColors.dark);

  static ThemeData light() => _build(Brightness.light, TimeItColors.light);

  /// Clear press / hover / focus overlays for any ButtonStyle, light or dark.
  static WidgetStateProperty<Color?> pressOverlay({
    required Color pressed,
    Color? hovered,
    Color? focused,
  }) {
    final hover = hovered ?? pressed.withValues(alpha: pressed.a * 0.65);
    final focus = focused ?? pressed.withValues(alpha: pressed.a * 0.5);
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) return pressed;
      if (states.contains(WidgetState.hovered)) return hover;
      if (states.contains(WidgetState.focused)) return focus;
      return null;
    });
  }

  static ThemeData _build(Brightness brightness, TimeItColors colors) {
    final onAccentPress = Colors.white.withValues(alpha: 0.28);
    final onAccentHover = Colors.white.withValues(alpha: 0.14);
    final onSurfacePress = colors.accent.withValues(alpha: 0.20);
    final onSurfaceHover = colors.accent.withValues(alpha: 0.10);

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.bg,
      splashFactory: InkRipple.splashFactory,
      splashColor: onSurfacePress,
      highlightColor: onSurfaceHover,
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
        iconTheme: IconThemeData(color: colors.fg),
        actionsIconTheme: IconThemeData(color: colors.fg),
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
        splashColor: onAccentPress,
        focusColor: onAccentHover,
        hoverColor: onAccentHover,
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
        ).copyWith(
          overlayColor: pressOverlay(
            pressed: onAccentPress,
            hovered: onAccentHover,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.fg,
          side: BorderSide(color: colors.line),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ).copyWith(
          overlayColor: pressOverlay(
            pressed: onSurfacePress,
            hovered: onSurfaceHover,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.fg,
          textStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w500,
          ),
        ).copyWith(
          overlayColor: pressOverlay(
            pressed: onSurfacePress,
            hovered: onSurfaceHover,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colors.fg,
        ).copyWith(
          overlayColor: pressOverlay(
            pressed: onSurfacePress,
            hovered: onSurfaceHover,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: Colors.white,
        ).copyWith(
          overlayColor: pressOverlay(
            pressed: onAccentPress,
            hovered: onAccentHover,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          overlayColor: pressOverlay(
            pressed: onSurfacePress,
            hovered: onSurfaceHover,
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
        selectedColor: colors.accent,
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
