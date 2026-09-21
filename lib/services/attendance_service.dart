import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceEntry {
  final String? date;
  final bool present;

  const AttendanceEntry({this.date, this.present = false});

  Map<String, dynamic> toJson() => {'date': date, 'present': present};

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) => AttendanceEntry(
        date: json['date'] as String?,
        present: json['present'] == true,
      );
}

class AttendanceService {
  static final AttendanceService instance = AttendanceService._();
  AttendanceService._();

  final Map<String, List<List<AttendanceEntry>>> _cache = {};
  SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  String _key(String year, String semester, String subjectCode) =>
      'attendance_v2_${year}_${semester}_$subjectCode';

  Future<List<List<AttendanceEntry>>> load(
    String year,
    String semester,
    String subjectCode,
    int weeklyClasses,
  ) async {
    await _init();
    final key = _key(year, semester, subjectCode);
    if (_cache.containsKey(key)) return _copy(_cache[key]!);

    final raw = _prefs!.getString(key);
    List<List<AttendanceEntry>> values = _empty(weeklyClasses);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List;
        values = List.generate(15, (week) {
          final weekData = week < decoded.length && decoded[week] is List ? decoded[week] as List : const [];
          return List.generate(weeklyClasses, (session) {
            if (session >= weekData.length || weekData[session] is! Map) return const AttendanceEntry();
            return AttendanceEntry.fromJson(Map<String, dynamic>.from(weekData[session] as Map));
          });
        });
      } catch (_) {
        values = _empty(weeklyClasses);
      }
    }
    _cache[key] = values;
    return _copy(values);
  }

  Future<void> save(
    String year,
    String semester,
    String subjectCode,
    List<List<AttendanceEntry>> values,
  ) async {
    await _init();
    final key = _key(year, semester, subjectCode);
    _cache[key] = _copy(values);
    await _prefs!.setString(key, jsonEncode(values.map((w) => w.map((e) => e.toJson()).toList()).toList()));
  }

  Future<void> clear(String year, String semester, String subjectCode) async {
    await _init();
    final key = _key(year, semester, subjectCode);
    _cache.remove(key);
    await _prefs!.remove(key);
  }

  List<List<AttendanceEntry>> _empty(int weeklyClasses) =>
      List.generate(15, (_) => List.generate(weeklyClasses, (_) => const AttendanceEntry()));

  List<List<AttendanceEntry>> _copy(List<List<AttendanceEntry>> source) =>
      source.map((w) => w.map((e) => AttendanceEntry(date: e.date, present: e.present)).toList()).toList();
}
