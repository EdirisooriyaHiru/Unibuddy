import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/planner_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_controller.dart';
import '../academic/years_screen.dart';
import '../attendance/attendance_screen.dart';
import '../gpa/gpa_screen.dart';
import '../notes/notes_screen.dart';
import '../planner/planner_screen.dart';
import '../study_tracker/study_tracker_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _heroController;

  @override
  void initState() {
    super.initState();
    PlannerStore.load();
    PlannerStore.revision.addListener(_refresh);
    _heroController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    PlannerStore.revision.removeListener(_refresh);
    _heroController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void open(BuildContext context, Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final displayName = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : (user?.email?.split('@').first ?? 'Student');
    final upcoming = PlannerStore.upcoming(limit: 3);
    final today = PlannerStore.today();
    final pendingToday = today.where((e) => !e.completed).length;
    final completedToday = today.where((e) => e.completed).length;
    final todayProgress = today.isEmpty ? 0.0 : completedToday / today.length;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Good morning,', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(.62), fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(displayName, style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 3),
                      Text('Small steps today. Big results tomorrow.', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(.55))),
                    ]),
                  ),
                  _roundButton(Icons.notifications_none_rounded, () => open(context, const PlannerScreen())),
                  const SizedBox(width: 8),
                  _roundButton(dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, () {
                    themeController.setMode(dark ? UniBuddyThemeMode.light : UniBuddyThemeMode.dark);
                  }),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
            sliver: SliverList(delegate: SliverChildListDelegate([
              _heroCard(context, displayName),
              const SizedBox(height: 16),
              _statsRow(context, todayProgress, pendingToday),
              const SizedBox(height: 18),
              _sectionTitle(context, 'Today’s Plan', 'View all', () => open(context, const PlannerScreen())),
              const SizedBox(height: 9),
              if (today.isNotEmpty)
                ...today.take(4).map((task) => Padding(padding: const EdgeInsets.only(bottom: 9), child: _taskTile(context, task)))
              else
                _emptyToday(context),
              const SizedBox(height: 16),
              _sectionTitle(context, 'Things to do', 'Planner', () => open(context, const PlannerScreen())),
              const SizedBox(height: 9),
              if (upcoming.isNotEmpty)
                _reminderPanel(context, upcoming)
              else
                _emptyReminder(context),
              const SizedBox(height: 18),
              _sectionTitle(context, 'Quick Access', null, null),
              const SizedBox(height: 10),
              _quickGrid(context),
              const SizedBox(height: 18),
              _motivationCard(context),
              const SizedBox(height: 12),
            ])),
          ),
        ],
      ),
    );
  }

  Widget _heroCard(BuildContext context, String name) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Container(
      height: 205,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: dark ? const [Color(0xFF31205B), Color(0xFF1B1430)] : const [Color(0xFFEAE2FF), Color(0xFFF8F4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        Positioned(right: -30, bottom: -28, child: AnimatedBuilder(
          animation: _heroController,
          builder: (_, child) => Transform.translate(offset: Offset(0, math.sin(_heroController.value * math.pi) * -7), child: child),
          child: Image.asset('assets/images/study_student.png', width: 315, height: 245, fit: BoxFit.contain),
        )),
        Positioned(left: 20, top: 20, right: 160, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Your study space', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          Text('Learn. Plan. Achieve.', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 7),
          Text('Keep your tasks, attendance and study goals moving together.', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(.62), height: 1.25)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => open(context, const StudyTrackerScreen()),
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text('Start studying'),
            style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          ),
        ])),
      ]),
    );
  }

  Widget _statsRow(BuildContext context, double progress, int pending) {
    return Row(children: [
      Expanded(child: _statCard(context, Icons.today_rounded, 'Today', '${(progress * 100).round()}%', purple)),
      const SizedBox(width: 9),
      Expanded(child: _statCard(context, Icons.task_alt_rounded, 'To do', '$pending', const Color(0xFFEB8C2D))),
      const SizedBox(width: 9),
      Expanded(child: _statCard(context, Icons.local_fire_department_rounded, 'Streak', 'Keep it up', const Color(0xFFE85B70))),
    ]);
  }

  Widget _statCard(BuildContext context, IconData icon, String label, String value, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 18, offset: const Offset(0, 7))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(radius: 16, backgroundColor: color.withOpacity(.12), child: Icon(icon, size: 18, color: color)),
        const SizedBox(height: 9),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
        Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(.55))),
      ]),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, String? action, VoidCallback? onTap) => Row(children: [
    Expanded(child: Text(title, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface))),
    if (action != null) TextButton(onPressed: onTap, child: Text(action)),
  ]);

  Widget _taskTile(BuildContext context, PlannerTask task) {
    final theme = Theme.of(context);
    final color = task.completed ? green : purple;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
        leading: CircleAvatar(backgroundColor: color.withOpacity(.11), child: Icon(task.completed ? Icons.check_rounded : Icons.menu_book_rounded, color: color)),
        title: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${task.subject.isEmpty ? task.type : task.subject} • ${TimeOfDay.fromDateTime(task.dateTime).format(context)}'),
        trailing: Text('${task.durationMinutes}m', style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
      ),
    );
  }

  Widget _reminderPanel(BuildContext context, List<PlannerTask> tasks) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF7250E8), Color(0xFF8B6CF0)]),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(children: tasks.map((task) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 19),
        const SizedBox(width: 10),
        Expanded(child: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        Text(_shortTime(context, task.dateTime), style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    )).toList()),
  );

  Widget _quickGrid(BuildContext context) => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 3,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 1.05,
    children: [
      _quick(context, 'GPA', Icons.school_rounded, purple, () => open(context, const GpaScreen())),
      _quick(context, 'Attendance', Icons.event_available_rounded, green, () => open(context, const AttendanceScreen())),
      _quick(context, 'Tracker', Icons.timer_rounded, const Color(0xFFEB8C2D), () => open(context, const StudyTrackerScreen())),
      _quick(context, 'Planner', Icons.calendar_month_rounded, const Color(0xFFE85B70), () => open(context, const PlannerScreen())),
      _quick(context, 'Academic', Icons.menu_book_rounded, const Color(0xFF4B9EEA), () => open(context, const YearsScreen())),
      _quick(context, 'Notes', Icons.note_alt_rounded, const Color(0xFF7B65D6), () => open(context, const NotesScreen())),
    ],
  );

  Widget _quick(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(11), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircleAvatar(radius: 21, backgroundColor: color.withOpacity(.12), child: Icon(icon, color: color)),
        const SizedBox(height: 8),
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
      ])),
    ),
  );

  Widget _motivationCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: [theme.colorScheme.primary.withOpacity(.10), theme.colorScheme.primary.withOpacity(.03)]),
      ),
      child: Row(children: [
        const Text('✨', style: TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(child: Text('One focused session today is better than a perfect plan tomorrow.', style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface))),
      ]),
    );
  }

  Widget _emptyToday(BuildContext context) => Card(child: ListTile(
    leading: CircleAvatar(backgroundColor: purple.withOpacity(.1), child: const Icon(Icons.add_task_rounded, color: purple)),
    title: const Text('No plan for today'),
    subtitle: const Text('Add a task in Study Planner and it will appear here.'),
    onTap: () => open(context, const PlannerScreen()),
  ));

  Widget _emptyReminder(BuildContext context) => Card(child: ListTile(
    leading: CircleAvatar(backgroundColor: purple.withOpacity(.1), child: const Icon(Icons.task_alt_rounded, color: purple)),
    title: const Text('You are all caught up 🎉'),
    subtitle: const Text('Your saved planner tasks will show here as reminders.'),
    onTap: () => open(context, const PlannerScreen()),
  ));

  Widget _roundButton(IconData icon, VoidCallback onTap) => Material(
    color: Theme.of(context).cardColor,
    shape: const CircleBorder(),
    child: InkWell(onTap: onTap, customBorder: const CircleBorder(), child: Padding(padding: const EdgeInsets.all(11), child: Icon(icon, size: 20))),
  );

  String _shortTime(BuildContext context, DateTime d) => '${d.day}/${d.month} • ${TimeOfDay.fromDateTime(d).format(context)}';
}
