// lib/utils/preferences.dart
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final Preferences instance = Preferences._();
  Preferences._();

  SharedPreferences? _p;
  Future<void> init() async => _p = await SharedPreferences.getInstance();

  int getLevelStars(int i) => _p?.getInt('stars_$i') ?? 0;
  int getMaxUnlocked() => _p?.getInt('max_unlocked') ?? 0;
  bool isSoundEnabled() => _p?.getBool('sound') ?? true;
  bool isMusicEnabled() => _p?.getBool('music') ?? true;
  bool isVibrationEnabled() => _p?.getBool('vibration') ?? true;

  Future<void> saveLevelResult(int i, int stars) async {
    if (stars > getLevelStars(i)) await _p?.setInt('stars_$i', stars);
    if (i + 1 > getMaxUnlocked()) await _p?.setInt('max_unlocked', i + 1);
  }

  Future<void> setSoundEnabled(bool v) async => _p?.setBool('sound', v);
  Future<void> setMusicEnabled(bool v) async => _p?.setBool('music', v);
  Future<void> setVibrationEnabled(bool v) async => _p?.setBool('vibration', v);

  int getTotalStars() {
    int t = 0;
    for (int i = 0; i < 150; i++) t += getLevelStars(i);
    return t;
  }

  int getCompletedCount() {
    int c = 0;
    for (int i = 0; i < 150; i++) {
      if (getLevelStars(i) > 0) c++;
    }
    return c;
  }
}
