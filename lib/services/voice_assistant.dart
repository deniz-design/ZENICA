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
  
  // Debouncing timers
  DateTime? _lastCorrectionTime;
  DateTime? _lastPoseAnnouncementTime;
  final Duration _correctionDebounce = const Duration(seconds: 5);
  final Duration _poseAnnouncementDebounce = const Duration(seconds: 3);
  
  // Track announced states
  String? _lastAnnouncedPose;
  bool _lastWasCorrect = false;

  /// Initialize TTS
  Future<void> initialize() async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.9); // Slightly slower, clear speech
      await _tts.setVolume(0.8); // 80% volume
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

  /// Set volume (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    await _tts.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Announce correct pose detected
  Future<void> announceCorrectPose(String poseName) async {
    if (!_isEnabled) return;
    
    // Debounce: only announce if pose changed or enough time passed
    final now = DateTime.now();
    if (_lastAnnouncedPose == poseName && 
        _lastWasCorrect &&
        now.difference(_lastPoseAnnouncementTime ?? now).inSeconds < 2) {
      return;
    }
    
    _lastAnnouncedPose = poseName;
    _lastWasCorrect = true;
    _lastPoseAnnouncementTime = now;
    
    final text = 'Perfect! You\'re in ${_titleCase(poseName)}. Hold it steady.';
    await _speak(text);
  }

  /// Announce wrong pose detected
  Future<void> announceWrongPose(String detectedPose, String targetPose) async {
    if (!_isEnabled) return;
    
    final now = DateTime.now();
    if (_lastAnnouncedPose == detectedPose && 
        !_lastWasCorrect &&
        now.difference(_lastPoseAnnouncementTime ?? now).inSeconds < 2) {
      return;
    }
    
    _lastAnnouncedPose = detectedPose;
    _lastWasCorrect = false;
    _lastPoseAnnouncementTime = now;
    
    final text = 'That\'s ${_titleCase(detectedPose)}. Adjust to ${_titleCase(targetPose)}.';
    await _speak(text);
  }

  /// Announce no pose detected
  Future<void> announceNoPose() async {
    if (!_isEnabled) return;
    
    final now = DateTime.now();
    if (_lastAnnouncedPose == 'none' &&
        now.difference(_lastPoseAnnouncementTime ?? now).inSeconds < 3) {
      return;
    }
    
    _lastAnnouncedPose = 'none';
    _lastPoseAnnouncementTime = now;
    
    const text = 'Step in front of the camera to get started.';
    await _speak(text);
  }

  /// Announce pose corrections (joint deviations)
  Future<void> announceCorrectionFeedback(String jointName, double deviation) async {
    if (!_isEnabled) return;
    
    final now = DateTime.now();
    if (now.difference(_lastCorrectionTime ?? now).inSeconds < _correctionDebounce.inSeconds) {
      return; // Debounce corrections
    }
    
    _lastCorrectionTime = now;
    
    final deviationInt = deviation.toInt();
    final text = 'Align your ${_titleCase(jointName)} by $deviationInt degrees.';
    await _speak(text);
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
