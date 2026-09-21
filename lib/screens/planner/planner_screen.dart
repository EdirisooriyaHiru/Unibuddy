import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/academic_data.dart';
import '../../services/planner_service.dart';
import '../../theme/app_theme.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});
  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  @override
  void initState() {
    super.initState();
    PlannerStore.load().then((_) { if (mounted) setState(() {}); });
    PlannerStore.revision.addListener(_refresh);
  }

  @override
  void dispose() {
    PlannerStore.revision.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = PlannerStore.today();
    final upcoming = PlannerStore.upcoming(limit: 8);
    final done = today.where((e) => e.completed).length;
    final progress = today.isEmpty ? 0.0 : done / today.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Study Planner')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTask,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Add Task'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => PlannerStore.load(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            _hero(now, today.length, done, progress),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: _stat('Today', '${today.length}', Icons.today_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _stat('Upcoming', '${upcoming.length}', Icons.upcoming_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _stat('Done', '$done', Icons.check_circle_rounded)),
            ]),
            const SizedBox(height: 22),
            const Text('What to do next', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (upcoming.isEmpty)
              _empty()
            else
              ...upcoming.map(_taskTile),
            const SizedBox(height: 22),
            const Text('Today', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (today.isEmpty)
              _empty(message: 'No tasks planned for today. Tap Add Task to plan your day.')
            else
              ...today.map(_taskTile),
          ],
        ),
      ),
    );
  }

  Widget _hero(DateTime now, int total, int done, double progress) => Card(
        color: purple,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Your study plan', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 5),
            Text('${_weekday(now.weekday)}, ${now.day} ${_month(now.month)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: Text('$done of $total tasks completed', style: const TextStyle(color: Colors.white))),
              Text('${(progress * 100).round()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, minHeight: 9, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Colors.white))),
          ]),
        ),
      );

  Widget _stat(String label, String value, IconData icon) => Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10), child: Column(children: [Icon(icon, color: purple), const SizedBox(height: 6), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.black54))])));

  Widget _taskTile(PlannerTask task) => Card(
        margin: const EdgeInsets.only(bottom: 9),
        child: ListTile(
          leading: GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); PlannerStore.toggle(task.id); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: task.completed ? Colors.green : purple.withOpacity(.10)),
              child: Icon(task.completed ? Icons.check : _typeIcon(task.type), color: task.completed ? Colors.white : purple),
            ),
          ),
          title: Text(task.title, style: TextStyle(fontWeight: FontWeight.w700, decoration: task.completed ? TextDecoration.lineThrough : null)),
          subtitle: Text('${task.subject.isEmpty ? task.type : '${task.subject} • ${task.type}'}\n${_dateTime(task.dateTime)} • ${task.durationMinutes} min'),
          isThreeLine: true,
          trailing: PopupMenuButton<String>(
            onSelected: (value) { if (value == 'delete') PlannerStore.remove(task.id); },
            itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Delete'))],
          ),
        ),
      );

  Widget _empty({String message = 'You are all caught up. Great work!'}) => Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [Icon(Icons.event_available_rounded, size: 42, color: purple.withOpacity(.7)), const SizedBox(height: 8), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54))])));

  Future<void> _showAddTask() async {
    final title = TextEditingController();
    final note = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String type = 'Study';
    String priority = 'Medium';
    String subject = '';
    int duration = 60;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(builder: (context, setModal) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Plan a task', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Task title', prefixIcon: Icon(Icons.task_alt))),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(value: subject.isEmpty ? null : subject, decoration: const InputDecoration(labelText: 'Subject (optional)', prefixIcon: Icon(Icons.menu_book_outlined)), items: academicYears.expand((y) => y.semesters).expand((s) => s.subjects).map((s) => DropdownMenuItem(value: s.name, child: Text(s.name, overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) => setModal(() => subject = v ?? '')),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'Type'), items: const ['Study','Revision','Assignment','Past Paper','Project','Reading'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setModal(() => type = v ?? 'Study'))),
              const SizedBox(width: 10),
              Expanded(child: DropdownButtonFormField<String>(value: priority, decoration: const InputDecoration(labelText: 'Priority'), items: const ['Low','Medium','High'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setModal(() => priority = v ?? 'Medium'))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () async { final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 730))); if (d != null) setModal(() => selectedDate = d); }, icon: const Icon(Icons.calendar_today), label: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: () async { final t = await showTimePicker(context: context, initialTime: selectedTime); if (t != null) setModal(() => selectedTime = t); }, icon: const Icon(Icons.schedule), label: Text(selectedTime.format(context)))),
            ]),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(value: duration, decoration: const InputDecoration(labelText: 'Estimated duration'), items: const [30,45,60,90,120,180].map((v) => DropdownMenuItem(value: v, child: Text('$v minutes'))).toList(), onChanged: (v) => setModal(() => duration = v ?? 60)),
            const SizedBox(height: 10),
            TextField(controller: note, maxLines: 2, decoration: const InputDecoration(labelText: 'Note (optional)', prefixIcon: Icon(Icons.notes_outlined))),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () async {
              if (title.text.trim().isEmpty) return;
              final dt = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
              await PlannerStore.add(PlannerTask(id: DateTime.now().microsecondsSinceEpoch.toString(), title: title.text.trim(), subject: subject, type: type, dateTime: dt, durationMinutes: duration, priority: priority, note: note.text.trim()));
              HapticFeedback.mediumImpact();
              if (context.mounted) Navigator.pop(context, true);
            }, icon: const Icon(Icons.save_rounded), label: const Text('Save Task'))),
          ])),
        );
      }),
    );
    title.dispose(); note.dispose();
    if (result == true && mounted) setState(() {});
  }

  String _dateTime(DateTime d) => '${d.day}/${d.month}/${d.year} • ${TimeOfDay.fromDateTime(d).format(context)}';
  IconData _typeIcon(String t) => switch (t) { 'Assignment' => Icons.assignment_outlined, 'Revision' => Icons.replay_rounded, 'Past Paper' => Icons.description_outlined, 'Project' => Icons.work_outline, 'Reading' => Icons.menu_book_outlined, _ => Icons.timer_outlined };
  String _weekday(int n) => const ['','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'][n];
  String _month(int n) => const ['','January','February','March','April','May','June','July','August','September','October','November','December'][n];
}
