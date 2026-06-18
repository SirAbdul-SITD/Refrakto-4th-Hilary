// lib/game/laser_level.dart
import 'dart:math';

enum TileKind { empty, emitter, target, mirror, wall }

class Tile {
  TileKind kind;
  int orient;   // emitter: facing 0..3 (current). mirror: 0 '/'  1 '\'
  int colorId;  // emitter/target color index
  int solOrient; // emitter's solution facing (for generation/par)
  Tile(this.kind, this.orient, this.colorId, this.solOrient);
  Tile clone() => Tile(kind, orient, colorId, solOrient);
}

class LaserLevel {
  final int index;
  final int size;
  final String difficulty;
  final List<Tile> initial;
  late List<Tile> tiles;
  final int beamCount;
  LaserLevel({
    required this.index,
    required this.size,
    required this.difficulty,
    required this.initial,
    required this.beamCount,
  }) {
    tiles = initial.map((t) => t.clone()).toList();
  }
  void reset() => tiles = initial.map((t) => t.clone()).toList();
}

class LevelGenerator {
  // dir: 0 up 1 right 2 down 3 left
  static const _dr = [-1, 0, 1, 0];
  static const _dc = [0, 1, 0, -1];

  static LaserLevel generate(int levelIndex) {
    int size, beams;
    String difficulty;
    if (levelIndex < 50) {
      size = 5; difficulty = 'Easy'; beams = 1 + levelIndex ~/ 25; // 1-2
    } else if (levelIndex < 100) {
      size = 6; difficulty = 'Medium'; beams = 2 + (levelIndex - 50) ~/ 40; // 2-3
    } else {
      size = 7; difficulty = 'Hard'; beams = 3;
    }

    final rng = Random(levelIndex * 8311 + levelIndex * 37 + 29);
    for (int attempt = 0; attempt < 400; attempt++) {
      final lvl = _build(levelIndex, size, beams, difficulty,
          Random(rng.nextInt(1 << 31)));
      if (lvl != null) return lvl;
    }
    return _build(levelIndex, 5, 1, difficulty, Random(7))!;
  }

  static LaserLevel? _build(
      int index, int s, int beams, String diff, Random rng) {
    final tiles = List<Tile>.generate(
        s * s, (_) => Tile(TileKind.empty, 0, 0, 0));
    final used = <int>{};

    // optionally scatter a few mirrors/walls (fixed) to enrich routing
    final obstacles = rng.nextInt(s);
    for (int k = 0; k < obstacles; k++) {
      final cell = rng.nextInt(s * s);
      if (used.contains(cell)) continue;
      if (rng.nextBool()) {
        tiles[cell] = Tile(TileKind.mirror, rng.nextInt(2), 0, 0);
      } else {
        tiles[cell] = Tile(TileKind.wall, 0, 0, 0);
      }
      used.add(cell);
    }

    // for each beam color, place emitter at a random free cell, trace in a
    // random direction respecting the fixed mirrors/walls; the first empty
    // cell where it would exit/stop becomes the target.
    for (int b = 0; b < beams; b++) {
      int? emitterCell;
      for (int tries = 0; tries < 40; tries++) {
        final cell = rng.nextInt(s * s);
        if (used.contains(cell)) continue;
        emitterCell = cell;
        break;
      }
      if (emitterCell == null) return null;
      final dir = rng.nextInt(4);
      // trace
      final path = _trace(tiles, s, emitterCell, dir, used);
      if (path.length < 2) {
        continue; // try a different beam? simpler: fail this build
      }
      // target = last cell of path if it's empty & unused
      final tgt = path.last;
      if (tgt == emitterCell || used.contains(tgt) ||
          tiles[tgt].kind != TileKind.empty) {
        return null;
      }
      tiles[emitterCell] = Tile(TileKind.emitter, dir, b, dir);
      tiles[tgt] = Tile(TileKind.target, dir, b, dir);
      used.add(emitterCell);
      used.add(tgt);
      // mark path cells as used so beams don't overlap targets/emitters
      for (final p in path) {
        used.add(p);
      }
    }

    if (used.where((c) => tiles[c].kind == TileKind.emitter).length != beams) {
      return null;
    }

    // scramble emitter facings away from solution
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i].kind == TileKind.emitter) {
        int o = tiles[i].solOrient;
        while (o == tiles[i].solOrient) {
          o = rng.nextInt(4);
        }
        tiles[i].orient = o;
      }
    }
    // ensure not already solved
    return LaserLevel(
      index: index, size: s, difficulty: diff,
      initial: tiles, beamCount: beams,
    );
  }

  /// Trace a beam; returns cells visited (excluding the emitter? include it).
  /// Stops at wall/target/edge; reflects at mirrors.
  static List<int> _trace(
      List<Tile> tiles, int s, int from, int dir, Set<int> blockTargets) {
    final cells = <int>[from];
    int r = from ~/ s, c = from % s, d = dir;
    int guard = 0;
    while (guard < s * s * 4) {
      guard++;
      r += _dr[d];
      c += _dc[d];
      if (r < 0 || c < 0 || r >= s || c >= s) break;
      final cell = r * s + c;
      final t = tiles[cell];
      if (t.kind == TileKind.wall) break;
      if (t.kind == TileKind.mirror) {
        cells.add(cell);
        d = _reflect(d, t.orient);
        continue;
      }
      if (t.kind == TileKind.emitter) break; // can't pass another emitter
      cells.add(cell);
    }
    return cells;
  }

  static int _reflect(int dir, int orient) {
    if (orient == 0) {
      const m = {0: 1, 1: 0, 2: 3, 3: 2}; // '/'
      return m[dir]!;
    } else {
      const m = {0: 3, 3: 0, 2: 1, 1: 2}; // '\'
      return m[dir]!;
    }
  }
}
