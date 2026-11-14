enum PhaseType {
  standby,
  work,
  rest;

  String get label {
    switch (this) {
      case PhaseType.standby:
        return 'Standby';
      case PhaseType.work:
        return 'Work';
      case PhaseType.rest:
        return 'Rest';
    }
  }

  static PhaseType fromName(String name) {
    return PhaseType.values.firstWhere(
      (v) => v.name == name,
      orElse: () => PhaseType.work,
    );
  }
}
