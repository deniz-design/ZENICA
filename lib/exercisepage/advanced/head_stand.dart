import 'package:flutter/material.dart';

class HeadStandPage extends StatelessWidget {
  const HeadStandPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe7b6b3),
      appBar: AppBar(
        title: const Text(
          'Demonstrations',
          style: TextStyle(
            color: Color(0xFF1B4332),
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff95D5B2),
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Color(0xFF1B4332)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset(
                  "assets/advanced/head_stand.png",
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Head Stand Pose",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
              const Text(
                "Headstand is an inversion pose that improves balance, strengthens the core and upper body, and promotes mental clarity.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "How to Do It:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Start in a kneeling position and interlace your fingers on the floor.\n"
                "- Place the crown of your head on the floor, ensuring your neck is not strained.\n"
                "- Engage your core and slowly lift your legs up, stacking your hips over your shoulders.\n"
                "- Hold the pose for 15-30 seconds.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "Benefits:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Strengthens the core, shoulders, and arms.\n"
                "- Improves balance and stability.\n"
                "- Stimulates the brain and relieves stress.",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
