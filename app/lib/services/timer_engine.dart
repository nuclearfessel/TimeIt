import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/interval_step.dart';
import '../models/phase_type.dart';
import 'cue_audio.dart';
import 'settings_store.dart';

enum EngineStatus { idle, running, paused, finished }

class TimerEngine extends ChangeNotifier {
  TimerEngine({SettingsStore? settings, CueAudio? audio})
      : _settings = settings,
        _audio = audio ?? CueAudio(settings: settings);

  final SettingsStore? _settings;
  final CueAudio _audio;
  List<IntervalStep> _schedule = [];
  int _index = 0;
  EngineStatus status = EngineStatus.idle;

  /// Absolute end of the current phase while running.
  DateTime? _phaseEndsAt;
  Duration _remainingWhenPaused = Duration.zero;
  Timer? _ticker;
  int _lastSecond = -1;

  IntervalStep? get currentStep =>
      _index >= 0 && _index < _schedule.length ? _schedule[_index] : null;

  int get index => _index;
  int get totalSteps => _schedule.length;
  List<IntervalStep> get schedule => List.unmodifiable(_schedule);

  Duration get remaining {
    if (status == EngineStatus.paused || status == EngineStatus.idle) {
      return _remainingWhenPaused;
    }
    if (status == EngineStatus.finished) return Duration.zero;
    if (_phaseEndsAt == null) {
      return Duration(seconds: currentStep?.seconds ?? 0);
    }
    final left = _phaseEndsAt!.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  Duration get totalRemaining {
    var sum = remaining;
    for (var i = _index + 1; i < _schedule.length; i++) {
      sum += Duration(seconds: _schedule[i].seconds);
    }
    return sum;
  }

  PhaseType? get phase => currentStep?.type;

  double get phaseProgress {
    final total = currentStep?.seconds ?? 0;
    if (total <= 0) return 1;
    final left = remaining.inMilliseconds / 1000.0;
    return (1 - (left / total)).clamp(0.0, 1.0);
  }

  int get _startBeeps => _settings?.startBeepCount ?? 1;
  int get _endBeeps => _settings?.endBeepCount ?? 3;

  void load(List<IntervalStep> steps) {
    _ticker?.cancel();
    _schedule = steps.map((s) => s.copy()).toList();
    _index = 0;
    status = EngineStatus.idle;
    _phaseEndsAt = null;
    _remainingWhenPaused = Duration(seconds: currentStep?.seconds ?? 0);
    _lastSecond = -1;
    notifyListeners();
  }

  void start() {
    if (_schedule.isEmpty) return;
    if (status == EngineStatus.finished) {
      _index = 0;
      _remainingWhenPaused = Duration(seconds: currentStep?.seconds ?? 0);
    }
    if (status == EngineStatus.idle) {
      _remainingWhenPaused = Duration(seconds: currentStep?.seconds ?? 0);
    }

    final seed = _remainingWhenPaused.inMilliseconds > 0
        ? _remainingWhenPaused
        : Duration(seconds: currentStep?.seconds ?? 0);

    status = EngineStatus.running;
    _phaseEndsAt = DateTime.now().add(seed);
    _lastSecond = seed.inSeconds;
    unawaited(_audio.playRepeats(CueKind.phase, _startBeeps));
    _startTicker();
    notifyListeners();
  }

  void pause() {
    if (status != EngineStatus.running) return;
    _remainingWhenPaused = remaining;
    _phaseEndsAt = null;
    status = EngineStatus.paused;
    _ticker?.cancel();
    notifyListeners();
  }

  void resume() {
    if (status != EngineStatus.paused) return;
    status = EngineStatus.running;
    _phaseEndsAt = DateTime.now().add(_remainingWhenPaused);
    _startTicker();
    notifyListeners();
  }

  void toggle() {
    switch (status) {
      case EngineStatus.running:
        pause();
      case EngineStatus.paused:
        resume();
      case EngineStatus.idle:
      case EngineStatus.finished:
        start();
    }
  }

  void skip() {
    if (_schedule.isEmpty || status == EngineStatus.finished) return;
    _advance(playCue: true);
  }

  void stop() {
    _ticker?.cancel();
    _phaseEndsAt = null;
    _index = 0;
    status = EngineStatus.idle;
    _remainingWhenPaused = Duration(seconds: currentStep?.seconds ?? 0);
    _lastSecond = -1;
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) => _tick());
  }

  void _tick() {
    if (status != EngineStatus.running || _phaseEndsAt == null) return;
    final left = remaining;
    final secs = left.inSeconds;
    if (secs != _lastSecond) {
      _lastSecond = secs;
      final endCount = _endBeeps.clamp(0, SettingsStore.maxBeepCount);
      if (endCount > 0 && secs > 0 && secs <= endCount) {
        unawaited(_audio.play(CueKind.countdown));
      }
    }
    notifyListeners();
    if (left <= Duration.zero) {
      _advance(playCue: true);
    }
  }

  void _advance({required bool playCue}) {
    if (_index >= _schedule.length - 1) {
      _ticker?.cancel();
      _phaseEndsAt = null;
      status = EngineStatus.finished;
      _remainingWhenPaused = Duration.zero;
      unawaited(_audio.play(CueKind.complete));
      notifyListeners();
      return;
    }
    _index += 1;
    _remainingWhenPaused = Duration(seconds: currentStep!.seconds);
    _phaseEndsAt = DateTime.now().add(_remainingWhenPaused);
    _lastSecond = currentStep!.seconds;
    status = EngineStatus.running;
    if (playCue) {
      unawaited(_audio.playRepeats(CueKind.phase, _startBeeps));
    }
    if (_ticker == null || !(_ticker?.isActive ?? false)) {
      _startTicker();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _audio.dispose();
    super.dispose();
  }
}
