
import Flutter
import UIKit
import AVFoundation
import Accelerate

public class IosPitchDetectorPlugin: NSObject, FlutterPlugin {
  private var audioEngine: AVAudioEngine?
  private var inputNode: AVAudioInputNode?
  private var bufferSize: AVAudioFrameCount = 1024
  private var sampleRate: Double = 44100.0
  private var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let eventChannel = FlutterEventChannel(name: "pitch_stream", binaryMessenger: registrar.messenger())
    let instance = IosPitchDetectorPlugin()
    eventChannel.setStreamHandler(instance)
  }
}

extension IosPitchDetectorPlugin: FlutterStreamHandler {
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    startAudioEngine()
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    stopAudioEngine()
    return nil
  }
}

extension IosPitchDetectorPlugin {
  private func startAudioEngine() {
    audioEngine = AVAudioEngine()
    inputNode = audioEngine?.inputNode

    let inputFormat = inputNode!.inputFormat(forBus: 0)
    sampleRate = inputFormat.sampleRate

    inputNode?.installTap(onBus: 0, bufferSize: bufferSize, format: inputFormat) { [weak self] (buffer, time) in
      guard let channelData = buffer.floatChannelData?[0] else { return }
      let frameLength = Int(buffer.frameLength)
      let signal = Array(UnsafeBufferPointer(start: channelData, count: frameLength))
      if let frequency = self?.detectPitch(signal: signal, sampleRate: self?.sampleRate ?? 44100.0) {
        DispatchQueue.main.async {
          self?.eventSink?(frequency)
        }
      }
    }

    try? audioEngine?.start()
  }

  private func stopAudioEngine() {
    inputNode?.removeTap(onBus: 0)
    audioEngine?.stop()
    audioEngine = nil
  }

  private func detectPitch(signal: [Float], sampleRate: Double) -> Float? {
    var window = [Float](repeating: 0.0, count: signal.count)
    vDSP_hann_window(&window, vDSP_Length(signal.count), Int32(vDSP_HANN_NORM))
    var windowedSignal = [Float](repeating: 0.0, count: signal.count)
    vDSP_vmul(signal, 1, window, 1, &windowedSignal, 1, vDSP_Length(signal.count))

    let log2n = UInt(round(log2(Float(signal.count))))
    let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))

    var realp = [Float](repeating: 0.0, count: signal.count/2)
    var imagp = [Float](repeating: 0.0, count: signal.count/2)
    var output = DSPSplitComplex(realp: &realp, imagp: &imagp)

    windowedSignal.withUnsafeBufferPointer { pointer in
      pointer.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: signal.count) { typeConvertedTransferBuffer in
        vDSP_ctoz(typeConvertedTransferBuffer, 2, &output, 1, vDSP_Length(signal.count / 2))
      }
    }

    vDSP_fft_zrip(fftSetup!, &output, 1, log2n, Int32(FFT_FORWARD))

    var magnitudes = [Float](repeating: 0.0, count: signal.count / 2)
    vDSP_zvmags(&output, 1, &magnitudes, 1, vDSP_Length(signal.count / 2))

    var maxMag: Float = 0.0
    var maxIndex: vDSP_Length = 0
    vDSP_maxvi(magnitudes, 1, &maxMag, &maxIndex, vDSP_Length(magnitudes.count))

    vDSP_destroy_fftsetup(fftSetup)

    let frequency = Float(maxIndex) * Float(sampleRate) / Float(signal.count)
    return frequency
  }
}
