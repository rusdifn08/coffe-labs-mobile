import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/auth/utils/auth_navigation_helper.dart';
import '../features/gamification/services/gamification_service.dart';
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
    this.subtitle = '',
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
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: borderColor, width: 1.1),
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
                  fontSize: 14,
                  color: AppTheme.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10.5,
                  ),
                ),
              ],
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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECE2D6), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.045),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (tool.isLocked) {
              TrialService.showToolkitLockedDialog(
                context: context,
                featureName: tool.title,
                onLoginTap: () =>
                    AuthNavigationHelper.openLoginScreen(context),
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
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: tool.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: tool.fallbackIcon != null
                          ? Icon(tool.fallbackIcon, color: tool.primaryColor, size: 18)
                          : ToolkitVectorIcon(
                              type: tool.iconType,
                              size: 18,
                              primaryColor: tool.primaryColor,
                              secondaryColor: tool.secondaryColor,
                            ),
                    ),
                    if (tool.isLocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFFB74D), width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.lock_fill, size: 9, color: Color(0xFFE65100)),
                            SizedBox(width: 2.5),
                            Text(
                              'PRO',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE65100),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Icon(
                        CupertinoIcons.chevron_forward,
                        size: 13,
                        color: AppTheme.textMuted.withValues(alpha: 0.45),
                      ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  tool.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                    letterSpacing: -0.2,
                    height: 1.15,
                  ),
                ),
                if (tool.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    tool.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
