import 'package:flutter/material.dart';
import '../../models/academic_models.dart';
import '../../theme/app_theme.dart';
import 'attendance_subjects_screen.dart';

class AttendanceSemestersScreen extends StatelessWidget {
  final YearData year;
  const AttendanceSemestersScreen({super.key, required this.year});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${year.title} • Attendance')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: year.semesters.length,
        itemBuilder: (context, i) {
          final semester = year.semesters[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: CircleAvatar(
                backgroundColor: purple.withOpacity(.12),
                child: Text('${i + 1}', style: const TextStyle(color: purple, fontWeight: FontWeight.bold)),
              ),
              title: Text(semester.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              subtitle: Text('${semester.subjects.length} Subjects'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AttendanceSubjectsScreen(year: year, semester: semester)),
              ),
            ),
          );
        },
      ),
    );
  }
}
