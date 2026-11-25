import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/alert_tone.dart';
import 'settings_store.dart';

enum CueKind { phase, countdown, complete }

class CueAudio {
  CueAudio({this._settings}) {
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);
    // Media player (not SoundPool) so Android audio-focus / attributes apply
    // reliably for mix-with-others vs duck.
    _player.setPlayerMode(PlayerMode.mediaPlayer);
    _settings?.addListener(_onSettingsChanged);
    unawaited(_applyAudioContext());
  }

  final SettingsStore? _settings;
  late final AudioPlayer _player;
  int _playGeneration = 0;

  /// How timer beeps interact with other apps' audio.
  ///
  /// Off → mix: Spotify/etc. keep playing (no audio focus / mixWithOthers).
  /// On → duck: briefly lower other audio for the cue (never exclusive gain,
  /// which would pause other apps entirely).
  @visibleForTesting
  static AudioContext audioContextFor({required bool lowerMusic}) {
    return AudioContext(
      android: AudioContextAndroid(
        // Short UI beeps — not "music" — so OEMs are less likely to treat us
        // as a competing media session.
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.assistanceSonification,
        audioMode: AndroidAudioMode.normal,
        isSpeakerphoneOn: false,
        stayAwake: false,
        audioFocus: lowerMusic
            ? AndroidAudioFocus.gainTransientMayDuck
            : AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: lowerMusic
            ? {
                AVAudioSessionOptions.mixWithOthers,
                AVAudioSessionOptions.duckOthers,
              }
            : {
                AVAudioSessionOptions.mixWithOthers,
              },
      ),
    );
  }

  /// Apply the global + player context for the current Lower-music setting.
  /// Safe to call before any [CueAudio] exists (e.g. from [main]).
  static Future<void> applyGlobalContext({required bool lowerMusic}) async {
    final ctx = audioContextFor(lowerMusic: lowerMusic);
    try {
      await AudioPlayer.global.setAudioContext(ctx);
    } catch (_) {
      // Context failure should never stop the timer UI.
    }
  }

  void _onSettingsChanged() {
    unawaited(_applyAudioContext());
  }

  Future<void> _applyAudioContext() async {
    final lower = _settings?.lowerMusicDuringWorkout ?? false;
    final ctx = audioContextFor(lowerMusic: lower);
    try {
      await AudioPlayer.global.setAudioContext(ctx);
      await _player.setAudioContext(ctx);
    } catch (_) {
      // Context failure should never stop the timer UI.
    }
  }

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
      // Re-apply immediately before play so a mid-session toggle is honored
      // and we never beep under the package default (exclusive focus).
      await _applyAudioContext();
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
    _settings?.removeListener(_onSettingsChanged);
    await _player.dispose();
  }
}
