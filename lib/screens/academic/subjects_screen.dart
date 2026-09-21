import 'package:flutter/material.dart';
import '../../models/academic_models.dart';
import '../../theme/app_theme.dart';
import 'subject_resources_screen.dart';

/// Lists the subjects that belong to [year] + [semester].
/// Tapping a subject opens SubjectResourcesScreen (Past Papers + Slides).
class SubjectsScreen extends StatelessWidget {
  final YearData year;
  final SemesterData semester;
  const SubjectsScreen({super.key, required this.year, required this.semester});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${year.title} • ${semester.title}')),
      body: semester.subjects.isEmpty
          ? const Center(child: Text('No subjects added for this semester yet.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: semester.subjects.map((subject) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
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
                        builder: (_) => SubjectResourcesScreen(subject: subject),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
