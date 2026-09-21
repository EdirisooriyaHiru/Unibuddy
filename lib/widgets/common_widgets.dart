import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// One line inside the "Today's Plan" card on the Home screen.
Widget planLine(String title, String time) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      children: [
        const Icon(Icons.check_box_outlined, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: const TextStyle(color: Colors.white))),
        Text(time, style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );
}

/// One tile inside the "Quick Access" grid on the Home screen.
Widget quick(BuildContext context, String label, IconData icon, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: purple.withOpacity(.10),
              child: Icon(icon, color: purple),
            ),
            const SizedBox(height: 7),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    ),
  );
}

/// One row inside the Study Planner list.
Widget task(String time, String title, IconData icon) {
  return Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: purple.withOpacity(.1),
        child: Icon(icon, color: purple),
      ),
      title: Text(title),
      subtitle: Text(time),
      trailing: Checkbox(value: false, onChanged: (_) {}),
    ),
  );
}

/// One row inside the Study Tracker "Today by Subject" list.
Widget studyRow(String name, String time, double value) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Expanded(child: Text(name)), Text(time)]),
          const SizedBox(height: 7),
          LinearProgressIndicator(value: value),
        ],
      ),
    ),
  );
}

/// One row inside the Profile screen menu list.
Widget profileTile(String title, IconData icon, {VoidCallback? onTap}) {
  return Card(
    child: ListTile(
      leading: Icon(icon, color: purple),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ?? () {},
    ),
  );
}

/// A generic scrolling list screen used by Materials/other simple lists.
class SimpleListScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  const SimpleListScreen({super.key, required this.title, required this.icon, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) => Card(
          child: ListTile(
            leading: Icon(icon, color: purple),
            title: Text(items[i]),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}
