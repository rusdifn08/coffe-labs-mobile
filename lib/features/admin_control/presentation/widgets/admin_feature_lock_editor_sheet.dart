import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_theme.dart';
import '../../models/admin_control_models.dart';

class AdminLockEditResult {
  final bool isLocked;
  final FeatureLockStatus lockStatus;
  final String? customBadgeLabel;
  final String lockTitle;
  final String lockMessage;
  final DateTime? estimatedUnlockAt;
  final bool allowAdminBypass;

  const AdminLockEditResult({
    required this.isLocked,
    required this.lockStatus,
    this.customBadgeLabel,
    required this.lockTitle,
    required this.lockMessage,
    this.estimatedUnlockAt,
    required this.allowAdminBypass,
  });
}

/// Bottom sheet cepat untuk memilih status warna (`MAINTENANCE`, `COMING_SOON`, `UPDATED`),
/// pesan kustom, estimasi buka (ETA), dan toggle Admin QA Bypass.
class AdminFeatureLockEditorSheet extends StatefulWidget {
  final FeatureControlItem item;

  const AdminFeatureLockEditorSheet({super.key, required this.item});

  static Future<AdminLockEditResult?> show(
    BuildContext context, {
    required FeatureControlItem item,
  }) {
    return showModalBottomSheet<AdminLockEditResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => AdminFeatureLockEditorSheet(item: item),
    );
  }

  @override
  State<AdminFeatureLockEditorSheet> createState() =>
      _AdminFeatureLockEditorSheetState();
}

class _AdminFeatureLockEditorSheetState
    extends State<AdminFeatureLockEditorSheet> {
  late bool _isLocked;
  late FeatureLockStatus _selectedStatus;
  late TextEditingController _badgeCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _msgCtrl;
  DateTime? _eta;
  late bool _allowAdminBypass;

  @override
  void initState() {
    super.initState();
    _isLocked = widget.item.isLocked;
    _selectedStatus = widget.item.lockStatus == FeatureLockStatus.unlocked
        ? FeatureLockStatus.maintenance
        : widget.item.lockStatus;
    _badgeCtrl = TextEditingController(text: widget.item.customBadgeLabel ?? '');
    _titleCtrl = TextEditingController(text: widget.item.lockTitle);
    _msgCtrl = TextEditingController(text: widget.item.lockMessage);
    _eta = widget.item.estimatedUnlockAt;
    _allowAdminBypass = widget.item.allowAdminBypass;
  }

  @override
  void dispose() {
    _badgeCtrl.dispose();
    _titleCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _applyQuickEta(Duration? offset) {
    setState(() {
      _eta = offset == null ? null : DateTime.now().add(offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 12, 18, bottomInset + 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBrown.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.featureKey,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textMuted,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          widget.item.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark_circle_fill,
                        color: AppTheme.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Master Lock Switch
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isLocked
                        ? _selectedStatus.cardBorderColor
                        : AppTheme.borderWarm,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isLocked ? CupertinoIcons.lock_fill : CupertinoIcons.lock_open_fill,
                      size: 18,
                      color: _isLocked
                          ? _selectedStatus.accentTextColor
                          : const Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isLocked ? 'Kartu Sedang Dikunci' : 'Kartu Aktif (Terbuka)',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            _isLocked
                                ? 'User non-Admin tidak bisa masuk ke fitur ini'
                                : 'Semua user bisa mengakses fitur secara normal',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _isLocked,
                      activeThumbColor: _selectedStatus.accentTextColor,
                      onChanged: (v) => setState(() => _isLocked = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Status Selector (3 Warna Berbeda)
              Opacity(
                opacity: _isLocked ? 1.0 : 0.45,
                child: IgnorePointer(
                  ignoring: !_isLocked,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Status & Warna Kartu Toolkit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _statusOption(FeatureLockStatus.maintenance, 'Maintenance'),
                          const SizedBox(width: 8),
                          _statusOption(FeatureLockStatus.comingSoon, 'Coming Soon'),
                          const SizedBox(width: 8),
                          _statusOption(FeatureLockStatus.updated, 'Updated'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _badgeCtrl,
                        decoration: InputDecoration(
                          labelText: 'Override Teks Pill (Opsional)',
                          hintText: _selectedStatus.defaultBadgeLabel,
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _titleCtrl,
                        decoration: InputDecoration(
                          labelText: 'Judul Pesan (Opsional)',
                          hintText: _selectedStatus.defaultTitleFor(widget.item.displayName),
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _msgCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Pesan Kustom untuk Pengguna',
                          hintText: _selectedStatus.defaultMessage,
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _eta == null
                            ? 'Estimasi Buka (ETA): Tidak diatur'
                            : 'Estimasi Buka: ${DateFormat('dd MMM HH:mm').format(_eta!.toLocal())}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _etaChip('+15 mnt', const Duration(minutes: 15)),
                          _etaChip('+30 mnt', const Duration(minutes: 30)),
                          _etaChip('+1 jam', const Duration(hours: 1)),
                          _etaChip('+3 jam', const Duration(hours: 3)),
                          if (_eta != null) _etaChip('Hapus ETA', null),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        value: _allowAdminBypass,
                        title: const Text(
                          'Izinkan Admin QA Bypass',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        subtitle: const Text(
                          'Akun Admin tetap bisa masuk mengetes fitur terkunci',
                          style: TextStyle(fontSize: 11),
                        ),
                        onChanged: (v) => setState(() => _allowAdminBypass = v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _isLocked
                        ? _selectedStatus.accentTextColor
                        : const Color(0xFF16A34A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(
                      AdminLockEditResult(
                        isLocked: _isLocked,
                        lockStatus: _isLocked
                            ? _selectedStatus
                            : FeatureLockStatus.unlocked,
                        customBadgeLabel: _badgeCtrl.text.trim().isEmpty
                            ? null
                            : _badgeCtrl.text.trim(),
                        lockTitle: _titleCtrl.text.trim(),
                        lockMessage: _msgCtrl.text.trim(),
                        estimatedUnlockAt: _isLocked ? _eta : null,
                        allowAdminBypass: _allowAdminBypass,
                      ),
                    );
                  },
                  icon: Icon(
                    _isLocked ? Icons.bolt_rounded : CupertinoIcons.lock_open_fill,
                    size: 18,
                  ),
                  label: Text(
                    _isLocked
                        ? 'Terapkan Lock Real-Time'
                        : 'Buka Kunci Real-Time',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusOption(FeatureLockStatus status, String label) {
    final selected = _selectedStatus == status;
    final accent = status.accentTextColor;
    return Expanded(
      child: GestureDetector(
        key: Key('lock_status_opt_${status.apiValue}'),
        onTap: () => setState(() => _selectedStatus = status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? status.pillBackgroundColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? accent : AppTheme.borderWarm,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(status.statusIcon, size: 18, color: accent),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: selected ? accent : AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _etaChip(String label, Duration? offset) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppTheme.borderWarm),
      onPressed: () => _applyQuickEta(offset),
    );
  }
}
