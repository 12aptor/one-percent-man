import 'package:flutter/material.dart';

class AppColors {
  // --- LIGHT MODE ---
  static const Color backgroundLight = Color(0xFFF5F6F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color accentLight = Color(0xFF582FFF);
  static const Color textPrimaryLight = Color(0xFF1A1D21);
  static const Color textSecondaryLight = Color(0xFF484C52);
  static const Color borderLight = Color(0xFFE5E7EB);

  // --- DARK MODE ---
  static const Color backgroundDark = Color(0xFF131417);
  static const Color surfaceDark = Color(0xFF1D1F24);
  static const Color accentDark = Color(0xFF9E86FF);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF676D75);
  static const Color borderDark = Color(0xFF2A2D35);

  // Legacy/Default (to avoid breaking existing code during migration)
  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color accent = accentLight;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color border = borderLight;
  
  // Semantic / Others
  static const Color error = Color(0xFFFF4C4C);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFF9800);

  // Pastel colors for tasks/schedule
  static const Color pastelBlue = Color(0xFFE0F2FE);
  static const Color pastelGreen = Color(0xFFDCFCE7);
  static const Color pastelOrange = Color(0xFFFFEDD5);
  static const Color pastelPurple = Color(0xFFF3E8FF);
  static const Color pastelRed = Color(0xFFFFE4E6);
  static const Color pastelYellow = Color(0xFFFEF9C3);
  static const Color pastelPink = Color(0xFFFCE7F3);
  static const Color pastelTeal = Color(0xFFCCFBF1);
}

