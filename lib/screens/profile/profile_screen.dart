import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_controller.dart';
import '../../widgets/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService().signOut();
      // AuthGate's StreamBuilder will automatically show the Login
      // screen once the sign-out event fires - no navigation needed.
    }
  }


  void _showThemePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appearance',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text('Choose how UniBuddy should look.'),
                const SizedBox(height: 12),
                ...UniBuddyThemeMode.values.map(
                  (mode) => RadioListTile<UniBuddyThemeMode>(
                    value: mode,
                    groupValue: themeController.mode,
                    title: Text(
                      mode == UniBuddyThemeMode.system
                          ? 'System default'
                          : mode == UniBuddyThemeMode.light
                              ? 'Light mode'
                              : 'Dark mode',
                    ),
                    secondary: Icon(
                      mode == UniBuddyThemeMode.system
                          ? Icons.brightness_auto_rounded
                          : mode == UniBuddyThemeMode.light
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                    ),
                    onChanged: (value) async {
                      if (value == null) return;
                      await themeController.setMode(value);
                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = (user?.displayName?.isNotEmpty ?? false) ? user!.displayName! : 'Student';
    final email = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 55),
          ),
          const SizedBox(height: 12),
          Center(child: Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          Center(child: Text(email)),
          const SizedBox(height: 25),
          const Card(
            child: ListTile(
              leading: Icon(Icons.school, color: purple),
              title: Text('Faculty of Technology'),
              subtitle: Text('General Sir John Kotelawala Defence University'),
            ),
          ),
          profileTile('Edit Profile', Icons.edit_outlined),
          profileTile('Change Password', Icons.lock_outline),
          profileTile('Notifications', Icons.notifications_none),
          profileTile('Settings', Icons.settings_outlined, onTap: () => _showThemePicker(context)),
          profileTile('Logout', Icons.logout, onTap: () => _confirmLogout(context)),
        ],
      ),
    );
  }
}
