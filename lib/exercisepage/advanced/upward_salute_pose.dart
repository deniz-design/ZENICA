import 'package:flutter/material.dart';
import 'package:yoga_two/pose_detection/pose_detection.dart';

class UpwardSalutePosePage extends StatelessWidget {
  const UpwardSalutePosePage({super.key});

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
                  "assets/advanced/upward_salute_pose.jpg",
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Upward Salute",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
              const Text(
                "Upward Salute (Urdhva Hastasana) is a standing pose that opens the chest and stretches the entire body. It symbolizes greeting the sun and creates a sense of openness and energy.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "How to Do It:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Stand tall with feet together or hip-width apart.\n"
                "- Inhale and sweep your arms out and up overhead.\n"
                "- Press your palms together or keep them facing each other.\n"
                "- Lift your chest and look up between your thumbs.\n"
                "- Ground down through your feet and relax your shoulders.\n"
                "- Hold for 30 seconds to 1 minute.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "Benefits:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Stretches the arms, shoulders, and full torso.\n"
                "- Opens the chest and improves breathing.\n"
                "- Relieves neck and shoulder tension.\n"
                "- Energizes the body and improves posture.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PoseDetectionScreen(targetPose: 'upward_salute')),
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
