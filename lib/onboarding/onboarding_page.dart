import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yoga_two/loginpage/auth_page.dart';
import 'package:yoga_two/models/user_profile.dart';
import 'package:yoga_two/services/profile_repository.dart';

/// Multi-step onboarding shown on the first app open, before login.
/// Collects personal details, body metrics (with a metric/imperial toggle and
/// live BMI), and yoga goals. Saves locally; a later account creation uploads
/// the same data to Firestore under the user's UID.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final ProfileRepository _repo = ProfileRepository();

  final PageController _pageController = PageController();
  int _step = 0;

  // Step 2 text controllers (height/weight typed input)
  final TextEditingController _heightController =
      TextEditingController(text: '160');
  final TextEditingController _weightController =
      TextEditingController(text: '60');

  // Step 1 — basics
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _gender = 'female';
  DateTime? _dob;

  // Step 2 — body
  bool _isMetric = true;
  double _heightCm = 160;
  double _weightKg = 60;

  // Step 3 — yoga
  String _yogaLevel = 'beginner';
  final Set<String> _goals = {
    'flexibility',
    'strength',
    'weight management',
    'stress relief',
  };
  final List<String> _allGoals = [
    'flexibility',
    'strength',
    'weight management',
    'stress relief',
  ];

  final List<String> _levels = ['beginner', 'intermediate', 'advanced'];

  bool get _canContinue =>
      _step != 0 || (_nameController.text.trim().isNotEmpty && _ageController.text.isNotEmpty);

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  double get _bmi {
    if (_heightCm <= 0) return 0;
    final m = _heightCm / 100;
    return _weightKg / (m * m);
  }

  // Display conversions for step 2
  double get _displayHeight => _isMetric ? _heightCm : _heightCm / 2.54;
  double get _displayWeight => _isMetric ? _weightKg : _weightKg * 2.20462;
  String get _heightUnit => _isMetric ? 'cm' : 'in';
  String get _weightUnit => _isMetric ? 'kg' : 'lb';
  double get _heightMin => _isMetric ? 100 : 40;
  double get _heightMax => _isMetric ? 220 : 86;
  double get _weightMin => _isMetric ? 30 : 66;
  double get _weightMax => _isMetric ? 200 : 440;

  void _onHeight(double value) {
    setState(() => _heightCm = _isMetric ? value : value * 2.54);
    _heightController.text = _displayHeight.toStringAsFixed(1);
  }

  void _onWeight(double value) {
    setState(() => _weightKg = _isMetric ? value : value / 2.20462);
    _weightController.text = _displayWeight.toStringAsFixed(1);
  }

  void _onHeightText(String text) {
    final v = double.tryParse(text);
    if (v == null || v <= 0) return;
    setState(() => _heightCm = _isMetric ? v : v * 2.54);
  }

  void _onWeightText(String text) {
    final v = double.tryParse(text);
    if (v == null || v <= 0) return;
    setState(() => _weightKg = _isMetric ? v : v / 2.20462);
  }

  Future<void> _finish() async {
    final profile = UserProfile(
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text) ?? 0,
      gender: _gender,
      heightCm: _heightCm,
      weightKg: _weightKg,
      dob: _dob,
      yogaLevel: _yogaLevel,
      goals: _goals.toList(),
    );
    await _repo.saveLocal(profile);
    await _repo.markOnboarded();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffefae0),
      appBar: AppBar(
        title: const Text(
          'Welcome',
          style: TextStyle(
            color: Color(0xFF1B4332),
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xfffefae0),
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Color(0xFF1B4332)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: List.generate(
                  4,
                  (i) => Expanded(
                    child: Container(
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i <= _step
                            ? const Color(0xFF2D6A4F)
                            : const Color(0xFFd4a373),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _step = i),
                children: [
                  _buildBasicsStep(),
                  _buildBodyStep(),
                  _buildYogaStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
            // Bottom nav
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_step > 0)
                    TextButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: _step < 3 ? (_canContinue ? () => _next() : null) : _finish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff7f5539),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      _step < 3 ? 'Next' : 'Finish',
                      style: const TextStyle(
                        color: Color(0xffD8F3DC),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ---------- Step 1: basics ----------
  Widget _buildBasicsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tell us about yourself',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          const Text('These details personalize your yoga experience.',
              style: TextStyle(fontSize: 14, color: Color(0xff7f5539))),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: _inputDeco('Full Name'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _inputDeco('Age'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          const Text('Gender', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['male', 'female', 'other'].map((g) {
              return ChoiceChip(
                label: Text(g[0].toUpperCase() + g.substring(1)),
                selected: _gender == g,
                onSelected: (_) => setState(() => _gender = g),
                selectedColor: const Color(0xFF2D6A4F),
                labelStyle: TextStyle(color: _gender == g ? Colors.white : Colors.black),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          const Text('Date of Birth (optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final pick = await showDatePicker(
                context: context,
                initialDate: _dob ?? DateTime(2000),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (pick != null) setState(() => _dob = pick);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFfaedcd),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dob == null
                        ? 'Select date'
                        : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.calendar_today, color: Color(0xff7f5539)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Step 2: body metrics ----------
  Widget _buildBodyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your body metrics',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          const Text('Used to estimate calories and BMI.',
              style: TextStyle(fontSize: 14, color: Color(0xff7f5539))),
          const SizedBox(height: 20),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Metric')),
              ButtonSegment(value: false, label: Text('Imperial')),
            ],
            selected: {_isMetric},
            onSelectionChanged: (sel) {
              setState(() => _isMetric = sel.first);
              // Re-sync the typed values to the new unit (160 cm ⇄ 63.0 in).
              _heightController.text = _displayHeight.toStringAsFixed(1);
              _weightController.text = _displayWeight.toStringAsFixed(1);
            },
            style: SegmentedButton.styleFrom(
              foregroundColor: const Color(0xff1B4332),
              backgroundColor: const Color(0xFFfaedcd),
              selectedForegroundColor: const Color(0xffD8F3DC),
              selectedBackgroundColor: const Color(0xFF2D6A4F),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Height (${_heightUnit.toUpperCase()})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              // Text input for precise entry
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _heightController,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  onChanged: _onHeightText,
                  decoration: InputDecoration(
                    isDense: true,
                    suffixText: _heightUnit,
                    filled: true,
                    fillColor: const Color(0xFFfaedcd),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _displayHeight.clamp(_heightMin, _heightMax),
            min: _heightMin,
            max: _heightMax,
            divisions: _isMetric ? 240 : 92,
            activeColor: const Color(0xFF2D6A4F),
            inactiveColor: const Color(0xffd4a373),
            label: '${_displayHeight.toStringAsFixed(1)} $_heightUnit',
            onChanged: _onHeight,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weight (${_weightUnit.toUpperCase()})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _weightController,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  onChanged: _onWeightText,
                  decoration: InputDecoration(
                    isDense: true,
                    suffixText: _weightUnit,
                    filled: true,
                    fillColor: const Color(0xFFfaedcd),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _displayWeight.clamp(_weightMin, _weightMax),
            min: _weightMin,
            max: _weightMax,
            divisions: _isMetric ? 200 : 92,
            activeColor: const Color(0xFF2D6A4F),
            inactiveColor: const Color(0xffd4a373),
            label: '${_displayWeight.toStringAsFixed(1)} $_weightUnit',
            onChanged: _onWeight,
          ),
          const SizedBox(height: 20),
          Card(
            color: const Color(0xFFd4a373),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Estimated BMI',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    _bmi.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(bmiCategory(_bmi),
                      style: const TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Step 3: yoga profile ----------
  Widget _buildYogaStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your yoga profile',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          const Text('Pick your level and what you want to achieve.',
              style: TextStyle(fontSize: 14, color: Color(0xff7f5539))),
          const SizedBox(height: 20),
          const Text('Yoga Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _levels.map((l) {
              final cap = l[0].toUpperCase() + l.substring(1);
              return ChoiceChip(
                label: Text(cap),
                selected: _yogaLevel == l,
                onSelected: (_) => setState(() => _yogaLevel = l),
                selectedColor: const Color(0xFF2D6A4F),
                labelStyle: TextStyle(color: _yogaLevel == l ? Colors.white : Colors.black),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Main Goals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allGoals.map((g) {
              final selected = _goals.contains(g);
              final cap = g.split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
              return FilterChip(
                label: Text(cap),
                selected: selected,
                onSelected: (v) => setState(() {
                  if (v) {
                    _goals.add(g);
                  } else {
                    _goals.remove(g);
                  }
                }),
                selectedColor: const Color(0xFF2D6A4F),
                labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ---------- Step 4: review ----------
  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Review your details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const SizedBox(height: 20),
          _reviewTile('Name', _nameController.text.trim().isEmpty ? '—' : _nameController.text.trim()),
          _reviewTile('Age', _ageController.text),
          _reviewTile('Gender', _gender[0].toUpperCase() + _gender.substring(1)),
          _reviewTile('DOB', _dob == null ? '—' : '${_dob!.day}/${_dob!.month}/${_dob!.year}'),
          _reviewTile('Height', '${_heightCm.toStringAsFixed(0)} cm'),
          _reviewTile('Weight', '${_weightKg.toStringAsFixed(0)} kg'),
          _reviewTile('BMI', '${_bmi.toStringAsFixed(1)} (${bmiCategory(_bmi)})'),
          _reviewTile('Yoga Level', _yogaLevel[0].toUpperCase() + _yogaLevel.substring(1)),
          _reviewTile(
            'Goals',
            _goals.isEmpty ? '—' : _goals.map((g) => g.split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')).join(', '),
          ),
        ],
      ),
    );
  }

  Widget _reviewTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Color(0xff7f5539))),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFfaedcd),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}

String bmiCategory(double bmi) {
  if (bmi < 18.5) return 'Underweight';
  if (bmi < 24.9) return 'Normal';
  if (bmi < 29.9) return 'Overweight';
  return 'Obese';
}