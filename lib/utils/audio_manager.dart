// lib/utils/audio_manager.dart
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'preferences.dart';

class AudioManager {
  static final AudioManager instance = AudioManager._();
  AudioManager._();

  final _sfx1 = AudioPlayer();
  final _sfx2 = AudioPlayer();
  final _music = AudioPlayer();
  bool _ready = false;

  Future<void> init() async {
    try {
      await _sfx1.setSource(AssetSource('sounds/turn.wav'));
      await _sfx2.setSource(AssetSource('sounds/complete.wav'));
      _ready = true;
    } catch (_) {}
    startMusic();
  }

  bool get _soundOn => Preferences.instance.isSoundEnabled();
  bool get _musicOn => Preferences.instance.isMusicEnabled();

  Future<void> startMusic() async {
    if (!_musicOn) return;
    try {
      final track = 1 + Random().nextInt(3);
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(0.35);
      await _music.play(AssetSource('music/ambient_$track.wav'));
    } catch (_) {}
  }

  Future<void> stopMusic() async => _music.stop();

  Future<void> playTurn() async {
    if (!_ready || !_soundOn) return;
    await _sfx1.stop();
    await _sfx1.resume();
  }

  Future<void> playComplete() async {
    if (!_ready || !_soundOn) return;
    await _sfx2.stop();
    await _sfx2.resume();
  }
}
