import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../controllers/communities_controllers.dart';
import '../utils/crockford_input_formatter.dart';

class JoinClubBySecretIdSheet extends ConsumerStatefulWidget {
  const JoinClubBySecretIdSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const JoinClubBySecretIdSheet(),
    );
  }

  @override
  ConsumerState<JoinClubBySecretIdSheet> createState() =>
      _JoinClubBySecretIdSheetState();
}

class _JoinClubBySecretIdSheetState
    extends ConsumerState<JoinClubBySecretIdSheet> {
  final _controller = TextEditingController();
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _controller.text.trim();
    if (CrockfordSecretIdInputFormatter.normalizeCore(code).length < 10) {
      setState(() => _errorText = 'Masukkan 10 karakter lengkap kode Secret ID.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });
    await HapticFeedback.mediumImpact();

    try {
      final res = await ref
          .read(secretIdJoinControllerProvider.notifier)
          .joinBySecret(code);
      if (!mounted) return;
      Navigator.of(context).pop();
      context.push('/social/clubs/${res.club.id}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderWarm,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      CupertinoIcons.lock_shield_fill,
                      color: AppTheme.primaryBrown,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gabung Club Rahasia',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          'Masukkan Secret ID dari Founder atau Admin Club',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _controller,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [CrockfordSecretIdInputFormatter()],
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppTheme.primaryBrown,
                ),
                decoration: InputDecoration(
                  hintText: 'CLB-4F9K-2X8P4W',
                  hintStyle: TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.textMuted.withValues(alpha: 0.55),
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceWhite,
                  prefixIcon: const Icon(
                    CupertinoIcons.ticket_fill,
                    color: AppTheme.accentAmber,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.borderWarm),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.borderWarm),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: AppTheme.primaryBrown, width: 1.6),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorText!,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(CupertinoIcons.checkmark_seal_fill, size: 18),
                label: Text(_submitting ? 'Memverifikasi...' : 'Gabung Club Sekarang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
