import 'package:flutter/material.dart';
import 'package:yoga_two/pose_detection/pose_detection.dart';

class TreePosePage extends StatelessWidget {
  const TreePosePage({super.key});

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
                  "assets/beginner/gifs/tree_pose.gif", // Path to your image asset
                  width: double.infinity, // Make the image span the width of the screen
                  height: 400, // Increased height to make the image larger
                  fit: BoxFit.cover, // Ensure the image covers the space without distortion
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Tree Pose",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
              const Text(
                "Tree Pose is a balancing pose that strengthens the legs and improves focus. It helps enhance posture and opens the hips.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "How to Do It:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Stand tall with your feet together.\n"
                "- Shift your weight to one foot and place the other foot on the inner thigh or calf (avoid the knee).\n"
                "- Bring your palms together in front of your chest or extend your arms overhead.\n"
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
                "- Improves balance and coordination.\n"
                "- Strengthens the legs and core.\n"
                "- Opens the hips and increases flexibility.",
                style: TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PoseDetectionScreen(targetPose: 'tree_pose')),
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

