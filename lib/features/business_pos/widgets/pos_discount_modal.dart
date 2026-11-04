import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PosDiscountModal extends StatefulWidget {
  final int subtotal;
  final Function(int discountAmount, String discountReason) onApply;

  const PosDiscountModal({
    super.key,
    required this.subtotal,
    required this.onApply,
  });

  static void show(
    BuildContext context, {
    required int subtotal,
    required Function(int discountAmount, String discountReason) onApply,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PosDiscountModal(subtotal: subtotal, onApply: onApply),
    );
  }

  @override
  State<PosDiscountModal> createState() => _PosDiscountModalState();
}

class _PosDiscountModalState extends State<PosDiscountModal> {
  int _selectedPercent = 0;
  final _customAmountController = TextEditingController();
  final _reasonController = TextEditingController(text: 'Diskon Promosi Bar');

  @override
  void dispose() {
    _customAmountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _applyDiscount() {
    int finalDiscount = 0;
    if (_selectedPercent > 0) {
      finalDiscount = ((widget.subtotal * _selectedPercent) / 100).round();
    } else {
      final custom = int.tryParse(_customAmountController.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
      finalDiscount = custom.clamp(0, widget.subtotal);
    }

    widget.onApply(finalDiscount, _reasonController.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.tag_fill, color: Color(0xFFD4AF37), size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Diskon & Potongan Barista', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Pilih persentase atau masukkan nominal custom', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.white38),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Percentage Buttons
          const Text('Pilihan Cepat (%):', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [5, 10, 15, 20, 50].map((p) {
              final isSel = _selectedPercent == p;
              return ChoiceChip(
                label: Text('$p%', style: TextStyle(color: isSel ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                selected: isSel,
                selectedColor: const Color(0xFFD4AF37),
                backgroundColor: const Color(0xFF222222),
                side: BorderSide(color: isSel ? const Color(0xFFD4AF37) : Colors.white12),
                onSelected: (val) {
                  setState(() {
                    _selectedPercent = val ? p : 0;
                    if (val) _customAmountController.clear();
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // Custom Amount Input
          const Text('Atau Masukkan Nominal Potongan (Rp):', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _customAmountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: 'Rp  ',
              prefixStyle: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
              hintText: 'Misal: 10000',
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (val) {
              if (val.isNotEmpty && _selectedPercent != 0) {
                setState(() => _selectedPercent = 0);
              }
            },
          ),

          const SizedBox(height: 14),

          // Alasan / Keterangan
          const Text('Alasan Potongan:', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _reasonController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Misal: Member VIP / Kompensasi Rasa',
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),

          const SizedBox(height: 20),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _applyDiscount,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(CupertinoIcons.checkmark_alt, size: 18),
              label: const Text('Terapkan Diskon ke Keranjang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
            ),
          ),
        ],
      ),
    );
  }
}
