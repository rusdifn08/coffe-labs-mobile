import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/gamification/services/gamification_service.dart';
import '../screens/onboarding_screen.dart';
import '../services/trial_service.dart';
import '../theme/app_theme.dart';
import 'toolkit_vector_icons.dart';

class ToolkitItem {
  final String title;
  final String subtitle;
  final String iconType;
  final IconData? fallbackIcon;
  final Color primaryColor;
  final Color secondaryColor;
  final List<Color> gradientColors;
  final Widget destination;
  final bool isLocked;

  const ToolkitItem({
    required this.title,
    required this.subtitle,
    required this.iconType,
    this.fallbackIcon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.gradientColors,
    required this.destination,
    this.isLocked = false,
  });
}

class ToolkitSectionHeader extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final Color badgeBg;
  final Color borderColor;
  final Widget? trailing;

  const ToolkitSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeBg,
    required this.borderColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          alignment: Alignment.center,
          child: icon,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                  color: AppTheme.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class ToolkitCard extends StatelessWidget {
  final ToolkitItem tool;

  const ToolkitCard({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceWhite,
      borderRadius: BorderRadius.circular(16),
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (tool.isLocked) {
            TrialService.showToolkitLockedDialog(
              context: context,
              featureName: tool.title,
              onLoginTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                );
              },
            );
            return;
          }
          GamificationService.instance.recordToolkitUsed(tool.title);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => tool.destination),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: tool.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: tool.fallbackIcon != null
                        ? Icon(tool.fallbackIcon, color: tool.primaryColor, size: 20)
                        : ToolkitVectorIcon(
                            type: tool.iconType,
                            size: 20,
                            primaryColor: tool.primaryColor,
                            secondaryColor: tool.secondaryColor,
                          ),
                  ),
                  if (tool.isLocked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFFB74D), width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.lock_fill, size: 10, color: Color(0xFFE65100)),
                          SizedBox(width: 3),
                          Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFE65100),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                tool.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                tool.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppTheme.textMuted,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
