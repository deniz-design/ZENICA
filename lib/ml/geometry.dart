import 'dart:math' as math;

/// Mirrors app/utils/geometry.py from the Arko007/yoga_pose space:
/// exact 15 biomechanical features in the same FEATURE_NAMES order.
class PoseGeometry {
  /// Landmark indices (canonical MediaPipe order; identical to MLKit's enum order).
  static const int nose = 0;
  static const int shoulderL = 11, shoulderR = 12;
  static const int elbowL = 13, elbowR = 14;
  static const int wristL = 15, wristR = 16;
  static const int hipL = 23, hipR = 24;
  static const int kneeL = 25, kneeR = 26;
  static const int ankleL = 27, ankleR = 28;
  static const int heelL = 29, heelR = 30;

  static const List<String> featureNames = [
    'elbow_l', 'elbow_r', 'shoulder_l', 'shoulder_r',
    'hip_l', 'hip_r', 'knee_l', 'knee_r',
    'ankle_l', 'ankle_r', 'trunk_l', 'trunk_r',
    'neck', 'hip_abduct_l', 'hip_abduct_r',
  ];

  /// 3D angle at vertex b between vectors b->a and b->c, in degrees.
  static double calculateAngle3D(
      (double, double, double) a,
      (double, double, double) b,
      (double, double, double) c) {
    final ba = (a.$1 - b.$1, a.$2 - b.$2, a.$3 - b.$3);
    final bc = (c.$1 - b.$1, c.$2 - b.$2, c.$3 - b.$3);
    final dot = ba.$1 * bc.$1 + ba.$2 * bc.$2 + ba.$3 * bc.$3;
    final normBa = math.sqrt(ba.$1 * ba.$1 + ba.$2 * ba.$2 + ba.$3 * ba.$3);
    final normBc = math.sqrt(bc.$1 * bc.$1 + bc.$2 * bc.$2 + bc.$3 * bc.$3);
    if (normBa == 0 || normBc == 0) return 180.0;
    final cos = (dot / (normBa * normBc)).clamp(-1.0, 1.0);
    return math.acos(cos) * 180.0 / math.pi;
  }

  /// Compute the 15 features from a list of (x, y, z, visibility)
  /// normalized MediaPipe/MLKit landmarks. With zeroZ=true (default) the
  /// z component is dropped, reproducing the proven 2D-only path from the
  /// space (its real-world accuracy findings).
  static List<double> extractAnglesFromLandmarks(
    List<(double, double, double, double)> points, {
    bool zeroZ = true,
  }) {
    if (points.length < 31) return List.filled(15, 0.0);

    List<(double, double, double)> pts = points
        .map((p) => (p.$1, p.$2, zeroZ ? 0.0 : p.$3))
        .toList();

    final shoulderMid = (
      (pts[shoulderL].$1 + pts[shoulderR].$1) / 2,
      (pts[shoulderL].$2 + pts[shoulderR].$2) / 2,
      (pts[shoulderL].$3 + pts[shoulderR].$3) / 2,
    );
    final hipMid = (
      (pts[hipL].$1 + pts[hipR].$1) / 2,
      (pts[hipL].$2 + pts[hipR].$2) / 2,
      (pts[hipL].$3 + pts[hipR].$3) / 2,
    );

    return [
      calculateAngle3D(pts[shoulderL], pts[elbowL], pts[wristL]),
      calculateAngle3D(pts[shoulderR], pts[elbowR], pts[wristR]),
      calculateAngle3D(pts[hipL], pts[shoulderL], pts[elbowL]),
      calculateAngle3D(pts[hipR], pts[shoulderR], pts[elbowR]),
      calculateAngle3D(pts[shoulderL], pts[hipL], pts[kneeL]),
      calculateAngle3D(pts[shoulderR], pts[hipR], pts[kneeR]),
      calculateAngle3D(pts[hipL], pts[kneeL], pts[ankleL]),
      calculateAngle3D(pts[hipR], pts[kneeR], pts[ankleR]),
      calculateAngle3D(pts[kneeL], pts[ankleL], pts[heelL]),
      calculateAngle3D(pts[kneeR], pts[ankleR], pts[heelR]),
      calculateAngle3D(pts[shoulderL], pts[hipL], pts[hipR]),
      calculateAngle3D(pts[shoulderR], pts[hipR], pts[hipL]),
      calculateAngle3D(pts[nose], shoulderMid, hipMid),
      calculateAngle3D(pts[hipR], pts[hipL], pts[kneeL]),
      calculateAngle3D(pts[hipL], pts[hipR], pts[kneeR]),
    ];
  }
}