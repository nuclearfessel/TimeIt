import 'package:flutter_test/flutter_test.dart';
import 'package:timed/models/phase_type.dart';
import 'package:timed/models/workout_timer.dart';

void main() {
  test('simple timer expands standby, work, rest rounds', () {
    final timer = WorkoutTimer(
      name: 'Test',
      kind: TimerKind.simple,
      standbySeconds: 5,
      workSeconds: 10,
      restSeconds: 5,
      rounds: 2,
    );
    final steps = timer.expand();
    expect(steps.map((s) => s.type).toList(), [
      PhaseType.standby,
      PhaseType.work,
      PhaseType.rest,
      PhaseType.work,
    ]);
    expect(timer.totalSeconds, 5 + 10 + 5 + 10);
  });

  test('advanced timer stacks phases across cycles', () {
    final timer = WorkoutTimer.newAdvanced();
    timer.cycles = 2;
    final steps = timer.expand();
    expect(steps.length, 6);
    expect(steps.first.type, PhaseType.standby);
  });
}
