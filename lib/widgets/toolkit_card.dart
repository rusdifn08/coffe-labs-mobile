import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/admin_control/controllers/system_control_sync_controller.dart';
import '../features/admin_control/models/admin_control_models.dart';
import '../features/admin_control/widgets/feature_locked_status_sheet.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/utils/auth_navigation_helper.dart';
import '../features/gamification/services/gamification_service.dart';
import '../services/auth_service.dart';
import '../services/trial_service.dart';
import '../theme/app_theme.dart';
import 'toolkit_vector_icons.dart';

class ToolkitItem {
  final String? featureKey;
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
    this.featureKey,
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
    final hasProviderScope =
        context.findAncestorWidgetOfExactType<UncontrolledProviderScope>() !=
                null ||
            context.findAncestorWidgetOfExactType<ProviderScope>() != null;

    if (hasProviderScope &&
        tool.featureKey != null &&
        tool.featureKey!.isNotEmpty) {
      return _LiveLockedToolkitCard(tool: tool);
    }
    return _ToolkitCardSurface(tool: tool);
  }
}

class _LiveLockedToolkitCard extends ConsumerWidget {
  final ToolkitItem tool;

  const _LiveLockedToolkitCard({required this.tool});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featureKey = tool.featureKey!;
    final control = ref.watch(featureLockProvider(featureKey));
    final authUser = ref.watch(authControllerProvider).value;
    final isAdmin =
        (authUser?.isAdmin ?? false) || (AuthService.cachedIsAdmin ?? false);

    return _ToolkitCardSurface(
      tool: tool,
      control: control,
      isAdmin: isAdmin,
      onRefreshStatus: () =>
          ref.read(systemControlProvider.notifier).syncFromRest(force: true),
      onEnterDestination: () {
        GamificationService.instance.recordToolkitUsed(tool.title);
        final ctrl = ref.read(systemControlProvider.notifier);
        ctrl.setActiveFeatureScreen(featureKey);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => tool.destination),
        ).whenComplete(() {
          ctrl.setActiveFeatureScreen(null);
        });
      },
    );
  }
}

class _ToolkitCardSurface extends StatelessWidget {
  final ToolkitItem tool;
  final FeatureControlItem? control;
  final bool isAdmin;
  final VoidCallback? onRefreshStatus;
  final VoidCallback? onEnterDestination;

  const _ToolkitCardSurface({
    required this.tool,
    this.control,
    this.isAdmin = false,
    this.onRefreshStatus,
    this.onEnterDestination,
  });

  void _defaultNavigate(BuildContext context) {
    GamificationService.instance.recordToolkitUsed(tool.title);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => tool.destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminLocked = control != null && control!.isLocked;
    final lockStatus =
        adminLocked ? control!.lockStatus : FeatureLockStatus.unlocked;
    final statusAccent = lockStatus.accentTextColor;
    final pillBg = lockStatus.pillBackgroundColor;
    final borderColor =
        adminLocked ? lockStatus.cardBorderColor : const Color(0xFFECE2D6);
    final canAdminBypass =
        adminLocked && isAdmin && (control?.allowAdminBypass ?? false);

    final effectiveSubtitle = adminLocked
        ? control!.effectiveCardSubtitle
        : tool.subtitle;

    return Container(
      decoration: BoxDecoration(
        color: adminLocked
            ? Color.alphaBlend(
                pillBg.withValues(alpha: 0.45),
                AppTheme.surfaceWhite,
              )
            : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: adminLocked ? 1.35 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (adminLocked ? statusAccent : AppTheme.primaryBrown)
                .withValues(alpha: adminLocked ? 0.08 : 0.045),
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
            // Layer 1 Enforcement: Admin Lock selalu memblokir akses masuk non-Admin
            if (adminLocked) {
              FeatureLockedStatusSheet.show(
                context,
                control: control!,
                canAdminBypass: canAdminBypass,
                onRefreshStatus: onRefreshStatus,
                onAdminBypassEnter: canAdminBypass
                    ? () {
                        if (onEnterDestination != null) {
                          onEnterDestination!();
                        } else {
                          _defaultNavigate(context);
                        }
                      }
                    : null,
              );
              return;
            }
            if (tool.isLocked) {
              TrialService.showToolkitLockedDialog(
                context: context,
                featureName: tool.title,
                onLoginTap: () =>
                    AuthNavigationHelper.openLoginScreen(context),
              );
              return;
            }
            if (onEnterDestination != null) {
              onEnterDestination!();
            } else {
              _defaultNavigate(context);
            }
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
                    Opacity(
                      opacity: adminLocked ? 0.72 : 1.0,
                      child: Container(
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
                            ? Icon(tool.fallbackIcon,
                                color: tool.primaryColor, size: 18)
                            : ToolkitVectorIcon(
                                type: tool.iconType,
                                size: 18,
                                primaryColor: tool.primaryColor,
                                secondaryColor: tool.secondaryColor,
                              ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (adminLocked)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: pillBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: borderColor,
                              width: 0.9,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.lock_fill,
                                size: 9,
                                color: statusAccent,
                              ),
                              const SizedBox(width: 2.5),
                              Flexible(
                                child: Text(
                                  control!.effectiveBadgeLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: statusAccent,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (tool.isLocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: const Color(0xFFFFB74D), width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.lock_fill,
                                size: 9, color: Color(0xFFE65100)),
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
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: adminLocked
                        ? AppTheme.textDark.withValues(alpha: 0.82)
                        : AppTheme.textDark,
                    letterSpacing: -0.2,
                    height: 1.15,
                  ),
                ),
                if (effectiveSubtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    effectiveSubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          adminLocked ? FontWeight.w700 : FontWeight.normal,
                      color: adminLocked ? statusAccent : AppTheme.textMuted,
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
