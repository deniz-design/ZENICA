import 'geometry.dart';

/// A single scored band on one feature: (featureName, lo, hi).
typedef FeatureBand = (String, double, double);

/// Port of app/utils/rules_classifier.py from Arko007/yoga_pose.
///
/// Deterministic biomechanical rules on the 15 2D angles, plus the hybrid
/// voting that combines the learned MLP call with the 2D-rule engine (and,
/// when available, a 3D world-landmark rule vote).
class RulesClassifier {
  /// Poses the rule engine currently can't surface until underlying
  /// real-world issues are fixed (see the Python docstring).
  /// warrior_1 is intentionally NOT disabled: it is a first-class output class
  /// of the MLP (label index 21) and its 2D arms-overhead signature
  /// (shoulder > 110) is distinct from warrior_2's 65-125 band.
  static const Set<String> _disabledPoses = {'chair_pose'};

  static String sanitizePose(String pose) =>
      _disabledPoses.contains(pose) ? 'transition/unknown' : pose;

  static bool _between(double v, double lo, double hi) => lo <= v && v <= hi;

  /// Map of feature name -> angle value.
  static String classifyPose(Map<String, double> a) {
    final hipL = a['hip_l']!;
    final hipR = a['hip_r']!;
    final kneeL = a['knee_l']!;
    final kneeR = a['knee_r']!;
    final shoulderL = a['shoulder_l']!;
    final shoulderR = a['shoulder_r']!;
    final trunkL = a['trunk_l']!;
    final trunkR = a['trunk_r']!;
    final neck = a['neck']!;

    if (hipL > 140 && hipR > 140 && kneeL > 140 && kneeR > 140 &&
        shoulderL < 55 && shoulderR < 55 && trunkL > 65 && trunkR > 65) {
      return 'mountain_pose';
    }
    if (hipL > 140 && hipR > 140 && kneeL > 140 && kneeR > 140 &&
        shoulderL > 115 && shoulderR > 115 && trunkL > 65 && trunkR > 65) {
      return 'upward_salute';
    }
    if (_between(hipL, 20, 140) && _between(hipR, 20, 140) &&
        kneeL > 110 && kneeR > 110 && shoulderL > 95 && shoulderR > 95) {
      return 'downward_dog';
    }
    if (hipL > 140 && hipR > 140 && kneeL > 140 && kneeR > 140 &&
        _between(shoulderL, 60, 110) && _between(shoulderR, 60, 110)) {
      return 'plank';
    }
    if (hipL > 120 && hipR > 120 && kneeL > 120 && kneeR > 120 &&
        _between(shoulderL, 5, 50) && _between(shoulderR, 5, 50) && neck >= 80) {
      return 'cobra_pose';
    }
    if (hipL < 90 && hipR < 90 && kneeL < 90 && kneeR < 90 &&
        shoulderL > 85 && shoulderR > 85) {
      return 'child_pose';
    }
    if (_between(hipL, 60, 120) && _between(hipR, 60, 120) &&
        kneeL > 135 && kneeR > 135 && trunkL >= 60 && trunkR >= 60) {
      return 'seated_staff';
    }
    if (_between(hipL, 50, 120) && _between(hipR, 50, 120) &&
        kneeL < 125 && kneeR < 125 && trunkL >= 60 && trunkR >= 60) {
      return 'seated_easy_pose';
    }
    if (_between(hipL, 75, 140) && _between(hipR, 75, 140) &&
        _between(kneeL, 75, 140) && _between(kneeR, 75, 140) &&
        (kneeL - kneeR).abs() < 30 && shoulderL > 95 && shoulderR > 95) {
      return 'chair_pose';
    }
    if ((kneeL > 150 && hipL > 165 && kneeR < 140) ||
        (kneeR > 150 && hipR > 165 && kneeL < 140)) {
      return 'tree_pose';
    }
    // Warrior I is evaluated before Warrior II: its arms-overhead signature
    // (shoulder > 110) overlaps Warrior II's 65-125 band in the 110-125 range,
    // and a held Warrior I must win there. Warrior II still gets any frame
    // whose arms sit in 65-110.
    final legs = (kneeL < 120 && kneeR > 130) || (kneeR < 120 && kneeL > 130);
    if (legs && shoulderL > 110 && shoulderR > 110) return 'warrior_1';
    final w2Arms = _between(shoulderL, 65, 125) && _between(shoulderR, 65, 125);
    if (legs && w2Arms) return 'warrior_2';
    if (legs) return 'lunge_pose';
    if (hipL < 70 && hipR < 70 && kneeL > 120 && kneeR > 120) return 'standing_forward_fold';
    if (_between(hipL, 70, 115) && _between(hipR, 70, 115) &&
        kneeL > 130 && kneeR > 130) {
      return 'halfway_lift';
    }
    if (_between(hipL, 60, 125) && _between(hipR, 60, 125) &&
        _between(kneeL, 60, 125) && _between(kneeR, 60, 125) &&
        _between(shoulderL, 60, 125) && _between(shoulderR, 60, 125)) {
      return 'table_top';
    }
    if (hipL > 140 && hipR > 140 && kneeL > 140 && kneeR > 140) return 'standing_pose';
    return 'transition/unknown';
  }

  static const Map<String, List<FeatureBand>> _poseFeatureBands = {
    'mountain_pose': [
      ('hip_l', 140, 180), ('hip_r', 140, 180), ('knee_l', 140, 180), ('knee_r', 140, 180),
      ('shoulder_l', 0, 55), ('shoulder_r', 0, 55), ('trunk_l', 65, 180), ('trunk_r', 65, 180),
    ],
    'upward_salute': [
      ('hip_l', 140, 180), ('hip_r', 140, 180), ('knee_l', 140, 180), ('knee_r', 140, 180),
      ('shoulder_l', 115, 180), ('shoulder_r', 115, 180), ('trunk_l', 65, 180), ('trunk_r', 65, 180),
    ],
    'downward_dog': [
      ('hip_l', 20, 140), ('hip_r', 20, 140), ('knee_l', 110, 180), ('knee_r', 110, 180),
      ('shoulder_l', 95, 180), ('shoulder_r', 95, 180),
    ],
    'plank': [
      ('hip_l', 140, 180), ('hip_r', 140, 180), ('knee_l', 140, 180), ('knee_r', 140, 180),
      ('shoulder_l', 60, 110), ('shoulder_r', 60, 110),
    ],
    'cobra_pose': [
      ('hip_l', 120, 180), ('hip_r', 120, 180), ('knee_l', 120, 180), ('knee_r', 120, 180),
      ('shoulder_l', 5, 50), ('shoulder_r', 5, 50), ('neck', 80, 180),
    ],
    'child_pose': [
      ('hip_l', 0, 90), ('hip_r', 0, 90), ('knee_l', 0, 90), ('knee_r', 0, 90),
      ('shoulder_l', 85, 180), ('shoulder_r', 85, 180),
    ],
    'seated_staff': [
      ('hip_l', 60, 120), ('hip_r', 60, 120), ('knee_l', 135, 180), ('knee_r', 135, 180),
      ('trunk_l', 60, 180), ('trunk_r', 60, 180),
    ],
    'seated_easy_pose': [
      ('hip_l', 50, 120), ('hip_r', 50, 120), ('knee_l', 0, 125), ('knee_r', 0, 125),
      ('trunk_l', 60, 180), ('trunk_r', 60, 180),
    ],
    'tree_pose': [],
    'warrior_1': [
      ('shoulder_l', 110, 180), ('shoulder_r', 110, 180),
    ],
    'warrior_2': [
      ('shoulder_l', 65, 125), ('shoulder_r', 65, 125),
    ],
    'lunge_pose': [],
    'standing_forward_fold': [
      ('hip_l', 0, 70), ('hip_r', 0, 70), ('knee_l', 120, 180), ('knee_r', 120, 180),
    ],
    'halfway_lift': [
      ('hip_l', 70, 115), ('hip_r', 70, 115), ('knee_l', 130, 180), ('knee_r', 130, 180),
    ],
    'chair_pose': [
      ('hip_l', 75, 140), ('hip_r', 75, 140), ('knee_l', 75, 140), ('knee_r', 75, 140),
      ('shoulder_l', 95, 180), ('shoulder_r', 95, 180),
    ],
    'table_top': [
      ('hip_l', 60, 125), ('hip_r', 60, 125), ('knee_l', 60, 125), ('knee_r', 60, 125),
      ('shoulder_l', 60, 125), ('shoulder_r', 60, 125),
    ],
    'standing_pose': [
      ('hip_l', 140, 180), ('hip_r', 140, 180), ('knee_l', 140, 180), ('knee_r', 140, 180),
    ],
  };

  /// Returns (correctness in [0,1], per-feature deviation in degrees).
  static (double, Map<String, double>) scorePose(String poseId, Map<String, double> a) {
    Map<String, double> deviations = {for (final f in PoseGeometry.featureNames) f: 0.0};
    final bands = _poseFeatureBands[poseId] ?? const <FeatureBand>[];
    if (bands.isEmpty) {
      final correctness = poseId == 'transition/unknown' ? 0.0 : 0.5;
      return (correctness, deviations);
    }

    double totalDev = 0.0;
    for (final (name, lo, hi) in bands) {
      final val = a[name] ?? 0.0;
      final dev = val < lo ? lo - val : (val > hi ? val - hi : 0.0);
      deviations[name] = dev;
      totalDev += dev;
    }
    final meanDev = totalDev / bands.length;
    final correctness = (1.0 - meanDev / 45.0).clamp(0.0, 1.0).toDouble();
    return (correctness, deviations);
  }

  /// Full hybrid classification.
  ///
  /// Combines the learned MLP's pose call with the deterministic 2D-rule
  /// engine and, when [worldAngles] is provided, a second independent 3D
  /// rule call (mimics hybrid_classify in the space). Returns
  /// (sanitizedPose, correctness, deviations).
  static (String, double, Map<String, double>) hybridClassify({
    required String mlpPose,
    required double mlpCorrectness,
    required Map<String, double> mlpDevs,
    required Map<String, double> angles2d,
    Map<String, double>? worldAngles,
  }) {
    final rulePose2d = classifyPose(angles2d);

    if (worldAngles == null) {
      if (rulePose2d == mlpPose) {
        return (sanitizePose(mlpPose), mlpCorrectness, mlpDevs);
      }
      final (c, d) = scorePose(rulePose2d, angles2d);
      return (sanitizePose(rulePose2d), c, d);
    }

    final rulePoseWorld = classifyPose(worldAngles);
    if (mlpPose == rulePose2d) {
      return (sanitizePose(mlpPose), mlpCorrectness, mlpDevs);
    } else if (rulePose2d == rulePoseWorld) {
      final (c, d) = scorePose(rulePose2d, angles2d);
      return (sanitizePose(rulePose2d), c, d);
    } else if (mlpPose == rulePoseWorld) {
      final (c, d) = scorePose(mlpPose, angles2d);
      return (sanitizePose(mlpPose), c, d);
    } else {
      final (c, d) = scorePose(rulePose2d, angles2d);
      return (sanitizePose(rulePose2d), c, d);
    }
  }
}