import 'package:uuid/uuid.dart';

import 'interval_step.dart';
import 'phase_type.dart';

/// One round in an advanced timer, with its own phase stack.
class TimerRound {
  TimerRound({
    String? id,
    List<IntervalStep>? steps,
  })  : id = id ?? const Uuid().v4(),
        steps = steps ??
            [
              IntervalStep(type: PhaseType.work, seconds: 40),
              IntervalStep(type: PhaseType.rest, seconds: 20),
            ];

  final String id;
  List<IntervalStep> steps;

  List<IntervalStep> activeSteps() =>
      steps.where((s) => s.seconds > 0).toList();

  TimerRound copy() => TimerRound(
        id: id,
        steps: steps.map((s) => s.copy()).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'steps': steps.map((s) => s.toJson()).toList(),
      };

  factory TimerRound.fromJson(Map<String, dynamic> json) {
    final stepsJson = json['steps'] as List<dynamic>?;
    return TimerRound(
      id: json['id'] as String?,
      steps: stepsJson
          ?.map((e) => IntervalStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
