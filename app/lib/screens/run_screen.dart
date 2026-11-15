import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    engine.load(
      widget.timer.expand(skipLastRest: widget.settings.skipLastRest),
    );
  }

  @override
  void dispose() {
    engine.dispose();
    super.dispose();
  }

  Color _bg(BuildContext context) {
    if (engine.status == EngineStatus.finished) return PhaseColors.complete;
    final phase = engine.phase;
    if (phase == null) return TimeItColors.of(context).bg;
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
        final timerPane = _TimerPane(
          title: widget.timer.name,
          phaseLabel: _phaseLabel,
          digits: formatDuration(engine.remaining),
          progress: engine.status == EngineStatus.finished
              ? 1
              : engine.phaseProgress,
          stepSummary: engine.status == EngineStatus.finished
              ? 'Workout complete'
              : 'Step ${engine.index + 1} of ${engine.totalSteps} · ${formatDuration(engine.totalRemaining)} left',
          showProgress: engine.status != EngineStatus.finished,
          onClose: () => Navigator.pop(context),
          onBg: onBg,
        );
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: bg,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                // Portrait and landscape: timer on top, up next + controls underneath.
                // Never show the phase stack list.
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: timerPane),
                    const SizedBox(height: 12),
                    _RunControls(
                      engine: engine,
                      onBg: onBg,
                      horizontal: true,
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
    required this.progress,
    required this.stepSummary,
    required this.showProgress,
    required this.onClose,
    required this.onBg,
  });

  final String title;
  final String phaseLabel;
  final String digits;
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
                  fontWeight: FontWeight.w500,
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
              final digitSize = (constraints.maxWidth / 3.8)
                  .clamp(40.0, 96.0)
                  .toDouble();
              final tight = constraints.maxHeight < 220;
              final gap = tight ? 6.0 : 12.0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth - 16,
                    ),
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
                            fontSize: tight ? 14.0 : 18.0,
                            color: onBg.withValues(alpha: 0.92),
                          ),
                        ),
                        SizedBox(height: gap),
                        Text(
                          digits,
                          maxLines: 1,
                          softWrap: false,
                          style: AppTheme.digits.copyWith(
                            fontSize: digitSize,
                            height: 1,
                            letterSpacing: -1,
                            color: onBg,
                          ),
                        ),
                        SizedBox(height: tight ? 8 : 16),
                        if (showProgress)
                          SizedBox(
                            width: constraints.maxWidth - 16,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: onBg.withValues(alpha: 0.2),
                                color: onBg,
                              ),
                            ),
                          ),
                        SizedBox(height: gap),
                        Text(
                          stepSummary,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            color: onBg.withValues(alpha: 0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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

class _RunControls extends StatelessWidget {
  const _RunControls({
    required this.engine,
    required this.onBg,
    required this.horizontal,
  });

  final TimerEngine engine;
  final Color onBg;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final showUpNext = engine.index + 1 < engine.totalSteps &&
        engine.status != EngineStatus.finished;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showUpNext) ...[
          _UpNext(engine: engine, onBg: onBg),
          const SizedBox(height: 12),
        ],
        _Controls(engine: engine, onBg: onBg, horizontal: horizontal),
      ],
    );
  }
}

class _UpNext extends StatelessWidget {
  const _UpNext({
    required this.engine,
    required this.onBg,
  });

  final TimerEngine engine;
  final Color onBg;

  @override
  Widget build(BuildContext context) {
    final next = engine.schedule[engine.index + 1];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Up next  ${next.type.label} · ${formatSeconds(next.seconds)}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          color: onBg.withValues(alpha: 0.9),
          fontWeight: FontWeight.w500,
          fontSize: 14,
          height: 1.3,
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.engine,
    required this.onBg,
    this.horizontal = false,
  });

  final TimerEngine engine;
  final Color onBg;
  final bool horizontal;

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

    final primary = SizedBox(
      height: horizontal ? 64 : 56,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: onBg,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ).copyWith(
          overlayColor: AppTheme.pressOverlay(
            pressed: Colors.black.withValues(alpha: 0.18),
            hovered: Colors.black.withValues(alpha: 0.08),
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
          style: TextStyle(
            fontFamily: 'HeptaSlab',
            fontSize: horizontal ? 20 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    if (horizontal) {
      return Row(
        children: [
          Expanded(
            child: _RoundButton(
              label: 'Reset',
              onBg: onBg,
              onPressed: engine.stop,
              height: 64,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: primary),
          const SizedBox(width: 10),
          Expanded(
            child: _RoundButton(
              label: 'Skip',
              onBg: onBg,
              onPressed: finished ? null : engine.skip,
              height: 64,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        primary,
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
    this.height = 48,
  });

  final String label;
  final Color onBg;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = onBg.withValues(alpha: enabled ? 1 : 0.4);
    return SizedBox(
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          splashColor: color.withValues(alpha: 0.28),
          highlightColor: color.withValues(alpha: 0.14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.55)),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
