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
  static const _startBeepsKey = 'timed.settings.start_beeps.v1';
  static const _endBeepsKey = 'timed.settings.end_beeps.v1';
  static const _lowerMusicKey = 'timed.settings.lower_music.v1';
  static const _vibrateKey = 'timed.settings.vibrate.v1';

  static const int maxBeepCount = 5;

  bool loaded = false;

  AppAppearance appearance = AppAppearance.dark;

  /// Play phase-change and complete sounds.
  bool alertSounds = true;

  /// Play countdown ticks near the end of each phase.
  bool countdownBeeps = true;

  /// How many beeps when a phase / workout starts (0–5).
  int startBeepCount = 1;

  /// How many countdown beeps leading into the end of each phase (0–5).
  int endBeepCount = 3;

  /// Stub: duck other apps' audio during a workout (not wired to OS audio yet).
  bool lowerMusicDuringWorkout = true;

  /// Stub: vibrate on alerts (not wired to haptics yet).
  bool vibrateOnAlert = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    appearance = AppAppearance.fromName(prefs.getString(_appearanceKey));
    alertSounds = prefs.getBool(_alertSoundsKey) ?? true;
    countdownBeeps = prefs.getBool(_countdownBeepsKey) ?? true;
    startBeepCount =
        (prefs.getInt(_startBeepsKey) ?? 1).clamp(0, maxBeepCount);
    endBeepCount = (prefs.getInt(_endBeepsKey) ?? 3).clamp(0, maxBeepCount);
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

  Future<void> setStartBeepCount(int value) async {
    final next = value.clamp(0, maxBeepCount);
    if (startBeepCount == next) return;
    startBeepCount = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_startBeepsKey, startBeepCount);
  }

  Future<void> setEndBeepCount(int value) async {
    final next = value.clamp(0, maxBeepCount);
    if (endBeepCount == next) return;
    endBeepCount = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_endBeepsKey, endBeepCount);
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
