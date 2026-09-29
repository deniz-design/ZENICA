import 'package:flutter/foundation.dart';

class PoseSession {
  final String poseName;
  final double accuracy;
  final int durationSeconds;
  final DateTime timestamp;

  PoseSession({
    required this.poseName,
    required this.accuracy,
    required this.durationSeconds,
    required this.timestamp,
  });
}

class SessionTracker {
  static final SessionTracker _instance = SessionTracker._internal();

  factory SessionTracker() {
    return _instance;
  }

  SessionTracker._internal();

  final List<PoseSession> _sessionPoses = [];
  String? _currentPose;

  /// Add a completed pose to the session
  void addPoseCompletion(String poseName, double accuracy, int durationSeconds) {
    _sessionPoses.add(
      PoseSession(
        poseName: poseName,
        accuracy: accuracy,
        durationSeconds: durationSeconds,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Set the current pose being practiced
  void setCurrentPose(String? poseName) {
    _currentPose = poseName;
  }

  /// Get all poses in the session
  List<PoseSession> getSessionPoses() => List.unmodifiable(_sessionPoses);

  /// Get current pose
  String? getCurrentPose() => _currentPose;

  /// Get session summary
  Map<String, dynamic> getSessionSummary() {
    final totalPoses = _sessionPoses.length;
    final totalTime = _sessionPoses.fold<int>(0, (sum, pose) => sum + pose.durationSeconds);
    final avgAccuracy = _sessionPoses.isEmpty
        ? 0.0
        : _sessionPoses.fold<double>(0, (sum, pose) => sum + pose.accuracy) / _sessionPoses.length;

    return {
      'totalPoses': totalPoses,
      'totalTimeSeconds': totalTime,
      'averageAccuracy': avgAccuracy,
      'poses': _sessionPoses,
    };
  }

  /// Clear the session
  void clearSession() {
    _sessionPoses.clear();
    _currentPose = null;
  }
}
