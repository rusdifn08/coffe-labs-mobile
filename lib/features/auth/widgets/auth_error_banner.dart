import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AuthErrorBanner extends StatelessWidget {
  final String errorMessage;
  final bool isSignUpMode;
  final VoidCallback onSwitchToLogin;

  const AuthErrorBanner({
    super.key,
    required this.errorMessage,
    required this.isSignUpMode,
    required this.onSwitchToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.redAccent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          if (isSignUpMode &&
              (errorMessage.contains('terdaftar') ||
                  errorMessage.contains('Login') ||
                  errorMessage.contains('timeout') ||
                  errorMessage.contains('Timeout'))) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: onSwitchToLogin,
                icon: const Icon(CupertinoIcons.arrow_right_circle_fill, size: 14, color: Colors.white),
                label: const Text(
                  'Beralih ke Login',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
