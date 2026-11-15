import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/alert_tone.dart';

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
  static const _appearanceKey = 'timeit.settings.appearance.v1';
  static const _alertSoundsKey = 'timeit.settings.alert_sounds.v1';
  static const _startBeepsKey = 'timeit.settings.start_beeps.v1';
  static const _endBeepsKey = 'timeit.settings.end_beeps.v1';
  static const _lowerMusicKey = 'timeit.settings.lower_music.v1';
  static const _vibrateKey = 'timeit.settings.vibrate.v1';
  static const _deleteWithoutConfirmKey =
      'timeit.settings.delete_without_confirm.v1';
  static const _skipLastRestKey = 'timeit.settings.skip_last_rest.v1';
  static const _startToneKey = 'timeit.settings.start_tone.v1';
  static const _endToneKey = 'timeit.settings.end_tone.v1';
  static const _finishToneKey = 'timeit.settings.finish_tone.v1';

  static const int maxBeepCount = 5;

  bool loaded = false;

  AppAppearance appearance = AppAppearance.dark;

  /// Master switch for all workout beeps (start, end/countdown, complete).
  bool alertSounds = true;

  /// How many start-of-phase beeps (0–5), one per second.
  int startBeepCount = 1;

  /// How many countdown beeps leading into the end of each phase (0–5).
  int endBeepCount = 3;

  /// Sound for lead-in / start-of-phase beeps.
  AlertTone startTone = AlertTone.pip;

  /// Sound for lead-out / end-of-phase countdown beeps.
  AlertTone endTone = AlertTone.blip;

  /// Sound for workout complete.
  AlertTone finishTone = AlertTone.chime;

  /// Stub: duck other apps' audio during a workout (not wired to OS audio yet).
  bool lowerMusicDuringWorkout = true;

  /// Haptic feedback on phase / countdown / complete cues.
  bool vibrateOnAlert = false;

  /// When true, home delete removes a timer immediately (no confirm dialog).
  bool deleteWithoutConfirmation = false;

  /// When true, trailing rest at the end of a workout is omitted.
  bool skipLastRest = true;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    appearance = AppAppearance.fromName(prefs.getString(_appearanceKey));
    alertSounds = prefs.getBool(_alertSoundsKey) ?? true;
    startBeepCount =
        (prefs.getInt(_startBeepsKey) ?? 1).clamp(0, maxBeepCount);
    endBeepCount = (prefs.getInt(_endBeepsKey) ?? 3).clamp(0, maxBeepCount);
    startTone = AlertTone.fromName(
      prefs.getString(_startToneKey),
      fallback: AlertTone.pip,
    );
    endTone = AlertTone.fromName(
      prefs.getString(_endToneKey),
      fallback: AlertTone.blip,
    );
    finishTone = AlertTone.fromName(
      prefs.getString(_finishToneKey),
      fallback: AlertTone.chime,
    );
    lowerMusicDuringWorkout = prefs.getBool(_lowerMusicKey) ?? true;
    vibrateOnAlert = prefs.getBool(_vibrateKey) ?? false;
    deleteWithoutConfirmation =
        prefs.getBool(_deleteWithoutConfirmKey) ?? false;
    skipLastRest = prefs.getBool(_skipLastRestKey) ?? true;
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

  Future<void> setStartTone(AlertTone value) async {
    if (startTone == value) return;
    startTone = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_startToneKey, value.name);
  }

  Future<void> setEndTone(AlertTone value) async {
    if (endTone == value) return;
    endTone = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_endToneKey, value.name);
  }

  Future<void> setFinishTone(AlertTone value) async {
    if (finishTone == value) return;
    finishTone = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_finishToneKey, value.name);
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

  Future<void> setDeleteWithoutConfirmation(bool value) async {
    deleteWithoutConfirmation = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_deleteWithoutConfirmKey, value);
  }

  Future<void> setSkipLastRest(bool value) async {
    skipLastRest = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_skipLastRestKey, value);
  }
}
