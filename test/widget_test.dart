// Basic smoke test: confirms the Splash screen shows the app name
// without crashing. Firebase.initializeApp is skipped here since
// plugins aren't available in the plain widget-test environment;
// this test only pumps the SplashScreen widget directly.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unibuddy/screens/splash_screen.dart';
import 'package:unibuddy/theme/app_theme.dart';

void main() {
  testWidgets('Splash screen shows the app name', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      home: const SplashScreen(),
    ));

    expect(find.text('UniBuddy'), findsOneWidget);
  });
}
