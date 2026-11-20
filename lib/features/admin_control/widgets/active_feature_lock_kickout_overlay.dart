import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/system_control_sync_controller.dart';
import '../models/admin_control_models.dart';

/// Watcher global di root aplikasi yang:
/// 1. Menginisialisasi koneksi real-time WebSocket Control Plane & re-sync saat app resumed.
/// 2. Menjalankan **Active-Session Maintenance Kickout**: jika user non-Admin sedang berada
///    di dalam layar fitur saat Admin menekan Lock, overlay kunci non-dismissible langsung muncul!
class ActiveFeatureLockKickoutWatcher extends ConsumerStatefulWidget {
  final GoRouter router;
  final Widget child;

  const ActiveFeatureLockKickoutWatcher({
    super.key,
    required this.router,
    required this.child,
  });

  @override
  ConsumerState<ActiveFeatureLockKickoutWatcher> createState() =>
      _ActiveFeatureLockKickoutWatcherState();
}

class _ActiveFeatureLockKickoutWatcherState
    extends ConsumerState<ActiveFeatureLockKickoutWatcher>
    with WidgetsBindingObserver {
  String _currentPath = AppRoutes.home;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentPath = _readRouterPath();
    widget.router.routerDelegate.addListener(_onRouteChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(systemControlProvider.notifier).initialize();
      }
    });
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_onRouteChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String _readRouterPath() {
    try {
      return widget.router.routerDelegate.currentConfiguration.uri.path;
    } catch (_) {
      return AppRoutes.home;
    }
  }

  void _onRouteChanged() {
    final next = _readRouterPath();
    if (next == _currentPath || !mounted) return;
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      setState(() => _currentPath = next);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _currentPath != next) {
          setState(() => _currentPath = next);
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(systemControlProvider.notifier).syncFromRest());
    }
  }

  @override
  Widget build(BuildContext context) {
    final controlState = ref.watch(systemControlProvider);
    final authUser = ref.watch(authControllerProvider).value;
    final isAdmin =
        (authUser?.isAdmin ?? false) || (AuthService.cachedIsAdmin ?? false);

    FeatureControlItem? activeLock;
    final pushedKey = controlState.activePushedFeatureKey;
    if (pushedKey != null && pushedKey.isNotEmpty) {
      final candidate = controlState.snapshot.featureForKey(pushedKey);
      if (candidate != null && candidate.isLocked) {
        activeLock = candidate;
      }
    }
    activeLock ??= controlState.snapshot.findLockedFeatureForRoute(_currentPath);

    final shouldKickout = activeLock != null &&
        !(isAdmin && activeLock.allowAdminBypass);

    return Stack(
      children: [
        widget.child,
        if (shouldKickout) _buildKickoutOverlay(activeLock),
      ],
    );
  }

  Widget _buildKickoutOverlay(FeatureControlItem locked) {
    final status = locked.lockStatus;
    final accent = status.accentTextColor;
    final pillBg = status.pillBackgroundColor;
    final borderColor = status.cardBorderColor;

    return Positioned.fill(
      child: Material(
        color: AppTheme.bgCream.withValues(alpha: 0.96),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor, width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.14),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: pillBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Icon(status.statusIcon, color: accent, size: 30),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.lock_fill, size: 12, color: accent),
                          const SizedBox(width: 5),
                          Text(
                            locked.effectiveBadgeLabel,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      locked.effectiveTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      locked.effectiveMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textDark,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(systemControlProvider.notifier)
                              .setActiveFeatureScreen(null);
                          widget.router.routerDelegate.navigatorKey
                              .currentState
                              ?.popUntil((route) => route.isFirst);
                          widget.router.go(AppRoutes.home);
                        },
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text(
                          'Kembali ke Barista Toolkit',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
