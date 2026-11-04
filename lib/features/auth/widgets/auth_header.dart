import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AuthHeader extends StatelessWidget {
  final bool isSignUpMode;

  const AuthHeader({super.key, required this.isSignUpMode});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Image.asset(
            'assets/images/coffee_labs_emblem.png',
            width: 86,
            height: 86,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.science_outlined,
              color: AppTheme.accentGold,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Coffee Labs',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          isSignUpMode
              ? 'Daftar Akun Barista Baru'
              : 'Specialty Coffee Brewing Hub',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textMuted,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
