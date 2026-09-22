import 'package:flutter/material.dart';

/// Centralized design tokens for the Home / Workspace feature.
/// Follows a mature, premium SaaS aesthetic: Obsidian Slate, crisp white surfaces,
/// subtle slate borders, and precision cobalt/slate accents.
class WorkspaceTheme {
  // Font Family
  static const String fontFamily = 'PlusJakartaSans';

  // Canvas & Surfaces
  static const Color canvas = Color(0xFFF8FAFC); // Slate-50
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Slate-100
  static const Color surfaceSubtle = Color(0xFFF8FAFC); // Slate-50

  // Brand / Primary Authority (Dark Obsidian Slate)
  static const Color primaryDark = Color(0xFF0F172A); // Slate-900
  static const Color primaryNavy = Color(0xFF1E293B); // Slate-800
  static const Color primaryBorder = Color(0xFF334155); // Slate-700

  // Accent & Interactive
  static const Color accentCobalt = Color(0xFF2563EB); // Cobalt Blue
  static const Color accentLight = Color(0xFFEFF6FF); // Blue-50
  static const Color accentBorder = Color(0xFFBFDBFE); // Blue-200
  static const Color accentSky = Color(0xFF0284C7);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFFE2E8F0); // Slate-200
  static const Color borderMedium = Color(0xFFCBD5E1); // Slate-300

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate-900
  static const Color textSecondary = Color(0xFF475569); // Slate-600
  static const Color textTertiary = Color(0xFF64748B); // Slate-500
  static const Color textMuted = Color(0xFF94A3B8); // Slate-400

  // Feedback States
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color errorBorder = Color(0xFFFECACA);

  // Radii
  static const double radiusPill = 28.0;
  static const double radiusCard = 16.0;
  static const double radiusElement = 12.0;
  static const double radiusSmall = 10.0;

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      offset: const Offset(0, 2),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get cardHoverShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.08),
      offset: const Offset(0, 6),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get fabShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.25),
      offset: const Offset(0, 8),
      blurRadius: 20,
      spreadRadius: -2,
    ),
  ];
}
