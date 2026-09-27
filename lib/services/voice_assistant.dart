import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class VoiceAssistant {
  static final VoiceAssistant _instance = VoiceAssistant._internal();
  
  factory VoiceAssistant() {
    return _instance;
  }
  
  VoiceAssistant._internal();
  
  final FlutterTts _tts = FlutterTts();
  bool _isEnabled = true;
  
  // State tracking - only announce on CHANGES, not every frame
  String? _lastStatePose;
  bool? _lastStateMatch;
  bool? _lastStateDetected;
  
  // Cooldown timer for same announcement
  DateTime? _lastAnnouncementTime;
  final Duration _announcementCooldown = const Duration(seconds: 2);

  /// Initialize TTS
  Future<void> initialize() async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.85); // Slightly slower, clear speech
      await _tts.setVolume(0.7); // 70% volume (less intrusive)
      await _tts.setPitch(1.0);
      
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _tts.synthesizeToFile("Test", "tts.wav");
      }
    } catch (e) {
      debugPrint('VoiceAssistant init error: $e');
    }
  }

  /// Enable/disable voice assistant
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      _tts.stop();
    }
  }

  /// Check pose state and announce ONLY on changes
  Future<void> checkPoseState(String? targetPose, bool poseMatches, bool poseDetected, String? detectedPose) async {
    if (!_isEnabled) return;
    
    // No change = no announcement
    if (_lastStatePose == targetPose && 
        _lastStateMatch == poseMatches && 
        _lastStateDetected == poseDetected) {
      return;
    }
    
    // Apply cooldown for same type of announcement
    final now = DateTime.now();
    if (_lastAnnouncementTime != null && 
        now.difference(_lastAnnouncementTime!).inSeconds < _announcementCooldown.inSeconds) {
      return;
    }
    
    // Update state
    _lastStatePose = targetPose;
    _lastStateMatch = poseMatches;
    _lastStateDetected = poseDetected;
    _lastAnnouncementTime = now;
    
    // Announce based on state
    if (!poseDetected) {
      // No pose detected
      await _speak('Step in front of the camera to get started.');
    } else if (targetPose != null && poseMatches) {
      // Correct pose
      await _speak('Perfect! You\'re in ${_titleCase(targetPose)}. Hold it steady.');
    } else if (targetPose != null && !poseMatches && detectedPose != null) {
      // Wrong pose
      await _speak('That\'s ${_titleCase(detectedPose)}. Adjust to ${_titleCase(targetPose)}.');
    }
  }

  /// Announce hold milestones (10s, 20s, 30s)
  Future<void> announceMilestone(int seconds) async {
    if (!_isEnabled) return;
    
    final text = _getMilestoneText(seconds);
    if (text.isNotEmpty) {
      await _speak(text);
    }
  }

  /// Announce achievement on completion
  Future<void> announceCompletion(String poseName, int seconds, double caloriesBurned) async {
    if (!_isEnabled) return;
    
    final text = 'Excellent! You held ${_titleCase(poseName)} for $seconds seconds '
        'and burned ${caloriesBurned.toStringAsFixed(1)} calories!';
    await _speak(text);
  }

  /// Internal speak method with error handling
  Future<void> _speak(String text) async {
    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

  /// Get milestone announcement text
  String _getMilestoneText(int seconds) {
    switch (seconds) {
      case 10:
        return 'Great form! Keep it up!';
      case 20:
        return 'Awesome! Twenty seconds down!';
      case 30:
        return 'Fantastic! Thirty seconds completed!';
      default:
        return '';
    }
  }

  /// Title case helper
  String _titleCase(String s) {
    return s.split('_').map((w) {
      return w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
    }).join(' ');
  }

  /// Stop speaking
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _tts.stop();
  }
}
