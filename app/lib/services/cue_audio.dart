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
    unawaited(_applyBeepContext());
  }

  final SettingsStore? _settings;
  late final AudioPlayer _player;
  AudioPlayer? _duckHold;
  bool _workoutActive = false;
  bool _duckHoldPlaying = false;
  int _playGeneration = 0;

  /// Beep player context — always mixes; never steals exclusive focus.
  /// Ducking other apps for a running workout is owned by [_duckHold].
  @visibleForTesting
  static AudioContext beepContext() {
    return AudioContext(
      android: const AudioContextAndroid(
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.assistanceSonification,
        audioMode: AndroidAudioMode.normal,
        isSpeakerphoneOn: false,
        stayAwake: false,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {AVAudioSessionOptions.mixWithOthers},
      ),
    );
  }

  /// Held for the whole running workout when Lower music is on.
  /// Requests transient duck focus so Spotify/etc. stay quieter until we stop.
  @visibleForTesting
  static AudioContext duckHoldContext() {
    return AudioContext(
      android: const AudioContextAndroid(
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioMode: AndroidAudioMode.normal,
        isSpeakerphoneOn: false,
        stayAwake: true,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {
          AVAudioSessionOptions.mixWithOthers,
          AVAudioSessionOptions.duckOthers,
        },
      ),
    );
  }

  /// Back-compat name used by tests / [applyGlobalContext].
  @visibleForTesting
  static AudioContext audioContextFor({required bool lowerMusic}) {
    return lowerMusic ? duckHoldContext() : beepContext();
  }

  /// Apply the mix (non-ducking) global context before any player exists.
  static Future<void> applyGlobalContext({required bool lowerMusic}) async {
    // Startup always mixes; duck hold starts only when a workout is running.
    final ctx = beepContext();
    try {
      await AudioPlayer.global.setAudioContext(ctx);
    } catch (_) {
      // Context failure should never stop the timer UI.
    }
  }

  void _onSettingsChanged() {
    unawaited(_syncDuckHold());
  }

  Future<void> _applyBeepContext() async {
    final ducking =
        _workoutActive && (_settings?.lowerMusicDuringWorkout ?? false);
    // While ducking, keep duckOthers on the shared iOS session — setting the
    // beep player to mix-only would clear ducking mid-workout.
    final sessionCtx = ducking ? duckHoldContext() : beepContext();
    final beepCtx = ducking
        ? AudioContext(
            android: const AudioContextAndroid(
              contentType: AndroidContentType.sonification,
              usageType: AndroidUsageType.assistanceSonification,
              audioMode: AndroidAudioMode.normal,
              isSpeakerphoneOn: false,
              stayAwake: false,
              // Hold player already owns MAY_DUCK; beeps must not steal focus.
              audioFocus: AndroidAudioFocus.none,
            ),
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.playback,
              options: const {
                AVAudioSessionOptions.mixWithOthers,
                AVAudioSessionOptions.duckOthers,
              },
            ),
          )
        : beepContext();
    try {
      await AudioPlayer.global.setAudioContext(sessionCtx);
      await _player.setAudioContext(beepCtx);
    } catch (_) {
      // Context failure should never stop the timer UI.
    }
  }

  /// Call when the run screen timer is running (start/resume) or not
  /// (pause/stop/finished). When Lower music is on, holds a near-silent
  /// looping stream that ducks other apps for the whole workout.
  Future<void> setWorkoutActive(bool active) async {
    _workoutActive = active;
    await _syncDuckHold();
  }

  Future<void> _syncDuckHold() async {
    final wantDuck =
        _workoutActive && (_settings?.lowerMusicDuringWorkout ?? false);
    try {
      if (wantDuck) {
        if (_duckHoldPlaying) return;
        await AudioPlayer.global.setAudioContext(duckHoldContext());
        final hold = _duckHold ??= AudioPlayer();
        await hold.setReleaseMode(ReleaseMode.loop);
        await hold.setPlayerMode(PlayerMode.mediaPlayer);
        await hold.setAudioContext(duckHoldContext());
        // Asset is a near-inaudible tone (not digital silence) so the OS
        // keeps the duck session active; volume stays full on that tiny amp.
        await hold.setVolume(1.0);
        await hold.play(AssetSource('sounds/silence.wav'));
        _duckHoldPlaying = true;
      } else if (_duckHoldPlaying || _duckHold != null) {
        _duckHoldPlaying = false;
        await _duckHold?.stop();
        await AudioPlayer.global.setAudioContext(beepContext());
        await _player.setAudioContext(beepContext());
      }
    } catch (_) {
      _duckHoldPlaying = false;
      // Duck-hold failure should never stop the timer UI.
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
      await _applyBeepContext();
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
    _workoutActive = false;
    _settings?.removeListener(_onSettingsChanged);
    try {
      await _duckHold?.stop();
      await _duckHold?.dispose();
    } catch (_) {}
    _duckHold = null;
    _duckHoldPlaying = false;
    await _player.dispose();
  }
}
