import 'package:flutter/material.dart';
import 'package:yoga_two/models/user_profile.dart';
import 'package:yoga_two/services/profile_repository.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _dobController;
  
  String? _selectedGender;
  String? _selectedLevel;
  List<String> _selectedGoals = [];
  
  bool _saving = false;
  final ProfileRepository _repo = ProfileRepository();

  final List<String> _genderOptions = ['male', 'female', 'other'];
  final List<String> _levelOptions = ['beginner', 'intermediate', 'advanced'];
  final List<String> _goalOptions = ['flexibility', 'strength', 'weight management', 'stress relief', 'endurance'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _ageController = TextEditingController(text: widget.profile.age > 0 ? '${widget.profile.age}' : '');
    _heightController = TextEditingController(text: widget.profile.heightCm > 0 ? '${widget.profile.heightCm.toStringAsFixed(0)}' : '');
    _weightController = TextEditingController(text: widget.profile.weightKg > 0 ? '${widget.profile.weightKg.toStringAsFixed(1)}' : '');
    _dobController = TextEditingController(text: widget.profile.dob != null ? '${widget.profile.dob!.day}/${widget.profile.dob!.month}/${widget.profile.dob!.year}' : '');
    
    _selectedGender = widget.profile.gender.isNotEmpty ? widget.profile.gender : null;
    _selectedLevel = widget.profile.yogaLevel.isNotEmpty ? widget.profile.yogaLevel : null;
    _selectedGoals = List.from(widget.profile.goals);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _savProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final age = int.tryParse(_ageController.text) ?? 0;
      final height = double.tryParse(_heightController.text) ?? 0;
      final weight = double.tryParse(_weightController.text) ?? 0;
      
      DateTime? dob;
      if (_dobController.text.isNotEmpty) {
        final parts = _dobController.text.split('/');
        if (parts.length == 3) {
          try {
            dob = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          } catch (_) {}
        }
      }

      final updated = widget.profile.copyWith(
        name: _nameController.text,
        age: age,
        heightCm: height,
        weightKg: weight,
        dob: dob,
        gender: _selectedGender ?? '',
        yogaLevel: _selectedLevel ?? '',
        goals: _selectedGoals,
      );

      await _repo.save(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFF2D6A4F),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.profile.dob ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3d0c3),
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF1B4332),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xfff3d0c3),
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Color(0xFF1B4332)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Information Section
            _buildSectionTitle('Personal Information'),
            const SizedBox(height: 12),
            _buildCard([
              _buildTextField('Name', _nameController, TextInputType.text),
              _buildDivider(),
              _buildTextField('Age', _ageController, TextInputType.number),
              _buildDivider(),
              _buildDateField('Date of Birth', _dobController),
              _buildDivider(),
              _buildDropdown('Gender', _selectedGender, _genderOptions, (value) {
                setState(() => _selectedGender = value);
              }),
            ]),

            const SizedBox(height: 24),

            // Physical Measurements Section
            _buildSectionTitle('Physical Measurements'),
            const SizedBox(height: 12),
            _buildCard([
              _buildTextField('Height (cm)', _heightController, TextInputType.number),
              _buildDivider(),
              _buildTextField('Weight (kg)', _weightController, TextInputType.numberWithOptions(decimal: true)),
            ]),

            const SizedBox(height: 24),

            // Yoga Profile Section
            _buildSectionTitle('Yoga Profile'),
            const SizedBox(height: 12),
            _buildCard([
              _buildDropdown('Experience Level', _selectedLevel, _levelOptions, (value) {
                setState(() => _selectedLevel = value);
              }),
              _buildDivider(),
              _buildGoalsSelector(),
            ]),

            const SizedBox(height: 32),

            // Save & Cancel Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : () => Navigator.pop(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B4332),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _savProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D6A4F),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B4332),
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      color: Colors.white.withValues(alpha: 0.95),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          style: const TextStyle(fontFamily: 'Poppins'),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFd4a373)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFd4a373), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: _selectDate,
          style: const TextStyle(fontFamily: 'Poppins'),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFFd4a373), size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFd4a373)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFd4a373), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            onChanged: onChanged,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        _cap(item),
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Main Goals',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _goalOptions
              .map((goal) => FilterChip(
                    label: Text(
                      _cap(goal),
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
                    ),
                    selected: _selectedGoals.contains(goal),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedGoals.add(goal);
                        } else {
                          _selectedGoals.remove(goal);
                        }
                      });
                    },
                    backgroundColor: Colors.transparent,
                    selectedColor: const Color(0xFFd4a373).withValues(alpha: 0.3),
                    side: BorderSide(
                      color: _selectedGoals.contains(goal) ? const Color(0xFFd4a373) : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: Colors.grey[300]),
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
