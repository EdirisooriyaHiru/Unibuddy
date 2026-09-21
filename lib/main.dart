import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await themeController.load();
  runApp(const UniBuddyApp());
}

class UniBuddyApp extends StatelessWidget {
  const UniBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (_, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'UniBuddy',
        theme: buildAppTheme(),
        darkTheme: buildDarkAppTheme(),
        themeMode: themeController.themeMode,
        home: const SplashScreen(),
      ),
    );
  }
}
