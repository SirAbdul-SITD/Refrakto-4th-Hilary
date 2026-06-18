// lib/game/board_painter.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'laser_level.dart';
import 'game_state.dart';
import '../utils/constants.dart';

class BoardPainter extends CustomPainter {
  final GameState st;
  BoardPainter(this.st);

  @override
  void paint(Canvas canvas, Size size) {
    final s = st.size;
    final cell = size.width / s;

    for (int i = 0; i < s * s; i++) {
      final r = i ~/ s, c = i % s;
      final rect = Rect.fromLTWH(c * cell + 2, r * cell + 2, cell - 4, cell - 4);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          Paint()..color = kCell);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          Paint()
            ..color = kCellEdge
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
    }

    // beams
    st.beams.forEach((colorId, path) {
      if (path.length < 2) return;
      final color = kBeamColors[colorId % kBeamColors.length];
      Offset ctr(int i) =>
          Offset((i % s) * cell + cell / 2, (i ~/ s) * cell + cell / 2);
      final p = Path()..moveTo(ctr(path.first).dx, ctr(path.first).dy);
      for (int k = 1; k < path.length; k++) {
        p.lineTo(ctr(path[k]).dx, ctr(path[k]).dy);
      }
      canvas.drawPath(
          p,
          Paint()
            ..color = color.withOpacity(0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = cell * 0.26
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));
      canvas.drawPath(
          p,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = cell * 0.07
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
    });

    // tiles
    for (int i = 0; i < s * s; i++) {
      final t = st.level.tiles[i];
      final r = i ~/ s, c = i % s;
      final center = Offset(c * cell + cell / 2, r * cell + cell / 2);
      switch (t.kind) {
        case TileKind.emitter:
          _emitter(canvas, center, cell, t);
          break;
        case TileKind.target:
          _target(canvas, center, cell, t, st.hitTargets.contains(i));
          break;
        case TileKind.mirror:
          _mirror(canvas, center, cell, t.orient);
          break;
        case TileKind.wall:
          _wall(canvas, center, cell);
          break;
        case TileKind.empty:
          break;
      }
    }
  }

  void _emitter(Canvas canvas, Offset c, double cell, Tile t) {
    final color = kBeamColors[t.colorId % kBeamColors.length];
    final r = cell * 0.30;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: r * 1.9, height: r * 1.9),
            const Radius.circular(7)),
        Paint()..color = kSurface);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: r * 1.9, height: r * 1.9),
            const Radius.circular(7)),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
    // facing arrow
    final off = [
      const Offset(0, -1),
      const Offset(1, 0),
      const Offset(0, 1),
      const Offset(-1, 0)
    ][t.orient];
    final tip = c + off * r * 0.75;
    final back = c - off * r * 0.2;
    final perp = Offset(-off.dy, off.dx) * r * 0.42;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(back.dx + perp.dx, back.dy + perp.dy)
      ..lineTo(back.dx - perp.dx, back.dy - perp.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _target(Canvas canvas, Offset c, double cell, Tile t, bool lit) {
    final color = kBeamColors[t.colorId % kBeamColors.length];
    final r = cell * 0.26;
    if (lit) {
      canvas.drawCircle(
          c,
          r * 1.8,
          Paint()
            ..color = color.withOpacity(0.6)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, r));
    }
    canvas.drawCircle(c, r, Paint()
      ..color = lit ? color : kSurface);
    canvas.drawCircle(c, r, Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5);
    canvas.drawCircle(c, r * 0.5, Paint()
      ..color = lit ? Colors.white : color.withOpacity(0.6));
  }

  void _mirror(Canvas canvas, Offset c, double cell, int orient) {
    final r = cell * 0.3;
    final a = orient == 0 ? -pi / 4 : pi / 4;
    final dx = cos(a) * r, dy = sin(a) * r;
    canvas.drawLine(c + Offset(-dx, -dy), c + Offset(dx, dy),
        Paint()
          ..color = kMirror
          ..strokeWidth = cell * 0.12
          ..strokeCap = StrokeCap.round);
  }

  void _wall(Canvas canvas, Offset c, double cell) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: cell * 0.7, height: cell * 0.7),
            const Radius.circular(5)),
        Paint()..color = kWall);
  }

  @override
  bool shouldRepaint(BoardPainter old) => true;
}
