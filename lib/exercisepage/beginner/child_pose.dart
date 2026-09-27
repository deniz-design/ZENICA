import 'package:flutter/material.dart';
import 'package:yoga_two/pose_detection/pose_detection.dart';

class ChildPosePage extends StatelessWidget {
  const ChildPosePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffefae0),
      appBar: AppBar(
        title: const Text(
          'Demonstrations',
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
                borderRadius: BorderRadius.circular(20.0), // Round the corners of the image
                child: Image.asset(
                  "assets/beginner/gifs/child_pose.gif", // Ensure the path to your asset is correct
                  width: double.infinity,  // The GIF will now stretch to fill the available width
                  height: 400, // Adjust the height to make the GIF larger
                  fit: BoxFit.cover, // Optional: Ensures the GIF covers the space without distortion
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Child's Pose",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
              const Text(
                "Child's Pose is a gentle resting pose that stretches the back, hips, and legs while calming the mind. It's often used as a resting position during yoga sessions.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "How to Do It:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Kneel on the floor with your toes touching and knees spread apart.\n"
                "- Sit back on your heels and stretch your arms forward.\n"
                "- Lower your forehead to the ground.\n"
                "- Relax your body and hold the pose for 1-2 minutes.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "Benefits:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Relieves stress and tension in the body.\n"
                "- Stretches the lower back and hips.\n"
                "- Improves flexibility in the thighs and knees.",
                style: TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PoseDetectionScreen(targetPose: 'child_pose')),
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

