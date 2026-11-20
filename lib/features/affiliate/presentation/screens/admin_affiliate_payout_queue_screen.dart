import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../qris_billing/domain/qris_billing_models.dart';
import '../../models/affiliate_models.dart';
import '../controllers/affiliate_controller.dart';

/// Panel Admin ACC Penarikan Saldo Afiliasi (Eksklusif Akun Role ADMIN).
class AdminAffiliatePayoutQueueScreen extends ConsumerStatefulWidget {
  const AdminAffiliatePayoutQueueScreen({super.key});

  @override
  ConsumerState<AdminAffiliatePayoutQueueScreen> createState() =>
      _AdminAffiliatePayoutQueueScreenState();
}

class _AdminAffiliatePayoutQueueScreenState
    extends ConsumerState<AdminAffiliatePayoutQueueScreen> {
  static const List<(String status, String label)> _tabs = [
    ('PENDING_ADMIN_REVIEW', 'Pending ACC'),
    ('PROCESSING_BY_ADMIN', 'Diproses'),
    ('COMPLETED_TRANSFERRED', 'Selesai'),
    ('REJECTED_REFUNDED', 'Ditolak'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(adminPayoutQueueProvider.notifier).loadQueue(),
    );
  }

  Future<void> _openApproveModal(AdminWithdrawalItem item) async {
    final refCtrl = TextEditingController();
    Uint8List? proofBytes;
    String? proofName;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1714),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (sheetCtx, setModalState) {
          final busy = ref.watch(adminPayoutQueueProvider).isMutating;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              14,
              16,
              MediaQuery.of(sheetCtx).viewInsets.bottom + 18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACC Transfer ${item.ticketNumber} (${formatRupiahIdr(item.netTransferAmountIdr)})',
                  style: const TextStyle(
                    color: Color(0xFFF9F5EE),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.bankOrWalletLabel} • ${item.accountNumber} a/n ${item.accountHolderName}',
                  style: const TextStyle(
                    color: Color(0xFFD4A373),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD4A373),
                    side: const BorderSide(color: Color(0xFFD4A373)),
                    minimumSize: const Size(double.infinity, 42),
                  ),
                  onPressed: busy
                      ? null
                      : () async {
                          final picked = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                            maxWidth: 1600,
                          );
                          if (picked == null) return;
                          final bytes = await picked.readAsBytes();
                          setModalState(() {
                            proofBytes = bytes;
                            proofName = picked.name;
                          });
                        },
                  icon: Icon(
                    proofBytes != null
                        ? Icons.check_circle_rounded
                        : Icons.upload_file_rounded,
                    size: 17,
                  ),
                  label: Text(
                    proofName != null
                        ? 'Bukti Dipilih: $proofName'
                        : 'Pilih Screenshot Bukti Transfer (Wajib)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: refCtrl,
                  style: const TextStyle(color: Color(0xFFF9F5EE), fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'No. Referensi Bank (Opsional)',
                    hintText: 'Contoh: TRF-MANDIRI-88321',
                    labelStyle: const TextStyle(
                      color: Color(0xFFD4A373),
                      fontSize: 11.5,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF12100E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: const Color(0xFF052E16),
                    ),
                    onPressed: busy || proofBytes == null
                        ? null
                        : () async {
                            final ok = await ref
                                .read(adminPayoutQueueProvider.notifier)
                                .approveWithProof(
                                  withdrawalId: item.id,
                                  imageBytes: proofBytes!,
                                  filename: proofName ?? 'proof.png',
                                  transferRefCode: refCtrl.text.trim(),
                                );
                            if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: ok
                                    ? const Color(0xFF166534)
                                    : const Color(0xFF991B1B),
                                content: Text(
                                  ok
                                      ? 'Tiket ${item.ticketNumber} di-ACC & bukti dikirim!'
                                      : (ref
                                              .read(adminPayoutQueueProvider)
                                              .errorMessage ??
                                          'Gagal ACC penarikan.'),
                                ),
                              ),
                            );
                          },
                    icon: const Icon(Icons.verified_rounded, size: 17),
                    label: Text(
                      busy
                          ? 'Mengunggah Bukti & ACC...'
                          : 'ACC & Tandai Sudah Ditransfer',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openRejectDialog(AdminWithdrawalItem item) async {
    final reasonCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1714),
        title: Text(
          'Tolak & Refund ${item.ticketNumber}',
          style: const TextStyle(
            color: Color(0xFFF9F5EE),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          style: const TextStyle(color: Color(0xFFF9F5EE), fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Contoh: Nomor rekening BCA tidak ditemukan / nama tidak cocok',
            hintStyle: const TextStyle(color: Color(0xFF78716C), fontSize: 12),
            filled: true,
            fillColor: const Color(0xFF12100E),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (reasonCtrl.text.trim().length < 4) return;
              final ok = await ref
                  .read(adminPayoutQueueProvider.notifier)
                  .rejectWithdrawal(
                    withdrawalId: item.id,
                    reason: reasonCtrl.text.trim(),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor:
                      ok ? const Color(0xFF166534) : const Color(0xFF991B1B),
                  content: Text(
                    ok
                        ? 'Tiket ditolak & saldo dikembalikan penuh ke afiliator.'
                        : 'Gagal menolak tiket.',
                  ),
                ),
              );
            },
            child: const Text('Tolak & Refund'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminPayoutQueueProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF12100E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12100E),
        foregroundColor: const Color(0xFFF9F5EE),
        elevation: 0,
        toolbarHeight: 48,
        title: const Text(
          'Panel Admin ACC Penarikan',
          style: TextStyle(
            color: Color(0xFFF9F5EE),
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(adminPayoutQueueProvider.notifier).loadQueue(),
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFD4A373)),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _tabs.map((t) {
                final active = state.selectedStatus == t.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    selected: active,
                    selectedColor: const Color(0xFFD4A373),
                    backgroundColor: const Color(0xFF1C1714),
                    label: Text(
                      t.$2,
                      style: TextStyle(
                        color: active
                            ? const Color(0xFF12100E)
                            : const Color(0xFFF9F5EE),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onSelected: (_) => ref
                        .read(adminPayoutQueueProvider.notifier)
                        .loadQueue(status: t.$1),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD4A373)),
                  )
                : state.items.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada tiket pada status ini.',
                          style: TextStyle(color: Color(0xFFA8A29E)),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                        itemCount: state.items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, idx) =>
                            _buildAdminCard(state.items[idx], state.isMutating),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(AdminWithdrawalItem item, bool busy) {
    final rem = item.slaDeadlineAt.difference(DateTime.now());
    final slaText = rem.isNegative
        ? 'Lewat SLA'
        : 'Sisa ${rem.inHours}j ${rem.inMinutes % 60}m';
    final df = DateFormat('dd MMM HH:mm');
    final isActionable = item.status == 'PENDING_ADMIN_REVIEW' ||
        item.status == 'PROCESSING_BY_ADMIN';

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1714),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4A373).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${item.affiliateFullName} (@${item.affiliateUsername})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF9F5EE),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: rem.isNegative
                      ? const Color(0xFFDC2626).withValues(alpha: 0.25)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  slaText,
                  style: TextStyle(
                    color: rem.isNegative
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFFFBBF24),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '${item.ticketNumber} • Kode ${item.affiliateCode} • ${df.format(item.createdAt.toLocal())}',
            style: const TextStyle(color: Color(0xFF9C8F82), fontSize: 10.5),
          ),
          const SizedBox(height: 9),

          // Quick Copy Bank & Exact Amount Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF12100E),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.bankOrWalletLabel} • ${item.accountNumber}',
                  style: const TextStyle(
                    color: Color(0xFFF9F5EE),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'a/n ${item.accountHolderName}',
                  style: const TextStyle(
                    color: Color(0xFFCBBFB2),
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      formatRupiahIdr(item.netTransferAmountIdr),
                      style: const TextStyle(
                        color: Color(0xFF4ADE80),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    _miniCopyBtn('Salin Rek', item.accountNumber),
                    _miniCopyBtn(
                      'Salin Nominal',
                      item.netTransferAmountIdr.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (isActionable) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (item.status == 'PENDING_ADMIN_REVIEW')
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD4A373),
                      side: const BorderSide(color: Color(0xFFD4A373)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                    ),
                    onPressed: busy
                        ? null
                        : () => ref
                            .read(adminPayoutQueueProvider.notifier)
                            .markProcessing(item.id),
                    icon: const Icon(Icons.sync_rounded, size: 15),
                    label: const Text(
                      'Diproses',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: const Color(0xFF052E16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                  ),
                  onPressed: busy ? null : () => _openApproveModal(item),
                  icon: const Icon(Icons.check_circle_rounded, size: 15),
                  label: const Text(
                    'ACC & Upload Bukti',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFCA5A5),
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                  ),
                  onPressed: busy ? null : () => _openRejectDialog(item),
                  icon: const Icon(CupertinoIcons.xmark_circle, size: 15),
                  label: const Text(
                    'Tolak',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniCopyBtn(String label, String value) {
    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('$label ($value) disalin!'),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFD4A373).withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD4A373),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
