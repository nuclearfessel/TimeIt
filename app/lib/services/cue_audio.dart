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

  Future<void> dispose() async {
    await _player.dispose();
  }
}
