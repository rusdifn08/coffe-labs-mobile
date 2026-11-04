import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AppBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Border? border;

  const AppBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 9.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
    this.borderRadius,
    this.border,
  });

  factory AppBadge.gold(String text) {
    return AppBadge(
      text: text,
      backgroundColor: AppTheme.accentGold.withValues(alpha: 0.22),
      textColor: AppTheme.primaryBrown,
      border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
    );
  }

  factory AppBadge.green(String text) {
    return AppBadge(
      text: text,
      backgroundColor: Colors.green.withValues(alpha: 0.15),
      textColor: Colors.green.shade800,
    );
  }

  factory AppBadge.locked(String text) {
    return AppBadge(
      text: text,
      backgroundColor: Colors.black.withValues(alpha: 0.65),
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.primaryBrown.withValues(alpha: 0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(6),
        border: border,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: textColor ?? AppTheme.primaryBrown,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
