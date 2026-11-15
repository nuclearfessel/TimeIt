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
        builder: (_) => EditorScreen(
          timer: draft,
          isNew: true,
          skipLastRest: settings.skipLastRest,
        ),
      ),
    );
    if (saved != null) {
      await store.upsert(saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = TimeItColors.of(context);
    return AnimatedBuilder(
      animation: Listenable.merge([store, settings]),
      builder: (context, _) {
        final timers = store.timers;
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Image.asset(
                  'assets/brand/timeit-mark-color.png',
                  height: 28,
                  width: 28,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(width: 10),
                const Text('TimeIt'),
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
                          skipLastRest: settings.skipLastRest,
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
                                builder: (_) => EditorScreen(
                                  timer: timer.copy(),
                                  skipLastRest: settings.skipLastRest,
                                ),
                              ),
                            );
                            if (edited != null) {
                              await store.upsert(edited);
                            }
                          },
                          onDelete: () async {
                            if (settings.deleteWithoutConfirmation) {
                              await store.delete(timer.id);
                              return;
                            }
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
          // Default Material endFloat margin is 16; pad so the button sits
          // 32 from the right and 28 from the bottom (incl. safe inset).
          floatingActionButton: timers.isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 12),
                  child: FloatingActionButton.extended(
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

  static const _ctaLabelStyle = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
    fontSize: 15,
    height: 1.2,
  );

  static const _ctaPadding = EdgeInsets.symmetric(horizontal: 22, vertical: 14);

  @override
  Widget build(BuildContext context) {
    final colors = TimeItColors.of(context);
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final logoSize = landscape ? 72.0 : 112.0;
    final headlineSize = landscape ? 22.0 : 26.0;

    final primary = FilledButton(
      onPressed: onSimple,
      style: FilledButton.styleFrom(
        padding: _ctaPadding,
        minimumSize: const Size(0, 48),
        textStyle: _ctaLabelStyle,
      ).copyWith(
        overlayColor: AppTheme.pressOverlay(
          pressed: Colors.white.withValues(alpha: 0.28),
          hovered: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: const Text('Create timer'),
    );
    final secondary = OutlinedButton(
      onPressed: onAdvanced,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.fg,
        side: BorderSide(color: colors.line),
        padding: _ctaPadding,
        minimumSize: const Size(0, 48),
        textStyle: _ctaLabelStyle,
      ).copyWith(
        overlayColor: AppTheme.pressOverlay(
          pressed: colors.accent.withValues(alpha: 0.20),
          hovered: colors.accent.withValues(alpha: 0.10),
        ),
      ),
      child: const Text('Create advanced timer'),
    );

    final ctas = landscape
        ? Row(
            children: [
              Expanded(child: primary),
              const SizedBox(width: 12),
              Expanded(child: secondary),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              primary,
              const SizedBox(height: 12),
              secondary,
            ],
          );

    final hPad = landscape ? 36.0 : 28.0;
    final vPad = landscape ? 12.0 : 28.0;

    final content = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/brand/timeit-mark-color.png',
            height: logoSize,
            width: logoSize,
            filterQuality: FilterQuality.high,
          ),
          SizedBox(height: landscape ? 12 : 18),
          Text(
            'Your next routine starts here.',
            style: AppTheme.header.copyWith(fontSize: headlineSize),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: landscape ? 6 : 10),
          Text(
            'Create a timer. Simple work/rest rounds, or advanced rounds each with their own phase stack.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.mute,
              height: 1.4,
              fontWeight: FontWeight.w500,
              fontSize: landscape ? 13.5 : 14,
            ),
          ),
          SizedBox(height: landscape ? 18 : 28),
          ctas,
        ],
      ),
    );

    // SliverFillRemaining fills the body viewport and centers; if the block
    // is taller than the screen it still scrolls instead of clipping.
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
            child: Center(child: content),
          ),
        ),
      ],
    );
  }
}

class _TimerCard extends StatelessWidget {
  const _TimerCard({
    required this.timer,
    required this.skipLastRest,
    required this.onStart,
    required this.onEdit,
    required this.onDelete,
  });

  final WorkoutTimer timer;
  final bool skipLastRest;
  final VoidCallback onStart;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = TimeItColors.of(context);
    final kindLabel =
        timer.kind == TimerKind.simple ? 'Simple' : 'Advanced';
    final total = formatSeconds(timer.totalSeconds(skipLastRest: skipLastRest));
    final summary = timer.kind == TimerKind.simple
        ? '${timer.simpleSteps.length} phases · ${timer.rounds} rounds · $total'
        : '${timer.advancedRoundCount} rounds · ${timer.advancedPhaseCount} phases · $total';

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
    final colors = TimeItColors.of(context);
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
