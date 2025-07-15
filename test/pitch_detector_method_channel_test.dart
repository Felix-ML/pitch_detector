import 'package:flutter_test/flutter_test.dart';
import 'package:pitch_detector/pitch_detector_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelIosPitchDetector platform = MethodChannelIosPitchDetector();

  test('stream can be initialized', () async {
    // Just test that the stream can be subscribed without throwing
    final stream = platform.pitchStream;
    expect(stream, isA<Stream<double>>());
  });
}
