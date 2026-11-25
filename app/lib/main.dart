import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';
import 'services/cue_audio.dart';
import 'services/settings_store.dart';
import 'services/timer_store.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Portrait and landscape for all screens (owner decision 2026-11-14).
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);

  final timers = TimerStore();
  final settings = SettingsStore();
  await Future.wait([timers.load(), settings.load()]);

  // Set mix/duck audio context before any beep player is created. Default
  // audioplayers focus is exclusive and would pause Spotify/etc.
  await CueAudio.applyGlobalContext(
    lowerMusic: settings.lowerMusicDuringWorkout,
  );

  runApp(TimeItApp(timers: timers, settings: settings));
}

class TimeItApp extends StatelessWidget {
  const TimeItApp({
    super.key,
    required this.timers,
    required this.settings,
  });

  final TimerStore timers;
  final SettingsStore settings;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'TimeIt',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          // Explicit Light/Dark only — never ThemeMode.system.
          themeMode: settings.appearance.themeMode,
          home: HomeScreen(store: timers, settings: settings),
        );
      },
    );
  }
}
