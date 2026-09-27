import 'package:flutter/material.dart';
import 'package:yoga_two/homepage/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yoga_two/loginpage/splash_gate.dart';
import 'package:yoga_two/services/reminder_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Local notification setup: 24h reminder re-scheduled on each launch.
  // Scheduling is silent; the runtime permission prompt is shown later from
  // the Profile page so it doesn't race app startup.
  try {
    await ReminderService.instance.init();
    await ReminderService.instance.scheduleDailyReminder();
  } catch (_) {
    // Notifications are best-effort; never block startup on them.
  }

  runApp(const YogaLoginApp());
}

class YogaLoginApp extends StatelessWidget {
  const YogaLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashGate(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}