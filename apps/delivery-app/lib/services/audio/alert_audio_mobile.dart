import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'alert_audio_platform.dart';

class AlertAudioMobile implements AlertAudioPlatform {
  static const MethodChannel _channel = MethodChannel('com.nilara.delivery/audio');

  @override
  void playTone(String toneName, {double volume = 85.0}) async {
    try {
      await _channel.invokeMethod('playTone', {
        'name': toneName,
        'volume': volume,
      });
    } catch (e) {
      debugPrint("Native alert audio error: $e. Falling back to SystemSound.");
      SystemSound.play(SystemSoundType.alert);
    }
  }

  @override
  void stopTone() async {
    try {
      await _channel.invokeMethod('stopTone');
    } catch (_) {}
  }

  @override
  void vibrate({int durationMs = 400}) async {
    try {
      await _channel.invokeMethod('vibrate', {'durationMs': durationMs});
    } catch (_) {
      HapticFeedback.vibrate();
    }
  }

  @override
  void speak(String text) {
    // Platform speech or no-op
  }
}

AlertAudioPlatform getAlertAudioPlatform() => AlertAudioMobile();
