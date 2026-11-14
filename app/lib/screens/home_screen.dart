import 'package:flutter/material.dart';

import '../models/workout_timer.dart';
import '../services/timer_store.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'editor_screen.dart';
import 'run_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store});

  final TimerStore store;

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
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final timers = store.timers;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Timed'),
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
                                builder: (_) => RunScreen(timer: timer),
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
                      backgroundColor: AppTheme.surface,
                      builder: (ctx) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text('Simple timer'),
                                subtitle: const Text(
                                  'Standby, work, rest, rounds',
                                ),
                                onTap: () =>
                                    Navigator.pop(ctx, TimerKind.simple),
                              ),
                              ListTile(
                                title: const Text('Advanced timer'),
                                subtitle: const Text(
                                  'Stack standby, work, and rest',
                                ),
                                onTap: () =>
                                    Navigator.pop(ctx, TimerKind.advanced),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        );
                      },
                    );
                    if (kind != null && context.mounted) {
                      await _create(context, kind);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New timer'),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your timers',
              style: AppTheme.header.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 10),
            const Text(
              'Create a simple work/rest timer, or an advanced stack of standby, work, and rest.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.mute, height: 1.4),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: onSimple,
              child: const Text('Create simple timer'),
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
    final kindLabel =
        timer.kind == TimerKind.simple ? 'Simple' : 'Advanced';
    final summary = timer.kind == TimerKind.simple
        ? '${formatSeconds(timer.workSeconds)} work · ${formatSeconds(timer.restSeconds)} rest · ${timer.rounds} rounds'
        : '${timer.steps.length} phases · ${timer.cycles} cycles · ${formatSeconds(timer.totalSeconds)}';

    return Material(
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.line),
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
                      style: const TextStyle(
                        color: AppTheme.mute,
                        fontSize: 13,
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
