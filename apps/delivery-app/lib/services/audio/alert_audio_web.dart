import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'alert_audio_platform.dart';

class AlertAudioWeb implements AlertAudioPlatform {
  web.AudioContext? _audioContext;
  final List<web.OscillatorNode> _activeOscillators = [];
  Timer? _playbackTimer;

  @override
  void stopTone() {
    _playbackTimer?.cancel();
    _playbackTimer = null;

    for (final osc in _activeOscillators) {
      try {
        osc.stop();
        osc.disconnect();
      } catch (_) {}
    }
    _activeOscillators.clear();

    try {
      _audioContext?.close();
    } catch (_) {}
    _audioContext = null;
  }

  @override
  void playTone(String toneName, {double volume = 85.0}) {
    stopTone();

    try {
      final ctx = web.AudioContext();
      _audioContext = ctx;
      if (ctx.state == 'suspended') {
        ctx.resume();
      }

      final double normalizedVol = (volume > 1.0 ? volume / 100.0 : volume).clamp(0.05, 1.0);

      final masterGain = ctx.createGain();
      masterGain.gain.value = normalizedVol;
      masterGain.connect(ctx.destination);

      final now = ctx.currentTime;

      if (toneName == 'Loud Ring') {
        for (final freq in [440.0, 480.0]) {
          final osc = ctx.createOscillator();
          osc.type = 'sine';
          osc.frequency.value = freq;
          osc.connect(masterGain);
          osc.start(now);
          osc.stop(now + 2.5);
          _activeOscillators.add(osc);
        }
      } else if (toneName == 'Melodic Chime') {
        final notes = [523.25, 659.25, 783.99];
        for (int i = 0; i < notes.length; i++) {
          final osc = ctx.createOscillator();
          final noteGain = ctx.createGain();
          osc.type = 'triangle';
          osc.frequency.value = notes[i];
          noteGain.gain.value = 0.6;
          osc.connect(noteGain);
          noteGain.connect(masterGain);

          final noteStart = now + (i * 0.18);
          osc.start(noteStart);
          osc.stop(noteStart + 1.8);
          _activeOscillators.add(osc);
        }
      } else if (toneName == 'Urgent Siren') {
        final osc = ctx.createOscillator();
        osc.type = 'sawtooth';
        osc.frequency.setValueAtTime(600, now);
        for (int i = 0; i < 3; i++) {
          final t = now + (i * 0.8);
          osc.frequency.linearRampToValueAtTime(1200, t + 0.4);
          osc.frequency.linearRampToValueAtTime(600, t + 0.8);
        }
        osc.connect(masterGain);
        osc.start(now);
        osc.stop(now + 2.5);
        _activeOscillators.add(osc);
      } else {
        // Beep Pulse
        for (int i = 0; i < 4; i++) {
          final osc = ctx.createOscillator();
          osc.type = 'square';
          osc.frequency.value = 950.0;
          final beepGain = ctx.createGain();
          beepGain.gain.value = 0.5;
          osc.connect(beepGain);
          beepGain.connect(masterGain);

          final t = now + (i * 0.35);
          osc.start(t);
          osc.stop(t + 0.18);
          _activeOscillators.add(osc);
        }
      }

      debugPrint('Playing $toneName at volume $normalizedVol on Web AudioContext (${ctx.state})');

      _playbackTimer = Timer(const Duration(milliseconds: 2800), () {
        stopTone();
      });
    } catch (e, stack) {
      debugPrint('Error synthesizing audio in AlertAudioWeb: $e\n$stack');
    }
  }

  @override
  void vibrate({int durationMs = 400}) {
    try {
      web.window.navigator.vibrate(durationMs.toJS);
    } catch (e) {
      debugPrint('Web vibration notice: $e');
    }
  }

  @override
  void speak(String text) {
    try {
      final synth = web.window.speechSynthesis;
      synth.cancel();
      final utterance = web.SpeechSynthesisUtterance(text);
      utterance.rate = 1.0;
      synth.speak(utterance);
    } catch (e) {
      debugPrint('Web speech synthesis notice: $e');
    }
  }
}

AlertAudioPlatform getAlertAudioPlatform() => AlertAudioWeb();
