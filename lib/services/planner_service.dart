import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlannerTask {
  final String id;
  final String title;
  final String subject;
  final String type;
  final DateTime dateTime;
  final int durationMinutes;
  final String priority;
  final String note;
  final bool completed;

  const PlannerTask({
    required this.id,
    required this.title,
    required this.subject,
    required this.type,
    required this.dateTime,
    required this.durationMinutes,
    required this.priority,
    required this.note,
    this.completed = false,
  });

  PlannerTask copyWith({bool? completed}) => PlannerTask(
        id: id,
        title: title,
        subject: subject,
        type: type,
        dateTime: dateTime,
        durationMinutes: durationMinutes,
        priority: priority,
        note: note,
        completed: completed ?? this.completed,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'type': type,
        'dateTime': dateTime.toIso8601String(),
        'durationMinutes': durationMinutes,
        'priority': priority,
        'note': note,
        'completed': completed,
      };

  factory PlannerTask.fromJson(Map<String, dynamic> json) => PlannerTask(
        id: json['id'] as String,
        title: json['title'] as String,
        subject: json['subject'] as String? ?? '',
        type: json['type'] as String? ?? 'Study',
        dateTime: DateTime.parse(json['dateTime'] as String),
        durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 60,
        priority: json['priority'] as String? ?? 'Medium',
        note: json['note'] as String? ?? '',
        completed: json['completed'] as bool? ?? false,
      );
}

class PlannerStore {
  static const _key = 'unibuddy_planner_tasks_v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);
  static List<PlannerTask> _tasks = [];
  static bool _loaded = false;

  static List<PlannerTask> get tasks => List.unmodifiable(_tasks);

  static Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List<dynamic>;
      _tasks = list
          .map((e) => PlannerTask.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    _loaded = true;
    revision.value++;
  }

  static Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_tasks.map((e) => e.toJson()).toList()));
    revision.value++;
  }

  static Future<void> add(PlannerTask task) async {
    await load();
    _tasks = [..._tasks, task]..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    await _persist();
  }

  static Future<void> toggle(String id) async {
    await load();
    _tasks = _tasks.map((t) => t.id == id ? t.copyWith(completed: !t.completed) : t).toList();
    await _persist();
  }

  static Future<void> remove(String id) async {
    await load();
    _tasks = _tasks.where((t) => t.id != id).toList();
    await _persist();
  }

  static List<PlannerTask> upcoming({int limit = 5}) {
    final now = DateTime.now();
    return _tasks.where((t) => !t.completed && t.dateTime.isAfter(now.subtract(const Duration(hours: 1)))).take(limit).toList();
  }

  static List<PlannerTask> today() {
    final now = DateTime.now();
    return _tasks.where((t) => t.dateTime.year == now.year && t.dateTime.month == now.month && t.dateTime.day == now.day).toList();
  }
}
