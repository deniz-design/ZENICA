import 'package:flutter/material.dart';
import 'package:yoga_two/homepage/media_player_page.dart';
import 'package:yoga_two/homepage/widgets/soundscape_card.dart';

class SoundscapeSection extends StatelessWidget {
  const SoundscapeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Soundscapes',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Color(0xFFd4a373),
          ),
        ),
        const SizedBox(height: 10.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SoundscapeCard(
                title: 'Ocean Waves',
                description: 'Relax with the soothing sound of ocean waves.',
                icon: Icons.spa,
                backgroundImage: 'assets/sound_ocean.jpg',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MediaPlayerPage(
                        title: 'Ocean Waves',
                        audioPath: 'soundscape/ocean.mp3',
                        backgroundImage: 'assets/sound_ocean.jpg',
                        slogan: 'Meditate to the calming sounds of ocean waves.',
                      ),
                    ),
                  );
                },
              ),
              SoundscapeCard(
                title: 'Rainforest',
                description: 'Immerse yourself in the sounds of the rainforest.',
                icon: Icons.nature,
                backgroundImage: 'assets/sound_forest.jpg',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MediaPlayerPage(
                        title: 'Rainforest',
                        audioPath: 'soundscape/rainforest.mp3',
                        backgroundImage: 'assets/sound_forest.jpg',
                        slogan: 'Meditate to the tranquil sounds of the rainforest.',
                      ),
                    ),
                  );
                },
              ),
              SoundscapeCard(
                title: 'Campfire',
                description: 'Unwind to the crackling sound of a campfire.',
                icon: Icons.local_fire_department,
                backgroundImage: 'assets/sound_campfire.jpg',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MediaPlayerPage(
                        title: 'Campfire',
                        audioPath: 'soundscape/campfire.mp3',
                        backgroundImage: 'assets/sound_campfire.jpg',
                        slogan: 'Meditate to the calming crackle of a campfire under the stars.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
