import 'package:flutter/material.dart';
import 'package:yoga_two/exercisepage/advanced/chaturanga_pose.dart';
import 'package:yoga_two/exercisepage/advanced/halfway_lift_pose.dart';
import 'package:yoga_two/exercisepage/advanced/seated_forward_fold.dart';
import 'package:yoga_two/exercisepage/advanced/table_top_pose.dart';
import 'package:yoga_two/exercisepage/advanced/triangle_pose.dart';
import 'package:yoga_two/exercisepage/advanced/upward_dog_pose.dart';
import 'package:yoga_two/exercisepage/advanced/upward_salute_pose.dart';
import 'package:yoga_two/exercisepage/beginner/child_pose.dart';
import 'package:yoga_two/exercisepage/beginner/cobra_pose.dart';
import 'package:yoga_two/exercisepage/beginner/corpse_pose.dart';
import 'package:yoga_two/exercisepage/beginner/downward_dog.dart';
import 'package:yoga_two/exercisepage/beginner/mountain_pose.dart';
import 'package:yoga_two/exercisepage/beginner/seated_easy_pose.dart';
import 'package:yoga_two/exercisepage/beginner/seated_staff_pose.dart';
import 'package:yoga_two/exercisepage/beginner/standing_pose.dart';
import 'package:yoga_two/exercisepage/beginner/tree_pose.dart';
import 'package:yoga_two/exercisepage/beginner/warrior1_pose.dart';
import 'package:yoga_two/exercisepage/intermediate/lunge_pose.dart';
import 'package:yoga_two/exercisepage/intermediate/plank_pose.dart';
import 'package:yoga_two/exercisepage/intermediate/standing_forward_fold.dart';
import 'package:yoga_two/exercisepage/intermediate/warrior_2_pose.dart';

class YogaStudio extends StatelessWidget {
  final List<Map<String, dynamic>> beginnerPoses = [
    {"name": "Mountain Pose", "image": "assets/beginner/beg_mountain.jpg", "page": const MountainPosePage()},
    {"name": "Child's Pose", "image": "assets/beginner/beg_child.jpg", "page": const ChildPosePage()},
    {"name": "Tree Pose", "image": "assets/beginner/beg_tree.jpg", "page": const TreePosePage()},
    {"name": "Seated Easy Pose", "image": "assets/beginner/seated_easy_pose.jpg", "page": const SeatedEasyPosePage()},
    {"name": "Seated Staff Pose", "image": "assets/beginner/seated_staff_pose.jpg", "page": const SeatedStaffPosePage()},
    {"name": "Standing Pose", "image": "assets/beginner/standing_pose.jpg", "page": const StandingPosePage()},
    {"name": "Corpse Pose", "image": "assets/beginner/corpse_pose.jpg", "page": const CorpsePosePage()},
  ];

  final List<Map<String, dynamic>> intermediatePoses = [
    {"name": "Downward Dog", "image": "assets/beginner/beg_dog.jpg", "page": const DownwardDogPage()},
    {"name": "Cobra Pose", "image": "assets/beginner/beg_cobra.jpg", "page": const CobraPosePage()},
    {"name": "Warrior I", "image": "assets/beginner/beg_warrior1.jpg", "page": const Warrior1PosePage()},
    {"name": "Warrior II", "image": "assets/intermediate/warrior_2_pose.jpg", "page": const Warrior2PosePage()},
    {"name": "Plank Pose", "image": "assets/intermediate/plank_pose.jpg", "page": const PlankPosePage()},
    {"name": "Lunge Pose", "image": "assets/intermediate/lunge_pose.jpg", "page": const LungePosePage()},
    {"name": "Standing Forward Fold", "image": "assets/intermediate/standing_forward_fold.jpg", "page": const StandingForwardFoldPage()},
  ];

  final List<Map<String, dynamic>> advancedPoses = [
    {"name": "Upward Salute", "image": "assets/advanced/upward_salute_pose.jpg", "page": const UpwardSalutePosePage()},
    {"name": "Chaturanga", "image": "assets/advanced/chaturanga_pose.jpg", "page": const ChaturangaPosePage()},
    {"name": "Upward Dog", "image": "assets/advanced/upward_dog_pose.jpg", "page": const UpwardDogPosePage()},
    {"name": "Halfway Lift", "image": "assets/advanced/halfway_lift_pose.jpg", "page": const HalfwayLiftPosePage()},
    {"name": "Triangle Pose", "image": "assets/advanced/triangle_pose.jpg", "page": const TrianglePosePage()},
    {"name": "Seated Forward Fold", "image": "assets/advanced/seated_forward_fold.jpg", "page": const SeatedForwardFoldPage()},
    {"name": "Table Top Pose", "image": "assets/advanced/table_top_pose.jpg", "page": const TableTopPosePage()},
  ];

  YogaStudio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffefae0),
      appBar: AppBar(
        title: const Text(
          'Choose Difficulty',
          style: TextStyle(
            color: Color(0xFFd4a373),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xfffefae0),
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Color(0xff7f5539)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildPoseSection("Beginner", beginnerPoses, context),
            buildPoseSection("Intermediate", intermediatePoses, context),
            buildPoseSection("Advanced", advancedPoses, context),
          ],
        ),
      ),
    );
  }

  Widget buildPoseSection(String title, List<Map<String, dynamic>> poses, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          ),
          SizedBox(
            height: 165,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: poses.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (poses[index]["page"] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => poses[index]["page"], // Redirects to the specific page
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Page for ${poses[index]["name"]} not available yet!"),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      elevation: 5,
                      child: Container(
                        width: 170,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: AssetImage(poses[index]["image"]!),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            child: Stack(
                              children: [
                                // Outline (Black text rendered slightly offset in all directions)
                                Text(
                                  poses[index]["name"]!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 2
                                      ..color = Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                // Fill (White text over the black outline)
                                Text(
                                  poses[index]["name"]!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
