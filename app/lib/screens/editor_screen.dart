import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/interval_step.dart';
import '../models/phase_type.dart';
import '../models/timer_round.dart';
import '../models/workout_timer.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({
    super.key,
    required this.timer,
    this.isNew = false,
  });

  final WorkoutTimer timer;
  final bool isNew;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late WorkoutTimer draft;
  late TextEditingController _name;

  @override
  void initState() {
    super.initState();
    draft = widget.timer.copy();
    _name = TextEditingController(text: draft.name);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    draft.name =
        _name.text.trim().isEmpty ? 'Untitled timer' : _name.text.trim();
    if (draft.kind == TimerKind.simple) {
      draft.syncSimpleScalarsFromSteps();
      if (draft.simpleSteps.where((s) => s.seconds > 0).isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add at least one phase.')),
        );
        return;
      }
    }
    if (draft.kind == TimerKind.advanced) {
      final hasPhase = draft.advancedRounds
          .any((round) => round.activeSteps().isNotEmpty);
      if (!hasPhase) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add at least one phase in a round.'),
          ),
        );
        return;
      }
    }
    Navigator.of(context).pop(draft);
  }

  void _addSimplePhase(PhaseType type) {
    final seconds = switch (type) {
      PhaseType.standby => 10,
      PhaseType.work => 40,
      PhaseType.rest => 20,
    };
    setState(() {
      draft.simpleSteps.add(IntervalStep(type: type, seconds: seconds));
      draft.syncSimpleScalarsFromSteps();
    });
  }

  Future<int?> _pickSeconds(String title, int current) {
    return showDialog<int>(
      context: context,
      builder: (_) => _SecondsPickerDialog(
        title: title,
        initial: current,
      ),
    );
  }

  void _setRounds(int next) {
    setState(() => draft.rounds = next.clamp(1, 99));
  }

  Future<void> _pickRounds() async {
    final next = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) => _RoundsWheelSheet(initial: draft.rounds),
    );
    if (next != null) _setRounds(next);
  }

  Future<PhaseType?> _pickPhase(BuildContext context) {
    final colors = TimeItColors.of(context);
    return showModalBottomSheet<PhaseType>(
      context: context,
      backgroundColor: colors.surface,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < PhaseType.values.length; i++) ...[
                if (i > 0) const SizedBox(height: 4),
                _SheetPhaseOption(
                  type: PhaseType.values[i],
                  onTap: () => Navigator.pop(ctx, PhaseType.values[i]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'New timer' : 'Edit timer'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          TextField(
            controller: _name,
            style: AppTheme.header.copyWith(fontSize: 22),
            textInputAction: TextInputAction.next,
            onTap: () {
              // Some devices keep focus without showing the IME; force it.
              SystemChannels.textInput.invokeMethod<void>('TextInput.show');
            },
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            draft.kind == TimerKind.simple ? 'Simple' : 'Advanced',
            style: TextStyle(
              color: TimeItColors.of(context).mute,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          if (draft.kind == TimerKind.simple) ..._simpleFields(),
          if (draft.kind == TimerKind.advanced) ..._advancedFields(context),
          const SizedBox(height: 24),
          Text(
            'Total ${formatSeconds(draft.totalSeconds)}',
            style: TextStyle(
              color: TimeItColors.of(context).mute,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _simpleFields() {
    final colors = TimeItColors.of(context);
    return [
      Text(
        'Build the phase stack for each round. Standby before the first work runs once; rounds repeat from the first work phase.',
        style: TextStyle(
          color: colors.mute,
          height: 1.35,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 12),
      ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        proxyDecorator: _stackProxyDecorator,
        itemCount: draft.simpleSteps.length,
        onReorderItem: (oldIndex, newIndex) {
          setState(() {
            final item = draft.simpleSteps.removeAt(oldIndex);
            draft.simpleSteps.insert(newIndex, item);
            draft.syncSimpleScalarsFromSteps();
          });
        },
        itemBuilder: (context, index) {
          final step = draft.simpleSteps[index];
          return _StepTile(
            key: ValueKey('simple-step-$index-${step.type.name}-${step.seconds}'),
            index: index,
            step: step,
            onType: () async {
              final next = await _pickPhase(context);
              if (next != null) {
                setState(() {
                  draft.simpleSteps[index].type = next;
                  draft.syncSimpleScalarsFromSteps();
                });
              }
            },
            onDuration: () async {
              final v = await _pickSeconds(step.type.label, step.seconds);
              if (v != null) {
                setState(() {
                  draft.simpleSteps[index].seconds =
                      v.clamp(step.type == PhaseType.work ? 1 : 0, 3600);
                  draft.syncSimpleScalarsFromSteps();
                });
              }
            },
            onDelete: () {
              setState(() {
                draft.simpleSteps.removeAt(index);
                draft.syncSimpleScalarsFromSteps();
              });
            },
          );
        },
      ),
      const SizedBox(height: 8),
      _PhaseAddRow(onAdd: _addSimplePhase),
      if (draft.simpleSteps.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Add at least one phase.',
            style: TextStyle(
              color: colors.mute,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      const SizedBox(height: 16),
      _RoundsStepper(
        value: draft.rounds,
        onNudge: _setRounds,
        onPick: _pickRounds,
      ),
    ];
  }

  List<Widget> _advancedFields(BuildContext context) {
    final colors = TimeItColors.of(context);
    return [
      Text(
        'Each round has its own phase stack. Drag rounds to reorder — numbers update automatically.',
        style: TextStyle(
          color: colors.mute,
          height: 1.35,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 12),
      ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        proxyDecorator: _roundProxyDecorator,
        itemCount: draft.advancedRounds.length,
        onReorderItem: (oldIndex, newIndex) {
          setState(() {
            final item = draft.advancedRounds.removeAt(oldIndex);
            draft.advancedRounds.insert(newIndex, item);
          });
        },
        itemBuilder: (context, roundIndex) {
          final round = draft.advancedRounds[roundIndex];
          return _RoundCard(
            key: ValueKey(round.id),
            roundIndex: roundIndex,
            roundNumber: roundIndex + 1,
            round: round,
            onDeleteRound: () {
              setState(() => draft.advancedRounds.removeAt(roundIndex));
            },
            onDuplicateRound: () {
              setState(() {
                draft.advancedRounds.insert(
                  roundIndex + 1,
                  TimerRound(
                    steps: round.steps.map((s) => s.copy()).toList(),
                  ),
                );
              });
            },
            onReorderPhases: (oldIndex, newIndex) {
              setState(() {
                final item = round.steps.removeAt(oldIndex);
                round.steps.insert(newIndex, item);
              });
            },
            onAddPhase: (type) {
              setState(() {
                final seconds = switch (type) {
                  PhaseType.standby => 10,
                  PhaseType.work => 40,
                  PhaseType.rest => 20,
                };
                round.steps.add(IntervalStep(type: type, seconds: seconds));
              });
            },
            onPhaseType: (stepIndex) async {
              final next = await _pickPhase(context);
              if (next != null) {
                setState(() => round.steps[stepIndex].type = next);
              }
            },
            onPhaseDuration: (stepIndex) async {
              final step = round.steps[stepIndex];
              final v = await _pickSeconds(step.type.label, step.seconds);
              if (v != null) {
                setState(() => step.seconds = v.clamp(1, 3600));
              }
            },
            onDeletePhase: (stepIndex) {
              setState(() => round.steps.removeAt(stepIndex));
            },
          );
        },
      ),
      if (draft.advancedRounds.isEmpty) ...[
        Text(
          'No rounds yet. Add one to build this timer.',
          style: TextStyle(
            color: colors.mute,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
      ] else
        const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.icon(
          onPressed: () {
            setState(() {
              draft.advancedRounds.add(
                TimerRound(
                  steps: [
                    IntervalStep(type: PhaseType.work, seconds: 40),
                    IntervalStep(type: PhaseType.rest, seconds: 20),
                  ],
                ),
              );
            });
          },
          style: FilledButton.styleFrom(
            backgroundColor: colors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          ).copyWith(
            overlayColor: AppTheme.pressOverlay(
              pressed: Colors.white.withValues(alpha: 0.28),
              hovered: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          icon: const Icon(Icons.add, weight: 700),
          label: const Text(
            'Add round',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    ];
  }
}

class _RoundCard extends StatelessWidget {
  const _RoundCard({
    super.key,
    required this.roundIndex,
    required this.roundNumber,
    required this.round,
    required this.onDeleteRound,
    required this.onDuplicateRound,
    required this.onReorderPhases,
    required this.onAddPhase,
    required this.onPhaseType,
    required this.onPhaseDuration,
    required this.onDeletePhase,
  });

  final int roundIndex;
  final int roundNumber;
  final TimerRound round;
  final VoidCallback onDeleteRound;
  final VoidCallback onDuplicateRound;
  final void Function(int oldIndex, int newIndex) onReorderPhases;
  final void Function(PhaseType type) onAddPhase;
  final void Function(int stepIndex) onPhaseType;
  final void Function(int stepIndex) onPhaseDuration;
  final void Function(int stepIndex) onDeletePhase;

  @override
  Widget build(BuildContext context) {
    final colors = TimeItColors.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: roundIndex,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.drag_handle, color: colors.mute),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Round $roundNumber',
                    style: AppTheme.header.copyWith(fontSize: 18),
                  ),
                ),
                IconButton(
                  tooltip: 'Duplicate round',
                  onPressed: onDuplicateRound,
                  icon: const Icon(Icons.copy_outlined),
                ),
                IconButton(
                  tooltip: 'Delete round',
                  onPressed: onDeleteRound,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              proxyDecorator: _stackProxyDecorator,
              itemCount: round.steps.length,
              onReorderItem: onReorderPhases,
              itemBuilder: (context, index) {
                final step = round.steps[index];
                return _StepTile(
                  key: ValueKey('${round.id}-step-$index-${step.type.name}'),
                  index: index,
                  step: step,
                  onType: () => onPhaseType(index),
                  onDuration: () => onPhaseDuration(index),
                  onDelete: () => onDeletePhase(index),
                );
              },
            ),
            const SizedBox(height: 8),
            _PhaseAddRow(onAdd: onAddPhase),
            if (round.steps.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Add at least one phase to this round.',
                  style: TextStyle(
                    color: colors.mute,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Width of two digits at the same type size as phase seconds.
double _roundsTwoDigitWidth(Color color) {
  final painter = TextPainter(
    text: TextSpan(
      text: '00',
      style: AppTheme.header.copyWith(fontSize: 16, color: color),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  return painter.width;
}

/// Compact rounds control: − / + for nudges; tap the value for a scroll wheel.
class _RoundsStepper extends StatelessWidget {
  const _RoundsStepper({
    required this.value,
    required this.onNudge,
    required this.onPick,
  });

  final int value;
  final ValueChanged<int> onNudge;
  final VoidCallback onPick;

  Widget _stepper({
    required TimeItColors colors,
    required IconData icon,
    required String tooltip,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: enabled ? onPressed : null,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        foregroundColor: colors.fg,
        disabledForegroundColor: colors.mute.withValues(alpha: 0.35),
        padding: const EdgeInsets.all(8),
      ).copyWith(
        overlayColor: AppTheme.pressOverlay(
          pressed: colors.accent.withValues(alpha: 0.20),
          hovered: colors.accent.withValues(alpha: 0.10),
        ),
      ),
      icon: Icon(icon, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = TimeItColors.of(context);
    final fieldFill = Color.lerp(colors.bg, colors.surface, 0.22)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Rounds',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: colors.fg,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: fieldFill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.line),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _stepper(
                    colors: colors,
                    icon: Icons.remove,
                    tooltip: 'Decrease',
                    enabled: value > 1,
                    onPressed: () => onNudge(value - 1),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onPick,
                      borderRadius: BorderRadius.circular(8),
                      overlayColor: AppTheme.pressOverlay(
                        pressed: colors.accent.withValues(alpha: 0.20),
                        hovered: colors.accent.withValues(alpha: 0.10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        // Match phase-seconds type size (16); fixed 2-digit
                        // width so 9 → 10 does not resize the stepper.
                        child: SizedBox(
                          width: _roundsTwoDigitWidth(colors.fg),
                          child: Text(
                            '$value',
                            textAlign: TextAlign.center,
                            style: AppTheme.header.copyWith(
                              fontSize: 16,
                              color: colors.fg,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _stepper(
                    colors: colors,
                    icon: Icons.add,
                    tooltip: 'Increase',
                    enabled: value < 99,
                    onPressed: () => onNudge(value + 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Short wheel sheet for picking 1–99 — no soft keyboard required.
class _RoundsWheelSheet extends StatefulWidget {
  const _RoundsWheelSheet({required this.initial});

  final int initial;

  @override
  State<_RoundsWheelSheet> createState() => _RoundsWheelSheetState();
}

class _RoundsWheelSheetState extends State<_RoundsWheelSheet> {
  static const int _min = 1;
  static const int _max = 99;

  late int _selected;
  late final FixedExtentScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial.clamp(_min, _max);
    _scroll = FixedExtentScrollController(initialItem: _selected - _min);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = TimeItColors.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rounds',
              style: AppTheme.header.copyWith(fontSize: 20, color: colors.fg),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: ListWheelScrollView.useDelegate(
                controller: _scroll,
                itemExtent: 40,
                perspective: 0.003,
                diameterRatio: 1.4,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (i) {
                  setState(() => _selected = i + _min);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: _max - _min + 1,
                  builder: (context, index) {
                    final n = index + _min;
                    final selected = n == _selected;
                    return Center(
                      child: Text(
                        '$n',
                        style: AppTheme.header.copyWith(
                          fontSize: selected ? 28 : 20,
                          color: selected ? colors.fg : colors.mute,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context, _selected),
                  child: const Text('Set'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhaseAddRow extends StatelessWidget {
  const _PhaseAddRow({required this.onAdd});

  final void Function(PhaseType type) onAdd;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final type in PhaseType.values)
          _PhaseAddChip(type: type, onPressed: () => onAdd(type)),
      ],
    );
  }
}

/// Phase add control: color swatch + plus + label on one text line (middle-aligned).
class _PhaseAddChip extends StatelessWidget {
  const _PhaseAddChip({required this.type, required this.onPressed});

  final PhaseType type;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = TimeItColors.of(context);
    final labelStyle = TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontWeight: FontWeight.w500,
      fontSize: 14,
      height: 1.2,
      leadingDistribution: TextLeadingDistribution.even,
      color: colors.fg,
    );
    return Material(
      color: colors.surface,
      shape: StadiumBorder(side: BorderSide(color: colors.line)),
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: PhaseColors.of(type),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  style: labelStyle,
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Transform.translate(
                          offset: const Offset(0, 0.5),
                          child: SizedBox(
                            width: 11,
                            height: 11,
                            child: CustomPaint(
                              painter: _PlusPainter(color: colors.fg),
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextSpan(text: type.label),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlusPainter extends CustomPainter {
  _PlusPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.square;
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(Offset(cx, 0.5), Offset(cx, size.height - 0.5), paint);
    canvas.drawLine(Offset(0.5, cy), Offset(size.width - 0.5, cy), paint);
  }

  @override
  bool shouldRepaint(covariant _PlusPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _SheetPhaseOption extends StatelessWidget {
  const _SheetPhaseOption({required this.type, required this.onTap});

  final PhaseType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: PhaseColors.of(type),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                type.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dragging proxy: soft alpha shadow (no opaque underlay).
Widget _dragProxyDecorator(
  Widget child,
  int index,
  Animation<double> animation, {
  required double radius,
}) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final t = Curves.easeOutCubic.transform(animation.value);
      return Material(
        type: MaterialType.transparency,
        elevation: 0,
        shadowColor: Colors.transparent,
        color: Colors.transparent,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35 * t),
                blurRadius: 18 * t,
                spreadRadius: 0,
                offset: Offset(0, 10 * t),
              ),
            ],
          ),
          child: child,
        ),
      );
    },
    child: child,
  );
}

Widget _stackProxyDecorator(
  Widget child,
  int index,
  Animation<double> animation,
) {
  return _dragProxyDecorator(child, index, animation, radius: 999);
}

Widget _roundProxyDecorator(
  Widget child,
  int index,
  Animation<double> animation,
) {
  return _dragProxyDecorator(child, index, animation, radius: 16);
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    super.key,
    required this.index,
    required this.step,
    required this.onType,
    required this.onDuration,
    required this.onDelete,
  });

  final int index;
  final IntervalStep step;
  final VoidCallback onType;
  final VoidCallback onDuration;
  final VoidCallback onDelete;

  static const _radius = BorderRadius.all(Radius.circular(999));

  @override
  Widget build(BuildContext context) {
    final colors = TimeItColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(color: colors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  child: Icon(Icons.drag_handle, color: colors.mute),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: onType,
                  borderRadius: _radius,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: PhaseColors.of(step.type),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          step.type.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: onDuration,
                child: Text(
                  formatSeconds(step.seconds),
                  style: AppTheme.header.copyWith(fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact seconds dialog — no FocusNode / TextInput.show. Tap the field to type.
class _SecondsPickerDialog extends StatefulWidget {
  const _SecondsPickerDialog({
    required this.title,
    required this.initial,
  });

  final String title;
  final int initial;

  @override
  State<_SecondsPickerDialog> createState() => _SecondsPickerDialogState();
}

class _SecondsPickerDialogState extends State<_SecondsPickerDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.initial}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _parsed {
    final raw = int.tryParse(_controller.text);
    if (raw == null) return widget.initial.clamp(0, 60 * 60);
    return raw.clamp(0, 60 * 60);
  }

  @override
  Widget build(BuildContext context) {
    final colors = TimeItColors.of(context);
    final fieldFill = Color.lerp(colors.bg, colors.surface, 0.22)!;
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: colors.line),
      borderRadius: BorderRadius.circular(10),
    );

    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        autocorrect: false,
        enableSuggestions: false,
        onTap: () {
          SystemChannels.textInput.invokeMethod<void>('TextInput.show');
        },
        onSubmitted: (_) => Navigator.pop(context, _parsed),
        decoration: InputDecoration(
          suffixText: 'seconds',
          filled: true,
          fillColor: fieldFill,
          border: border,
          enabledBorder: border,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colors.accent, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _parsed),
          child: const Text('Set'),
        ),
      ],
    );
  }
}
