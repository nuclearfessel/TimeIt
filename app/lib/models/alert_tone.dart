/// Shared palette of alert beep sounds for start, end, and finish cues.
enum AlertTone {
  blip,
  pip,
  chime,
  buzz,
  chirp,
  pulse;

  String get label => switch (this) {
        AlertTone.blip => 'Blip',
        AlertTone.pip => 'Pip',
        AlertTone.chime => 'Chime',
        AlertTone.buzz => 'Buzz',
        AlertTone.chirp => 'Chirp',
        AlertTone.pulse => 'Pulse',
      };

  /// Asset path under `assets/` for [AudioPlayer] AssetSource.
  String get assetPath => switch (this) {
        AlertTone.blip => 'sounds/tone_blip.wav',
        AlertTone.pip => 'sounds/tone_pip.wav',
        AlertTone.chime => 'sounds/tone_chime.wav',
        AlertTone.buzz => 'sounds/tone_buzz.wav',
        AlertTone.chirp => 'sounds/tone_chirp.wav',
        AlertTone.pulse => 'sounds/tone_pulse.wav',
      };

  static AlertTone fromName(String? name, {required AlertTone fallback}) {
    return AlertTone.values.firstWhere(
      (v) => v.name == name,
      orElse: () => fallback,
    );
  }
}
