import 'package:flutter/material.dart';

import '../services/settings_store.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.settings});

  final SettingsStore settings;

  @override
  Widget build(BuildContext context) {
    final colors = TimedColors.of(context);

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
                'Light and Dark are set here. Timed does not follow the system theme.',
                style: TextStyle(color: colors.mute, fontSize: 13, height: 1.35),
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
                title: const Text('Alert sounds'),
                subtitle: Text(
                  'Phase changes and workout complete',
                  style: TextStyle(color: colors.mute, fontSize: 13),
                ),
                value: settings.alertSounds,
                onChanged: settings.setAlertSounds,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Countdown beeps'),
                subtitle: Text(
                  'Last 3 seconds of each phase',
                  style: TextStyle(color: colors.mute, fontSize: 13),
                ),
                value: settings.countdownBeeps,
                onChanged: settings.setCountdownBeeps,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Lower music during workout'),
                subtitle: Text(
                  'Coming soon — preference is saved',
                  style: TextStyle(color: colors.mute, fontSize: 13),
                ),
                value: settings.lowerMusicDuringWorkout,
                onChanged: settings.setLowerMusicDuringWorkout,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vibrate on alert'),
                subtitle: Text(
                  'Coming soon — preference is saved',
                  style: TextStyle(color: colors.mute, fontSize: 13),
                ),
                value: settings.vibrateOnAlert,
                onChanged: settings.setVibrateOnAlert,
              ),
              const SizedBox(height: 28),
              _SectionLabel('About'),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Timed'),
                subtitle: Text(
                  'Workout interval timer · v1.0.1',
                  style: TextStyle(color: colors.mute),
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
        color: TimedColors.of(context).fg,
      ),
    );
  }
}
