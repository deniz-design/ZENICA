import 'package:flutter/material.dart';
import 'package:yoga_two/pose_detection/pose_detection.dart';

class DownwardDogPage extends StatelessWidget {
  const DownwardDogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffefae0),
      appBar: AppBar(
        title: const Text(
          'Demonstration',
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
                borderRadius: BorderRadius.circular(20.0), // Rounds the corners of the image
                child: Image.asset(
                  "assets/beginner/gifs/downward_dog.gif", // Path to your image asset
                  width: double.infinity, // Ensures the image spans the available width
                  height: 400, // Adjust the height to make the image larger
                  fit: BoxFit.cover, // Ensures the image covers the area without distortion
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Downward Dog Pose",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
              const Text(
                "Downward Dog is a foundational yoga pose that stretches and strengthens the entire body. It helps to calm the mind and energize the body.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "How to Do It:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Start on your hands and knees in a tabletop position.\n"
                "- Spread your fingers wide and press your palms into the mat.\n"
                "- Tuck your toes under and lift your hips towards the ceiling.\n"
                "- Straighten your legs as much as possible while keeping a slight bend in the knees if needed.\n"
                "- Press your heels towards the floor and keep your head relaxed between your arms.\n"
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
                "- Strengthens the arms, shoulders, and legs.\n"
                "- Stretches the hamstrings, calves, and spine.\n"
                "- Improves blood flow and energizes the body.\n"
                "- Helps relieve stress and calm the mind.",
                style: TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PoseDetectionScreen(targetPose: 'downward_dog')),
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

