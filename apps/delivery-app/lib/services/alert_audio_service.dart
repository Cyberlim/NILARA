import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@JS('deliveryAudio.playTone')
external void _jsPlayTone(JSString toneName, JSNumber volume);

@JS('deliveryAudio.stopTone')
external void _jsStopTone();

@JS('deliveryAudio.vibrate')
external void _jsVibrate(JSNumber ms);

@JS('deliveryAudio.speak')
external void _jsSpeak(JSString text);

class AlertAudioService {
  static final AlertAudioService _instance = AlertAudioService._internal();
  factory AlertAudioService() => _instance;
  AlertAudioService._internal();

  void playTone(String toneName, {double volume = 85.0}) {
    // Normalize volume between 0.01 and 1.0
    final normalizedVol = (volume > 1.0 ? volume / 100.0 : volume).clamp(0.01, 1.0);
    if (kIsWeb) {
      try {
        _jsPlayTone(toneName.toJS, normalizedVol.toJS);
      } catch (e) {
        debugPrint('Error playing tone via Web Audio: $e');
      }
    } else {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  void stopTone() {
    if (kIsWeb) {
      try {
        _jsStopTone();
      } catch (e) {
        debugPrint('Error stopping tone via Web Audio: $e');
      }
    }
  }

  void vibrate({int durationMs = 400}) {
    HapticFeedback.vibrate();
    if (kIsWeb) {
      try {
        _jsVibrate(durationMs.toJS);
      } catch (e) {
        debugPrint('Error triggering vibration: $e');
      }
    }
  }

  void speak(String text) {
    if (kIsWeb) {
      try {
        _jsSpeak(text.toJS);
      } catch (e) {
        debugPrint('Error speaking prompt: $e');
      }
    }
  }
}
