import 'package:audioplayers/audioplayers.dart';

enum CueKind { phase, countdown, complete }

class CueAudio {
  CueAudio() {
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);
    _player.setPlayerMode(PlayerMode.lowLatency);
  }

  late final AudioPlayer _player;
  bool muted = false;

  Future<void> play(CueKind kind) async {
    if (muted) return;
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
