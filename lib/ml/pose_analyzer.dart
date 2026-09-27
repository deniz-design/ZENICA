import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'geometry.dart';
import 'model_engine.dart';
import 'rules_classifier.dart';

/// The combined on-device pipeline for the PosePerfect app.
///
/// Camera frame (via google_mlkit PoseDetector) → normalized landmarks →
/// 15 feature angles → 3-head MLP → hybrid (rules + MLP) classification.
class PoseAnalyzer {
  final Yoga3HeadMLPEngine _engine = Yoga3HeadMLPEngine();
  final PoseDetector _poseDetector;
  final Map<PoseLandmarkType, PoseLandmark> _lastLandmarks = {};

  PoseAnalyzer({PoseDetectionModel model = PoseDetectionModel.accurate})
      : _poseDetector = PoseDetector(
          options: PoseDetectorOptions(model: model, mode: PoseDetectionMode.stream),
        );

  bool get isLoaded => _engine.isReady;

  Map<PoseLandmarkType, PoseLandmark> get lastLandmarks => _lastLandmarks;

  Future<void> loadModel() => _engine.loadFromAssets();

  /// Converts a raw camera frame into an [InputImage] that MLKit can process.
  /// Handles both JPEG (single plane) and NV21/YUV_420_888 (three-plane)
  /// formats.
  static InputImage inputImageFromCameraImage(CameraImage image, {int rotationDeg = 0}) {
    final plane = image.planes[0];
    final size = ui.Size(image.width.toDouble(), image.height.toDouble());

    if (image.format.group == ImageFormatGroup.jpeg) {
      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: size,
          rotation: _rotationIndexed(rotationDeg),
          format: InputImageFormat.nv21,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    }

    // NV21 / YUV_420_888
    final nv21 = _yuv420888ToNv21ByteBuffer(image);
    return InputImage.fromBytes(
      bytes: nv21,
      metadata: InputImageMetadata(
        size: size,
        rotation: _rotationIndexed(rotationDeg),
        format: InputImageFormat.nv21,
        bytesPerRow: image.width,
      ),
    );
  }

  static InputImageRotation _rotationIndexed(int deg) => switch (deg) {
        90 => InputImageRotation.rotation90deg,
        180 => InputImageRotation.rotation180deg,
        270 => InputImageRotation.rotation270deg,
        _ => InputImageRotation.rotation0deg,
      };

  static Uint8List _yuv420888ToNv21ByteBuffer(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final yBytes = yPlane.bytes;
    final uBytes = uPlane.bytes;
    final vBytes = vPlane.bytes;

    final yRowStride = yPlane.bytesPerRow;
    final uRowStride = uPlane.bytesPerRow;
    final vRowStride = vPlane.bytesPerRow;
    final uPixelStride = uPlane.bytesPerPixel ?? 2;
    final vPixelStride = vPlane.bytesPerPixel ?? 2;

    final out = Uint8List(width * height * 3 ~/ 2);
    int o = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        out[o++] = yBytes[y * yRowStride + x];
      }
    }

    // UV interleaving pattern for NV21 is V, U
    for (int y = 0; y < height ~/ 2; y++) {
      for (int x = 0; x < width ~/ 2; x++) {
        final uIndex = y * uRowStride + x * uPixelStride;
        final vIndex = y * vRowStride + x * vPixelStride;
        // NV21 stores V then U
        out[o++] = vBytes[vIndex];
        out[o++] = uBytes[uIndex];
      }
    }
    return out;
  }

  /// Detects poses in a raw camera frame.
  Future<List<Pose>> detectFromCameraImage(CameraImage image, {int rotationDeg = 0}) {
    final input = inputImageFromCameraImage(image, rotationDeg: rotationDeg);
    return _poseDetector.processImage(input);
  }

  /// Runs the full pipeline on a detected [Pose] from the camera.
  ///
  /// Returns a complete analysis result, or null if no pose is detected.
  PoseResult? analyze({required Pose pose, required int imgWidth, required int imgHeight}) {
    if (!_engine.isReady) return null;
    final landmarks = pose.landmarks.values.toList();
    if (landmarks.isEmpty) return null;

    // Build landmark arrays in canonical MediaPipe index order.
    // MLKit's PoseLandmarkType enum uses the exact same indices as MediaPipe
    // (0=nose, 11=leftShoulder, ... 32=rightFootIndex).
    final ordered = List<(double, double, double, double)>.filled(33, (0, 0, 0, 0));
    for (final lm in pose.landmarks.entries) {
      final idx = lm.key.index;
      if (idx < 33) {
        ordered[idx] = (lm.value.x / imgWidth, lm.value.y / imgHeight, 0.0, lm.value.likelihood);
      }
    }
    _lastLandmarks.addAll(pose.landmarks);

    final angles = PoseGeometry.extractAnglesFromLandmarks(ordered, zeroZ: true);

    // MLP inference
    final inf = _engine.infer(angles);
    final (poseIdx, poseProb) = _engine.softmaxPose(inf.poseLogits);
    final mlpPose = _engine.labels![poseIdx];
    final mlpCorrectness = 1.0 / (1.0 + math.exp(-inf.correctnessLogit));

    // Map 15 deviations (predicted in [0,1], normalized) to degrees.
    Map<String, double> mlpDevs = {};
    for (int i = 0; i < 15; i++) {
      mlpDevs[PoseGeometry.featureNames[i]] =
          (inf.deviations[i] * 180.0).clamp(0.0, 180.0).toDouble();
    }

    // angles dict for the rules engine (feature name -> angle)
    Map<String, double> anglesDict = {
      for (int i = 0; i < 15; i++) PoseGeometry.featureNames[i]: angles[i],
    };

    // Hybrid voting (no world-landmark signal from MLKit -> 2-way)
    final (finalPose, correctness, devs) = RulesClassifier.hybridClassify(
      mlpPose: mlpPose,
      mlpCorrectness: mlpCorrectness,
      mlpDevs: mlpDevs,
      angles2d: anglesDict,
    );

    return PoseResult(
      poseId: finalPose,
      mlpPose: mlpPose,
      poseConfidence: poseProb,
      correctness: correctness,
      deviations: devs,
      angles: anglesDict,
      featureNames: List.of(PoseGeometry.featureNames),
    );
  }

  Future<void> dispose() => _poseDetector.close();
}

/// Result of analyzing a single camera frame.
class PoseResult {
  final String poseId;
  final String mlpPose;
  final double poseConfidence;
  final double correctness;
  final Map<String, double> deviations;
  final Map<String, double> angles;
  final List<String> featureNames;

  PoseResult({
    required this.poseId,
    required this.mlpPose,
    required this.poseConfidence,
    required this.correctness,
    required this.deviations,
    required this.angles,
    required this.featureNames,
  });

  /// Returns a short set of (feature, deviation) joint cues with notable
  /// corrections, sorted by largest deviation.
  List<(String, double)> topDeviations({int count = 3}) {
    final entries = deviations.entries.where((e) => e.value > 5.0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(count).map((e) => (e.key, e.value)).toList();
  }
}