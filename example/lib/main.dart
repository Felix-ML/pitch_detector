import 'package:flutter/material.dart';
import 'package:pitch_detector/pitch_detector.dart';

void main() => runApp(const PitchTestApp());

class PitchTestApp extends StatelessWidget {
  const PitchTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: PitchHomePage());
  }
}

class PitchHomePage extends StatefulWidget {
  const PitchHomePage({super.key});

  @override
  PitchHomePageState createState() => PitchHomePageState();
}

class PitchHomePageState extends State<PitchHomePage> {
  double? _frequency;

  @override
  void initState() {
    super.initState();
    IosPitchDetector.pitchStream.listen((frequency) {
      setState(() {
        _frequency = frequency;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pitch Detector Example')),
      body: Center(
        child: Text(
          _frequency != null
              ? 'Detected: ${_frequency!.toStringAsFixed(2)} Hz'
              : 'Listening...',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
