import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../utils/barista_utils.dart';
import '../../../screens/grinder_converter_screen.dart';

class GrinderConverterSheet {
  static void show(BuildContext context, String rawGrind) {
    final conversions = BaristaUtils.grinderConversions(rawGrind);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.78,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBrown.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.circle_grid_hex, color: AppTheme.primaryBrown, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Konversi Klik Grinder',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '💡 Referensi Resep: $rawGrind\nKonversi dihitung berdasarkan kalibrasi mikron partikel standar industri.',
                  style: const TextStyle(fontSize: 11, color: AppTheme.primaryBrown, height: 1.35, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: conversions.entries.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 6),
                  itemBuilder: (context, idx) {
                    final e = conversions.entries.elementAt(idx);
                    final isHeader = idx < 2; // Kategori & Ukuran Partikel
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isHeader ? AppTheme.primaryBrown.withValues(alpha: 0.06) : AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isHeader
                              ? AppTheme.primaryBrown.withValues(alpha: 0.2)
                              : AppTheme.primaryBrown.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  isHeader ? CupertinoIcons.sparkles : CupertinoIcons.slider_horizontal_3,
                                  size: 14,
                                  color: isHeader ? AppTheme.primaryBrown : AppTheme.accentAmber,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    e.key,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: isHeader ? AppTheme.primaryBrown : AppTheme.textDark,
                                      fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              e.value,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isHeader ? AppTheme.primaryBrown : const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBrown,
                    side: const BorderSide(color: AppTheme.primaryBrown),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GrinderConverterScreen()),
                    );
                  },
                  icon: const Icon(CupertinoIcons.circle_grid_hex_fill, size: 16),
                  label: const Text('Buka Matriks Lengkap Grinder & Mikron', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
