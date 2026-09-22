import 'package:flutter/material.dart';

/// Centralized Auth Theme tokens providing modern pastel aesthetics,
/// clean typography with Plus Jakarta Sans, and soft shadows.
class AuthTheme {
  // Font Family
  static const String fontFamily = 'PlusJakartaSans';

  // Surface & Ambient Canvas
  static const Color background = Color(0xFFF8FAFC); // Slate-50
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  
  // Ambient Accent Surfaces (Crisp White + Sky Blue + Obsidian Slate)
  static const Color pastelBlue = Color(0xFFEFF6FF); // Sky-50
  static const Color pastelPurple = Color(0xFFEFF6FF); // Sky-50
  static const Color pastelPink = Color(0xFFF8FAFC); // Slate-50
  static const Color pastelMint = Color(0xFFF1F5F9); // Slate-100
  static const Color pastelCyan = Color(0xFFE0F2FE); // Sky-100

  // Primary Accent & Gradient (Obsidian Slate Authority)
  static const Color primary = Color(0xFF0F172A); // Slate-900
  static const Color primaryLight = Color(0xFF1E293B); // Slate-800
  static const Color primaryDark = Color(0xFF020617); // Slate-950

  // Secondary Accent (Vibrant Sky Blue / Precision Cobalt)
  static const Color accentSky = Color(0xFF0284C7); // Sky-600
  static const Color accentCobalt = Color(0xFF2563EB); // Cobalt-600
  static const Color accentLight = Color(0xFFEFF6FF); // Sky-50
  static const Color accentBorder = Color(0xFFBAE6FD); // Sky-200
  static const Color accentMuted = Color(0xFFE0F2FE); // Sky-100

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B), // Slate-800
      Color(0xFF0F172A), // Obsidian Slate-900
    ],
  );

  static const LinearGradient primaryGradientPressed = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF020617),
    ],
  );

  // Input Field Colors with Sky Blue focus glow
  static const Color inputBg = Color(0xFFF8FAFC);
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color inputFocusBorder = Color(0xFF0284C7); // Sky Blue
  static const Color inputFocusGlow = Color(0x260284C7); // 15% Sky glow

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFFCBD5E1);

  // Feedback States
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color errorBorder = Color(0xFFFECACA);
  
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);

  // Radius
  static const double radiusPill = 28.0;
  static const double radiusField = 16.0;
  static const double radiusCard = 20.0;
  static const double radiusSmall = 12.0;

  // Shadows
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.20),
      offset: const Offset(0, 6),
      blurRadius: 16,
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.04),
      offset: const Offset(0, 4),
      blurRadius: 14,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get fieldFocusShadow => [
    const BoxShadow(
      color: inputFocusGlow,
      offset: Offset(0, 0),
      blurRadius: 8,
      spreadRadius: 2,
    ),
  ];

  // Typography Styles
  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.6,
    height: 1.25,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.4,
    height: 1.3,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.45,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.1,
  );

  static const TextStyle inputText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle inputHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textTertiary,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: -0.2,
  );

  static const TextStyle link = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: accentSky,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );
}
