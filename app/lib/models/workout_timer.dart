import 'package:uuid/uuid.dart';

import 'interval_step.dart';
import 'phase_type.dart';
import 'timer_round.dart';

enum TimerKind {
  simple,
  advanced;

  static TimerKind fromName(String name) {
    return TimerKind.values.firstWhere(
      (v) => v.name == name,
      orElse: () => TimerKind.simple,
    );
  }
}

/// A user-created interval timer (simple or advanced).
class WorkoutTimer {
  WorkoutTimer({
    String? id,
    required this.name,
    required this.kind,
    this.standbySeconds = 10,
    this.workSeconds = 40,
    this.restSeconds = 20,
    this.rounds = 8,
    List<TimerRound>? advancedRounds,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        advancedRounds = advancedRounds ??
            [
              TimerRound(
                steps: [
                  IntervalStep(type: PhaseType.standby, seconds: 10),
                  IntervalStep(type: PhaseType.work, seconds: 45),
                  IntervalStep(type: PhaseType.rest, seconds: 15),
                ],
              ),
            ],
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  String name;
  TimerKind kind;

  /// Simple timer fields.
  int standbySeconds;
  int workSeconds;
  int restSeconds;

  /// Simple: how many work bouts (rest skipped after the last).
  int rounds;

  /// Advanced: each round has its own phase stack.
  List<TimerRound> advancedRounds;

  DateTime updatedAt;

  int get advancedRoundCount => advancedRounds.length;

  int get advancedPhaseCount => advancedRounds.fold<int>(
        0,
        (sum, round) => sum + round.activeSteps().length,
      );

  /// Expand into the flat run sequence used by the engine.
  List<IntervalStep> expand() {
    if (kind == TimerKind.simple) {
      final out = <IntervalStep>[];
      if (standbySeconds > 0) {
        out.add(IntervalStep(type: PhaseType.standby, seconds: standbySeconds));
      }
      final count = rounds < 1 ? 1 : rounds;
      for (var r = 0; r < count; r++) {
        out.add(IntervalStep(type: PhaseType.work, seconds: workSeconds));
        final isLast = r == count - 1;
        if (!isLast && restSeconds > 0) {
          out.add(IntervalStep(type: PhaseType.rest, seconds: restSeconds));
        }
      }
      return out;
    }

    final out = <IntervalStep>[];
    for (final round in advancedRounds) {
      out.addAll(round.activeSteps().map((s) => s.copy()));
    }
    if (out.isEmpty) {
      return [IntervalStep(type: PhaseType.work, seconds: 30)];
    }
    return out;
  }

  int get totalSeconds =>
      expand().fold<int>(0, (sum, step) => sum + step.seconds);

  WorkoutTimer copy() {
    return WorkoutTimer(
      id: id,
      name: name,
      kind: kind,
      standbySeconds: standbySeconds,
      workSeconds: workSeconds,
      restSeconds: restSeconds,
      rounds: rounds,
      advancedRounds: advancedRounds.map((r) => r.copy()).toList(),
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'kind': kind.name,
        'standbySeconds': standbySeconds,
        'workSeconds': workSeconds,
        'restSeconds': restSeconds,
        'rounds': rounds,
        'advancedRounds': advancedRounds.map((r) => r.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory WorkoutTimer.fromJson(Map<String, dynamic> json) {
    return WorkoutTimer(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Timer',
      kind: TimerKind.fromName(json['kind'] as String? ?? 'simple'),
      standbySeconds: (json['standbySeconds'] as num?)?.toInt() ?? 10,
      workSeconds: (json['workSeconds'] as num?)?.toInt() ?? 40,
      restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 20,
      rounds: (json['rounds'] as num?)?.toInt() ?? 8,
      advancedRounds: _parseAdvancedRounds(json),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Migrates legacy `steps` + `cycles` into per-round stacks.
  static List<TimerRound>? _parseAdvancedRounds(Map<String, dynamic> json) {
    final roundsJson = json['advancedRounds'] as List<dynamic>?;
    if (roundsJson != null) {
      return roundsJson
          .map((e) => TimerRound.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final stepsJson = json['steps'] as List<dynamic>?;
    if (stepsJson == null) return null;

    final steps = stepsJson
        .map((e) => IntervalStep.fromJson(e as Map<String, dynamic>))
        .toList();
    final cycles = (json['cycles'] as num?)?.toInt() ?? 1;
    final count = cycles < 1 ? 1 : cycles;
    return List.generate(
      count,
      (_) => TimerRound(steps: steps.map((s) => s.copy()).toList()),
    );
  }

  static WorkoutTimer newSimple() {
    return WorkoutTimer(
      name: 'Simple timer',
      kind: TimerKind.simple,
      standbySeconds: 10,
      workSeconds: 40,
      restSeconds: 20,
      rounds: 8,
    );
  }

  static WorkoutTimer newAdvanced() {
    return WorkoutTimer(
      name: 'Advanced timer',
      kind: TimerKind.advanced,
      advancedRounds: [
        TimerRound(
          steps: [
            IntervalStep(type: PhaseType.standby, seconds: 10),
            IntervalStep(type: PhaseType.work, seconds: 45),
            IntervalStep(type: PhaseType.rest, seconds: 15),
          ],
        ),
        TimerRound(
          steps: [
            IntervalStep(type: PhaseType.work, seconds: 30),
            IntervalStep(type: PhaseType.rest, seconds: 10),
          ],
        ),
        TimerRound(
          steps: [
            IntervalStep(type: PhaseType.work, seconds: 20),
            IntervalStep(type: PhaseType.rest, seconds: 20),
          ],
        ),
      ],
    );
  }
}
