import 'package:flutter/material.dart';

class BMICalculatorPage extends StatefulWidget {
  const BMICalculatorPage({super.key});

  @override
  BMICalculatorPageState createState() => BMICalculatorPageState();
}

class BMICalculatorPageState extends State<BMICalculatorPage> {
  bool _isMetric = true; // unit toggle: metric (cm/kg) or imperial (in/lb)

  // Canonical metric values — always stored in cm / kg regardless of input unit.
  double _height = 160; // cm
  double _weight = 60; // kg
  int _age = 20;
  bool _isMale = true;

  // Display values for the active unit system.
  double get _displayHeight => _isMetric ? _height : _height / 2.54; // cm -> in
  double get _displayWeight => _isMetric ? _weight : _weight * 2.20462; // kg -> lb
  String get _heightUnit => _isMetric ? 'cm' : 'in';
  String get _weightUnit => _isMetric ? 'kg' : 'lb';

  // Slider bounds per unit system (weight is text-entry only).
  double get _heightMin => _isMetric ? 100.0 : 40.0; // cm / in
  double get _heightMax => _isMetric ? 220.0 : 86.0;

  void _toggleUnit(bool metric) {
    setState(() {
      _isMetric = metric;
    });
  }

  /// Converts the active-unit display inputs back to canonical metric,
  /// then computes BMI = weight(kg) / (height(m))^2.
  void _calculateBMI() {
    final effectiveHeightBoard = _height; // locked in metric already
    double heightInMeters = effectiveHeightBoard / 100;
    double bmi = _weight / (heightInMeters * heightInMeters);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BMIResultPage(bmi: bmi),
      ),
    );
  }

  void _onHeightChanged(double value) {
    // value is in the active unit system; convert to canonical cm.
    setState(() => _height = _isMetric ? value : value * 2.54);
  }

  void _onHeightText(String text) {
    double? value = double.tryParse(text);
    if (value == null) return;
    if (_isMetric && value >= 100 && value <= 220) {
      setState(() => _height = value);
    } else if (!_isMetric && value >= 40 && value <= 86) {
      setState(() => _height = value * 2.54);
    }
  }

  void _onWeightChanged(String text) {
    double? value = double.tryParse(text);
    if (value == null) return;
    setState(() => _weight = _isMetric ? value : value / 2.20462);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffefae0),
      appBar: AppBar(
        title: const Text(
          'BMI Calculator',
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Unit toggle: Metric / Imperial
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Metric (cm/kg)')),
                    ButtonSegment(value: false, label: Text('Imperial (in/lb)')),
                  ],
                  selected: {_isMetric},
                  onSelectionChanged: (sel) => _toggleUnit(sel.first),
                  style: SegmentedButton.styleFrom(
                    foregroundColor: const Color(0xff1B4332),
                    backgroundColor: const Color(0xFFfaedcd),
                    selectedForegroundColor: const Color(0xffD8F3DC),
                    selectedBackgroundColor: const Color(0xFF2D6A4F),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGenderCard('Male', Icons.male, _isMale, () {
                      setState(() => _isMale = true);
                    }),
                    _buildGenderCard('Female', Icons.female, !_isMale, () {
                      setState(() => _isMale = false);
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                _buildEditableSliderCard(
                  'Height',
                  '${_displayHeight.toStringAsFixed(1)} $_heightUnit',
                  _displayHeight,
                  _heightMin,
                  _heightMax,
                  _onHeightChanged,
                  _onHeightText,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildEditableValueCard(
                        'Weight',
                        '${_displayWeight.toStringAsFixed(1)} $_weightUnit',
                        _onWeightChanged),
                    _buildEditableValueCard('Age', '$_age', (value) {
                      setState(() => _age = int.tryParse(value) ?? _age);
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _calculateBMI,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7f5539),
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'CALCULATE',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Color(0xffD8F3DC)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard(
      String gender, IconData icon, bool isSelected, Function onPressed) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Card(
        color: isSelected ? const Color(0xFFd4a373) : const Color(0xFFfaedcd),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: 100,
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: const Color(0xffffffff)),
              const SizedBox(height: 10),
              Text(gender, style: const TextStyle(color: Color(0xffffffff))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableSliderCard(String label, String value, double sliderValue,
      double min, double max, Function(double) onChanged, Function(String) onTextChanged) {
    return Card(
      color: const Color(0xFFd4a373),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins')),
            Slider(
              value: sliderValue,
              min: min,
              max: max,
              activeColor: const Color(0xfff3d0c3),
              inactiveColor: const Color.fromARGB(255, 44, 63, 45),
              onChanged: onChanged,
            ),
            SizedBox(
              width: 100,
              child: TextFormField(
                initialValue: value,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'),
                onChanged: onTextChanged,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableValueCard(
      String label, String value, Function(String) onChanged) {
    return Card(
      color: const Color(0xFFd4a373),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 10),
            SizedBox(
              width: 80,
              child: TextFormField(
                initialValue: value,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat'),
                onChanged: onChanged,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BMIResultPage extends StatelessWidget {
  final double bmi;

  const BMIResultPage({super.key, required this.bmi});

  @override
  Widget build(BuildContext context) {
    String result;
    String message;
    Color resultColor;

    if (bmi < 18.5) {
      result = 'UNDERWEIGHT';
      message = 'You need to gain some weight.';
      resultColor = const Color.fromARGB(255, 1, 127, 230);
    } else if (bmi < 24.9) {
      result = 'NORMAL';
      message = 'You have a normal body weight. Good job!';
      resultColor = const Color.fromARGB(255, 12, 88, 14);
    } else if (bmi < 29.9) {
      result = 'OVERWEIGHT';
      message = 'Consider exercising more.';
      resultColor = const Color.fromARGB(255, 208, 125, 0);
    } else {
      result = 'OBESE';
      message = 'Seek advice from a healthcare provider.';
      resultColor = const Color.fromARGB(255, 247, 16, 0);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFfaedcd),
      appBar: AppBar(
        title: const Text(
          'BMI Calculator',
          style: TextStyle(
            color: Color(0xFFd4a373),
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFfaedcd),
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Color(0xFF1B4332)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Your Result',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFd4a373)),
                ),
                const SizedBox(height: 20),
                Card(
                  color: const Color(0xFFd4a373),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          result,
                          style: TextStyle(
                              color: resultColor,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins'),
                        ),
                        Text(
                          bmi.toStringAsFixed(1),
                          style: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat'),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 24),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7f5539),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'RE-CALCULATE',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
