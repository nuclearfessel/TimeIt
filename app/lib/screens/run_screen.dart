import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/workout_timer.dart';
import '../services/timer_engine.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

class RunScreen extends StatefulWidget {
  const RunScreen({super.key, required this.timer});

  final WorkoutTimer timer;

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  late final TimerEngine engine;

  @override
  void initState() {
    super.initState();
    engine = TimerEngine();
    engine.load(widget.timer.expand());
  }

  @override
  void dispose() {
    engine.dispose();
    super.dispose();
  }

  Color get _bg {
    if (engine.status == EngineStatus.finished) return PhaseColors.complete;
    final phase = engine.phase;
    if (phase == null) return AppTheme.bg;
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
        final bg = _bg;
        final onBg = Colors.white;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: bg,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: onBg),
                        ),
                        Expanded(
                          child: Text(
                            widget.timer.name,
                            textAlign: TextAlign.center,
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
                    const Spacer(flex: 2),
                    Text(
                      _phaseLabel,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        fontSize: 18,
                        color: onBg.withValues(alpha: 0.92),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      formatDuration(engine.remaining),
                      style: AppTheme.digits.copyWith(
                        fontSize: 96,
                        color: onBg,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (engine.status != EngineStatus.finished)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: engine.phaseProgress,
                          minHeight: 8,
                          backgroundColor: onBg.withValues(alpha: 0.2),
                          color: onBg,
                        ),
                      ),
                    const SizedBox(height: 14),
                    Text(
                      engine.status == EngineStatus.finished
                          ? 'Workout complete'
                          : 'Step ${engine.index + 1} of ${engine.totalSteps} · ${formatDuration(engine.totalRemaining)} left',
                      style: TextStyle(
                        color: onBg.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(flex: 3),
                    if (engine.index + 1 < engine.totalSteps &&
                        engine.status != EngineStatus.finished)
                      _UpNext(engine: engine, onBg: onBg),
                    const SizedBox(height: 28),
                    _Controls(engine: engine, onBg: onBg),
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

class _UpNext extends StatelessWidget {
  const _UpNext({required this.engine, required this.onBg});

  final TimerEngine engine;
  final Color onBg;

  @override
  Widget build(BuildContext context) {
    final next = engine.schedule[engine.index + 1];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Up next  ${next.type.label} · ${formatSeconds(next.seconds)}',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: onBg.withValues(alpha: 0.9),
          fontWeight: FontWeight.w500,
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

    return Row(
      children: [
        Expanded(
          child: _RoundButton(
            label: 'Reset',
            onBg: onBg,
            onPressed: engine.stop,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 72,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: onBg,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
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
                finished
                    ? 'Restart'
                    : running
                        ? 'Pause'
                        : engine.status == EngineStatus.paused
                            ? 'Resume'
                            : 'Start',
                style: const TextStyle(
                  fontFamily: 'HeptaSlab',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RoundButton(
            label: 'Skip',
            onBg: onBg,
            onPressed: finished ? null : engine.skip,
          ),
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
      height: 72,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: onBg,
          side: BorderSide(color: onBg.withValues(alpha: 0.55)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
