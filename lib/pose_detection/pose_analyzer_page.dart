import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../ml/pose_analyzer.dart';
import '../services/session_tracker.dart';

class PoseAnalyzerPage extends StatefulWidget {
  const PoseAnalyzerPage({super.key});

  @override
  State<PoseAnalyzerPage> createState() => _PoseAnalyzerPageState();
}

class _PoseAnalyzerPageState extends State<PoseAnalyzerPage> {
  final SessionTracker _sessionTracker = SessionTracker();
  CameraController? _controller;
  PoseAnalyzer? _analyzer;
  PoseResult? _lastResult;
  bool _loading = true;
  bool _modelLoaded = false;
  String? _error;
  bool _cameraActive = false;
  
  List<CameraDescription> _availableCameras = const [];
  CameraLensDirection _lensDirection = CameraLensDirection.front;

  @override
  void initState() {
    super.initState();
    _initializeAnalyzer();
  }

  Future<void> _initializeAnalyzer() async {
    try {
      _availableCameras = await availableCameras();
      final analyzer = PoseAnalyzer();
      await analyzer.loadModel();
      if (!mounted) return;
      setState(() {
        _analyzer = analyzer;
        _modelLoaded = true;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Analyzer init error: $e');
      if (mounted) {
        setState(() {
          _error = '$e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _startCamera() async {
    if (!_modelLoaded || _analyzer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model is still loading...')),
      );
      return;
    }

    try {
      if (_availableCameras.isEmpty) {
        throw Exception('No cameras available');
      }

      final selected = _availableCameras.firstWhere(
        (c) => c.lensDirection == _lensDirection,
        orElse: () => _availableCameras.first,
      );

      _controller = CameraController(
        selected,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      if (!mounted) {
        await _controller!.dispose();
        return;
      }

      _controller!.startImageStream(_onFrame);

      if (mounted) {
        setState(() => _cameraActive = true);
      }
    } catch (e) {
      debugPrint('Camera error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_analyzer == null || !_cameraActive) return;
    try {
      final poses = await _analyzer!.detectFromCameraImage(image);
      if (poses.isEmpty) {
        if (mounted) {
          setState(() => _lastResult = null);
        }
        return;
      }

      final result = _analyzer!.analyze(
        pose: poses.first,
        imgWidth: image.width,
        imgHeight: image.height,
      );

      if (result != null && mounted && _cameraActive) {
        setState(() => _lastResult = result);
        _sessionTracker.setCurrentPose(result.poseId);
      }
    } catch (e) {
      debugPrint('Frame processing error: $e');
    }
  }

  Future<void> _flipCamera() async {
    if (_availableCameras.length < 2 || !_cameraActive) return;
    
    final old = _controller;
    _controller = null;
    await old?.dispose();
    
    _lensDirection = _lensDirection == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;
    
    await _startCamera();
  }

  Future<void> _stopCamera() async {
    _cameraActive = false;
    await _controller?.dispose();
    _controller = null;
    if (mounted) {
      setState(() => _cameraActive = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraActive && _controller != null && _controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Camera Preview
            SizedBox.expand(
              child: CameraPreview(_controller!),
            ),

            // Top buttons
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Material(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _stopCamera,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.close, color: Colors.black, size: 24),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _flipCamera,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.flip_camera_android, color: Colors.black, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pose Detection Result Card - Bottom
            if (_lastResult != null)
              Positioned(
                bottom: 32,
                left: 16,
                right: 16,
                child: Card(
                  color: Colors.black87,
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Current Pose',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _titleCase(_lastResult!.poseId),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD8F3DC),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Accuracy: ${(_lastResult!.correctness * 100).round()}%',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: _getAccuracyColor(_lastResult!.correctness),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${(_lastResult!.correctness * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Positioned(
                bottom: 32,
                left: 16,
                right: 16,
                child: Card(
                  color: Colors.black87,
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Move into frame to detect pose...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontFamily: 'Poppins',
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Main screen when camera is not active
    return Scaffold(
      backgroundColor: const Color(0xff95D5B2),
      appBar: AppBar(
        title: const Text(
          'Pose Analyzer',
          style: TextStyle(
            color: Color(0xFF1B4332),
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff95D5B2),
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Color(0xFF1B4332)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xff7f5539)),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Card(
                      color: Colors.white.withValues(alpha: 0.95),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info, color: Color(0xFF2D6A4F), size: 24),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Real-Time Pose Detection',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B4332),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Open your camera to see which yoga pose you\'re performing in real-time. The analyzer will detect your body movements and identify the pose instantly with accuracy feedback.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontFamily: 'Poppins',
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Start Camera Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _modelLoaded ? _startCamera : null,
                        icon: const Icon(Icons.camera_alt, size: 24),
                        label: const Text(
                          'Open Camera',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D6A4F),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    if (!_modelLoaded)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Card(
                          color: const Color(0xFFFFA500).withValues(alpha: 0.15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Color(0xFFFFA500),
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.hourglass_bottom, color: Color(0xFFFFA500), size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Loading AI Model',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFFA500),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'The pose detection model is being loaded. This happens once on first use.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Card(
                          color: const Color(0xFF9D0208).withValues(alpha: 0.15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Color(0xFF9D0208),
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: Color(0xFF9D0208), size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF9D0208),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Current Pose Display
                    if (_lastResult != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Detected Pose',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B4332),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _titleCase(_lastResult!.poseId),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B4332),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getAccuracyColor(_lastResult!.correctness),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${(_lastResult!.correctness * 100).round()}%',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  String _titleCase(String s) =>
      s.split('_').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

  Color _getAccuracyColor(double correctness) {
    if (correctness >= 0.8) return const Color(0xFF2D6A4F);
    if (correctness >= 0.6) return const Color(0xFFA4AC86);
    if (correctness >= 0.4) return const Color(0xFFFFA500);
    return const Color(0xFF9D0208);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _analyzer?.dispose();
    super.dispose();
  }
}
