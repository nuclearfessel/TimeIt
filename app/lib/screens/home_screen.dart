import 'package:flutter/material.dart';

import '../models/workout_timer.dart';
import '../services/settings_store.dart';
import '../services/timer_store.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'editor_screen.dart';
import 'run_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.store,
    required this.settings,
  });

  final TimerStore store;
  final SettingsStore settings;

  Future<void> _create(BuildContext context, TimerKind kind) async {
    final draft =
        kind == TimerKind.simple ? WorkoutTimer.newSimple() : WorkoutTimer.newAdvanced();
    final saved = await Navigator.of(context).push<WorkoutTimer>(
      MaterialPageRoute(
        builder: (_) => EditorScreen(timer: draft, isNew: true),
      ),
    );
    if (saved != null) {
      await store.upsert(saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = TimedColors.of(context);
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final timers = store.timers;
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Image.asset(
                  'assets/brand/timed-mark-color.png',
                  height: 28,
                  width: 28,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(width: 10),
                const Text('Timed'),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Settings',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(settings: settings),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          body: !store.loaded
              ? const Center(child: CircularProgressIndicator())
              : timers.isEmpty
                  ? _EmptyState(
                      onSimple: () => _create(context, TimerKind.simple),
                      onAdvanced: () => _create(context, TimerKind.advanced),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: timers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final timer = timers[i];
                        return _TimerCard(
                          timer: timer,
                          onStart: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RunScreen(
                                  timer: timer,
                                  settings: settings,
                                ),
                              ),
                            );
                          },
                          onEdit: () async {
                            final edited =
                                await Navigator.of(context).push<WorkoutTimer>(
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditorScreen(timer: timer.copy()),
                              ),
                            );
                            if (edited != null) {
                              await store.upsert(edited);
                            }
                          },
                          onDelete: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete timer?'),
                                content: Text('Remove “${timer.name}”?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) await store.delete(timer.id);
                          },
                        );
                      },
                    ),
          floatingActionButton: timers.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () async {
                    final kind = await showModalBottomSheet<TimerKind>(
                      context: context,
                      backgroundColor: colors.surface,
                      builder: (ctx) {
                        return SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Container(
                                    width: 36,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: colors.line,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _NewTimerSheetOption(
                                  title: 'Simple timer',
                                  subtitle:
                                      'Standby, work, rest phases and rounds',
                                  onTap: () =>
                                      Navigator.pop(ctx, TimerKind.simple),
                                ),
                                const SizedBox(height: 8),
                                _NewTimerSheetOption(
                                  title: 'Advanced timer',
                                  subtitle:
                                      'Rounds with their own phase stacks',
                                  onTap: () =>
                                      Navigator.pop(ctx, TimerKind.advanced),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                    if (kind != null && context.mounted) {
                      await _create(context, kind);
                    }
                  },
                  icon: const Icon(Icons.add, weight: 700),
                  label: const Text(
                    'New timer',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSimple, required this.onAdvanced});

  final VoidCallback onSimple;
  final VoidCallback onAdvanced;

  @override
  Widget build(BuildContext context) {
    final colors = TimedColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/brand/timed-mark-color.png',
              height: 56,
              width: 56,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(height: 18),
            Text(
              'Your next routine starts here.',
              style: AppTheme.header.copyWith(fontSize: 26),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Create a timer. Simple work/rest rounds, or advanced rounds each with their own phase stack.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.mute,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: onSimple,
              child: const Text('Create timer'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAdvanced,
              child: const Text('Create advanced timer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerCard extends StatelessWidget {
  const _TimerCard({
    required this.timer,
    required this.onStart,
    required this.onEdit,
    required this.onDelete,
  });

  final WorkoutTimer timer;
  final VoidCallback onStart;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = TimedColors.of(context);
    final kindLabel =
        timer.kind == TimerKind.simple ? 'Simple' : 'Advanced';
    final summary = timer.kind == TimerKind.simple
        ? '${timer.simpleSteps.length} phases · ${timer.rounds} rounds · ${formatSeconds(timer.totalSeconds)}'
        : '${timer.advancedRoundCount} rounds · ${timer.advancedPhaseCount} phases · ${formatSeconds(timer.totalSeconds)}';

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onStart,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timer.name,
                      style: AppTheme.header.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$kindLabel · $summary',
                      style: TextStyle(
                        color: colors.mute,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewTimerSheetOption extends StatelessWidget {
  const _NewTimerSheetOption({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = TimedColors.of(context);
    return Material(
      color: colors.bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: colors.mute,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
