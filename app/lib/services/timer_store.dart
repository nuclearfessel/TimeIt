import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_timer.dart';

class TimerStore extends ChangeNotifier {
  static const _key = 'timed.workout_timers.v1';

  final List<WorkoutTimer> _timers = [];
  bool loaded = false;

  List<WorkoutTimer> get timers {
    final copy = [..._timers];
    copy.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return copy;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    _timers.clear();
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final item in list) {
        _timers.add(WorkoutTimer.fromJson(item as Map<String, dynamic>));
      }
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_timers.map((t) => t.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  WorkoutTimer? byId(String id) {
    try {
      return _timers.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsert(WorkoutTimer timer) async {
    timer.updatedAt = DateTime.now();
    final index = _timers.indexWhere((t) => t.id == timer.id);
    if (index >= 0) {
      _timers[index] = timer;
    } else {
      _timers.add(timer);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _timers.removeWhere((t) => t.id == id);
    await _persist();
    notifyListeners();
  }
}
