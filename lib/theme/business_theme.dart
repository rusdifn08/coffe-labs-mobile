import 'package:flutter/material.dart';

/// Executive Theme & Color Palette for Coffee Labs Mode Business.
/// Uses a warm, inviting, premium Mocha Charcoal aesthetic (#211E1B)
/// paired with Luxury Amber Gold (#E5A93C), Warm Mocha Card Surfaces (#302C27),
/// and Crisp Warm Cream accents (#FAF7F2).
class BusinessTheme {
  // Softer & Warmer Backgrounds (Not too dark, comfortable for all day cashier & manager eyes)
  static const Color bgDark = Color(0xFF211E1B);
  static const Color bgSurface = Color(0xFF282521);
  static const Color cardBg = Color(0xFF302C27);
  static const Color cardElevated = Color(0xFF38342E);
  static const Color cardHover = Color(0xFF443E37);
  static const Color modalBg = Color(0xFF2A2622);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFF443E37);
  static const Color borderHighlighted = Color(0xFF5A5248);
  static const Color borderGold = Color(0xFFE5A93C);

  // Accents
  static const Color goldAccent = Color(0xFFE5A93C);
  static const Color goldLight = Color(0xFFF5C067);
  static const Color amberWarm = Color(0xFFF39C12);
  static const Color copperWarm = Color(0xFFD38B5D);

  // Typography
  static const Color textLight = Color(0xFFFAF7F2);
  static const Color textSecondary = Color(0xFFD5CDC3);
  static const Color textMuted = Color(0xFFA69D92);
  static const Color textMutedDark = Color(0xFF7E756A);

  // Navigation Bar & Side Rail
  static const Color navBarBg = Color(0xFF26231F);
  static const Color navBarBorder = Color(0xFF3E3831);

  // Status Indicators
  static const Color statusSuccess = Color(0xFF10B981);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusDanger = Color(0xFFEF4444);
  static const Color statusInfo = Color(0xFF3B82F6);

  // Pre-configured BoxDecorations
  static BoxDecoration cardDecoration({
    Color backgroundColor = cardBg,
    Color borderColor = borderSubtle,
    double borderRadius = 16.0,
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
              : Colors.black.withValues(alpha: 0.22),
          blurRadius: hasGoldGlow ? 14 : 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  static BoxDecoration badgeDecoration({
    required Color color,
    double borderRadius = 8.0,
  }) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: color.withValues(alpha: 0.45), width: 0.8),
    );
  }
}
