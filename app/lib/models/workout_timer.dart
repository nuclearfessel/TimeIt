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
    List<IntervalStep>? simpleSteps,
    List<TimerRound>? advancedRounds,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        simpleSteps = simpleSteps ??
            _defaultSimpleSteps(
              standbySeconds: standbySeconds,
              workSeconds: workSeconds,
              restSeconds: restSeconds,
            ),
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

  /// Legacy simple scalar fields (kept in sync for older summaries / JSON).
  int standbySeconds;
  int workSeconds;
  int restSeconds;

  /// Simple: how many times to run the phase stack.
  int rounds;

  /// Simple: editable phase stack (standby / work / rest in any mix).
  List<IntervalStep> simpleSteps;

  /// Advanced: each round has its own phase stack.
  List<TimerRound> advancedRounds;

  DateTime updatedAt;

  int get advancedRoundCount => advancedRounds.length;

  int get advancedPhaseCount => advancedRounds.fold<int>(
        0,
        (sum, round) => sum + round.activeSteps().length,
      );

  static List<IntervalStep> _defaultSimpleSteps({
    required int standbySeconds,
    required int workSeconds,
    required int restSeconds,
  }) {
    return [
      if (standbySeconds > 0)
        IntervalStep(type: PhaseType.standby, seconds: standbySeconds),
      IntervalStep(type: PhaseType.work, seconds: workSeconds < 1 ? 40 : workSeconds),
      if (restSeconds > 0)
        IntervalStep(type: PhaseType.rest, seconds: restSeconds),
    ];
  }

  /// Keep scalar fields aligned with the simple stack for home summaries.
  void syncSimpleScalarsFromSteps() {
    final standby = simpleSteps.where((s) => s.type == PhaseType.standby);
    final work = simpleSteps.where((s) => s.type == PhaseType.work);
    final rest = simpleSteps.where((s) => s.type == PhaseType.rest);
    standbySeconds = standby.isEmpty ? 0 : standby.first.seconds;
    workSeconds = work.isEmpty ? 40 : work.first.seconds;
    restSeconds = rest.isEmpty ? 0 : rest.first.seconds;
  }

  /// Expand into the flat run sequence used by the engine.
  ///
  /// When [skipLastRest] is true, trailing rest phases at the end of the
  /// workout are omitted (simple last round and advanced final round alike).
  List<IntervalStep> expand({bool skipLastRest = true}) {
    late final List<IntervalStep> out;
    if (kind == TimerKind.simple) {
      final template = simpleSteps.where((s) => s.seconds > 0).toList();
      if (template.isEmpty) {
        return [IntervalStep(type: PhaseType.work, seconds: 30)];
      }
      // Phases before the first work run once (e.g. standby). From the first
      // work onward, the stack repeats for [rounds].
      final firstWork = template.indexWhere((s) => s.type == PhaseType.work);
      final preface = firstWork > 0
          ? template.sublist(0, firstWork)
          : <IntervalStep>[];
      final cycle =
          firstWork >= 0 ? template.sublist(firstWork) : template;
      out = <IntervalStep>[
        ...preface.map((s) => s.copy()),
      ];
      final count = rounds < 1 ? 1 : rounds;
      for (var r = 0; r < count; r++) {
        for (final step in cycle) {
          out.add(step.copy());
        }
      }
    } else {
      out = <IntervalStep>[];
      for (final round in advancedRounds) {
        out.addAll(round.activeSteps().map((s) => s.copy()));
      }
    }

    if (skipLastRest) {
      while (out.isNotEmpty && out.last.type == PhaseType.rest) {
        out.removeLast();
      }
    }

    return out.isEmpty
        ? [IntervalStep(type: PhaseType.work, seconds: 30)]
        : out;
  }

  int totalSeconds({bool skipLastRest = true}) => expand(skipLastRest: skipLastRest)
      .fold<int>(0, (sum, step) => sum + step.seconds);

  WorkoutTimer copy() {
    return WorkoutTimer(
      id: id,
      name: name,
      kind: kind,
      standbySeconds: standbySeconds,
      workSeconds: workSeconds,
      restSeconds: restSeconds,
      rounds: rounds,
      simpleSteps: simpleSteps.map((s) => s.copy()).toList(),
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
        'simpleSteps': simpleSteps.map((s) => s.toJson()).toList(),
        'advancedRounds': advancedRounds.map((r) => r.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory WorkoutTimer.fromJson(Map<String, dynamic> json) {
    final standby = (json['standbySeconds'] as num?)?.toInt() ?? 10;
    final work = (json['workSeconds'] as num?)?.toInt() ?? 40;
    final rest = (json['restSeconds'] as num?)?.toInt() ?? 20;
    final simpleSteps = (json['simpleSteps'] as List<dynamic>?)
        ?.map((e) => IntervalStep.fromJson(e as Map<String, dynamic>))
        .toList();
    return WorkoutTimer(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Timer',
      kind: TimerKind.fromName(json['kind'] as String? ?? 'simple'),
      standbySeconds: standby,
      workSeconds: work,
      restSeconds: rest,
      rounds: (json['rounds'] as num?)?.toInt() ?? 8,
      simpleSteps: simpleSteps,
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
      simpleSteps: [
        IntervalStep(type: PhaseType.standby, seconds: 10),
        IntervalStep(type: PhaseType.work, seconds: 40),
        IntervalStep(type: PhaseType.rest, seconds: 20),
      ],
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
