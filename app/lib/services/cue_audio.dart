import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../models/alert_tone.dart';
import 'settings_store.dart';

enum CueKind { phase, countdown, complete }

class CueAudio {
  CueAudio({this._settings}) {
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);
    _player.setPlayerMode(PlayerMode.lowLatency);
  }

  final SettingsStore? _settings;
  late final AudioPlayer _player;
  int _playGeneration = 0;

  AlertTone toneFor(CueKind kind) {
    final settings = _settings;
    if (settings == null) {
      return switch (kind) {
        CueKind.phase => AlertTone.pip,
        CueKind.countdown => AlertTone.blip,
        CueKind.complete => AlertTone.chime,
      };
    }
    return switch (kind) {
      CueKind.phase => settings.startTone,
      CueKind.countdown => settings.endTone,
      CueKind.complete => settings.finishTone,
    };
  }

  Future<void> play(CueKind kind) async {
    final settings = _settings;
    // Haptics are independent of alert sounds (vibrate-only workouts).
    if (settings?.vibrateOnAlert ?? false) {
      _vibrate(kind);
    }
    if (settings != null && !settings.alertSounds) return;
    await playTone(toneFor(kind));
  }

  /// Preview a tone from Settings (ignores the alert-sounds master switch).
  Future<void> playTone(AlertTone tone) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(tone.assetPath));
    } catch (_) {
      // Audio failure should never stop the timer UI.
    }
  }

  void _vibrate(CueKind kind) {
    try {
      switch (kind) {
        case CueKind.countdown:
          HapticFeedback.lightImpact();
        case CueKind.phase:
          HapticFeedback.mediumImpact();
        case CueKind.complete:
          HapticFeedback.heavyImpact();
      }
    } catch (_) {
      // Haptics failure should never stop the timer UI.
    }
  }

  /// Plays [kind] [count] times, one beep per second (start-of-phase cues).
  Future<void> playRepeats(CueKind kind, int count) async {
    final n = count.clamp(0, SettingsStore.maxBeepCount);
    if (n <= 0) return;
    final generation = ++_playGeneration;
    for (var i = 0; i < n; i++) {
      if (generation != _playGeneration) return;
      await play(kind);
      if (i < n - 1) {
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }
  }

  /// Stops an in-flight one-per-second start-beep sequence.
  void cancelRepeats() {
    _playGeneration++;
  }

  Future<void> dispose() async {
    cancelRepeats();
    await _player.dispose();
  }
}
