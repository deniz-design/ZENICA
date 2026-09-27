// Basic widget test for the Yoga Login page.
//
// Pumps the login page and verifies the core fields render.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yoga_two/loginpage/login_page.dart';

void main() {
  testWidgets('Login page renders email and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: YogaLoginPage()));

    // Login heading renders.
    expect(find.text('LOGIN'), findsOneWidget);

    // Email and password fields are present.
    expect(find.byType(TextField), findsNWidgets(2));

    // Login button is present.
    expect(find.text('Login'), findsOneWidget);
  });
}