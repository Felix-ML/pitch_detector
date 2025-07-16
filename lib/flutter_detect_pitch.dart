import 'dart:async';

import 'flutter_detect_pitch_interface.dart';

class IosPitchDetector {
  static Stream<double> get pitchStream =>
      IosPitchDetectorPlatform.instance.pitchStream;
}
