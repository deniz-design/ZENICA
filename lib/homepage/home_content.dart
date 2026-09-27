import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'sections/soundscape_section.dart';
import 'sections/daily_tip_section.dart';
import 'sections/quick_recipe_section.dart';

class HomeContent extends StatelessWidget {
  final List<String> yogaImages = [
    'assets/logowithimage.png',
    'assets/yoga_pose2.jpeg',
    'assets/yoga_pose3.jpeg',
    'assets/yoga_pose4.jpeg',
    'assets/yoga_pose5.jpeg',
    'assets/yoga_pose6.jpeg',
    'assets/yoga_pose7.jpeg',
    'assets/yoga_pose8.jpeg',
    'assets/yoga_pose9.jpeg',
    'assets/yoga_pose10.jpeg',
    'assets/yoga_pose11.jpeg',
    'assets/yoga_pose12.jpeg',
    'assets/yoga_pose13.jpeg',
    'assets/yoga_pose14.jpeg',
    'assets/yoga_pose15.jpeg',
  ];

  HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel Slider Section
            Center(
              child: CarouselSlider(
                items: yogaImages.map((imagePath) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 190,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  autoPlayInterval: const Duration(seconds: 3),
                ),
              ),
            ),
            const SizedBox(height: 20.0),

            // Sections
            const SoundscapeSection(),
            const SizedBox(height: 20.0),
            const DailyTipSection(),
            const SizedBox(height: 20.0),
            const QuickRecipeSection(),
          ],
        ),
      ),
    );
  }
}
