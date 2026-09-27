/// Metabolic equivalents (METs) per pose, keyed by the classifier pose id
/// from [assets/model/pose_labels.txt].
///
/// MET is a rough measure of exercise intensity: 1 MET ≈ resting. Yoga
/// typically ranges ~1.5 (restorative) to ~4.0 (vigorous vinyasa). Values
/// below are reasonable estimates for each pose.
const Map<String, double> kPoseMet = {
  'corpse': 1.0, // savasana — near resting
  'child_pose': 1.5,
  'seated_easy_pose': 1.5,
  'seated_staff': 2.0,
  'seated_forward': 2.0,
  'mountain_pose': 1.8,
  'standing_pose': 1.8,
  'table_top': 2.0,
  'downward_dog': 3.0,
  'upward_dog': 3.0,
  'cobra_pose': 2.5,
  'tree_pose': 2.5,
  'triangle': 2.5,
  'warrior_1': 3.0,
  'warrior_2': 3.0,
  'halfway_lift': 2.5,
  'standing_forward_fold': 2.5,
  'plank': 4.0,
  'chaturanga': 4.0,
  'lunge_pose': 3.5,
  'upward_salute': 2.5,
  'transition/unknown': 2.0,
};

const double _kDefaultMet = 2.5;

double metFor(String poseId) => kPoseMet[poseId] ?? _kDefaultMet;

/// Calories burned ≈ MET × weight(kg) × duration(hours).
/// [heldMinutes] is the cumulative minutes the pose was correctly held.
double caloriesBurned(String poseId, double weightKg, double heldMinutes) {
  if (weightKg <= 0 || heldMinutes <= 0) return 0;
  return metFor(poseId) * weightKg * (heldMinutes / 60);
}