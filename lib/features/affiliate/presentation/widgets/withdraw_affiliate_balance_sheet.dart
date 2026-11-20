import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../qris_billing/domain/qris_billing_models.dart';
import '../../models/affiliate_models.dart';
import '../controllers/affiliate_controller.dart';

class WithdrawAffiliateBalanceSheet extends ConsumerStatefulWidget {
  final AffiliateWalletModel wallet;
  final AffiliateProgramTerms terms;

  const WithdrawAffiliateBalanceSheet({
    super.key,
    required this.wallet,
    required this.terms,
  });

  static Future<void> show(
    BuildContext context, {
    required AffiliateWalletModel wallet,
    required AffiliateProgramTerms terms,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1714),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => WithdrawAffiliateBalanceSheet(
        wallet: wallet,
        terms: terms,
      ),
    );
  }

  @override
  ConsumerState<WithdrawAffiliateBalanceSheet> createState() =>
      _WithdrawAffiliateBalanceSheetState();
}

class _WithdrawAffiliateBalanceSheetState
    extends ConsumerState<WithdrawAffiliateBalanceSheet> {
  late String _selectedChannelCode;
  late final TextEditingController _accountNumCtrl;
  late final TextEditingController _accountHolderCtrl;
  late final TextEditingController _amountCtrl;
  final TextEditingController _notesCtrl = TextEditingController();
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _selectedChannelCode = widget.wallet.savedPayoutChannel ?? 'BANK_BCA';
    _accountNumCtrl =
        TextEditingController(text: widget.wallet.savedAccountNumber ?? '');
    _accountHolderCtrl =
        TextEditingController(text: widget.wallet.savedAccountHolderName ?? '');
    final initialAmt = widget.wallet.availableBalanceIdr >=
            widget.terms.minWithdrawalIdr
        ? widget.wallet.availableBalanceIdr
        : widget.terms.minWithdrawalIdr;
    _amountCtrl = TextEditingController(text: initialAmt.toString());
  }

  @override
  void dispose() {
    _accountNumCtrl.dispose();
    _accountHolderCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  PayoutChannelOption get _selectedOption =>
      PayoutChannelOption.all.firstWhere(
        (c) => c.code == _selectedChannelCode,
        orElse: () => PayoutChannelOption.all.first,
      );

  Future<void> _submit() async {
    final rawAmt = int.tryParse(
          _amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    if (rawAmt < widget.terms.minWithdrawalIdr) {
      setState(() {
        _validationError =
            'Minimal penarikan adalah ${formatRupiahIdr(widget.terms.minWithdrawalIdr)}.';
      });
      return;
    }
    if (rawAmt > widget.wallet.availableBalanceIdr) {
      setState(() {
        _validationError =
            'Saldo tersedia Anda (${widget.wallet.formattedAvailable}) tidak mencukupi.';
      });
      return;
    }
    if (_accountNumCtrl.text.trim().length < 6) {
      setState(() {
        _validationError = 'Masukkan nomor rekening / e-wallet minimal 6 digit.';
      });
      return;
    }
    if (_accountHolderCtrl.text.trim().length < 2) {
      setState(() {
        _validationError = 'Masukkan nama pemilik rekening yang valid.';
      });
      return;
    }

    setState(() => _validationError = null);
    final opt = _selectedOption;
    final ticket = await ref
        .read(affiliateDashboardProvider.notifier)
        .submitWithdrawal(
          requestedAmountIdr: rawAmt,
          payoutChannel: opt.code,
          bankOrWalletLabel: opt.label,
          accountNumber: _accountNumCtrl.text.trim(),
          accountHolderName: _accountHolderCtrl.text.trim(),
          userNotes: _notesCtrl.text.trim(),
        );

    if (!mounted) return;
    if (ticket == null) {
      setState(() {
        _validationError = ref.read(affiliateDashboardProvider).errorMessage ??
            'Gagal mengajukan penarikan.';
      });
      return;
    }

    Navigator.of(context).pop();
    final slaStr =
        DateFormat('EEE, dd MMM HH:mm').format(ticket.slaDeadlineAt.toLocal());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        backgroundColor: const Color(0xFF166534),
        content: Text(
          'Tiket ${ticket.ticketNumber} (${formatRupiahIdr(ticket.netTransferAmountIdr)}) diajukan! Estimasi cair maks. $slaStr WIB.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(affiliateDashboardProvider).isSubmitting;
    final maxAvail = widget.wallet.availableBalanceIdr;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFFD4A373),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Tarik Saldo Afiliasi',
                    style: TextStyle(
                      color: Color(0xFFF9F5EE),
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  widget.wallet.formattedAvailable,
                  style: const TextStyle(
                    color: Color(0xFF4ADE80),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // SLA 1x24 Working Hours Info Banner
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A373).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD4A373).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.clock_fill,
                    color: Color(0xFFD4A373),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Transfer manual oleh Admin maksimal 1×24 jam hari kerja • Biaya admin Rp 0 • Minimal ${formatRupiahIdr(widget.terms.minWithdrawalIdr)}.',
                      style: const TextStyle(
                        color: Color(0xFFF9F5EE),
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              'Pilih Bank / E-Wallet Tujuan',
              style: TextStyle(
                color: Color(0xFFCBBFB2),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: PayoutChannelOption.all.map((opt) {
                final active = opt.code == _selectedChannelCode;
                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => _selectedChannelCode = opt.code),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFFD4A373)
                          : const Color(0xFF12100E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: active
                            ? const Color(0xFFD4A373)
                            : Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      opt.label,
                      style: TextStyle(
                        color: active
                            ? const Color(0xFF12100E)
                            : const Color(0xFFF9F5EE),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            _darkField(
              controller: _accountNumCtrl,
              label: _selectedOption.isEwallet
                  ? 'Nomor HP ${_selectedOption.label}'
                  : 'Nomor Rekening ${_selectedOption.label}',
              hint: _selectedOption.isEwallet ? '0812xxxxxxxx' : '1234567890',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            _darkField(
              controller: _accountHolderCtrl,
              label: 'Nama Pemilik Rekening (Sesuai Buku Tabungan/E-Wallet)',
              hint: 'Contoh: Risa Hanipah',
            ),
            const SizedBox(height: 8),
            _darkField(
              controller: _amountCtrl,
              label: 'Nominal Penarikan (Rp)',
              hint: 'Minimal 100000',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 7),

            // Quick Nominal Chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _quickAmtChip('Rp 100.000', 100000),
                if (maxAvail >= 250000) _quickAmtChip('Rp 250.000', 250000),
                if (maxAvail >= widget.terms.minWithdrawalIdr)
                  _quickAmtChip('Tarik Semua', maxAvail),
              ],
            ),

            if (_validationError != null) ...[
              const SizedBox(height: 10),
              Text(
                _validationError!,
                style: const TextStyle(
                  color: Color(0xFFFCA5A5),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: const Color(0xFF052E16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isSubmitting ? null : _submit,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF052E16),
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 17),
                label: Text(
                  isSubmitting
                      ? 'Mengajukan Penarikan...'
                      : 'Ajukan Penarikan Saldo',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAmtChip(String label, int val) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() => _amountCtrl.text = val.toString()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD4A373),
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _darkField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Color(0xFFF9F5EE),
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFFD4A373), fontSize: 11),
        hintStyle: const TextStyle(color: Color(0xFF78716C), fontSize: 11.5),
        filled: true,
        fillColor: const Color(0xFF12100E),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(
            color: const Color(0xFFD4A373).withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFFD4A373)),
        ),
      ),
    );
  }
}
