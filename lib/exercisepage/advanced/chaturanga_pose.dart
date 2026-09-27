import 'package:flutter/material.dart';
import 'package:yoga_two/pose_detection/pose_detection.dart';

class ChaturangaPosePage extends StatelessWidget {
  const ChaturangaPosePage({super.key});

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
                  "assets/advanced/chaturanga_pose.jpg",
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Chaturanga",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
              const Text(
                "Chaturanga (Four-Limbed Staff Pose) is an integral part of sun salutations. It strengthens the arms, wrists, and core while building full-body endurance.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "How to Do It:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Start in a high plank position.\n"
                "- Shift your weight forward and bend your elbows back close to your body.\n"
                "- Lower your chest toward the floor, keeping elbows at 90 degrees.\n"
                "- Keep your body in a straight line with core engaged.\n"
                "- Hold for a few breaths before transitioning to upward dog.\n"
                "- Modify by lowering your knees if needed.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "Benefits:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Strengthens the arms, wrists, and shoulders.\n"
                "- Builds core strength and stability.\n"
                "- Tones the abdominal and upper body muscles.\n"
                "- Improves balance and body control.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PoseDetectionScreen(targetPose: 'chaturanga')),
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
