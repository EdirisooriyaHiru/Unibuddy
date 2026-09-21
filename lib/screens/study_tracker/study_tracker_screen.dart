import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/academic_data.dart';
import '../../models/academic_models.dart';
import '../../theme/app_theme.dart';

class StudyTrackerScreen extends StatefulWidget {
  const StudyTrackerScreen({super.key});

  @override
  State<StudyTrackerScreen> createState() => _StudyTrackerScreenState();
}

class _StudyTrackerScreenState extends State<StudyTrackerScreen> {
  static const _storageKey = 'unibuddy_study_sessions_v2';
  List<_StudySession> _sessions = [];
  bool _loading = true;
  int _goalMinutes = 180;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    final goal = prefs.getInt('unibuddy_study_goal_minutes') ?? 180;
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List)
            .map((e) => _StudySession.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _sessions = list;
      } catch (_) {}
    }
    if (mounted) setState(() { _goalMinutes = goal; _loading = false; });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_sessions.map((e) => e.toJson()).toList()));
  }

  int get _todayMinutes {
    final now = DateTime.now();
    return _sessions.where((s) => _sameDay(s.date, now)).fold(0, (sum, s) => sum + s.minutes);
  }

  int get _weekMinutes {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    return _sessions.where((s) => !s.date.isBefore(monday)).fold(0, (sum, s) => sum + s.minutes);
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _addSession(_StudySession session) async {
    setState(() => _sessions = [..._sessions, session]..sort((a, b) => b.date.compareTo(a.date)));
    await _save();
    if (mounted) SystemSound.play(SystemSoundType.click);
  }

  Future<void> _deleteSession(_StudySession session) async {
    setState(() => _sessions.remove(session));
    await _save();
  }

  Future<void> _setGoal() async {
    final controller = TextEditingController(text: (_goalMinutes / 60).toStringAsFixed(1));
    final value = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily study goal'),
        content: TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Hours', suffixText: 'h')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, double.tryParse(controller.text)), child: const Text('Save')),
        ],
      ),
    );
    if (value == null || value <= 0) return;
    final minutes = (value * 60).round();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unibuddy_study_goal_minutes', minutes);
    setState(() => _goalMinutes = minutes);
  }

  Future<void> _startFlow() async {
    final result = await Navigator.push<_StudySession>(context, MaterialPageRoute(builder: (_) => const _StudySetupScreen()));
    if (result != null) await _addSession(result);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final todayProgress = (_todayMinutes / _goalMinutes).clamp(0.0, 1.0);
    final weekGoal = _goalMinutes * 7;
    final weekProgress = (_weekMinutes / weekGoal).clamp(0.0, 1.0);
    final streak = _calculateStreak();

    return Scaffold(
      appBar: AppBar(title: const Text('Study Tracker'), actions: [IconButton(onPressed: _setGoal, icon: const Icon(Icons.flag_outlined))]),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _AnimatedHero(today: _todayMinutes, goal: _goalMinutes, progress: todayProgress),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _statCard(Icons.local_fire_department_rounded, '$streak days', 'Study streak')),
              const SizedBox(width: 10),
              Expanded(child: _statCard(Icons.timer_outlined, _formatMinutes(_weekMinutes), 'This week')),
            ]),
            const SizedBox(height: 12),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Weekly Goal', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), Text('${(weekProgress * 100).round()}%')]),
              const SizedBox(height: 10),
              ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: weekProgress, minHeight: 10)),
              const SizedBox(height: 8),
              Text('${_formatMinutes(_weekMinutes)} of ${_formatMinutes(weekGoal)} target', style: const TextStyle(color: Colors.black54)),
            ]))),
            const SizedBox(height: 12),
            SizedBox(height: 52, child: FilledButton.icon(onPressed: _startFlow, icon: const Icon(Icons.play_arrow_rounded), label: const Text('Start Study Session', style: TextStyle(fontWeight: FontWeight.bold)))),
            const SizedBox(height: 18),
            const Text('This Week', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _WeeklyChart(sessions: _sessions),
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Recent Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text('${_sessions.length} total', style: const TextStyle(color: Colors.black54))]),
            const SizedBox(height: 8),
            if (_sessions.isEmpty)
              Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(children: [Icon(Icons.menu_book_outlined, size: 42, color: purple.withOpacity(.65)), const SizedBox(height: 8), const Text('No study sessions yet'), const SizedBox(height: 4), const Text('Start your first session and your progress will appear here.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54))]))),
            ..._sessions.take(8).map((s) => Dismissible(key: ValueKey(s.id), background: Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete_outline)), direction: DismissDirection.endToStart, onDismissed: (_) => _deleteSession(s), child: _SessionCard(session: s))),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [CircleAvatar(backgroundColor: purple.withOpacity(.10), child: Icon(icon, color: purple)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12))]))])));

  int _calculateStreak() {
    if (_sessions.isEmpty) return 0;
    final days = _sessions.map((s) => DateTime(s.date.year, s.date.month, s.date.day)).toSet();
    var cursor = DateTime.now();
    if (!days.contains(DateTime(cursor.year, cursor.month, cursor.day))) cursor = cursor.subtract(const Duration(days: 1));
    var count = 0;
    while (days.contains(DateTime(cursor.year, cursor.month, cursor.day))) { count++; cursor = cursor.subtract(const Duration(days: 1)); }
    return count;
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60; final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

class _AnimatedHero extends StatelessWidget {
  final int today, goal;
  final double progress;

  const _AnimatedHero({required this.today, required this.goal, required this.progress});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, value, __) {
        return Card(
          color: purple,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Today's Study", style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 5),
                      Text(_fmt(today), style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Goal: ${_fmt(goal)}', style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 13),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 9,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 7,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    Text('${(value * 100).round()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _fmt(int m) => '${m ~/ 60}h ${m % 60}m';
}

bool _sameDayChart(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

class _WeeklyChart extends StatelessWidget {
  final List<_StudySession> sessions;
  const _WeeklyChart({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final values = List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return sessions.where((s) => _sameDayChart(s.date, day)).fold<int>(0, (sum, s) => sum + s.minutes);
    });
    final max = values.fold<int>(60, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
        child: SizedBox(
          height: 165,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              final day = monday.add(Duration(days: i));
              final h = 95 * values[i] / max;
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(values[i] == 0 ? '' : '${values[i]}m', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                  const SizedBox(height: 3),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 350 + i * 70),
                    width: 24,
                    height: h.clamp(5.0, 95.0).toDouble(),
                    decoration: BoxDecoration(color: values[i] == 0 ? Colors.black12 : purple, borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(height: 6),
                  Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][i], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('${day.day}', style: const TextStyle(fontSize: 9, color: Colors.black45)),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final _StudySession session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: purple.withOpacity(.1),
          child: const Icon(Icons.menu_book_rounded, color: purple),
        ),
        title: Text(
          session.subjectName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('${session.studyType} • ${session.date.day}/${session.date.month}/${session.date.year}'),
        trailing: Text(_fmt(session.minutes), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  static String _fmt(int m) => '${m ~/ 60}h ${m % 60}m';
}

class _StudySetupScreen extends StatefulWidget { const _StudySetupScreen(); @override State<_StudySetupScreen> createState() => _StudySetupScreenState(); }
class _StudySetupScreenState extends State<_StudySetupScreen> {
  int yearIndex = 0, semesterIndex = 0; Subject? subject; String type = 'Revision'; int duration = 25; Timer? timer; int remaining = 0; bool running = false;
  YearData get year => academicYears[yearIndex];
  SemesterData get semester => year.semesters[semesterIndex];
  List<Subject> get subjects => semester.subjects;
  @override void dispose() { timer?.cancel(); super.dispose(); }
  void _start() { if (subject == null) return; if (remaining == 0) remaining = duration * 60; setState(() => running = true); SystemSound.play(SystemSoundType.click); timer?.cancel(); timer = Timer.periodic(const Duration(seconds: 1), (_) { if (remaining <= 1) { timer?.cancel(); setState(() { remaining = 0; running = false; }); SystemSound.play(SystemSoundType.click); _finish(duration); } else { setState(() => remaining--); } }); }
  void _pause() { timer?.cancel(); setState(() => running = false); }
  void _finish(int minutes) { if (subject == null) return; Navigator.pop(context, _StudySession(id: DateTime.now().microsecondsSinceEpoch.toString(), subjectCode: subject!.code, subjectName: subject!.name, date: DateTime.now(), minutes: minutes, studyType: type, year: year.title, semester: semester.title)); }
  Future<void> _manual() async { if (subject == null) return; final c = TextEditingController(text: duration.toString()); final mins = await showDialog<int>(context: context, builder: (_) => AlertDialog(title: const Text('Add completed session'), content: TextField(controller: c, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration', suffixText: 'minutes')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, int.tryParse(c.text)), child: const Text('Add'))])); if (mins != null && mins > 0 && mounted) _finish(mins); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Start Study')), body: ListView(padding: const EdgeInsets.all(16), children: [const Text('Choose your study path', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 16), DropdownButtonFormField<int>(value: yearIndex, decoration: const InputDecoration(labelText: 'Academic Year', border: OutlineInputBorder()), items: List.generate(academicYears.length, (i) => DropdownMenuItem(value: i, child: Text(academicYears[i].title))), onChanged: (v) => setState(() { yearIndex = v!; semesterIndex = 0; subject = null; })), const SizedBox(height: 12), DropdownButtonFormField<int>(value: semesterIndex, decoration: const InputDecoration(labelText: 'Semester', border: OutlineInputBorder()), items: List.generate(year.semesters.length, (i) => DropdownMenuItem(value: i, child: Text(year.semesters[i].title))), onChanged: (v) => setState(() { semesterIndex = v!; subject = null; })), const SizedBox(height: 12), DropdownButtonFormField<Subject>(value: subject, isExpanded: true, decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()), items: subjects.map((s) => DropdownMenuItem(value: s, child: Text('${s.code} • ${s.name}', overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) => setState(() => subject = v)), const SizedBox(height: 12), DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'Study Type', border: OutlineInputBorder()), items: const ['Lecture','Revision','Assignment','Past Paper','Reading'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => type = v!)), const SizedBox(height: 18), Card(color: Theme.of(context).colorScheme.surface, child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [Text(_displayTime(remaining == 0 ? duration * 60 : remaining), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Wrap(spacing: 8, children: [for (final m in [25, 50, 90]) ChoiceChip(label: Text('${m}m'), selected: duration == m, onSelected: running ? null : (_) => setState(() { duration = m; remaining = 0; }))]), const SizedBox(height: 18), Row(mainAxisAlignment: MainAxisAlignment.center, children: [if (running) IconButton.filled(onPressed: _pause, icon: const Icon(Icons.pause)), if (!running) IconButton.filled(onPressed: _start, icon: const Icon(Icons.play_arrow)), const SizedBox(width: 10), OutlinedButton.icon(onPressed: subject == null || running ? null : _manual, icon: const Icon(Icons.add), label: const Text('Add Session'))])]))), const SizedBox(height: 10), if (running) const Text('Focus mode is running. Keep this screen open until the session finishes.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54))]));
  String _displayTime(int s) => '${(s ~/ 60).toString().padLeft(2,'0')}:${(s % 60).toString().padLeft(2,'0')}';
}

class _StudySession { final String id, subjectCode, subjectName, studyType, year, semester; final DateTime date; final int minutes; _StudySession({required this.id, required this.subjectCode, required this.subjectName, required this.date, required this.minutes, required this.studyType, required this.year, required this.semester}); Map<String,dynamic> toJson()=>{'id':id,'subjectCode':subjectCode,'subjectName':subjectName,'date':date.toIso8601String(),'minutes':minutes,'studyType':studyType,'year':year,'semester':semester}; factory _StudySession.fromJson(Map<String,dynamic> j)=>_StudySession(id:j['id'],subjectCode:j['subjectCode'],subjectName:j['subjectName'],date:DateTime.parse(j['date']),minutes:j['minutes'],studyType:j['studyType'],year:j['year'],semester:j['semester']); }
