import 'package:flutter/material.dart';
import 'package:yoga_two/pose_detection/pose_detection.dart';

class MountainPosePage extends StatelessWidget {
  const MountainPosePage({super.key});

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
        iconTheme: const IconThemeData(color: Color(0xff7f5539)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0), // Adjust the radius to make corners rounder or sharper
                child: Image.asset(
                  "assets/beginner/gifs/mountain_pose.gif", // Ensure this asset exists
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Mountain Pose",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
              const Text(
                "Mountain Pose is a foundational yoga pose that helps improve posture, balance, and alignment. It strengthens the legs and core while calming the mind.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "How to Do It:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Stand with your feet together, pressing your feet into the ground.\n"
                "- Engage your legs and lift your kneecaps.\n"
                "- Keep your arms by your sides, palms facing forward.\n"
                "- Lengthen your spine and keep your shoulders relaxed.\n"
                "- Hold the pose for 30 seconds to 1 minute.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "Benefits:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Improves posture and balance.\n"
                "- Strengthens the legs, core, and ankles.\n"
                "- Reduces stress and promotes calmness.",
                style: TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PoseDetectionScreen(targetPose: 'mountain_pose')),
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

