import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/models/social_graph_models.dart';
import '../controllers/relationship_controller.dart';

class SmartFollowFollbackButton extends ConsumerWidget {
  final String targetUserOrUsername;
  final VoidCallback? onEditProfile;
  final VoidCallback? onOpenDirectChat;
  final bool compact;

  const SmartFollowFollbackButton({
    super.key,
    required this.targetUserOrUsername,
    this.onEditProfile,
    this.onOpenDirectChat,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSnap = ref.watch(
      userRelationshipControllerProvider(targetUserOrUsername),
    );
    final notifier = ref.read(
      userRelationshipControllerProvider(targetUserOrUsername).notifier,
    );

    return asyncSnap.when(
      loading: () => _LoadingPill(compact: compact),
      error: (_, _) => RelationshipCtaButton(
        state: RelationshipState.none,
        compact: compact,
        onTap: notifier.refresh,
      ),
      data: (snap) {
        if (snap.state == RelationshipState.selfProfile && !compact) {
          return OutlinedButton.icon(
            onPressed: onEditProfile,
            icon: const Icon(CupertinoIcons.pencil, size: 16),
            label: const Text('Edit Profil Barista'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryBrown,
              side: const BorderSide(color: AppTheme.borderWarm, width: 1.4),
              backgroundColor: AppTheme.surfaceWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          );
        }

        final cta = RelationshipCtaButton(
          state: snap.state,
          compact: compact,
          onTap: snap.state == RelationshipState.selfProfile
              ? (onEditProfile ?? () {})
              : () => notifier.toggleFollow(),
        );

        if (compact || onOpenDirectChat == null) {
          return cta;
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: cta),
            const SizedBox(width: 8),
            _QuickMessageIconButton(
              highlightMutual: snap.state == RelationshipState.mutual,
              onPressed: onOpenDirectChat!,
            ),
          ],
        );
      },
    );
  }
}

class RelationshipCtaButton extends StatelessWidget {
  final RelationshipState state;
  final VoidCallback onTap;
  final bool compact;

  const RelationshipCtaButton({
    super.key,
    required this.state,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (state == RelationshipState.selfProfile && compact) {
      return const SizedBox.shrink();
    }
    final spec = _styleFor(state);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 11 : 14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 16,
            vertical: compact ? 7 : 10,
          ),
          decoration: BoxDecoration(
            color: spec.bgColor,
            borderRadius: BorderRadius.circular(compact ? 11 : 14),
            border: spec.borderColor != null
                ? Border.all(color: spec.borderColor!, width: 1.3)
                : null,
            boxShadow: spec.showShadow
                ? [
                    BoxShadow(
                      color: AppTheme.primaryBrown.withValues(alpha: 0.14),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Row(
              key: ValueKey(state),
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(spec.icon, size: compact ? 13 : 15, color: spec.fgColor),
                const SizedBox(width: 6),
                Text(
                  state.ctaLabel,
                  style: TextStyle(
                    fontSize: compact ? 12 : 13.5,
                    fontWeight: FontWeight.w700,
                    color: spec.fgColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _CtaVisualSpec _styleFor(RelationshipState s) {
    switch (s) {
      case RelationshipState.selfProfile:
        return const _CtaVisualSpec(
          bgColor: AppTheme.surfaceWhite,
          fgColor: AppTheme.primaryBrown,
          borderColor: AppTheme.borderWarm,
          icon: CupertinoIcons.person_crop_circle,
          showShadow: false,
        );
      case RelationshipState.none:
        return const _CtaVisualSpec(
          bgColor: AppTheme.primaryBrown,
          fgColor: Colors.white,
          borderColor: null,
          icon: CupertinoIcons.person_add_solid,
          showShadow: true,
        );
      case RelationshipState.followedByTarget:
        return const _CtaVisualSpec(
          bgColor: AppTheme.accentGold,
          fgColor: AppTheme.textDark,
          borderColor: Color(0xFFB58E1C),
          icon: CupertinoIcons.arrow_uturn_left,
          showShadow: true,
        );
      case RelationshipState.requested:
        return const _CtaVisualSpec(
          bgColor: AppTheme.bgCream,
          fgColor: AppTheme.textMuted,
          borderColor: AppTheme.borderWarm,
          icon: CupertinoIcons.clock,
          showShadow: false,
        );
      case RelationshipState.following:
        return _CtaVisualSpec(
          bgColor: AppTheme.surfaceWhite,
          fgColor: AppTheme.primaryBrown,
          borderColor: AppTheme.primaryBrown.withValues(alpha: 0.38),
          icon: CupertinoIcons.checkmark_alt,
          showShadow: false,
        );
      case RelationshipState.mutual:
        return const _CtaVisualSpec(
          bgColor: Color(0xFFEEF7F1),
          fgColor: Color(0xFF1F6E43),
          borderColor: Color(0xFF9CD4B5),
          icon: CupertinoIcons.person_2_fill,
          showShadow: false,
        );
    }
  }
}

class _CtaVisualSpec {
  final Color bgColor;
  final Color fgColor;
  final Color? borderColor;
  final IconData icon;
  final bool showShadow;

  const _CtaVisualSpec({
    required this.bgColor,
    required this.fgColor,
    required this.borderColor,
    required this.icon,
    required this.showShadow,
  });
}

class _QuickMessageIconButton extends StatelessWidget {
  final bool highlightMutual;
  final VoidCallback onPressed;

  const _QuickMessageIconButton({
    required this.highlightMutual,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: highlightMutual ? 'Chat Cepat (Teman Mutual)' : 'Kirim Pesan',
      child: Material(
        color: highlightMutual
            ? AppTheme.accentGold.withValues(alpha: 0.18)
            : AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: highlightMutual
                ? AppTheme.accentGold
                : AppTheme.borderWarm,
            width: 1.3,
          ),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              CupertinoIcons.chat_bubble_2_fill,
              size: 18,
              color: AppTheme.primaryBrown,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingPill extends StatelessWidget {
  final bool compact;

  const _LoadingPill({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 86 : 120,
      height: compact ? 30 : 38,
      decoration: BoxDecoration(
        color: AppTheme.borderWarm.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(compact ? 11 : 14),
      ),
    );
  }
}
