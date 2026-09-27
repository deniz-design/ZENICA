import 'package:flutter/material.dart';
import 'package:yoga_two/loginpage/auth_page.dart';
import 'package:yoga_two/onboarding/onboarding_page.dart';
import 'package:yoga_two/services/profile_repository.dart';

/// Splash that decides the first screen: Onboarding (first open) or AuthPage.
class SplashGate extends StatelessWidget {
  const SplashGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ProfileRepository().isOnboarded(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // While the flag loads, show a minimal splash.
          return const Scaffold(
            backgroundColor: Color(0xfffefae0),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xff7f5539)),
            ),
          );
        }
        final onboarded = snapshot.data ?? false;
        if (onboarded) {
          return const AuthPage();
        } else {
          return const OnboardingPage();
        }
      },
    );
  }
}