abstract class AlertAudioPlatform {
  void playTone(String toneName, {double volume = 85.0});
  void stopTone();
  void vibrate({int durationMs = 400});
  void speak(String text);
}
