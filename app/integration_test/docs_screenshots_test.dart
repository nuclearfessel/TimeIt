import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeit/models/workout_timer.dart';
import 'package:timeit/screens/editor_screen.dart';
import 'package:timeit/screens/home_screen.dart';
import 'package:timeit/screens/run_screen.dart';
import 'package:timeit/screens/settings_screen.dart';
import 'package:timeit/services/settings_store.dart';
import 'package:timeit/services/timer_store.dart';
import 'package:timeit/theme/app_theme.dart';

Widget _app({
  required Widget home,
  required SettingsStore settings,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: settings.appearance.themeMode,
    home: home,
  );
}

Future<(SettingsStore, TimerStore)> _seed() async {
  SharedPreferences.setMockInitialValues({});
  final settings = SettingsStore();
  await settings.load();
  await settings.setAppearance(AppAppearance.dark);
  final store = TimerStore();
  await store.load();
  await store.upsert(WorkoutTimer.newSimple()..name = 'HIIT 40/20');
  await store.upsert(WorkoutTimer.newAdvanced()..name = 'Pyramid');
  return (settings, store);
}

Future<void> _capture(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
  Widget home,
  SettingsStore settings,
) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  await tester.pumpWidget(_app(settings: settings, home: home));
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  await binding.convertFlutterSurfaceToImage();
  await tester.pumpAndSettle();
  await binding.takeScreenshot(name);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('01-home', (tester) async {
    final (settings, store) = await _seed();
    await _capture(
      binding,
      tester,
      '01-home',
      HomeScreen(store: store, settings: settings),
      settings,
    );
  });

  testWidgets('07-home-with-timers', (tester) async {
    final (settings, store) = await _seed();
    await _capture(
      binding,
      tester,
      '07-home-with-timers',
      HomeScreen(store: store, settings: settings),
      settings,
    );
  });

  testWidgets('04-settings', (tester) async {
    final (settings, _) = await _seed();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      _app(settings: settings, home: SettingsScreen(settings: settings)),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    // Scroll so start/end/finish tone dropdowns are in frame.
    await tester.drag(find.byType(ListView).first, const Offset(0, -320));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('04-settings');
  });

  testWidgets('05-editor-simple', (tester) async {
    final (settings, _) = await _seed();
    await _capture(
      binding,
      tester,
      '05-editor-simple',
      EditorScreen(timer: WorkoutTimer.newSimple()..name = 'HIIT 40/20'),
      settings,
    );
  });

  testWidgets('06-editor-advanced', (tester) async {
    final (settings, _) = await _seed();
    await _capture(
      binding,
      tester,
      '06-editor-advanced',
      EditorScreen(timer: WorkoutTimer.newAdvanced()..name = 'Pyramid'),
      settings,
    );
  });

  testWidgets('02-run-portrait', (tester) async {
    final (settings, _) = await _seed();
    await _capture(
      binding,
      tester,
      '02-run-portrait',
      RunScreen(timer: WorkoutTimer.newSimple()..name = 'HIIT 40/20', settings: settings),
      settings,
    );
  });

  testWidgets('03-run-active', (tester) async {
    final (settings, _) = await _seed();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      _app(
        settings: settings,
        home: RunScreen(
          timer: WorkoutTimer.newSimple()..name = 'HIIT 40/20',
          settings: settings,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pump(const Duration(milliseconds: 600));
    await binding.convertFlutterSurfaceToImage();
    await tester.pump();
    await binding.takeScreenshot('03-run-active');
    // Pause so the engine timer cannot fire after the test ends.
    final pause = find.text('Pause');
    if (pause.evaluate().isNotEmpty) {
      await tester.tap(pause);
      await tester.pump();
    }
  });

  testWidgets('08-run-landscape', (tester) async {
    final (settings, _) = await _seed();
    await tester.binding.setSurfaceSize(const Size(844, 430));
    await tester.pumpWidget(
      _app(
        settings: settings,
        home: RunScreen(
          timer: WorkoutTimer.newSimple()..name = 'HIIT 40/20',
          settings: settings,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('08-run-landscape');
  });
}
