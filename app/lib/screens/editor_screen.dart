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

  Future<int?> _pickSeconds(String title, int current) async {
    final controller = TextEditingController(text: '$current');
    return showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              suffixText: 'seconds',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final v = int.tryParse(controller.text) ?? current;
                Navigator.pop(ctx, v.clamp(0, 60 * 60));
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }

  Future<PhaseType?> _pickPhase(BuildContext context) {
    final colors = TimedColors.of(context);
    return showModalBottomSheet<PhaseType>(
      context: context,
      backgroundColor: colors.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: PhaseType.values
              .map(
                (p) => ListTile(
                  title: Text(p.label),
                  leading: CircleAvatar(
                    backgroundColor: PhaseColors.of(p),
                    radius: 8,
                  ),
                  onTap: () => Navigator.pop(ctx, p),
                ),
              )
              .toList(),
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
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            draft.kind == TimerKind.simple ? 'Simple' : 'Advanced',
            style: TextStyle(color: TimedColors.of(context).mute),
          ),
          const SizedBox(height: 12),
          if (draft.kind == TimerKind.simple) ..._simpleFields(),
          if (draft.kind == TimerKind.advanced) ..._advancedFields(context),
          const SizedBox(height: 24),
          Text(
            'Total ${formatSeconds(draft.totalSeconds)}',
            style: TextStyle(color: TimedColors.of(context).mute),
          ),
        ],
      ),
    );
  }

  List<Widget> _simpleFields() {
    return [
      _ValueTile(
        label: 'Standby',
        value: formatSeconds(draft.standbySeconds),
        color: PhaseColors.standby,
        onTap: () async {
          final v = await _pickSeconds('Standby', draft.standbySeconds);
          if (v != null) setState(() => draft.standbySeconds = v);
        },
      ),
      _ValueTile(
        label: 'Work',
        value: formatSeconds(draft.workSeconds),
        color: PhaseColors.work,
        onTap: () async {
          final v = await _pickSeconds('Work', draft.workSeconds);
          if (v != null) setState(() => draft.workSeconds = v.clamp(1, 3600));
        },
      ),
      _ValueTile(
        label: 'Rest',
        value: formatSeconds(draft.restSeconds),
        color: PhaseColors.rest,
        onTap: () async {
          final v = await _pickSeconds('Rest', draft.restSeconds);
          if (v != null) setState(() => draft.restSeconds = v);
        },
      ),
      _ValueTile(
        label: 'Rounds',
        value: '${draft.rounds}',
        onTap: () async {
          final v = await _pickSeconds('Rounds', draft.rounds);
          if (v != null) setState(() => draft.rounds = v.clamp(1, 99));
        },
      ),
    ];
  }

  List<Widget> _advancedFields(BuildContext context) {
    final colors = TimedColors.of(context);
    return [
      Text(
        'Each round has its own phase stack. Rounds run in order.',
        style: TextStyle(color: colors.mute, height: 1.35),
      ),
      const SizedBox(height: 12),
      ...List.generate(draft.advancedRounds.length, (roundIndex) {
        final round = draft.advancedRounds[roundIndex];
        return _RoundCard(
          key: ValueKey(round.id),
          roundNumber: roundIndex + 1,
          round: round,
          canDelete: draft.advancedRounds.length > 1,
          onDeleteRound: () {
            setState(() => draft.advancedRounds.removeAt(roundIndex));
          },
          onDuplicateRound: () {
            setState(() {
              draft.advancedRounds.insert(
                roundIndex + 1,
                TimerRound(steps: round.steps.map((s) => s.copy()).toList()),
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
      }),
      const SizedBox(height: 8),
      OutlinedButton.icon(
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
        icon: const Icon(Icons.add),
        label: const Text('Add round'),
      ),
    ];
  }
}

class _RoundCard extends StatelessWidget {
  const _RoundCard({
    super.key,
    required this.roundNumber,
    required this.round,
    required this.canDelete,
    required this.onDeleteRound,
    required this.onDuplicateRound,
    required this.onReorderPhases,
    required this.onAddPhase,
    required this.onPhaseType,
    required this.onPhaseDuration,
    required this.onDeletePhase,
  });

  final int roundNumber;
  final TimerRound round;
  final bool canDelete;
  final VoidCallback onDeleteRound;
  final VoidCallback onDuplicateRound;
  final void Function(int oldIndex, int newIndex) onReorderPhases;
  final void Function(PhaseType type) onAddPhase;
  final void Function(int stepIndex) onPhaseType;
  final void Function(int stepIndex) onPhaseDuration;
  final void Function(int stepIndex) onDeletePhase;

  @override
  Widget build(BuildContext context) {
    final colors = TimedColors.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
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
                if (canDelete)
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('+ Standby'),
                  onPressed: () => onAddPhase(PhaseType.standby),
                ),
                ActionChip(
                  label: const Text('+ Work'),
                  onPressed: () => onAddPhase(PhaseType.work),
                ),
                ActionChip(
                  label: const Text('+ Rest'),
                  onPressed: () => onAddPhase(PhaseType.rest),
                ),
              ],
            ),
            if (round.steps.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Add at least one phase to this round.',
                  style: TextStyle(color: colors.mute, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ValueTile extends StatelessWidget {
  const _ValueTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.color,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: color == null
            ? null
            : CircleAvatar(backgroundColor: color, radius: 8),
        title: Text(label),
        trailing: Text(
          value,
          style: AppTheme.header.copyWith(fontSize: 18),
        ),
      ),
    );
  }
}

/// Dragging proxy: fully rounded tile + soft alpha shadow (no opaque underlay).
Widget _stackProxyDecorator(
  Widget child,
  int index,
  Animation<double> animation,
) {
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
            borderRadius: BorderRadius.circular(999),
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
    final colors = TimedColors.of(context);
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
        child: ListTile(
          leading: ReorderableDragStartListener(
            index: index,
            child: Icon(Icons.drag_handle, color: colors.mute),
          ),
          title: InkWell(
            onTap: onType,
            borderRadius: _radius,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: PhaseColors.of(step.type),
                  radius: 7,
                ),
                const SizedBox(width: 8),
                Text(step.type.label),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
