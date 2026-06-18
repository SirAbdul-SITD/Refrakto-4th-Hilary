// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/preferences.dart';
import 'level_select_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final completed = Preferences.instance.getCompletedCount();
    final totalStars = Preferences.instance.getTotalStars();
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(children: [
          const Spacer(flex: 2),
          Icon(Icons.wifi_tethering_rounded, color: kAccent, size: 84),
          const SizedBox(height: 18),
          Text('REFRAKTO',
              style: techno(40, color: kAccent, weight: FontWeight.w900, letterSpacing: 6)),
          const SizedBox(height: 8),
          Text('AIM · REFLECT · ALIGN', style: techno(11, color: kTextDim, letterSpacing: 4)),
          const SizedBox(height: 28),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _chip(Icons.check_circle_outline, '$completed / $kTotalLevels', kEasyColor),
            const SizedBox(width: 14),
            _chip(Icons.star, '$totalStars', kStarOn),
          ]),
          const Spacer(flex: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 52),
            child: Column(children: [
              _btn(context, 'PLAY', Icons.play_arrow_rounded, true,
                  () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const LevelSelectScreen()))),
              const SizedBox(height: 14),
              _btn(context, 'SETTINGS', Icons.tune_rounded, false,
                  () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SettingsScreen()))),
            ]),
          ),
          const SizedBox(height: 56),
        ]),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: kSurface, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorder)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label, style: techno(13)),
        ]));

  Widget _btn(BuildContext context, String label, IconData icon, bool primary,
          VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: primary
                ? const LinearGradient(colors: [Color(0xFF159e8a), Color(0xFF2EE6C8)])
                : null,
            color: primary ? null : kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: primary ? kAccent.withOpacity(0.7) : kBorder,
                width: primary ? 1.5 : 1),
            boxShadow: primary
                ? [BoxShadow(color: kAccent.withOpacity(0.3), blurRadius: 22)]
                : null),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: primary ? Colors.white : kTextDim, size: 20),
            const SizedBox(width: 10),
            Text(label, style: techno(15,
                color: primary ? Colors.white : kTextDim, letterSpacing: 3)),
          ])),
      );
}
