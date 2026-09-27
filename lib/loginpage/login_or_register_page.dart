import 'package:flutter/material.dart';
import 'package:yoga_two/loginpage/login_page.dart';
import 'package:yoga_two/loginpage/registration_page.dart';


class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  
  //initial show login page
  bool showLoginPage = true;

  //toggle bw login and register
  void togglePages(){
    setState((){
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
      if (showLoginPage) {
        return const YogaLoginPage();
      }
      else {
        return const RegistrationPage();
      }
  }
}