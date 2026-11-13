import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../controllers/communities_controllers.dart';

class CommunityDeepLinkListener extends ConsumerStatefulWidget {
  final Widget child;

  const CommunityDeepLinkListener({super.key, required this.child});

  @override
  ConsumerState<CommunityDeepLinkListener> createState() =>
      _CommunityDeepLinkListenerState();
}

class _CommunityDeepLinkListenerState
    extends ConsumerState<CommunityDeepLinkListener> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  String? _lastHandledUri;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        _handleIncomingUri(initial);
      }
    } catch (_) {}
    _sub = _appLinks.uriLinkStream.listen(_handleIncomingUri, onError: (_) {});
  }

  Future<void> _handleIncomingUri(Uri uri) async {
    final full = uri.toString();
    if (_lastHandledUri == full) return;
    final token = _extractClubInviteToken(uri);
    if (token == null || token.isEmpty) return;

    _lastHandledUri = full;
    try {
      final joined = await ref
          .read(secretIdJoinControllerProvider.notifier)
          .joinByToken(token);
      if (!mounted) return;
      ref.read(appRouterProvider).go('/social/clubs/${joined.club.id}');
    } catch (_) {
      // Fallback: open interactive link resolver screen if user isn't logged in yet
      ref.read(appRouterProvider).go('/c/$token');
    }
  }

  static String? _extractClubInviteToken(Uri uri) {
    final segs = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (uri.scheme == 'coffeelabs' &&
        uri.host == 'club' &&
        segs.length >= 2 &&
        segs.first == 'join') {
      return segs[1];
    }
    if (uri.scheme.startsWith('http') &&
        uri.host.contains('coffeelabs.app') &&
        segs.length >= 2 &&
        segs.first == 'c') {
      return segs[1];
    }
    return null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
