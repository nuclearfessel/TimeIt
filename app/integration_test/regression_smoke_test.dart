import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeit/models/alert_tone.dart';
import 'package:timeit/models/workout_timer.dart';
import 'package:timeit/screens/editor_screen.dart';
import 'package:timeit/screens/home_screen.dart';
import 'package:timeit/screens/run_screen.dart';
import 'package:timeit/screens/settings_screen.dart';
import 'package:timeit/services/settings_store.dart';
import 'package:timeit/services/timer_store.dart';
import 'package:timeit/theme/app_theme.dart';

Widget _app({required Widget home, required SettingsStore settings}) {
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
  return (settings, store);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home lists timers and opens settings', (tester) async {
    final (settings, store) = await _seed();
    await store.upsert(WorkoutTimer.newSimple()..name = 'Smoke HIIT');

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      _app(
        settings: settings,
        home: HomeScreen(store: store, settings: settings),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Smoke HIIT'), findsOneWidget);
    expect(find.text('New timer'), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Alert sounds'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Skip last rest'), findsOneWidget);
    expect(find.text('Delete without confirmation'), findsOneWidget);
  });

  testWidgets('settings tone and timer toggles update store', (tester) async {
    final (settings, _) = await _seed();

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      _app(settings: settings, home: SettingsScreen(settings: settings)),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();

    final skipTile = find.widgetWithText(SwitchListTile, 'Skip last rest');
    expect(skipTile, findsOneWidget);
    final before = settings.skipLastRest;
    await tester.tap(skipTile);
    await tester.pumpAndSettle();
    expect(settings.skipLastRest, isNot(before));

    final deleteTile =
        find.widgetWithText(SwitchListTile, 'Delete without confirmation');
    await tester.tap(deleteTile);
    await tester.pumpAndSettle();
    expect(settings.deleteWithoutConfirmation, isTrue);

    expect(AlertTone.values.contains(settings.startTone), isTrue);
    expect(find.text('Start sound'), findsOneWidget);
    expect(find.text('End sound'), findsOneWidget);
    expect(find.text('Finish sound'), findsOneWidget);
  });

  testWidgets('editor save returns a named timer', (tester) async {
    final (settings, _) = await _seed();
    WorkoutTimer? saved;

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    saved = await Navigator.of(context).push<WorkoutTimer>(
                      MaterialPageRoute(
                        builder: (_) => EditorScreen(
                          timer: WorkoutTimer.newSimple()..name = 'Edit Me',
                          isNew: true,
                          skipLastRest: settings.skipLastRest,
                        ),
                      ),
                    );
                  },
                  child: const Text('Open editor'),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();
    expect(find.text('New timer'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved, isNotNull);
    expect(saved!.name, 'Edit Me');
    expect(saved!.expand().isNotEmpty, isTrue);
  });

  testWidgets('run screen starts and pauses without crash', (tester) async {
    final (settings, _) = await _seed();
    await settings.setAlertSounds(false);
    await settings.setVibrateOnAlert(false);

    final timer = WorkoutTimer.newSimple()..name = 'Run Smoke';
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      _app(
        settings: settings,
        home: RunScreen(timer: timer, settings: settings),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Start'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Pause'), findsOneWidget);
    await tester.tap(find.text('Pause'));
    await tester.pump();
    expect(find.text('Resume'), findsOneWidget);
  });
}
