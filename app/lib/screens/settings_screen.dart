import 'package:flutter/material.dart';

import '../services/settings_store.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.settings});

  final SettingsStore settings;

  @override
  Widget build(BuildContext context) {
    final colors = TimeItColors.of(context);

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            children: [
              _SectionLabel('Appearance'),
              const SizedBox(height: 8),
              Text(
                'Theme',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colors.fg,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Light and Dark are set here. TimeIt does not follow the system theme.',
                style: TextStyle(
                  color: colors.mute,
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<AppAppearance>(
                segments: const [
                  ButtonSegment(
                    value: AppAppearance.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: AppAppearance.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                ],
                selected: {settings.appearance},
                onSelectionChanged: (next) {
                  if (next.isNotEmpty) {
                    settings.setAppearance(next.first);
                  }
                },
              ),
              const SizedBox(height: 28),
              _SectionLabel('Sound'),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Lower music during workout'),
                subtitle: Text(
                  'Coming soon — preference is saved',
                  style: TextStyle(
                    color: colors.mute,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: settings.lowerMusicDuringWorkout,
                onChanged: settings.setLowerMusicDuringWorkout,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Alert sounds'),
                subtitle: Text(
                  'Start beeps, end beeps, and workout complete',
                  style: TextStyle(
                    color: colors.mute,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: settings.alertSounds,
                onChanged: settings.setAlertSounds,
              ),
              const SizedBox(height: 8),
              _BeepCountSlider(
                title: 'Start beeps',
                subtitle: 'One beep per second at the start of each phase',
                value: settings.startBeepCount,
                enabled: settings.alertSounds,
                onChanged: settings.setStartBeepCount,
              ),
              const SizedBox(height: 8),
              _BeepCountSlider(
                title: 'End beeps',
                subtitle: 'How many beeps leading into the end of each phase',
                value: settings.endBeepCount,
                enabled: settings.alertSounds,
                onChanged: settings.setEndBeepCount,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vibrate on alert'),
                subtitle: Text(
                  'Coming soon — preference is saved',
                  style: TextStyle(
                    color: colors.mute,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: settings.vibrateOnAlert,
                onChanged: settings.setVibrateOnAlert,
              ),
              const SizedBox(height: 28),
              _SectionLabel('About'),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('TimeIt'),
                subtitle: Text(
                  'Workout interval timer · v1.0.12',
                  style: TextStyle(
                    color: colors.mute,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTheme.header.copyWith(
        fontSize: 18,
        color: TimeItColors.of(context).fg,
      ),
    );
  }
}

class _BeepCountSlider extends StatelessWidget {
  const _BeepCountSlider({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final int value;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = TimeItColors.of(context);
    final titleColor = enabled ? colors.fg : colors.mute;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colors.mute,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$value',
                style: AppTheme.header.copyWith(
                  fontSize: 20,
                  color: titleColor,
                ),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: 0,
            max: SettingsStore.maxBeepCount.toDouble(),
            divisions: SettingsStore.maxBeepCount,
            label: '$value',
            onChanged: enabled ? (v) => onChanged(v.round()) : null,
          ),
        ],
      ),
    );
  }
}
