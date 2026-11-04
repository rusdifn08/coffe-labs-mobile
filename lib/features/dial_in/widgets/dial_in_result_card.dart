import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/dial_in_models.dart';

class DialInResultCard extends StatelessWidget {
  final DiagnosisResult res;
  final bool isEn;

  const DialInResultCard({
    super.key,
    required this.res,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [res.bannerColor.withValues(alpha: 0.12), res.bannerColor.withValues(alpha: 0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: res.bannerColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(res.bannerIcon, color: res.bannerColor, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  res.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: res.bannerColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(res.rootCause, style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87)),
          const Divider(height: 24),
          Text(
            isEn ? '💡 Recommended Prescription / Tindakan:' : '💡 Rekomendasi Solusi & Kalibrasi:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          ...res.actions.map(
            (act) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBrown)),
                  Expanded(child: Text(act, style: const TextStyle(fontSize: 12.5, height: 1.35))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
