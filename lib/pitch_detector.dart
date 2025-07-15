import 'dart:async';
import 'pitch_detector_platform_interface.dart';

class IosPitchDetector {
  static Stream<double> get pitchStream =>
      IosPitchDetectorPlatform.instance.pitchStream;
}
