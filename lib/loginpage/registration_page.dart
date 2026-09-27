import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yoga_two/loginpage/login_page.dart';
import 'package:yoga_two/services/profile_repository.dart';
import 'create_button.dart';
import 'create_failure_dialog.dart';


class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  RegistrationPageState createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmpassController = TextEditingController();


  void _register() async {

     

   try {
    
    if (passwordController.text != confirmpassController.text) {
      _showFailureMessage();
      return;
    }

    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );
    // Check if login is successful
    if (userCredential.user != null) {
      // Upload the onboarding profile (collected before account creation)
      // into Firestore keyed by the new user's UID.
      await ProfileRepository().uploadLocalToFirestore(userCredential.user!.uid);
      if (!mounted) return;
      //account created successfully message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account Created Successfully...'),
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
      builder: (context) => const CreateFailureDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff95D5B2),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 150),
              Image.asset(
                'assets/poseperfect.png',
                width: 100,
                height: 100,
              ),
              const Text(
                'CREATE ACCOUNT',
                style: TextStyle(
                  fontSize: 40,
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
              // Password field
              TextField(
                controller: confirmpassController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Confirm password',
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
              CreateButton(onPressed: _register),
              const SizedBox(height: 20),
              // Create Account Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already Registered??",
                    style: TextStyle(color: Color(0xff1B4332), fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
          builder: (context) => const YogaLoginPage(),
                ),
              );
            },
                    child: const Text(
                      'Login Here',
                      style: TextStyle(color: Color(0xff2D6A4F), fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}