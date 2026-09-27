import 'package:flutter/material.dart';
import 'package:yoga_two/pose_detection/pose_detection.dart';

class UpwardDogPosePage extends StatelessWidget {
  const UpwardDogPosePage({super.key});

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
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset(
                  "assets/advanced/upward_dog_pose.jpg",
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Upward Dog",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
              const Text(
                "Upward Dog (Urdhva Mukha Svanasana) is a backbending pose that opens the chest and strengthens the spine and arms. It energizes the body and improves posture.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "How to Do It:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Lie face down with hands under your shoulders.\n"
                "- Press through your palms and lift your chest off the floor.\n"
                "- Straighten your arms and engage your legs.\n"
                "- Keep your shoulders relaxed and away from your ears.\n"
                "- Lift your thighs off the mat and gaze forward or upward.\n"
                "- Hold for 3 to 5 breaths.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "Benefits:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Strengthens the spine, arms, and wrists.\n"
                "- Opens the chest and lungs.\n"
                "- Stretches the abdomen and hip flexors.\n"
                "- Improves posture and relieves fatigue.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PoseDetectionScreen(targetPose: 'upward_dog')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff7f5539),
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
