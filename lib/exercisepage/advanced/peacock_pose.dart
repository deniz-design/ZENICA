import 'package:flutter/material.dart';

class PeacockPosePage extends StatelessWidget {
  const PeacockPosePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff95D5B2),
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
                  "assets/advanced/peacock_pose.png",
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Peacock Pose",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
              const Text(
                "Peacock Pose is an advanced arm balance that strengthens the core, arms, and wrists, while improving flexibility in the spine.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "How to Do It:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Start in a seated position with your legs straight.\n"
                "- Place your hands flat on the ground behind you, fingers pointing towards your feet.\n"
                "- Engage your core and lift your legs off the ground, balancing on your hands.\n"
                "- Hold the pose for 10-15 seconds.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "Benefits:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Strengthens the arms, wrists, and core.\n"
                "- Increases flexibility in the spine.\n"
                "- Improves concentration and focus.",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
