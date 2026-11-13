import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../controllers/communities_controllers.dart';

class InviteTokenJoinScreen extends ConsumerStatefulWidget {
  final String token;

  const InviteTokenJoinScreen({super.key, required this.token});

  @override
  ConsumerState<InviteTokenJoinScreen> createState() =>
      _InviteTokenJoinScreenState();
}

class _InviteTokenJoinScreenState extends ConsumerState<InviteTokenJoinScreen> {
  bool _joining = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_attemptJoin);
  }

  Future<void> _attemptJoin() async {
    setState(() {
      _joining = true;
      _error = null;
    });
    try {
      final res = await ref
          .read(secretIdJoinControllerProvider.notifier)
          .joinByToken(widget.token);
      if (!mounted) return;
      context.go('/social/clubs/${res.club.id}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _joining = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(title: const Text('Undangan Coffee Club')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.ticket_fill,
                size: 54,
                color: AppTheme.primaryBrown,
              ),
              const SizedBox(height: 16),
              if (_joining) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 14),
                const Text('Memverifikasi link undangan Coffee Club...'),
              ] else ...[
                Text(
                  _error ?? 'Klik Gabung untuk membuka club.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textDark),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _attemptJoin,
                  child: const Text('Gabung Club Sekarang'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
