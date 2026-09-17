import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_service.dart';
import '../services/alert_audio_service.dart';

class SettingsPreferencesScreen extends StatefulWidget {
  const SettingsPreferencesScreen({super.key});

  @override
  State<SettingsPreferencesScreen> createState() =>
      _SettingsPreferencesScreenState();
}

class _SettingsPreferencesScreenState extends State<SettingsPreferencesScreen> {
  // 1. Navigation & Route Tracking (OpenStreetMap)
  String _navigationApp = "OpenStreetMap";
  bool _autoCenterMap = true;
  bool _voiceRoutePrompts = true;
  bool _highContrastMap = false;
  bool _offlineMapCaching = true;

  // 2. Alert Tone & Volume
  String _alertTone = "Loud Ring";
  double _soundVolume = 85.0;
  bool _vibrateOnAlert = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    final user = UserService().currentUser.value;
    final prefs = user?.deliveryDetails?['preferences'];

    if (prefs != null && prefs is Map) {
      _applyPreferencesMap(Map<String, dynamic>.from(prefs));
    }

    UserService().fetchPreferences().then((serverPrefs) {
      if (mounted && serverPrefs != null) {
        _applyPreferencesMap(serverPrefs);
      }
    });
  }

  void _applyPreferencesMap(Map<String, dynamic> prefs) {
    setState(() {
      _navigationApp = prefs['navigationApp'] ?? _navigationApp;
      _autoCenterMap = prefs['autoCenterMap'] ?? _autoCenterMap;
      _voiceRoutePrompts = prefs['voiceRoutePrompts'] ?? _voiceRoutePrompts;
      _highContrastMap = prefs['highContrastMap'] ?? _highContrastMap;
      _offlineMapCaching =
          prefs['offlineMapCaching'] ?? _offlineMapCaching;
      _alertTone = prefs['alertTone'] ?? _alertTone;
      _soundVolume = (prefs['soundVolume'] != null)
          ? (prefs['soundVolume'] as num).toDouble()
          : _soundVolume;
      _vibrateOnAlert = prefs['vibrateOnAlert'] ?? _vibrateOnAlert;
    });
  }

  Map<String, dynamic> _buildPreferencesMap() {
    return {
      'navigationApp': _navigationApp,
      'autoCenterMap': _autoCenterMap,
      'voiceRoutePrompts': _voiceRoutePrompts,
      'highContrastMap': _highContrastMap,
      'offlineMapCaching': _offlineMapCaching,
      'alertTone': _alertTone,
      'soundVolume': _soundVolume,
      'vibrateOnAlert': _vibrateOnAlert,
    };
  }

  Future<void> _savePreferences({bool showToast = false}) async {
    final data = _buildPreferencesMap();
    final success = await UserService().updatePreferences(data);

    if (mounted && showToast) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                success ? "Preferences synced to server" : "Saved locally",
                style: GoogleFonts.outfit(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E9C1C),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openSubScreen(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings & Preferences",
          style: GoogleFonts.outfit(
            color: const Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              "PREFERENCES",
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Colors.grey.shade500,
              ),
            ),
          ),

          // Clean single card with the 3 essential links
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // 1. Navigation Maps Link
                _buildSectionLink(
                  icon: Icons.navigation_rounded,
                  title: "Navigation Maps",
                  subtitle: "Built-in GPS & live route tracking",
                  badge: "OpenStreetMap",
                  onTap: () => _openSubScreen(
                    _NavigationMapsSubScreen(
                      autoCenter: _autoCenterMap,
                      voicePrompts: _voiceRoutePrompts,
                      highContrast: _highContrastMap,
                      offlineCaching: _offlineMapCaching,
                      onSave: (autoCenter, voice, contrast, offline) {
                        setState(() {
                          _autoCenterMap = autoCenter;
                          _voiceRoutePrompts = voice;
                          _highContrastMap = contrast;
                          _offlineMapCaching = offline;
                        });
                        _savePreferences(showToast: true);
                      },
                    ),
                  ),
                ),
                _buildDivider(),

                // 2. Alert Tone Link
                _buildSectionLink(
                  icon: Icons.notifications_active_outlined,
                  title: "Alert Tone",
                  subtitle: "Order ringtones, volume & vibration",
                  badge: _alertTone,
                  onTap: () => _openSubScreen(
                    _AlertToneSubScreen(
                      currentTone: _alertTone,
                      volume: _soundVolume,
                      vibrateAlert: _vibrateOnAlert,
                      onSave: (tone, vol, vib) {
                        setState(() {
                          _alertTone = tone;
                          _soundVolume = vol;
                          _vibrateOnAlert = vib;
                        });
                        _savePreferences(showToast: true);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // Clean App Version Footer
          Center(
            child: Text(
              "Nilara Delivery Partner v1.2.4",
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.shade100, height: 1);
  }

  Widget _buildSectionLink({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF1E9C1C), size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: const Color(0xFF0F172A),
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          subtitle,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E9C1C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E9C1C),
                ),
              ),
            ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 22),
        ],
      ),
      onTap: onTap,
    );
  }
}

// -------------------------------------------------------------
// 1. NAVIGATION MAPS SUB-SCREEN (RIDER ESSENTIALS)
// -------------------------------------------------------------
class _NavigationMapsSubScreen extends StatefulWidget {
  final bool autoCenter;
  final bool voicePrompts;
  final bool highContrast;
  final bool offlineCaching;
  final Function(bool, bool, bool, bool) onSave;

  const _NavigationMapsSubScreen({
    required this.autoCenter,
    required this.voicePrompts,
    required this.highContrast,
    required this.offlineCaching,
    required this.onSave,
  });

  @override
  State<_NavigationMapsSubScreen> createState() =>
      _NavigationMapsSubScreenState();
}

class _NavigationMapsSubScreenState extends State<_NavigationMapsSubScreen> {
  late bool _autoCenter;
  late bool _voicePrompts;
  late bool _highContrast;
  late bool _offlineCaching;

  @override
  void initState() {
    super.initState();
    _autoCenter = widget.autoCenter;
    _voicePrompts = widget.voicePrompts;
    _highContrast = widget.highContrast;
    _offlineCaching = widget.offlineCaching;
  }

  void _persist() {
    widget.onSave(_autoCenter, _voicePrompts, _highContrast, _offlineCaching);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Navigation Maps",
          style: GoogleFonts.outfit(
            color: const Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "ACTIVE NAVIGATION MAP",
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF1E9C1C).withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E9C1C).withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E9C1C),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              title: Row(
                children: [
                  Text(
                    "OpenStreetMap",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "ACTIVE",
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E9C1C),
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Built-in live GPS turn-by-turn routing to dark store hubs and customer drop locations.",
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              trailing: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF1E9C1C),
                size: 26,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            "RIDER MAP CONTROLS",
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  title: Text(
                    "Auto-Center on Bike",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    "Keep the map focused on your moving position while on the road.",
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                  value: _autoCenter,
                  activeThumbColor: const Color(0xFF1E9C1C),
                  activeTrackColor: const Color(0xFFE8F5E9),
                  onChanged: (val) {
                    setState(() => _autoCenter = val);
                    _persist();
                  },
                ),
                Divider(color: Colors.grey.shade100, height: 1),
                SwitchListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  title: Text(
                    "Voice Route Alerts",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    "Audio prompts for turns and approaching customer drop location.",
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                  value: _voicePrompts,
                  activeThumbColor: const Color(0xFF1E9C1C),
                  activeTrackColor: const Color(0xFFE8F5E9),
                  onChanged: (val) {
                    setState(() => _voicePrompts = val);
                    _persist();
                  },
                ),
                Divider(color: Colors.grey.shade100, height: 1),
                SwitchListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  title: Text(
                    "High-Contrast Sunlight Mode",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    "Sharpen road lines and street text for direct sunlight outdoor riding.",
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                  value: _highContrast,
                  activeThumbColor: const Color(0xFF1E9C1C),
                  activeTrackColor: const Color(0xFFE8F5E9),
                  onChanged: (val) {
                    setState(() => _highContrast = val);
                    _persist();
                  },
                ),
                Divider(color: Colors.grey.shade100, height: 1),
                SwitchListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  title: Text(
                    "Offline Route Pre-loading",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    "Pre-loads local dark store zone to smoothly navigate low-signal basement areas.",
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                  value: _offlineCaching,
                  activeThumbColor: const Color(0xFF1E9C1C),
                  activeTrackColor: const Color(0xFFE8F5E9),
                  onChanged: (val) {
                    setState(() => _offlineCaching = val);
                    _persist();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 2. ALERT TONE SUB-SCREEN
// -------------------------------------------------------------
class _AlertToneSubScreen extends StatefulWidget {
  final String currentTone;
  final double volume;
  final bool vibrateAlert;
  final Function(String, double, bool) onSave;

  const _AlertToneSubScreen({
    required this.currentTone,
    required this.volume,
    required this.vibrateAlert,
    required this.onSave,
  });

  @override
  State<_AlertToneSubScreen> createState() => _AlertToneSubScreenState();
}

class _AlertToneSubScreenState extends State<_AlertToneSubScreen> {
  late String _selectedTone;
  late double _volume;
  late bool _vibrateAlert;

  String? _playingTone;
  Timer? _previewTimer;

  final List<Map<String, String>> _tones = [
    {
      'name': 'Loud Ring',
      'tag': 'Default',
      'desc': 'High-decibel urgent acoustic alert for noisy traffic',
    },
    {
      'name': 'Melodic Chime',
      'tag': 'Smooth',
      'desc': 'Harmonic pleasant chime tone',
    },
    {
      'name': 'Urgent Siren',
      'tag': 'Loudest',
      'desc': 'Dual-tone pulsing siren designed for road noise',
    },
    {
      'name': 'Beep Pulse',
      'tag': 'Fast',
      'desc': 'Continuous digital beeps for packing alerts',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedTone = widget.currentTone;
    _volume = widget.volume;
    _vibrateAlert = widget.vibrateAlert;
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    AlertAudioService().stopTone();
    super.dispose();
  }

  void _persist() {
    widget.onSave(_selectedTone, _volume, _vibrateAlert);
  }

  void _testTone(String toneName) {
    if (_playingTone == toneName) {
      _previewTimer?.cancel();
      AlertAudioService().stopTone();
      ScaffoldMessenger.of(context).clearSnackBars();
      setState(() => _playingTone = null);
      return;
    }

    _previewTimer?.cancel();
    AlertAudioService().stopTone();

    setState(() => _playingTone = toneName);

    // Play real audio tone via native AudioTrack / ToneGenerator / Web Audio
    AlertAudioService().playTone(toneName, volume: _volume);

    // Vibrate if vibration is enabled
    if (_vibrateAlert) {
      AlertAudioService().vibrate(durationMs: 350);
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              "Playing tone: '$toneName' (${_volume.toInt()}%)",
              style: GoogleFonts.outfit(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    _previewTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        AlertAudioService().stopTone();
        setState(() => _playingTone = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Alert Tone",
          style: GoogleFonts.outfit(
            color: const Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "ORDER RINGTONES",
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tones.length,
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.grey.shade100, height: 1),
              itemBuilder: (context, index) {
                final tone = _tones[index];
                final isSelected = _selectedTone == tone['name'];
                final isPlayingThis = _playingTone == tone['name'];

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1E9C1C)
                          : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.music_note_rounded,
                      color: isSelected ? Colors.white : const Color(0xFF1E9C1C),
                      size: 20,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        tone['name']!,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E9C1C).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tone['tag']!,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E9C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    tone['desc']!,
                    style: GoogleFonts.outfit(
                      fontSize: 12, color: Colors.grey.shade600),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isPlayingThis
                              ? Icons.stop_circle_rounded
                              : Icons.play_circle_fill_rounded,
                          color: isPlayingThis
                              ? Colors.orange
                              : const Color(0xFF1E9C1C),
                          size: 28,
                        ),
                        onPressed: () => _testTone(tone['name']!),
                      ),
                      isSelected
                          ? const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF1E9C1C), size: 24)
                          : const Icon(Icons.radio_button_unchecked,
                              color: Colors.grey, size: 24),
                    ],
                  ),
                  onTap: () {
                    setState(() => _selectedTone = tone['name']!);
                    _persist();
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          Text(
            "VOLUME & VIBRATION",
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Ringtone Volume",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            "${_volume.toInt()}%",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: const Color(0xFF1E9C1C),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.volume_mute_rounded,
                              size: 18, color: Colors.grey.shade400),
                          Expanded(
                            child: Slider(
                              value: _volume,
                              min: 0,
                              max: 100,
                              divisions: 20,
                              activeColor: const Color(0xFF1E9C1C),
                              inactiveColor: Colors.grey.shade200,
                              onChanged: (val) {
                                setState(() => _volume = val);
                              },
                              onChangeEnd: (val) {
                                _persist();
                                if (_playingTone != null) {
                                  AlertAudioService().playTone(_playingTone!, volume: val);
                                }
                              },
                            ),
                          ),
                          const Icon(Icons.volume_up_rounded,
                              size: 20, color: Color(0xFF1E9C1C)),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey.shade100, height: 1),
                SwitchListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  title: Text(
                    "Vibrate on Incoming Order",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    "Vibrate device when a new delivery order is assigned.",
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                  value: _vibrateAlert,
                  activeThumbColor: const Color(0xFF1E9C1C),
                  activeTrackColor: const Color(0xFFE8F5E9),
                  onChanged: (val) {
                    setState(() => _vibrateAlert = val);
                    if (val) {
                      AlertAudioService().vibrate(durationMs: 400);
                    }
                    _persist();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
