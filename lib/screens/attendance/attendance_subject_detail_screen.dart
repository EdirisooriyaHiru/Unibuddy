import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/academic_models.dart';
import '../../services/attendance_service.dart';
import '../../theme/app_theme.dart';

class AttendanceSubjectDetailScreen extends StatefulWidget {
  final YearData year;
  final SemesterData semester;
  final Subject subject;

  const AttendanceSubjectDetailScreen({
    super.key,
    required this.year,
    required this.semester,
    required this.subject,
  });

  @override
  State<AttendanceSubjectDetailScreen> createState() => _AttendanceSubjectDetailScreenState();
}

class _AttendanceSubjectDetailScreenState extends State<AttendanceSubjectDetailScreen> {
  static const int totalWeeks = 15;
  static const double eligibilityThreshold = 80;

  late final int weeklyClasses;
  List<List<AttendanceEntry>> sessions = [];
  bool loading = true;

  int get totalClasses => weeklyClasses * totalWeeks;
  int get totalAttended => sessions.fold(0, (sum, week) => sum + week.where((e) => e.present).length);
  int get markedClasses => sessions.fold(0, (sum, week) => sum + week.where((e) => e.date != null).length);
  double get percentage => totalClasses == 0 ? 0 : totalAttended / totalClasses * 100;
  bool get eligible => percentage >= eligibilityThreshold;

  @override
  void initState() {
    super.initState();
    weeklyClasses = 1; // One lecture/session per week for every subject.
    _load();
  }

  Future<void> _load() async {
    final data = await AttendanceService.instance.load(widget.year.title, widget.semester.title, widget.subject.code, weeklyClasses);
    if (!mounted) return;
    setState(() {
      sessions = data;
      loading = false;
    });
  }

  Future<void> _save() => AttendanceService.instance.save(widget.year.title, widget.semester.title, widget.subject.code, sessions);

  Future<void> _pickDate(int week, int session) async {
    final current = sessions[week][session].date;
    final initial = current == null ? DateTime.now() : DateTime.tryParse(current) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Select class date',
    );
    if (picked == null) return;
    final date = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    setState(() => sessions[week][session] = AttendanceEntry(date: date, present: sessions[week][session].present));
    await _save();
  }

  Future<void> _toggleAttendance(int week, int session) async {
    final entry = sessions[week][session];
    if (entry.date == null) {
      await _pickDate(week, session);
      if (!mounted) return;
    }
    final latest = sessions[week][session];
    final nextPresent = !latest.present;
    setState(() => sessions[week][session] = AttendanceEntry(date: latest.date, present: nextPresent));
    await SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
    await _save();
  }

  Future<void> _clearSession(int week, int session) async {
    setState(() => sessions[week][session] = const AttendanceEntry());
    await _save();
  }

  Future<void> _reset() async {
    setState(() => sessions = List.generate(totalWeeks, (_) => List.generate(weeklyClasses, (_) => const AttendanceEntry())));
    await AttendanceService.instance.clear(widget.year.title, widget.semester.title, widget.subject.code);
  }

  String _displayDate(String? iso) {
    if (iso == null) return 'Add date';
    final d = DateTime.tryParse(iso);
    if (d == null) return 'Add date';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Scaffold(appBar: AppBar(title: Text(widget.subject.name)), body: const Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'reset') await _reset();
            },
            itemBuilder: (_) => const [PopupMenuItem(value: 'reset', child: Text('Reset attendance'))],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _headerCard(),
          const SizedBox(height: 14),
          _howItWorksCard(),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(child: Text('15-week attendance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              Text('$markedClasses / 15 lectures', style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(totalWeeks, _weekCard),
        ],
      ),
    );
  }

  Widget _headerCard() {
    final progress = (percentage / 100).clamp(0.0, 1.0);
    final statusColor = eligible ? Colors.green : Colors.red;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(widget.subject.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: statusColor.withOpacity(.10), borderRadius: BorderRadius.circular(20)),
              child: Text(eligible ? 'ELIGIBLE' : 'NOT ELIGIBLE', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ]),
          const SizedBox(height: 4),
          Text('${widget.subject.code}  •  ${widget.subject.credits}', style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 18),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percentage),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text('${value.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          ),
            const SizedBox(width: 10),
            Padding(padding: const EdgeInsets.only(bottom: 7), child: Text('$totalAttended / 15 attended', style: const TextStyle(color: Colors.black54))),
          ]),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: value, minHeight: 9)),
          ),
          const SizedBox(height: 8),
          Text('Minimum required: ${eligibilityThreshold.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ]),
      ),
    );
  }

  Widget _howItWorksCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: purple.withOpacity(.07), borderRadius: BorderRadius.circular(16), border: Border.all(color: purple.withOpacity(.12))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline, color: purple),
        const SizedBox(width: 10),
        Expanded(child: Text('This subject has one lecture per week for 15 weeks. Add the lecture date, then tap Present or Absent. Credits are used for the module, not for increasing the weekly attendance sessions.', style: const TextStyle(fontSize: 13, height: 1.4))),
      ]),
    );
  }

  Widget _weekCard(int weekIndex) {
    final week = sessions[weekIndex];
    final present = week.where((e) => e.present).length;
    final scheduled = week.where((e) => e.date != null).length;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(color: purple.withOpacity(.10), borderRadius: BorderRadius.circular(11)), child: Center(child: Text('${weekIndex + 1}', style: const TextStyle(color: purple, fontWeight: FontWeight.bold)))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Week ${weekIndex + 1}', style: const TextStyle(fontWeight: FontWeight.bold)), Text('$present / 1 present', style: const TextStyle(color: Colors.black54, fontSize: 12))])),
            Text('$scheduled/1', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
          ]),
          const SizedBox(height: 8),
          _sessionTile(weekIndex, 0),
        ]),
      ),
    );
  }

  Widget _sessionTile(int week, int session) {
    final entry = sessions[week][session];
    final present = entry.present;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(top: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: present ? Colors.green.withOpacity(.055) : Colors.grey.withOpacity(.045),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: present ? Colors.green.withOpacity(.25) : Colors.grey.withOpacity(.14)),
      ),
      child: Row(children: [
        Icon(Icons.event_outlined, size: 20, color: entry.date == null ? Colors.black45 : purple),
        const SizedBox(width: 8),
        Expanded(child: InkWell(onTap: () => _pickDate(week, session), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Class ${session + 1}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), Text(_displayDate(entry.date), style: TextStyle(fontSize: 12, color: entry.date == null ? Colors.black45 : Colors.black54))]))),
        if (entry.date != null) IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 36, minHeight: 36), tooltip: 'Clear class', onPressed: () => _clearSession(week, session), icon: const Icon(Icons.close, size: 18, color: Colors.black45)),
        const SizedBox(width: 2),
        SizedBox(
          height: 34,
          child: OutlinedButton.icon(
            onPressed: () => _toggleAttendance(week, session),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: Icon(
                present ? Icons.check_circle : Icons.circle_outlined,
                key: ValueKey(present),
                size: 17,
              ),
            ),
            label: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: Text(
                present ? 'Present' : (entry.date == null ? 'Add' : 'Absent'),
                key: ValueKey('${present}_${entry.date != null}'),
                style: const TextStyle(fontSize: 11),
              ),
            ),
            style: OutlinedButton.styleFrom(foregroundColor: present ? Colors.green : Colors.black54, side: BorderSide(color: present ? Colors.green.withOpacity(.5) : Colors.grey.withOpacity(.3)), padding: const EdgeInsets.symmetric(horizontal: 9)),
          ),
        ),
      ]),
    );
  }
}
