[# pitch_detector

A Flutter plugin for **real-time pitch detection** using the device microphone (iOS and Android).  
It uses `AVAudioEngine` and `Accelerate` (iOS) or `AudioRecord` (Android) for fast and reliable frequency estimation.

---

## 🚀 Features

- 🎤 Real-time microphone input
- ⚙️ Native audio processing (AVAudioEngine on iOS, AudioRecord on Android)
- 📡 Pitch detection via FFT (iOS) or zero-crossing (Android)
- 📶 Stream interface for live frequency values
- 🔒 Works offline and privacy-friendly

> **Platform Support**: iOS ✅, Android ✅

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  pitch_detector: ^0.0.1+1
```

Then run:

```bash
flutter pub get
```

---

## ⚙️ iOS Configuration

Add this to your `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app uses the microphone to detect pitch.</string>
```

---

## ⚙️ Android Configuration

Add this permission to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

Make sure your `minSdkVersion` is **21 or higher** in `android/app/build.gradle`:

```gradle
defaultConfig {
    minSdk = 21
}
```

For Android 6.0+ you must also request runtime permission using e.g. the [permission_handler](https://pub.dev/packages/permission_handler) plugin.

---

## 💡 Usage

```dart
import 'package:pitch_detector/pitch_detector.dart';

void startListening() async {
  // Request permission if needed
  if (await Permission.microphone.request().isGranted) {
    PitchDetector.pitchStream.listen((frequency) {
      print('Detected frequency: ${frequency.toStringAsFixed(2)} Hz');
    });
  }
}

```

You can start this from a button or widget lifecycle like `initState`.

---

## 🔁 API

### `PitchDetector.pitchStream`

A broadcast stream that emits a new frequency value (as `double`) every ~100ms.

---

## 📱 Example

A simple example is available under `example/`. To run it:

```bash
cd example
flutter run
```

---

## 📋 Roadmap

- [x] iOS pitch detection via FFT
- [x] Android pitch detection via AudioRecord
- [ ] Frequency → musical note conversion
- [ ] Visual pitch indicator widget
- [ ] Replace Android zero-crossing with FFT or Yin

---

## 🧪 Known Limitations

- Android detection is basic (zero-crossing only)
- Background noise can impact accuracy
- Outputs raw frequency only (not musical notes)

---

## 📄 License

MIT License. See [LICENSE](LICENSE).

---

## 👤 Author

Developed by Felix L – feel free to contribute or open issues!

GitHub: [https://github.com/felix-ml/pitch_detector](https://github.com/felix-ml/pitch_detector)
]()