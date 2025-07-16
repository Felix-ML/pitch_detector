package de.felixml.flutter_detect_pitch

import android.media.AudioFormat
import aflucndroid.media.AudioRecord
import android.media.MediaRecorder
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlin.concurrent.thread

class FlutterDetectPitchPlugin : EventChannel.StreamHandler {

  private var recorder: AudioRecord? = null
  private var recordingThread: Thread? = null
  private var isRecording = false
  private var eventSink: EventChannel.EventSink? = null

  companion object {
    private const val SAMPLE_RATE = 44100
    private const val CHANNEL_CONFIG = AudioFormat.CHANNEL_IN_MONO
    private const val AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT
    private const val BUFFER_SIZE = 2048

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val eventChannel = EventChannel(registrar.messenger(), "pitch_stream")
      val instance = FlutterDetectPitchPlugin()
      eventChannel.setStreamHandler(instance)
    }
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    this.eventSink = events
    startRecording()
  }

  override fun onCancel(arguments: Any?) {
    stopRecording()
  }

  private fun startRecording() {
    recorder = AudioRecord(
      MediaRecorder.AudioSource.MIC,
      SAMPLE_RATE,
      CHANNEL_CONFIG,
      AUDIO_FORMAT,
      BUFFER_SIZE * 2
    )

    recorder?.startRecording()
    isRecording = true

    recordingThread = thread(start = true) {
      val buffer = ShortArray(BUFFER_SIZE)
      while (isRecording) {
        val read = recorder?.read(buffer, 0, BUFFER_SIZE) ?: 0
        if (read > 0) {
          val frequency = detectFrequency(buffer, read)
          if (frequency > 0) {
            eventSink?.success(frequency)
          }
        }
      }
    }
  }

  private fun stopRecording() {
    isRecording = false
    recorder?.stop()
    recorder?.release()
    recorder = null
    recordingThread = null
  }

  private fun detectFrequency(buffer: ShortArray, read: Int): Float {
    // Simple zero-crossing detection (demo only)
    var numCrossings = 0
    for (i in 1 until read) {
      if ((buffer[i - 1] > 0 && buffer[i] <= 0) || (buffer[i - 1] < 0 && buffer[i] >= 0)) {
        numCrossings++
      }
    }

    val durationInSeconds = read.toFloat() / SAMPLE_RATE
    return if (durationInSeconds > 0) {
      (numCrossings / 2f) / durationInSeconds
    } else {
      0f
    }
  }
}