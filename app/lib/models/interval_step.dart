import 'phase_type.dart';

class IntervalStep {
  IntervalStep({
    required this.type,
    required this.seconds,
  });

  PhaseType type;
  int seconds;

  IntervalStep copy() => IntervalStep(type: type, seconds: seconds);

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'seconds': seconds,
      };

  factory IntervalStep.fromJson(Map<String, dynamic> json) {
    return IntervalStep(
      type: PhaseType.fromName(json['type'] as String? ?? 'work'),
      seconds: (json['seconds'] as num?)?.toInt() ?? 30,
    );
  }
}
