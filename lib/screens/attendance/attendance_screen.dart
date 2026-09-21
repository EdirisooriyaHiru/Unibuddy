import 'package:flutter/material.dart';
import '../../services/attendance_service.dart';
import '../../models/academic_models.dart';
import '../../data/academic_data.dart';
import '../../theme/app_theme.dart';
import 'attendance_semesters_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<_RiskSubject> _riskSubjects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRiskSubjects();
  }

  Future<void> _loadRiskSubjects() async {
    final result = <_RiskSubject>[];
    for (final year in academicYears) {
      for (final semester in year.semesters) {
        for (final subject in semester.subjects) {
          final weeks = await AttendanceService.instance.load(year.title, semester.title, subject.code, 1);
          final marked = weeks.expand((w) => w).where((e) => e.date != null).length;
          final attended = weeks.expand((w) => w).where((e) => e.date != null && e.present).length;
          if (marked > 0 && attended / 15 * 100 < 80) {
            result.add(_RiskSubject(year, semester, subject, attended));
          }
        }
      }
    }
    if (!mounted) return;
    setState(() { _riskSubjects = result; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: RefreshIndicator(
        onRefresh: _loadRiskSubjects,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            if (!_loading && _riskSubjects.isNotEmpty) ...[
              _riskCard(),
              const SizedBox(height: 16),
            ],
            const Text('Academic Years', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                mainAxisExtent: 148,
              ),
              itemCount: academicYears.length,
              itemBuilder: (context, i) {
                final year = academicYears[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceSemestersScreen(year: year)));
                    _loadRiskSubjects();
                  },
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: purple.withOpacity(.12),
                            child: Text('${i + 1}', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: purple)),
                          ),
                          const SizedBox(height: 9),
                          Text(year.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 3),
                          Text('${year.semesters.length} Semesters', style: const TextStyle(color: Colors.black54, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _riskCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            const Expanded(child: Text('Needs attention', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            Text('${_riskSubjects.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 5),
          const Text('Subjects below 80% appear here until they become eligible.', style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 10),
          ..._riskSubjects.take(4).map((r) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.menu_book_outlined, size: 20),
            title: Text(r.subject.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('${r.year.title} • ${r.semester.title} • ${r.attended}/15 attended'),
          )),
          if (_riskSubjects.length > 4) Text('+ ${_riskSubjects.length - 4} more subjects', style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ]),
      ),
    );
  }
}

class _RiskSubject {
  final YearData year;
  final SemesterData semester;
  final Subject subject;
  final int attended;
  _RiskSubject(this.year, this.semester, this.subject, this.attended);
}