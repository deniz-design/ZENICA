import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yoga_two/loginpage/registration_page.dart';
import 'package:yoga_two/services/profile_repository.dart';
import 'login_button.dart';
import 'login_failure_dialog.dart';

class YogaLoginPage extends StatefulWidget {
  const YogaLoginPage({super.key});

  @override
  YogaLoginPageState createState() => YogaLoginPageState();
}

class YogaLoginPageState extends State<YogaLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login() async {

  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );
    
    // Check if login is successful
    if (userCredential.user != null) {
      // Reconcile any pre-account onboarding profile into Firestore.
      await ProfileRepository().uploadLocalToFirestore(userCredential.user!.uid);
      if (!mounted) return;
      //logged in successfully message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged in Successfully...'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to the HomePage or AuthPage
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } else {
      // Show failure message if login fails
      _showFailureMessage();
    }
  } catch (e) {
    // Handle error (e.g., wrong credentials)
    _showFailureMessage();
  }
}

  void _showFailureMessage() {
    showDialog(
      context: context,
      builder: (context) => const FailureDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff95D5B2),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Image.asset(
              'assets/poseperfect.png',
              width: 100,
              height: 100,
            ),
            const Text(
              'LOGIN',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Color(0xff1B4332),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 40),
            // Email field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Enter email id',
                filled: true,
                fillColor: const Color(0xffB7E4C7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Password field
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter password',
                filled: true,
                fillColor: const Color(0xffB7E4C7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Login Button
            LoginButton(onPressed: _login),
            const SizedBox(height: 20),
            // Create Account Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Not registered yet?",
                  style: TextStyle(color: Color(0xff1B4332), fontSize: 16),
                ),
                TextButton(
                  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegistrationPage(),
      ),
    );
  },
                  child: const Text(
                    'Register Now',
                    style: TextStyle(color: Color(0xff2D6A4F), fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}