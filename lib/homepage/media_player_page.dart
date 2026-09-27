import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MediaPlayerPage extends StatefulWidget {
  final String title;
  final String audioPath;
  final String backgroundImage;
  final String slogan;

  const MediaPlayerPage({super.key, 
    required this.title,
    required this.audioPath,
    required this.backgroundImage,
    required this.slogan,
  });

  @override
  MediaPlayerPageState createState() => MediaPlayerPageState();
}

class MediaPlayerPageState extends State<MediaPlayerPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    // The asset path is relative to the 'assets/' directory.
    _audioPlayer.setSource(AssetSource(widget.audioPath));
  }

  void _togglePlayPause() async {
    try {
      if (isPlaying) {
        await _audioPlayer.pause();
      } else if (_hasStarted) {
        // resume() only continues playback that was previously started.
        await _audioPlayer.resume();
      } else {
        // First play: start the source from the beginning.
        await _audioPlayer.play(AssetSource(widget.audioPath));
        _hasStarted = true;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not play audio: $e')),
        );
      }
      return;
    }
    if (mounted) {
      setState(() {
        isPlaying = !isPlaying;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            widget.backgroundImage,
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.4),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.slogan,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              IconButton(
                iconSize: 80,
                icon: Icon(
                  isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: Colors.white,
                ),
                onPressed: _togglePlayPause,
              ),
              const SizedBox(height: 10),
              Text(
                isPlaying ? 'Playing' : 'Paused',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
