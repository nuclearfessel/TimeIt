import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeit/services/cue_audio.dart';

void main() {
  test('lower music off mixes — no Android focus, iOS mixWithOthers', () {
    final ctx = CueAudio.audioContextFor(lowerMusic: false);

    expect(ctx.android.audioFocus, AndroidAudioFocus.none);
    expect(ctx.android.contentType, AndroidContentType.sonification);
    expect(ctx.android.usageType, AndroidUsageType.assistanceSonification);

    expect(ctx.iOS.category, AVAudioSessionCategory.playback);
    expect(ctx.iOS.options, {AVAudioSessionOptions.mixWithOthers});
    expect(ctx.iOS.options.contains(AVAudioSessionOptions.duckOthers), isFalse);
  });

  test('lower music on ducks — never exclusive gain', () {
    final ctx = CueAudio.audioContextFor(lowerMusic: true);

    expect(ctx.android.audioFocus, AndroidAudioFocus.gainTransientMayDuck);
    expect(ctx.android.audioFocus, isNot(AndroidAudioFocus.gain));

    expect(ctx.iOS.category, AVAudioSessionCategory.playback);
    expect(
      ctx.iOS.options,
      {
        AVAudioSessionOptions.mixWithOthers,
        AVAudioSessionOptions.duckOthers,
      },
    );
  });
}
