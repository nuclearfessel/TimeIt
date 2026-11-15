import 'package:audioplayers/audioplayers.dart';

import 'settings_store.dart';

enum CueKind { phase, countdown, complete }

class CueAudio {
  CueAudio({SettingsStore? this._settings}) {
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);
    _player.setPlayerMode(PlayerMode.lowLatency);
  }

  final SettingsStore? _settings;
  late final AudioPlayer _player;
  int _playGeneration = 0;

  Future<void> play(CueKind kind) async {
    final settings = _settings;
    if (settings != null) {
      if (kind == CueKind.countdown && !settings.countdownBeeps) return;
      if (kind != CueKind.countdown && !settings.alertSounds) return;
    }
    final asset = switch (kind) {
      CueKind.phase => 'sounds/phase.wav',
      CueKind.countdown => 'sounds/countdown.wav',
      CueKind.complete => 'sounds/complete.wav',
    };
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (_) {
      // Audio failure should never stop the timer UI.
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
