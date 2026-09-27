import 'package:flutter/material.dart';
import 'package:yoga_two/pose_detection/pose_detection.dart';

class Warrior1PosePage extends StatelessWidget {
  const Warrior1PosePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffefae0),
      appBar: AppBar(
        title: const Text(
          'Choose Difficulty',
          style: TextStyle(
            color: Color(0xFFd4a373),
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xfffefae0),
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Color(0xFF1B4332)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0), // Rounding the corners of the image
                child: Image.asset(
                  "assets/beginner/gifs/warrior1_pose.gif", // Path to your image asset
                  width: double.infinity, // Make the image span the width of the screen
                  height: 400, // Increased height to make the image larger
                  fit: BoxFit.cover, // Ensures the image covers the area without distortion
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Warrior I Pose",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
              const Text(
                "Warrior I is a powerful standing pose that stretches the hips and strengthens the legs. It improves stamina and balance while promoting focus.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "How to Do It:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Start in a standing position.\n"
                "- Step one foot back, bending the front knee to a 90-degree angle.\n"
                "- Keep your back leg straight, and extend your arms overhead.\n"
                "- Look forward and hold the pose for 30 seconds to 1 minute.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "Benefits:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Strengthens the legs, core, and arms.\n"
                "- Improves balance and flexibility.\n"
                "- Increases stamina and energy.",
                style: TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PoseDetectionScreen(targetPose: 'warrior_1')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff7f5539), // Button color
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text(
                  "Try Now",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

