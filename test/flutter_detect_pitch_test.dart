import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_detect_pitch/flutter_detect_pitch.dart';
import 'package:flutter_detect_pitch/flutter_detect_pitch_method_channel.dart';
import 'package:flutter_detect_pitch/flutter_detect_pitch_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockIosPitchDetectorPlatform
    with MockPlatformInterfaceMixin
    implements IosPitchDetectorPlatform {
  @override
  Stream<double> get pitchStream => Stream.value(440.0);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MethodChannelIosPitchDetector platform =
      MethodChannelIosPitchDetector();
  const MethodChannel methodChannel = MethodChannel('pitch_stream');

  group('Platform interface tests', () {
    test('plugin loads', () {
      final plugin = IosPitchDetector();
      expect(plugin, isNotNull);
    });

    test('mock pitch stream returns value', () async {
      IosPitchDetectorPlatform.instance = MockIosPitchDetectorPlatform();
      final frequency = await IosPitchDetector.pitchStream.first;
      expect(frequency, equals(440.0));
    });
  });

  group('MethodChannel tests', () {
    test('pitchStream is a Stream<double>', () {
      final stream = platform.pitchStream;
      expect(stream, isA<Stream<double>>());
    });

    test('pitchStream can be subscribed without exception', () {
      expect(() {
        platform.pitchStream.listen((_) {});
      }, returnsNormally);
    });

    test('method channel call returns expected mock result', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (call) async {
            if (call.method == 'start') return true;
            return null;
          });

      final result = await methodChannel.invokeMethod('start');
      expect(result, isTrue);

      // Clean up
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, null);
    });
  });
}
