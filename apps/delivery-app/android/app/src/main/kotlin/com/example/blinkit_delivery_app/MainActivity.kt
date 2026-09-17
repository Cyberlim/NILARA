package com.example.blinkit_delivery_app

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import android.media.ToneGenerator
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread
import kotlin.math.PI
import kotlin.math.sin

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.nilara.delivery/audio"
    private var activeTrack: AudioTrack? = null
    private var activeToneGen: ToneGenerator? = null
    @Volatile
    private var isPlaying = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playTone" -> {
                    val name = call.argument<String>("name") ?: "Loud Ring"
                    val volume = (call.argument<Double>("volume") ?: 85.0).toFloat()
                    playSynthesizedTone(name, volume)
                    result.success(true)
                }
                "stopTone" -> {
                    stopActiveTone()
                    result.success(true)
                }
                "vibrate" -> {
                    val durationMs = (call.argument<Int>("durationMs") ?: 400).toLong()
                    doVibrate(durationMs)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun stopActiveTone() {
        isPlaying = false
        try {
            activeToneGen?.stopTone()
            activeToneGen?.release()
        } catch (_: Exception) {}
        activeToneGen = null

        try {
            activeTrack?.let {
                if (it.playState == AudioTrack.PLAYSTATE_PLAYING) {
                    it.stop()
                }
                it.release()
            }
        } catch (_: Exception) {}
        activeTrack = null
    }

    private fun playSynthesizedTone(toneName: String, volumePercent: Float) {
        stopActiveTone()
        isPlaying = true

        thread(start = true) {
            try {
                val sampleRate = 44100
                val volume = (volumePercent.coerceIn(5f, 100f) / 100f)

                val buffer: ShortArray = when (toneName) {
                    "Melodic Chime" -> generateMelodicChime(sampleRate, volume)
                    "Urgent Siren" -> generateUrgentSiren(sampleRate, volume)
                    "Beep Pulse" -> generateBeepPulse(sampleRate, volume)
                    else -> generateLoudRing(sampleRate, volume)
                }

                if (!isPlaying) return@thread

                val track = AudioTrack.Builder()
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_ALARM)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                    .setAudioFormat(
                        AudioFormat.Builder()
                            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                            .setSampleRate(sampleRate)
                            .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                            .build()
                    )
                    .setBufferSizeInBytes(buffer.size * 2)
                    .setTransferMode(AudioTrack.MODE_STATIC)
                    .build()

                track.setVolume(AudioTrack.getMaxVolume())
                track.write(buffer, 0, buffer.size)

                activeTrack = track
                if (isPlaying) {
                    track.play()
                } else {
                    track.release()
                }
            } catch (e: Exception) {
                // Fallback to ToneGenerator if AudioTrack has any issue
                playFallbackToneGenerator(toneName, volumePercent)
            }
        }
    }

    private fun generateLoudRing(sampleRate: Int, volume: Float): ShortArray {
        val durationSec = 2.5
        val totalSamples = (sampleRate * durationSec).toInt()
        val buffer = ShortArray(totalSamples)

        // Dual frequencies 440 Hz + 480 Hz (US standard acoustic ring cadence)
        // Pulsing: 0.8s on, 0.4s off, 0.8s on, 0.5s off
        for (i in 0 until totalSamples) {
            val t = i.toDouble() / sampleRate
            val isRingPhase = (t in 0.0..0.8) || (t in 1.2..2.0)
            if (isRingPhase) {
                val s1 = sin(2.0 * PI * 440.0 * t)
                val s2 = sin(2.0 * PI * 480.0 * t)
                val mixed = ((s1 + s2) * 0.5 * volume * Short.MAX_VALUE).toInt()
                buffer[i] = mixed.coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt()).toShort()
            } else {
                buffer[i] = 0
            }
        }
        return buffer
    }

    private fun generateMelodicChime(sampleRate: Int, volume: Float): ShortArray {
        // C5 (523.25Hz), E5 (659.25Hz), G5 (783.99Hz)
        val durationSec = 2.2
        val totalSamples = (sampleRate * durationSec).toInt()
        val buffer = ShortArray(totalSamples)
        val notes = doubleArrayOf(523.25, 659.25, 783.99)
        val noteStarts = doubleArrayOf(0.0, 0.22, 0.44)

        for (i in 0 until totalSamples) {
            val t = i.toDouble() / sampleRate
            var sample = 0.0
            for (n in notes.indices) {
                val start = noteStarts[n]
                if (t >= start) {
                    val noteTime = t - start
                    val decay = Math.exp(-noteTime * 2.2)
                    sample += sin(2.0 * PI * notes[n] * noteTime) * decay * 0.5
                }
            }
            val mixed = (sample * volume * Short.MAX_VALUE).toInt()
            buffer[i] = mixed.coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt()).toShort()
        }
        return buffer
    }

    private fun generateUrgentSiren(sampleRate: Int, volume: Float): ShortArray {
        // Alternating pitch sweep 700Hz to 1300Hz
        val durationSec = 2.4
        val totalSamples = (sampleRate * durationSec).toInt()
        val buffer = ShortArray(totalSamples)
        var phase = 0.0

        for (i in 0 until totalSamples) {
            val t = i.toDouble() / sampleRate
            val modulation = (sin(2.0 * PI * 2.0 * t) + 1.0) * 0.5
            val currentFreq = 700.0 + (600.0 * modulation)

            phase += 2.0 * PI * currentFreq / sampleRate
            val sample = sin(phase) * volume * Short.MAX_VALUE
            buffer[i] = sample.toInt().coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt()).toShort()
        }
        return buffer
    }

    private fun generateBeepPulse(sampleRate: Int, volume: Float): ShortArray {
        // 4 rapid digital beeps (950Hz), 150ms on, 150ms off
        val durationSec = 2.0
        val totalSamples = (sampleRate * durationSec).toInt()
        val buffer = ShortArray(totalSamples)

        for (i in 0 until totalSamples) {
            val t = i.toDouble() / sampleRate
            val cycle = t % 0.30
            val isBeep = cycle < 0.15 && t < 1.2
            if (isBeep) {
                val sample = sin(2.0 * PI * 950.0 * t) * volume * Short.MAX_VALUE
                buffer[i] = sample.toInt().coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt()).toShort()
            } else {
                buffer[i] = 0
            }
        }
        return buffer
    }

    private fun playFallbackToneGenerator(toneName: String, volumePercent: Float) {
        try {
            val streamVolume = (volumePercent.coerceIn(10f, 100f)).toInt()
            val tg = ToneGenerator(AudioManager.STREAM_ALARM, streamVolume)
            activeToneGen = tg
            val toneType = when (toneName) {
                "Melodic Chime" -> ToneGenerator.TONE_PROP_PROMPT
                "Urgent Siren" -> ToneGenerator.TONE_CDMA_EMERGENCY_RINGBACK
                "Beep Pulse" -> ToneGenerator.TONE_PROP_BEEP
                else -> ToneGenerator.TONE_CDMA_ALERT_NETWORK_LITE
            }
            tg.startTone(toneType, 2000)
        } catch (_: Exception) {}
    }

    private fun doVibrate(durationMs: Long) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
                vibratorManager?.defaultVibrator?.vibrate(
                    VibrationEffect.createOneShot(durationMs, VibrationEffect.DEFAULT_AMPLITUDE)
                )
            } else {
                @Suppress("DEPRECATION")
                val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    vibrator?.vibrate(VibrationEffect.createOneShot(durationMs, VibrationEffect.DEFAULT_AMPLITUDE))
                } else {
                    @Suppress("DEPRECATION")
                    vibrator?.vibrate(durationMs)
                }
            }
        } catch (_: Exception) {}
    }
}
