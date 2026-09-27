import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yoga_two/loginpage/login_page.dart';
import 'package:yoga_two/models/user_profile.dart';
import 'package:yoga_two/services/profile_repository.dart';
import 'package:yoga_two/services/reminder_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileRepository _repo = ProfileRepository();
  UserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _repo.load();
    if (!mounted) return;
    setState(() {
      _profile = p;
      _loading = false;
    });
  }

  /// Ask for notification permission only when the user taps the toggle, so
  /// the OS dialog appears while the screen is plainly visible (fixing the
  /// "greyed out / can't tap" issue).
  Future<void> _enableReminder() async {
    final granted = await ReminderService.instance.requestPermission();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(granted
            ? 'Daily reminder enabled ✔'
            : 'Reminder not enabled. Notifications are blocked.'),
        backgroundColor: granted ? const Color(0xFF2D6A4F) : const Color(0xFF9D0208),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // If no user is logged in, go to the login page
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const YogaLoginPage(),
                ),
              );
            },
            child: const Text('Please login first'),
          ),
        ),
      );
    }

    final p = _profile ??
    UserProfile(uid: user.uid, email: user.email ?? '');

    return Scaffold(
      backgroundColor: const Color(0xfff3d0c3), // Same background as the rest of the app
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xff7f5539)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPersonalInfoSection(user, p),
                  const SizedBox(height: 20),

                  // Yoga Profile
                  _sectionTitle('Yoga Profile'),
                  const SizedBox(height: 8),
                  Card(
                    color: const Color(0xFFfaedcd),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _infoRow('Level', p.yogaLevel.isEmpty ? '—' : _cap(p.yogaLevel)),
                          const Divider(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Main Goals',
                              style: TextStyle(color: Colors.grey[800], fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: p.goals.isEmpty
                                  ? [const Chip(label: Text('No goals set'), backgroundColor: Color(0xFFd4a373))]
                                  : p.goals
                                      .map((g) => Chip(
                                            label: Text(_cap(g)),
                                            backgroundColor: const Color(0xFFd4a373),
                                          ))
                                      .toList(),
                            ),
                          ),
                          const Divider(height: 20),
                          // Daily reminder toggle — asks for permission on tap
                          // (not during startup) so the OS dialog stays tappable.
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Daily Reminder (24h)',
                                style: TextStyle(fontSize: 16, color: Color(0xff7f5539), fontFamily: 'Poppins'),
                              ),
                              Switch(
                                value: false,
                                activeThumbColor: const Color(0xFF2D6A4F),
                                onChanged: (_) => _enableReminder(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Progress & Statistics
                  _sectionTitle('Progress & Statistics'),
                  const SizedBox(height: 8),
                  Card(
                    color: const Color(0xFFfaedcd),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _infoRow('Total Yoga Sessions', '${p.totalSessions}'),
                          _infoRow('Daily Yoga Sessions', '${p.dailySessions}'),
                          _infoRow('Poses Completed', '${p.posesCompleted}'),
                          _infoRow('Average Pose Accuracy', '${(p.avgAccuracy * 100).toStringAsFixed(0)}%'),
                          _infoRow('Weekly Progress', '${p.weeklyProgress} sessions'),
                          _infoRow('Monthly Progress', '${p.monthlyProgress} sessions'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign Out Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        await FirebaseAuth.instance.signOut(); // Sign out the user
                        if (!nav.mounted) return;
                        nav.pushNamedAndRemoveUntil('/', (route) => false); // Go to the login gate
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF081C15), // Button color
                        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffD8F3DC),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPersonalInfoSection(User user, UserProfile p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Personal Information'),
        const SizedBox(height: 8),
        Card(
          color: const Color(0xFFfaedcd),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Picture Section
                const Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/profile_placeholder.png'),
                  ),
                ),
                const SizedBox(height: 20.0),

                // Name
                Center(
                  child: Text(
                    p.name.isEmpty ? 'Yoga Enthusiast' : p.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4332),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Email
                Center(
                  child: Text(
                    'Email: ${user.email ?? 'Not available'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1B4332),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                _infoRow('Age', p.age > 0 ? '${p.age}' : '—'),
                _infoRow('Gender', p.gender.isEmpty ? '—' : _cap(p.gender)),
                _infoRow('Date of Birth', p.dob == null ? '—' : _fmtDob(p.dob!)),
                _infoRow('Height', p.heightCm > 0 ? '${p.heightCm.toStringAsFixed(0)} cm' : '—'),
                _infoRow('Weight', p.weightKg > 0 ? '${p.weightKg.toStringAsFixed(1)} kg' : '—'),
                _infoRow('BMI', p.bmiValue > 0 ? p.bmiValue.toStringAsFixed(1) : '—'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B4332),
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Color(0xff7f5539), fontFamily: 'Poppins'),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _fmtDob(DateTime d) => '${d.day}/${d.month}/${d.year}';
}