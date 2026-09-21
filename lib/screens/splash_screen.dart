import 'package:flutter/material.dart';
import 'auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5B2DAF), Color(0xFF7E57C2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.school, color: Colors.white, size: 92),
              SizedBox(height: 18),
              Text('UniBuddy',
                  style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('All-in-One Student Management & Study Tracker',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 70),
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 12),
              Text('Loading...', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
