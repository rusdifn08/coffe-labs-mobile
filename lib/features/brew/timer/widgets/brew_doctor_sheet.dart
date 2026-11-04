import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/language_service.dart';

class BrewDoctorSheet {
  static void show(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEn ? 'Brew Doctor (Flavor Correction Guide)' : 'Brew Doctor (Panduan Koreksi Rasa)',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _doctorTipCard(
              icon: CupertinoIcons.bolt_fill,
              color: Colors.orange,
              title: isEn ? 'Too Sour / Acidic / Thin (Under-Extracted)' : 'Terlalu Asam / Kecut / Tipis (Under-Extracted)',
              fix: isEn
                  ? '• Fine grind by 1–2 clicks\n• Raise water temp by +2°C\n• Pour slightly slower or extend bloom time.'
                  : '• Haluskan gilingan 1–2 klik\n• Naikkan suhu air +2°C\n• Tuang sedikit lebih lambat atau tambah waktu bloom.',
            ),
            _doctorTipCard(
              icon: CupertinoIcons.flame_fill,
              color: Colors.redAccent,
              title: isEn ? 'Too Bitter / Astringent / Dry (Over-Extracted)' : 'Terlalu Pahit / Sepat / Kering (Over-Extracted)',
              fix: isEn
                  ? '• Coarsen grind by 1–2 clicks\n• Lower water temp by -2°C\n• Reduce agitation (swirl) and pour gently in center.'
                  : '• Kasarkan gilingan 1–2 klik\n• Turunkan suhu air -2°C\n• Kurangi goyangan (swirl) dan tuang lebih lembut di tengah.',
            ),
            _doctorTipCard(
              icon: CupertinoIcons.drop,
              color: Colors.blueAccent,
              title: isEn ? 'Low Body / Watery Brew (Weak)' : 'Kurang Body / Terlalu Encer (Weak)',
              fix: isEn
                  ? '• Use a tighter ratio (e.g. 1:14 or 1:15)\n• Increase coffee dose by +1g to +2g.'
                  : '• Gunakan rasio lebih pendek (misal 1:14 atau 1:15)\n• Tambahkan dosis kopi +1g hingga +2g.',
            ),
          ],
        ),
      ),
    );
  }

  static Widget _doctorTipCard({
    required IconData icon,
    required Color color,
    required String title,
    required String fix,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(fix, style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted, height: 1.4)),
        ],
      ),
    );
  }
}
