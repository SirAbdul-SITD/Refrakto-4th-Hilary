// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/preferences.dart';
import '../utils/audio_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _sound;
  late bool _music;
  late bool _vibration;

  @override
  void initState() {
    super.initState();
    _sound = Preferences.instance.isSoundEnabled();
    _music = Preferences.instance.isMusicEnabled();
    _vibration = Preferences.instance.isVibrationEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextDim),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('SETTINGS', style: techno(16, letterSpacing: 4)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          _toggle(Icons.volume_up_rounded, 'SOUND EFFECTS', _sound, (v) async {
            setState(() => _sound = v);
            await Preferences.instance.setSoundEnabled(v);
          }),
          const SizedBox(height: 12),
          _toggle(Icons.music_note_rounded, 'MUSIC', _music, (v) async {
            setState(() => _music = v);
            await Preferences.instance.setMusicEnabled(v);
            if (v) {
              AudioManager.instance.startMusic();
            } else {
              AudioManager.instance.stopMusic();
            }
          }),
          const SizedBox(height: 12),
          _toggle(Icons.vibration_rounded, 'HAPTIC FEEDBACK', _vibration,
              (v) async {
            setState(() => _vibration = v);
            await Preferences.instance.setVibrationEnabled(v);
          }),
          const SizedBox(height: 36),
          Divider(color: kBorder.withOpacity(0.5)),
          const SizedBox(height: 24),
          Text('REFRAKTO', style: techno(13, color: kAccent, letterSpacing: 4)),
          const SizedBox(height: 6),
          Text('v1.0  ·  150 Levels',
              style: techno(10,
                  color: kTextDim.withOpacity(0.5), letterSpacing: 2)),
        ]),
      ),
    );
  }

  Widget _toggle(
          IconData icon, String label, bool value, ValueChanged<bool> onCh) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: value ? kAccent.withOpacity(0.4) : kBorder),
        ),
        child: Row(children: [
          Icon(icon, color: value ? kAccent : kTextDim, size: 20),
          const SizedBox(width: 14),
          Text(label,
              style: techno(12,
                  color: value ? Colors.white : kTextDim, letterSpacing: 2)),
          const Spacer(),
          Switch.adaptive(
            value: value,
            onChanged: onCh,
            activeColor: kAccent,
            activeTrackColor: kAccent.withOpacity(0.3),
            inactiveThumbColor: kTextDim,
            inactiveTrackColor: kBorder,
          ),
        ]),
      );
}
