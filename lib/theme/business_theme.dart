import 'package:flutter/material.dart';

/// Executive Theme & Color Palette for Coffee Labs Mode Business.
/// Uses an ultra-sleek Dark Roasted Espresso aesthetic (#141311) paired with
/// Luxury Gold (#D4AF37), Warm Amber (#E5A93C), and Crisp Warm Cream accents (#FAF7F2).
class BusinessTheme {
  // Backgrounds
  static const Color bgDark = Color(0xFF141311);
  static const Color bgSurface = Color(0xFF1A1815);
  static const Color cardBg = Color(0xFF22201D);
  static const Color cardElevated = Color(0xFF2A2723);
  static const Color modalBg = Color(0xFF1E1C19);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFF332F2A);
  static const Color borderHighlighted = Color(0xFF4A443B);
  static const Color borderGold = Color(0xFFD4AF37);

  // Accents
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF3C654);
  static const Color amberWarm = Color(0xFFE5A93C);
  static const Color copperWarm = Color(0xFFC67C4E);

  // Typography
  static const Color textLight = Color(0xFFFAF7F2);
  static const Color textSecondary = Color(0xFFC8BFB2);
  static const Color textMuted = Color(0xFF8E867B);
  static const Color textMutedDark = Color(0xFF655F56);

  // Navigation Bar
  static const Color navBarBg = Color(0xFF171513);
  static const Color navBarBorder = Color(0xFF2D2924);

  // Status Indicators
  static const Color statusSuccess = Color(0xFF10B981);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusDanger = Color(0xFFEF4444);
  static const Color statusInfo = Color(0xFF3B82F6);

  // Pre-configured BoxDecorations
  static BoxDecoration cardDecoration({
    Color backgroundColor = cardBg,
    Color borderColor = borderSubtle,
    double borderRadius = 18.0,
    bool hasGoldGlow = false,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: 1.0),
      boxShadow: [
        BoxShadow(
          color: hasGoldGlow
              ? goldAccent.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.28),
          blurRadius: hasGoldGlow ? 16 : 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration badgeDecoration({
    required Color color,
    double borderRadius = 8.0,
  }) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: color.withValues(alpha: 0.5), width: 0.8),
    );
  }
}
