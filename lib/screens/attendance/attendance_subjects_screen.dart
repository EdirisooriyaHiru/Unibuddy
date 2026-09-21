import 'package:flutter/material.dart';
import '../../models/academic_models.dart';
import '../../theme/app_theme.dart';
import 'attendance_subject_detail_screen.dart';

class AttendanceSubjectsScreen extends StatelessWidget {
  final YearData year;
  final SemesterData semester;
  const AttendanceSubjectsScreen({super.key, required this.year, required this.semester});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${year.title} • ${semester.title}')),
      body: semester.subjects.isEmpty
          ? const Center(child: Text('No subjects added for this semester yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: semester.subjects.length,
              itemBuilder: (context, i) {
                final subject = semester.subjects[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: purple.withOpacity(.12),
                      child: const Icon(Icons.menu_book, color: purple),
                    ),
                    title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${subject.code} • ${subject.credits}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceSubjectDetailScreen(
                          year: year,
                          semester: semester,
                          subject: subject,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
