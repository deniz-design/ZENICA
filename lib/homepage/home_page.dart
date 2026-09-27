import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'home_content.dart';
import '../bmicalcpage/bmicalc_page.dart';
import '../exercisepage/exercise_page.dart';
import '../profilepage/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeContent(),
    YogaStudio(), // Pass a title here
    const BMICalculatorPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffefae0),
      appBar: AppBar(
        title: const Text(
          'zenica .',
          style: TextStyle(
            color: Color(0xFFd4a373),
            fontSize: 40,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xfffefae0),
        elevation: 0.0,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: const Color(0xff7f5539),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: GNav(
            gap: 8,
            color: const Color(0xFFfaedcd),
            activeColor: const Color(0xFFfaedcd),
            tabBackgroundColor: const Color(0xffd4a373),
            padding: const EdgeInsets.all(10),
            onTabChange: _onItemTapped,
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.self_improvement,
                text: 'Exercise',
              ),
              GButton(
                icon: Icons.calculate_rounded,
                text: 'BMI Calculator',
              ),
              GButton(
                icon: Icons.person_2_outlined,
                text: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
