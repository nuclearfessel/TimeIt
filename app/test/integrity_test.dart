import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeit/models/alert_tone.dart';
import 'package:timeit/models/interval_step.dart';
import 'package:timeit/models/phase_type.dart';
import 'package:timeit/models/timer_round.dart';
import 'package:timeit/models/workout_timer.dart';
import 'package:timeit/services/settings_store.dart';
import 'package:timeit/services/timer_store.dart';

void main() {
  test('alert tone palette has six unique assets and labels', () {
    expect(AlertTone.values.length, 6);
    final assets = AlertTone.values.map((t) => t.assetPath).toSet();
    final labels = AlertTone.values.map((t) => t.label).toSet();
    expect(assets.length, 6);
    expect(labels.length, 6);
    for (final tone in AlertTone.values) {
      expect(tone.assetPath, startsWith('sounds/tone_'));
      expect(tone.assetPath, endsWith('.wav'));
      expect(tone.label.isNotEmpty, isTrue);
    }
  });

  test('new simple and advanced timers have unique ids and valid phases', () {
    final a = WorkoutTimer.newSimple();
    final b = WorkoutTimer.newSimple();
    final c = WorkoutTimer.newAdvanced();
    expect(a.id, isNot(b.id));
    expect(a.id, isNot(c.id));
    expect(a.simpleSteps.every((s) => s.seconds >= 0), isTrue);
    expect(a.simpleSteps.any((s) => s.type == PhaseType.work), isTrue);
    final roundIds = c.advancedRounds.map((r) => r.id).toSet();
    expect(roundIds.length, c.advancedRounds.length);
    for (final round in c.advancedRounds) {
      expect(round.steps, isNotEmpty);
      expect(round.steps.every((s) => PhaseType.values.contains(s.type)), isTrue);
    }
  });

  test('workout timer JSON round-trip preserves identity and schedule', () {
    final original = WorkoutTimer(
      name: 'Roundtrip',
      kind: TimerKind.simple,
      rounds: 4,
      simpleSteps: [
        IntervalStep(type: PhaseType.standby, seconds: 7),
        IntervalStep(type: PhaseType.work, seconds: 25),
        IntervalStep(type: PhaseType.rest, seconds: 12),
      ],
    );
    final restored = WorkoutTimer.fromJson(original.toJson());
    expect(restored.id, original.id);
    expect(restored.name, original.name);
    expect(restored.kind, original.kind);
    expect(restored.rounds, original.rounds);
    expect(restored.simpleSteps.length, original.simpleSteps.length);
    expect(
      restored.expand(skipLastRest: true).map((s) => '${s.type.name}:${s.seconds}'),
      original.expand(skipLastRest: true).map((s) => '${s.type.name}:${s.seconds}'),
    );
  });

  test('advanced JSON round-trip keeps distinct round ids', () {
    final original = WorkoutTimer.newAdvanced()..name = 'Adv';
    final restored = WorkoutTimer.fromJson(original.toJson());
    expect(restored.advancedRounds.length, original.advancedRounds.length);
    expect(
      restored.advancedRounds.map((r) => r.id).toSet().length,
      original.advancedRounds.length,
    );
  });

  test('timer store rejects duplicate ids on upsert and lists unique ids', () async {
    SharedPreferences.setMockInitialValues({});
    final store = TimerStore();
    await store.load();
    final t1 = WorkoutTimer.newSimple()..name = 'A';
    final t2 = WorkoutTimer(
      id: t1.id,
      name: 'A-replaced',
      kind: TimerKind.simple,
      simpleSteps: [
        IntervalStep(type: PhaseType.work, seconds: 10),
      ],
    );
    await store.upsert(t1);
    await store.upsert(t2);
    expect(store.timers.length, 1);
    expect(store.timers.single.name, 'A-replaced');
    await store.upsert(WorkoutTimer.newSimple()..name = 'B');
    final ids = store.timers.map((t) => t.id).toSet();
    expect(ids.length, store.timers.length);
  });

  test('settings store persists tones and timer prefs', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsStore();
    await settings.load();
    expect(settings.skipLastRest, isTrue);
    expect(settings.deleteWithoutConfirmation, isFalse);
    expect(settings.startTone, AlertTone.pip);
    expect(settings.endTone, AlertTone.blip);
    expect(settings.finishTone, AlertTone.chime);

    await settings.setStartTone(AlertTone.buzz);
    await settings.setEndTone(AlertTone.chirp);
    await settings.setFinishTone(AlertTone.pulse);
    await settings.setSkipLastRest(false);
    await settings.setDeleteWithoutConfirmation(true);
    await settings.setVibrateOnAlert(true);
    await settings.setStartBeepCount(4);
    await settings.setEndBeepCount(2);

    final again = SettingsStore();
    await again.load();
    expect(again.startTone, AlertTone.buzz);
    expect(again.endTone, AlertTone.chirp);
    expect(again.finishTone, AlertTone.pulse);
    expect(again.skipLastRest, isFalse);
    expect(again.deleteWithoutConfirmation, isTrue);
    expect(again.vibrateOnAlert, isTrue);
    expect(again.startBeepCount, 4);
    expect(again.endBeepCount, 2);
  });

  test('empty active steps fall back to a work phase', () {
    final empty = WorkoutTimer(
      name: 'Empty',
      kind: TimerKind.advanced,
      advancedRounds: [
        TimerRound(steps: [IntervalStep(type: PhaseType.rest, seconds: 0)]),
      ],
    );
    final steps = empty.expand();
    expect(steps, isNotEmpty);
    expect(steps.first.type, PhaseType.work);
  });
}
