import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../ml/pose_analyzer.dart';
import '../services/pose_met.dart';
import '../services/profile_repository.dart';

/// Live pose detection + feedback screen.
///
/// Shows the camera feed, overlays the detected skeleton, and displays the
/// classified pose, correctness %, and top joint-deviation corrections.
class PoseDetectionScreen extends StatefulWidget {
  final CameraController? Function()? cameraGetter;
  final List<CameraDescription>? cameras;

  /// Optional intended pose to match (e.g. 'tree_pose').
  final String? targetPose;

  const PoseDetectionScreen({super.key, this.cameraGetter, this.cameras, this.targetPose});

  @override
  State<PoseDetectionScreen> createState() => _PoseDetectionScreenState();
}

class _PoseDetectionScreenState extends State<PoseDetectionScreen> {
  CameraController? _controller;
  PoseAnalyzer? _analyzer;
  PoseResult? _lastResult;
  bool _loading = true;
  String? _error;
  bool _modelLoaded = false;
  Timer? _processingTimer;

  // --- Hold timer + calories ---
  Timer? _holdTicker; // 1 Hz ticker that runs while the target pose is held
  int _heldSeconds = 0; // cumulative seconds the pose has been held correctly
  bool _currentlyHeld = false; // edge guard: truthy only once rising edge handled
  bool _completionHandled = false; // record stats + notify only once per session
  final List<double> _accuracySamples = []; // correctness samples collected while held
  double _weightKg = 55; // loaded from profile for calorie math

  /// Currently-selected lens direction; toggled by the flip button.
  CameraLensDirection _lensDirection = CameraLensDirection.front;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      // Load the user's weight for calorie math (falls back to default).
      _weightKg = await ProfileRepository().currentWeightKg();

      // Set up camera
      List<CameraDescription>? cameras = widget.cameras;
      cameras ??= await availableCameras();
      if (cameras.isEmpty) throw Exception('No cameras available');
      _availableCameras = cameras;

      // Prefer front camera for yoga practice
      final selected = _pickCamera(_lensDirection, cameras);

      final controller = CameraController(selected, ResolutionPreset.medium,
          enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _loading = false;
      });
      controller.startImageStream(_onFrame);

      // Load ML model
      if (_analyzer == null) {
        final analyzer = PoseAnalyzer();
        await analyzer.loadModel();
        if (!mounted) return;
        setState(() {
          _analyzer = analyzer;
          _modelLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('PoseDetection init error: $e');
      if (mounted) {
        setState(() {
          _error = '$e';
          _loading = false;
        });
      }
    }
  }

  /// The cached list of available cameras, kept for the flip toggle.
  List<CameraDescription> _availableCameras = const [];

  /// Returns the first camera with [direction], falling back to the first
  /// available camera if none matches.
  static CameraDescription _pickCamera(CameraLensDirection direction, List<CameraDescription> cameras) {
    for (final c in cameras) {
      if (c.lensDirection == direction) return c;
    }
    return cameras.first;
  }

  /// Disposes the current [CameraController] and re-initializes on the
  /// opposite lens direction (front <-> back).
  Future<void> _flipCamera() async {
    if (_availableCameras.length < 2) return; // Nothing to switch to.
    final old = _controller;
    _controller = null;
    await old?.dispose();
    _lensDirection = _lensDirection == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;
    await _init();
  }

  Future<void> _onFrame(CameraImage image) async {
    if (!_modelLoaded || _analyzer == null) return;
    try {
      final poses = await _analyzer!.detectFromCameraImage(image);
      
      // Analyze all detected poses
      final results = <PoseResult>[];
      for (final pose in poses) {
        final result =
            _analyzer!.analyze(pose: pose, imgWidth: image.width, imgHeight: image.height);
        if (result != null) {
          results.add(result);
        }
      }
      
      if (results.isEmpty || !mounted) return;
      
      // FILTERING: If a target pose is set, show ONLY that pose
      // Otherwise, show the pose with highest confidence
      PoseResult displayResult;
      if (widget.targetPose != null) {
        // Filter to find the target pose
        final targetResult = results.firstWhere(
          (r) => r.poseId == widget.targetPose,
          orElse: () => results.first, // Fallback to first if target not found
        );
        displayResult = targetResult;
        
        // Only update hold timer if this result matches the target
        _updateHold(displayResult.poseId == widget.targetPose, displayResult.correctness);
      } else {
        // No target pose set: show the most confident detection
        displayResult = results.reduce((a, b) => a.poseConfidence > b.poseConfidence ? a : b);
      }
      
      setState(() => _lastResult = displayResult);
    } catch (e) {
      debugPrint('Frame processing error: $e');
    }
  }

  /// Accumulates "held correctly" time. On the rising edge of a match
  /// (`match` true while not already held) it starts a 1 Hz ticker; while the
  /// user drifts out of the pose the accumulator freezes but does not reset.
  /// At >= 30s cumulative hold, records stats and notifies the user once.
  void _updateHold(bool isMatch, double correctness) {
    if (!isMatch) {
      // Freeze the timer while out of the pose; don't reset progress.
      return;
    }

    // Rising edge: user just entered (or re-entered) the correct pose.
    if (!_currentlyHeld) {
      _currentlyHeld = true;
      _holdTicker?.cancel();
      _holdTicker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _heldSeconds++);
        _checkCompletion();
      });
    }

    // Sample correctness every frame while held, for the average accuracy stat.
    _accuracySamples.add(correctness);
  }

  /// Once the pose has been held for 30s, cancel the ticker, average the
  /// collected correctness samples, persist the stat, and inform the user.
  void _checkCompletion() {
    if (_heldSeconds < 30 || _completionHandled) return;
    _completionHandled = true;
    _holdTicker?.cancel();
    _holdTicker = null;
    _currentlyHeld = false;

    // Notify the profile store.
    final accuracy = _accuracySamples.isEmpty
        ? _lastResult?.correctness ?? 0.0
        : _accuracySamples.reduce((a, b) => a + b) / _accuracySamples.length;
    // Fire-and-forget; these are best-effort stat writes.
    ProfileRepository().recordCompletedPose(widget.targetPose ?? 'unknown', accuracy);

    if (!mounted) return;
    final poseId = widget.targetPose ?? 'unknown';
    final kcaLTotal = caloriesBurned(poseId, _weightKg, _heldSeconds / 60);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🎉 ${_titleCase(poseId)} held for 30s (+${_heldSeconds.toStringAsFixed(0)}s total)! '
          'Burned ~${kcaLTotal.toStringAsFixed(2)} kcal',
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: const Color(0xFF2D6A4F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff95D5B2),
      appBar: AppBar(
        title: Text(widget.targetPose != null ? _titleCase(widget.targetPose!) : 'Pose Detection',
            style: const TextStyle(color: Color(0xFF1B4332), fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        centerTitle: true,
        backgroundColor: const Color(0xff95D5B2),
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Color(0xFF1B4332)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildCameraView(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFF1B4332)),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF1B4332))),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _init, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        SizedBox.expand(
          child: _controller != null && _controller!.value.isInitialized
              ? CameraPreview(_controller!)
              : const Center(child: CircularProgressIndicator()),
        ),
        // Camera flip toggle (front <-> back)
        if (_availableCameras.length > 1)
          Positioned(
            right: 16,
            bottom: 100,
            child: Material(
              color: Colors.white.withValues(alpha: 0.85),
              shape: const CircleBorder(),
              elevation: 4,
              child: IconButton(
                icon: const Icon(Icons.cameraswitch, color: Color(0xFF1B4332), size: 28),
                tooltip: 'Flip camera',
                onPressed: _flipCamera,
              ),
            ),
          ),
        // Overlay result cards
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: _lastResult == null ? const SizedBox.shrink() : _buildResultCard(),
        ),
        // Hold timer + calories overlay (only while a target pose is set)
        // Bottom-left, opposite the camera-flip toggle (bottom-right), so they
        // never overlap.
        if (widget.targetPose != null)
          Positioned(
            bottom: 100,
            left: 16,
            child: _buildHoldOverlay(),
          ),
        if (!_modelLoaded)
          const Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Center(child: LinearProgressIndicator()),
          ),
        if (_lastResult != null && widget.targetPose != null)
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: _buildMatchBanner(),
          ),
      ],
    );
  }

  Widget _buildResultCard() {
    final r = _lastResult!;
    
    // When a target pose is set, emphasize it and show if it matches
    final isTargetMode = widget.targetPose != null;
    final isMatch = isTargetMode && r.poseId == widget.targetPose;
    
    return Card(
      color: Colors.white.withValues(alpha: 0.92),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isTargetMode
          ? BorderSide(
              color: isMatch ? const Color(0xFF2D6A4F) : const Color(0xFF9D0208),
              width: 2,
            )
          : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Target pose indicator
            if (isTargetMode)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      isMatch ? Icons.check_circle : Icons.info,
                      color: isMatch ? const Color(0xFF2D6A4F) : const Color(0xFF9D0208),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isMatch
                          ? 'Target: ${_titleCase(widget.targetPose!)}'
                          : 'Detected: ${_titleCase(r.poseId)} (target: ${_titleCase(widget.targetPose!)})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isMatch ? const Color(0xFF2D6A4F) : const Color(0xFF9D0208),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Pose name and correctness
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pose: ${_titleCase(r.poseId)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _correctnessColor(r.correctness),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(r.correctness * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Confidence: ${(r.poseConfidence * 100).round()}%',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const Divider(height: 12),
            // Top 3 deviations to fix
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Adjustments needed:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B4332),
                ),
              ),
            ),
            ...r.topDeviations().take(3).map((d) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Text('•', style: TextStyle(color: Color(0xFF9D0208))),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${d.$1}: ${d.$2.toStringAsFixed(0)}° off',
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  /// Returns color based on correctness percentage
  Color _correctnessColor(double correctness) {
    if (correctness >= 0.8) return const Color(0xFF2D6A4F); // Green
    if (correctness >= 0.6) return const Color(0xFFA4AC86); // Yellow-green
    if (correctness >= 0.4) return const Color(0xFFFFA500); // Orange
    return const Color(0xFF9D0208); // Red
  }

  Widget _buildMatchBanner() {
    final r = _lastResult!;
    final isMatch = r.poseId == widget.targetPose;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: isMatch ? const Color(0xFF2D6A4F) : const Color(0xFF9D0208),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isMatch ? const Color(0xFF2D6A4F) : const Color(0xFF9D0208))
                .withValues(alpha: 0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isMatch ? Icons.check_circle : Icons.adjust,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMatch ? '✓ Perfect!' : '✗ Not quite right',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isMatch
                    ? 'Hold this pose to earn points!'
                    : 'Adjust to match "${_titleCase(widget.targetPose!)}"',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Live "hold time + calories" chip shown while a target pose is active.
  Widget _buildHoldOverlay() {
    final poseId = widget.targetPose ?? 'unknown';
    final met = metFor(poseId);
    final perMinute = met * _weightKg / 60; // kcal per minute burn rate
    final kcaLTotal = caloriesBurned(poseId, _weightKg, _heldSeconds / 60);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_outlined, color: Color(0xFF1B4332), size: 20),
              const SizedBox(width: 4),
              Text(
                '${_heldSeconds}s',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B4332)),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                '${perMinute.toStringAsFixed(2)} kcal/min · ${kcaLTotal.toStringAsFixed(2)} kcal',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xff7f5539)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _titleCase(String s) => s.split('_').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

  @override
  void dispose() {
    _processingTimer?.cancel();
    _holdTicker?.cancel();
    _controller?.dispose();
    _analyzer?.dispose();
    super.dispose();
  }
}