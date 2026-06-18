// lib/utils/constants.dart
import 'package:flutter/material.dart';

// ── Refrakto palette: void black + neon beams ──────────────────────────
const Color kBg          = Color(0xFF07090F);
const Color kSurface     = Color(0xFF111521);
const Color kBorder      = Color(0xFF222a3d);
const Color kAccent      = Color(0xFF2EE6C8);
const Color kCell        = Color(0xFF0C1019);
const Color kCellEdge    = Color(0xFF1B2233);
const Color kMirror      = Color(0xFFC7D2E8);
const Color kWall        = Color(0xFF323A52);
const Color kTextPrimary = Color(0xFFEAF0FA);
const Color kTextDim     = Color(0xFF7A88A6);

const Color kStarOn  = Color(0xFFFFD54F);
const Color kStarOff = Color(0xFF1A2030);

const Color kEasyColor   = Color(0xFF2EE6C8);
const Color kMediumColor = Color(0xFF5AA9FF);
const Color kHardColor   = Color(0xFFFF7043);

// Up to 3 beam colors per level
const List<Color> kBeamColors = [
  Color(0xFFFF4D7D), // pink
  Color(0xFF36D1FF), // cyan
  Color(0xFFFFC23D), // amber
];

const int kTotalLevels = 150;

TextStyle techno(double size,
        {Color color = kTextPrimary,
        FontWeight weight = FontWeight.bold,
        double letterSpacing = 1.5}) =>
    TextStyle(
        fontSize: size, color: color, fontWeight: weight,
        letterSpacing: letterSpacing);
