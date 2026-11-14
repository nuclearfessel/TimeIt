import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';
import 'services/timer_store.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final store = TimerStore();
  await store.load();

  runApp(TimedApp(store: store));
}

class TimedApp extends StatelessWidget {
  const TimedApp({super.key, required this.store});

  final TimerStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timed',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: HomeScreen(store: store),
    );
  }
}
