import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pitch_detector_method_channel.dart';

abstract class IosPitchDetectorPlatform extends PlatformInterface {
  IosPitchDetectorPlatform() : super(token: _token);
  static final Object _token = Object();

  static IosPitchDetectorPlatform _instance = MethodChannelIosPitchDetector();
  static IosPitchDetectorPlatform get instance => _instance;

  static set instance(IosPitchDetectorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<double> get pitchStream {
    throw UnimplementedError('pitchStream has not been implemented.');
  }
}
