import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/daily_tip_card.dart';

class DailyTipSection extends StatefulWidget {
  const DailyTipSection({super.key});

  @override
  DailyTipSectionState createState() => DailyTipSectionState();
}

class DailyTipSectionState extends State<DailyTipSection> {
  final List<Map<String, String>> dailyTips = [
    {'title': 'Stay Hydrated', 'description': 'Drinking water improves flexibility.'},
    {'title': 'Proper Breathing', 'description': 'Focus on your breathing for relaxation.'},
    {'title': 'Focus on Posture', 'description': 'Good posture maximizes yoga benefits.'},
  ];

  int currentTipIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        currentTipIndex = (currentTipIndex + 1) % dailyTips.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DailyTipCard(
      title: dailyTips[currentTipIndex]['title']!,
      description: dailyTips[currentTipIndex]['description']!,
    );
  }
}
