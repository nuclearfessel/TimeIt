import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/interval_step.dart';
import '../models/workout_timer.dart';
import '../services/settings_store.dart';
import '../services/timer_engine.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

class RunScreen extends StatefulWidget {
  const RunScreen({
    super.key,
    required this.timer,
    required this.settings,
  });

  final WorkoutTimer timer;
  final SettingsStore settings;

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  late final TimerEngine engine;

  @override
  void initState() {
    super.initState();
    engine = TimerEngine(settings: widget.settings);
    engine.load(widget.timer.expand());
  }

  @override
  void dispose() {
    engine.dispose();
    super.dispose();
  }

  Color _bg(BuildContext context) {
    if (engine.status == EngineStatus.finished) return PhaseColors.complete;
    final phase = engine.phase;
    if (phase == null) return TimedColors.of(context).bg;
    return PhaseColors.of(phase);
  }

  String get _phaseLabel {
    if (engine.status == EngineStatus.finished) return 'Done';
    return engine.phase?.label.toUpperCase() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: engine,
      builder: (context, _) {
        final bg = _bg(context);
        const onBg = Colors.white;
        final size = MediaQuery.sizeOf(context);
        // Scale digits to the left pane so phones and tablets stay readable.
        final digitSize = (size.width * 0.22).clamp(52.0, 120.0);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: bg,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _TimerPane(
                        title: widget.timer.name,
                        phaseLabel: _phaseLabel,
                        digits: formatDuration(engine.remaining),
                        digitSize: digitSize,
                        progress: engine.status == EngineStatus.finished
                            ? 1
                            : engine.phaseProgress,
                        stepSummary: engine.status == EngineStatus.finished
                            ? 'Workout complete'
                            : 'Step ${engine.index + 1} of ${engine.totalSteps} · ${formatDuration(engine.totalRemaining)} left',
                        showProgress:
                            engine.status != EngineStatus.finished,
                        onClose: () => Navigator.pop(context),
                        onBg: onBg,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _SidePane(
                        engine: engine,
                        onBg: onBg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TimerPane extends StatelessWidget {
  const _TimerPane({
    required this.title,
    required this.phaseLabel,
    required this.digits,
    required this.digitSize,
    required this.progress,
    required this.stepSummary,
    required this.showProgress,
    required this.onClose,
    required this.onBg,
  });

  final String title;
  final String phaseLabel;
  final String digits;
  final double digitSize;
  final double progress;
  final String stepSummary;
  final bool showProgress;
  final VoidCallback onClose;
  final Color onBg;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onClose,
              icon: Icon(Icons.close, color: onBg),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                  color: onBg.withValues(alpha: 0.9),
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth,
                    maxHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          phaseLabel,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            fontSize: 18,
                            color: onBg.withValues(alpha: 0.92),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          digits,
                          style: AppTheme.digits.copyWith(
                            fontSize: digitSize,
                            color: onBg,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (showProgress)
                          SizedBox(
                            width: constraints.maxWidth.clamp(120, 420),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor:
                                    onBg.withValues(alpha: 0.2),
                                color: onBg,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          stepSummary,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: onBg.withValues(alpha: 0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SidePane extends StatelessWidget {
  const _SidePane({
    required this.engine,
    required this.onBg,
  });

  final TimerEngine engine;
  final Color onBg;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Stack',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontSize: 12,
            color: onBg.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _StackList(engine: engine, onBg: onBg),
        ),
        if (engine.index + 1 < engine.totalSteps &&
            engine.status != EngineStatus.finished) ...[
          const SizedBox(height: 8),
          _UpNext(engine: engine, onBg: onBg),
        ],
        const SizedBox(height: 10),
        _Controls(engine: engine, onBg: onBg),
      ],
    );
  }
}

class _StackList extends StatelessWidget {
  const _StackList({required this.engine, required this.onBg});

  final TimerEngine engine;
  final Color onBg;

  @override
  Widget build(BuildContext context) {
    final steps = engine.schedule;
    if (steps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        itemCount: steps.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          color: onBg.withValues(alpha: 0.12),
        ),
        itemBuilder: (context, index) {
          final step = steps[index];
          final current = index == engine.index &&
              engine.status != EngineStatus.finished;
          final done = index < engine.index ||
              engine.status == EngineStatus.finished;
          return _StackRow(
            index: index,
            step: step,
            current: current,
            done: done,
            onBg: onBg,
          );
        },
      ),
    );
  }
}

class _StackRow extends StatelessWidget {
  const _StackRow({
    required this.index,
    required this.step,
    required this.current,
    required this.done,
    required this.onBg,
  });

  final int index;
  final IntervalStep step;
  final bool current;
  final bool done;
  final Color onBg;

  @override
  Widget build(BuildContext context) {
    final alpha = current ? 1.0 : done ? 0.45 : 0.82;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          CircleAvatar(
            radius: 5,
            backgroundColor: PhaseColors.of(step.type).withValues(alpha: alpha),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              step.type.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: onBg.withValues(alpha: alpha),
                fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            formatSeconds(step.seconds),
            style: TextStyle(
              color: onBg.withValues(alpha: alpha),
              fontSize: 12,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpNext extends StatelessWidget {
  const _UpNext({required this.engine, required this.onBg});

  final TimerEngine engine;
  final Color onBg;

  @override
  Widget build(BuildContext context) {
    final next = engine.schedule[engine.index + 1];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Up next\n${next.type.label} · ${formatSeconds(next.seconds)}',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: onBg.withValues(alpha: 0.9),
          fontWeight: FontWeight.w500,
          fontSize: 13,
          height: 1.3,
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.engine, required this.onBg});

  final TimerEngine engine;
  final Color onBg;

  @override
  Widget build(BuildContext context) {
    final running = engine.status == EngineStatus.running;
    final finished = engine.status == EngineStatus.finished;
    final primaryLabel = finished
        ? 'Restart'
        : running
            ? 'Pause'
            : engine.status == EngineStatus.paused
                ? 'Resume'
                : 'Start';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: onBg,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              if (finished) {
                engine.stop();
                engine.start();
              } else {
                engine.toggle();
              }
            },
            child: Text(
              primaryLabel,
              style: const TextStyle(
                fontFamily: 'HeptaSlab',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _RoundButton(
                label: 'Reset',
                onBg: onBg,
                onPressed: engine.stop,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RoundButton(
                label: 'Skip',
                onBg: onBg,
                onPressed: finished ? null : engine.skip,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.label,
    required this.onBg,
    required this.onPressed,
  });

  final String label;
  final Color onBg;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: onBg,
          side: BorderSide(color: onBg.withValues(alpha: 0.55)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}
