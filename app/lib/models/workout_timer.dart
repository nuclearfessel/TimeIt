import 'package:uuid/uuid.dart';

import 'interval_step.dart';
import 'phase_type.dart';

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
    List<IntervalStep>? steps,
    this.cycles = 1,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        steps = steps ??
            [
              IntervalStep(type: PhaseType.standby, seconds: 10),
              IntervalStep(type: PhaseType.work, seconds: 40),
              IntervalStep(type: PhaseType.rest, seconds: 20),
            ],
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  String name;
  TimerKind kind;

  /// Simple timer fields.
  int standbySeconds;
  int workSeconds;
  int restSeconds;
  int rounds;

  /// Advanced timer fields: stacked phases repeated [cycles] times.
  List<IntervalStep> steps;
  int cycles;

  DateTime updatedAt;

  /// Expand into the flat run sequence used by the engine.
  List<IntervalStep> expand() {
    if (kind == TimerKind.simple) {
      final out = <IntervalStep>[];
      if (standbySeconds > 0) {
        out.add(IntervalStep(type: PhaseType.standby, seconds: standbySeconds));
      }
      for (var r = 0; r < rounds; r++) {
        out.add(IntervalStep(type: PhaseType.work, seconds: workSeconds));
        final isLast = r == rounds - 1;
        if (!isLast && restSeconds > 0) {
          out.add(IntervalStep(type: PhaseType.rest, seconds: restSeconds));
        }
      }
      return out;
    }

    final out = <IntervalStep>[];
    final base = steps.where((s) => s.seconds > 0).toList();
    if (base.isEmpty) {
      return [
        IntervalStep(type: PhaseType.work, seconds: 30),
      ];
    }
    final times = cycles < 1 ? 1 : cycles;
    for (var c = 0; c < times; c++) {
      for (final step in base) {
        out.add(step.copy());
      }
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
      steps: steps.map((s) => s.copy()).toList(),
      cycles: cycles,
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
        'steps': steps.map((s) => s.toJson()).toList(),
        'cycles': cycles,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory WorkoutTimer.fromJson(Map<String, dynamic> json) {
    final stepsJson = json['steps'] as List<dynamic>?;
    return WorkoutTimer(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Timer',
      kind: TimerKind.fromName(json['kind'] as String? ?? 'simple'),
      standbySeconds: (json['standbySeconds'] as num?)?.toInt() ?? 10,
      workSeconds: (json['workSeconds'] as num?)?.toInt() ?? 40,
      restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 20,
      rounds: (json['rounds'] as num?)?.toInt() ?? 8,
      steps: stepsJson
          ?.map((e) => IntervalStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      cycles: (json['cycles'] as num?)?.toInt() ?? 1,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
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
      cycles: 3,
      steps: [
        IntervalStep(type: PhaseType.standby, seconds: 10),
        IntervalStep(type: PhaseType.work, seconds: 45),
        IntervalStep(type: PhaseType.rest, seconds: 15),
      ],
    );
  }
}
