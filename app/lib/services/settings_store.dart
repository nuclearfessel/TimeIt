import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App chrome theme. Never follows the OS — Light or Dark only.
enum AppAppearance {
  light,
  dark;

  String get label => switch (this) {
        AppAppearance.light => 'Light',
        AppAppearance.dark => 'Dark',
      };

  ThemeMode get themeMode => switch (this) {
        AppAppearance.light => ThemeMode.light,
        AppAppearance.dark => ThemeMode.dark,
      };

  static AppAppearance fromName(String? name) {
    return AppAppearance.values.firstWhere(
      (v) => v.name == name,
      orElse: () => AppAppearance.dark,
    );
  }
}

class SettingsStore extends ChangeNotifier {
  static const _appearanceKey = 'timed.settings.appearance.v1';
  static const _alertSoundsKey = 'timed.settings.alert_sounds.v1';
  static const _countdownBeepsKey = 'timed.settings.countdown_beeps.v1';
  static const _lowerMusicKey = 'timed.settings.lower_music.v1';
  static const _vibrateKey = 'timed.settings.vibrate.v1';

  bool loaded = false;

  AppAppearance appearance = AppAppearance.dark;

  /// Play phase-change and complete sounds.
  bool alertSounds = true;

  /// Play last-3-seconds countdown ticks.
  bool countdownBeeps = true;

  /// Stub: duck other apps' audio during a workout (not wired to OS audio yet).
  bool lowerMusicDuringWorkout = true;

  /// Stub: vibrate on alerts (not wired to haptics yet).
  bool vibrateOnAlert = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    appearance = AppAppearance.fromName(prefs.getString(_appearanceKey));
    alertSounds = prefs.getBool(_alertSoundsKey) ?? true;
    countdownBeeps = prefs.getBool(_countdownBeepsKey) ?? true;
    lowerMusicDuringWorkout = prefs.getBool(_lowerMusicKey) ?? true;
    vibrateOnAlert = prefs.getBool(_vibrateKey) ?? false;
    loaded = true;
    notifyListeners();
  }

  Future<void> setAppearance(AppAppearance value) async {
    if (appearance == value) return;
    appearance = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appearanceKey, value.name);
  }

  Future<void> setAlertSounds(bool value) async {
    alertSounds = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_alertSoundsKey, value);
  }

  Future<void> setCountdownBeeps(bool value) async {
    countdownBeeps = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_countdownBeepsKey, value);
  }

  Future<void> setLowerMusicDuringWorkout(bool value) async {
    lowerMusicDuringWorkout = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lowerMusicKey, value);
  }

  Future<void> setVibrateOnAlert(bool value) async {
    vibrateOnAlert = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrateKey, value);
  }
}
