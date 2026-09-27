/// Personal + yoga profile for a user.
///
/// Metric is the canonical storage unit (height in cm, weight in kg).
/// Stored locally on first-launch onboarding and mirrored to Firestore
/// keyed by the Firebase auth UID once the user has an account.
class UserProfile {
  final String uid;
  final String name;
  final int age;
  final String gender; // male / female / other
  final double heightCm;
  final double weightKg;
  final String email;
  final DateTime? dob;
  final String yogaLevel; // beginner / intermediate / advanced
  final List<String> goals; // flexibility, strength, weight management, stress relief

  // Progress & statistics
  final int totalSessions;
  final int dailySessions;
  final int posesCompleted;
  final double avgAccuracy; // 0..1
  final int weeklyProgress;
  final int monthlyProgress;

  const UserProfile({
    this.uid = '',
    this.name = '',
    this.age = 0,
    this.gender = '',
    this.heightCm = 0,
    this.weightKg = 0,
    this.email = '',
    this.dob,
    this.yogaLevel = '',
    this.goals = const [],
    this.totalSessions = 0,
    this.dailySessions = 0,
    this.posesCompleted = 0,
    this.avgAccuracy = 0,
    this.weeklyProgress = 0,
    this.monthlyProgress = 0,
  });

  /// BMI = weight(kg) / (height(m))^2. Single source of truth, reused by the
  /// BMI calculator and the profile page.
  double get bmiValue {
    if (heightCm <= 0) return 0;
    final m = heightCm / 100;
    return weightKg / (m * m);
  }

  /// Whether the minimal onboarding fields have been supplied.
  bool get hasLocalEssentials =>
      name.isNotEmpty && age > 0 && heightCm > 0 && weightKg > 0;

  UserProfile copyWith({
    String? uid,
    String? name,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? email,
    DateTime? dob,
    String? yogaLevel,
    List<String>? goals,
    int? totalSessions,
    int? dailySessions,
    int? posesCompleted,
    double? avgAccuracy,
    int? weeklyProgress,
    int? monthlyProgress,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      yogaLevel: yogaLevel ?? this.yogaLevel,
      goals: goals ?? this.goals,
      totalSessions: totalSessions ?? this.totalSessions,
      dailySessions: dailySessions ?? this.dailySessions,
      posesCompleted: posesCompleted ?? this.posesCompleted,
      avgAccuracy: avgAccuracy ?? this.avgAccuracy,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      monthlyProgress: monthlyProgress ?? this.monthlyProgress,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'email': email,
      'dob': dob?.toIso8601String(),
      'yogaLevel': yogaLevel,
      'goals': goals,
      'totalSessions': totalSessions,
      'dailySessions': dailySessions,
      'posesCompleted': posesCompleted,
      'avgAccuracy': avgAccuracy,
      'weeklyProgress': weeklyProgress,
      'monthlyProgress': monthlyProgress,
    };
  }

  factory UserProfile.fromFirestore(Map<String, dynamic>? d, {String uid = ''}) {
    if (d == null) return const UserProfile();
    return UserProfile(
      uid: uid,
      name: d['name'] as String? ?? '',
      age: (d['age'] as num?)?.toInt() ?? 0,
      gender: d['gender'] as String? ?? '',
      heightCm: (d['heightCm'] as num?)?.toDouble() ?? 0,
      weightKg: (d['weightKg'] as num?)?.toDouble() ?? 0,
      email: d['email'] as String? ?? '',
      dob: d['dob'] != null ? DateTime.tryParse(d['dob'] as String) : null,
      yogaLevel: d['yogaLevel'] as String? ?? '',
      goals: (d['goals'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      totalSessions: (d['totalSessions'] as num?)?.toInt() ?? 0,
      dailySessions: (d['dailySessions'] as num?)?.toInt() ?? 0,
      posesCompleted: (d['posesCompleted'] as num?)?.toInt() ?? 0,
      avgAccuracy: (d['avgAccuracy'] as num?)?.toDouble() ?? 0,
      weeklyProgress: (d['weeklyProgress'] as num?)?.toInt() ?? 0,
      monthlyProgress: (d['monthlyProgress'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => toFirestore();

  factory UserProfile.fromJson(Map<String, dynamic> d) => UserProfile.fromFirestore(d);
}
