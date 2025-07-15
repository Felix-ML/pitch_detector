import 'dart:async';
import 'package:flutter/services.dart';
import 'pitch_detector_platform_interface.dart';

class MethodChannelIosPitchDetector extends IosPitchDetectorPlatform {
  static const EventChannel _pitchEventChannel = EventChannel('pitch_stream');

  @override
  Stream<double> get pitchStream =>
      _pitchEventChannel.receiveBroadcastStream().map((e) => e as double);
}
