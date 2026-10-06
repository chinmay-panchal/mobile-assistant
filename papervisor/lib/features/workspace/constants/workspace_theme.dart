import 'package:flutter/material.dart';

/// Centralized design tokens for the Home / Workspace feature.
/// Follows a mature, premium SaaS aesthetic: Obsidian Slate, crisp white surfaces,
/// subtle slate borders, and precision cobalt/slate accents.
class WorkspaceTheme {
  // Current Theme Mode State
  static bool isDark = false;

  // Font Family
  static const String fontFamily = 'PlusJakartaSans';

  // Canvas & Surfaces
  static Color get canvas =>
      isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC);
  static Color get surfaceWhite =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
  static Color get cardBackground => surfaceWhite;
  static Color get surfaceMuted =>
      isDark ? const Color(0xFF151F32) : const Color(0xFFF1F5F9);
  static Color get surfaceSubtle =>
      isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

  // Brand / Primary Authority (Dark Obsidian Slate in light mode, Vibrant Cobalt in dark mode)
  static Color get primaryDark =>
      isDark ? const Color(0xFF2563EB) : const Color(0xFF0F172A);
  static Color get primaryNavy =>
      isDark ? const Color(0xFF1D4ED8) : const Color(0xFF1E293B);
  static Color get primaryBorder =>
      isDark ? const Color(0xFF3B82F6) : const Color(0xFF334155);

  // Accent & Interactive
  static const Color accentCobalt = Color(0xFF2563EB); // Cobalt Blue
  static Color get accentLight =>
      isDark ? const Color(0xFF172554) : const Color(0xFFEFF6FF);
  static Color get accentBorder =>
      isDark ? const Color(0xFF1E40AF) : const Color(0xFFBFDBFE);
  static const Color accentSky = Color(0xFF0284C7);

  // Borders & Dividers
  static Color get borderSubtle =>
      isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  static Color get borderMedium =>
      isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

  // Typography Colors
  static Color get textPrimary =>
      isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  static Color get textSecondary =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  static Color get textTertiary =>
      isDark ? const Color(0xFF64748B) : const Color(0xFF64748B);
  static Color get textMuted =>
      isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8);

  // Feedback States
  static const Color error = Color(0xFFEF4444);
  static Color get errorLight =>
      isDark ? const Color(0xFF451A1A) : const Color(0xFFFEF2F2);
  static Color get errorBorder =>
      isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA);

  // Radii
  static const double radiusPill = 28.0;
  static const double radiusCard = 16.0;
  static const double radiusElement = 12.0;
  static const double radiusSmall = 10.0;

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: isDark
          ? Colors.black.withValues(alpha: 0.3)
          : const Color(0xFF0F172A).withValues(alpha: 0.04),
      offset: const Offset(0, 2),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get cardHoverShadow => [
    BoxShadow(
      color: isDark
          ? Colors.black.withValues(alpha: 0.5)
          : const Color(0xFF0F172A).withValues(alpha: 0.08),
      offset: const Offset(0, 6),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get fabShadow => [
    BoxShadow(
      color: isDark
          ? const Color(0xFF2563EB).withValues(alpha: 0.4)
          : const Color(0xFF0F172A).withValues(alpha: 0.25),
      offset: const Offset(0, 8),
      blurRadius: 20,
      spreadRadius: -2,
    ),
  ];
}
