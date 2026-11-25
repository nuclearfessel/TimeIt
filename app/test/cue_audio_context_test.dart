import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeit/services/cue_audio.dart';

void main() {
  test('beep context always mixes — no Android focus', () {
    final ctx = CueAudio.beepContext();

    expect(ctx.android.audioFocus, AndroidAudioFocus.none);
    expect(ctx.android.contentType, AndroidContentType.sonification);
    expect(ctx.android.usageType, AndroidUsageType.assistanceSonification);

    expect(ctx.iOS.category, AVAudioSessionCategory.playback);
    expect(ctx.iOS.options, {AVAudioSessionOptions.mixWithOthers});
    expect(ctx.iOS.options.contains(AVAudioSessionOptions.duckOthers), isFalse);
  });

  test('duck hold context ducks for the whole workout — never exclusive gain', () {
    final ctx = CueAudio.duckHoldContext();

    expect(ctx.android.audioFocus, AndroidAudioFocus.gainTransientMayDuck);
    expect(ctx.android.audioFocus, isNot(AndroidAudioFocus.gain));
    expect(ctx.android.usageType, AndroidUsageType.media);

    expect(ctx.iOS.category, AVAudioSessionCategory.playback);
    expect(
      ctx.iOS.options,
      {
        AVAudioSessionOptions.mixWithOthers,
        AVAudioSessionOptions.duckOthers,
      },
    );
  });

  test('audioContextFor maps lower-music flag to duck vs mix', () {
    expect(
      CueAudio.audioContextFor(lowerMusic: false).android.audioFocus,
      AndroidAudioFocus.none,
    );
    expect(
      CueAudio.audioContextFor(lowerMusic: true).android.audioFocus,
      AndroidAudioFocus.gainTransientMayDuck,
    );
  });
}
