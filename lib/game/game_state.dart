// lib/game/game_state.dart
import 'package:flutter/material.dart';
import 'laser_level.dart';
import '../utils/preferences.dart';
import '../utils/audio_manager.dart';

class GameState extends ChangeNotifier {
  late LaserLevel level;
  int moves = 0;
  bool isComplete = false;
  int stars = 0;
  int currentLevelIndex = 0;
  bool initialized = false;

  // computed beams: colorId -> list of cells the beam passes
  Map<int, List<int>> beams = {};
  Set<int> hitTargets = {};

  static const _dr = [-1, 0, 1, 0];
  static const _dc = [0, 1, 0, -1];

  void loadLevel(int index) {
    currentLevelIndex = index;
    level = LevelGenerator.generate(index);
    moves = 0;
    isComplete = false;
    stars = 0;
    initialized = true;
    _recompute();
    notifyListeners();
  }

  int get size => level.size;
  int get parMoves => level.beamCount; // min: one correct turn per emitter

  void rotate(int cell) {
    if (isComplete) return;
    final t = level.tiles[cell];
    if (t.kind != TileKind.emitter) return;
    t.orient = (t.orient + 1) % 4;
    moves++;
    AudioManager.instance.playTurn();
    _recompute();
    if (hitTargets.length == level.beamCount && !isComplete) {
      isComplete = true;
      stars = _calcStars();
      AudioManager.instance.playComplete();
      Preferences.instance.saveLevelResult(currentLevelIndex, stars);
    }
    notifyListeners();
  }

  void _recompute() {
    beams = {};
    hitTargets = {};
    final s = size;
    for (int i = 0; i < level.tiles.length; i++) {
      final t = level.tiles[i];
      if (t.kind != TileKind.emitter) continue;
      final path = <int>[i];
      int r = i ~/ s, c = i % s, d = t.orient;
      int guard = 0;
      while (guard < s * s * 4) {
        guard++;
        r += _dr[d];
        c += _dc[d];
        if (r < 0 || c < 0 || r >= s || c >= s) break;
        final cell = r * s + c;
        final tile = level.tiles[cell];
        if (tile.kind == TileKind.wall) break;
        if (tile.kind == TileKind.emitter) break;
        if (tile.kind == TileKind.mirror) {
          path.add(cell);
          d = _reflect(d, tile.orient);
          continue;
        }
        if (tile.kind == TileKind.target) {
          path.add(cell);
          if (tile.colorId == t.colorId) hitTargets.add(cell);
          break; // beam absorbed by target
        }
        path.add(cell);
      }
      beams[t.colorId] = path;
    }
  }

  int _reflect(int dir, int orient) {
    if (orient == 0) {
      const m = {0: 1, 1: 0, 2: 3, 3: 2};
      return m[dir]!;
    } else {
      const m = {0: 3, 3: 0, 2: 1, 1: 2};
      return m[dir]!;
    }
  }

  int _calcStars() {
    if (moves <= parMoves) return 3;
    if (moves <= parMoves * 3) return 2;
    return 1;
  }

  void restartLevel() {
    level.reset();
    moves = 0;
    isComplete = false;
    stars = 0;
    _recompute();
    notifyListeners();
  }

  void nextLevel() {
    if (currentLevelIndex < 149) loadLevel(currentLevelIndex + 1);
  }
}
