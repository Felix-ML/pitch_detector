import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pitch_detector/pitch_detector.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('pitch stream emits values', (WidgetTester tester) async {
    final stream = IosPitchDetector.pitchStream;

    // Listen for the first event from the stream and complete the test
    final frequency = await stream.first;

    // Test that a frequency value is received and is a valid number
    expect(frequency, isA<double>());
    expect(frequency > 0, true);
  });
}
