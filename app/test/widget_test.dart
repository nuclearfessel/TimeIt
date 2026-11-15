import 'package:flutter_test/flutter_test.dart';
import 'package:timed/models/interval_step.dart';
import 'package:timed/models/phase_type.dart';
import 'package:timed/models/timer_round.dart';
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

  test('advanced timer runs each round stack in order', () {
    final timer = WorkoutTimer(
      name: 'Advanced',
      kind: TimerKind.advanced,
      advancedRounds: [
        TimerRound(
          steps: [
            IntervalStep(type: PhaseType.standby, seconds: 5),
            IntervalStep(type: PhaseType.work, seconds: 10),
          ],
        ),
        TimerRound(
          steps: [
            IntervalStep(type: PhaseType.work, seconds: 20),
            IntervalStep(type: PhaseType.rest, seconds: 8),
          ],
        ),
      ],
    );
    final steps = timer.expand();
    expect(steps.map((s) => s.type).toList(), [
      PhaseType.standby,
      PhaseType.work,
      PhaseType.work,
      PhaseType.rest,
    ]);
    expect(timer.totalSeconds, 5 + 10 + 20 + 8);
    expect(timer.advancedRoundCount, 2);
  });

  test('legacy steps and cycles migrate into identical rounds', () {
    final timer = WorkoutTimer.fromJson({
      'name': 'Legacy',
      'kind': 'advanced',
      'cycles': 2,
      'steps': [
        {'type': 'work', 'seconds': 30},
        {'type': 'rest', 'seconds': 10},
      ],
    });
    expect(timer.advancedRounds.length, 2);
    expect(timer.expand().length, 4);
    expect(timer.expand().map((s) => s.type).toList(), [
      PhaseType.work,
      PhaseType.rest,
      PhaseType.work,
      PhaseType.rest,
    ]);
  });
}
