import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

/// Handles persistence of the user profile.
///
/// Source of truth once logged in is Cloud Firestore, keyed by auth UID.
/// Before an account exists (first-launch onboarding) or when Firestore is
/// unavailable, everything falls back to local [SharedPreferences] storage.
class ProfileRepository {
  static const _kProfileKey = 'user_profile';
  static const _kOnboardedKey = 'onboarded';

  /// Loads the profile: Firestore by current UID, falling back to local.
  Future<UserProfile?> load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserProfile.fromFirestore(doc.data(), uid: user.uid);
        }
      } catch (_) {
        // Firestore unavailable (not enabled / offline). Fall through to local.
      }
    }
    return loadLocal();
  }

  /// Saves to Firestore when logged in; otherwise stores locally.
  Future<void> save(UserProfile p) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
              p.copyWith(uid: user.uid).toFirestore(),
              SetOptions(merge: true),
            );
        // Keep local mirror in sync too.
        await _saveLocal(p.copyWith(uid: user.uid));
        return;
      } catch (_) {
        // Fall through to local on Firestore failure.
      }
    }
    await _saveLocal(p);
  }

  Future<UserProfile?> loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProfileKey);
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLocal(UserProfile p) => _saveLocal(p);

  Future<void> _saveLocal(UserProfile p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfileKey, jsonEncode(p.toJson()));
  }

  Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardedKey) ?? false;
  }

  Future<void> markOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardedKey, true);
  }

  /// Reconciles the local (pre-account) profile into Firestore under [uid].
  /// Only writes if the Firestore doc is absent, to avoid clobbering stats
  /// recorded after account creation.
  Future<void> uploadLocalToFirestore(String uid) async {
    final local = await loadLocal();
    if (local == null) return;
    try {
      final doc = FirebaseFirestore.instance.collection('users').doc(uid);
      final snap = await doc.get();
      if (!snap.exists) {
        await doc.set(local.copyWith(uid: uid, email: local.email.isEmpty ? FirebaseAuth.instance.currentUser?.email ?? '' : local.email).toFirestore());
      }
    } catch (_) {
      // Firestore unavailable — local data is preserved, nothing else to do.
    }
  }

  /// Increments the completion counters for one completed pose session.
  Future<void> recordCompletedPose(String poseId, double accuracy) async {
    final now = DateTime.now();
    final dayKey = '${now.year}-${now.month}-${now.day}';
    final p = await load() ?? const UserProfile();
    final updated = p.copyWith(
      totalSessions: p.totalSessions + 1,
      dailySessions: p.dailySessions + 1,
      posesCompleted: p.posesCompleted + 1,
      avgAccuracy: p.posesCompleted == 0
          ? accuracy.toDouble()
          : (p.avgAccuracy * p.posesCompleted + accuracy) / (p.posesCompleted + 1),
      weeklyProgress: p.weeklyProgress + 1,
      monthlyProgress: p.monthlyProgress + 1,
    );

    await save(updated);

    // Track the last-activity date for rolling daily counts (this keeps
    // "daily sessions" meaningful without a full calendar).
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('last_activity_day') != dayKey) {
      await prefs.setString('last_activity_day', dayKey);
    }
  }

  /// Current weight in kg for calorie math (falls back to a sensible default).
  Future<double> currentWeightKg() async {
    final p = await load();
    if (p != null && p.weightKg > 0) return p.weightKg;
    return 55.0;
  }
}