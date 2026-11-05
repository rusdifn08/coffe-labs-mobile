import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/business_pos_models.dart';
import '../../../providers/workspace_mode_provider.dart';
import '../screens/business_main_layout.dart';

class BusinessSuiteLauncherCard extends ConsumerWidget {
  final bool isBusiness;

  const BusinessSuiteLauncherCard({
    super.key,
    required this.isBusiness,
  });

  void _handleTap(BuildContext context, WidgetRef ref) {
    if (isBusiness) {
      ref.read(workspaceModeProvider.notifier).forceSetMode(WorkspaceMode.business);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BusinessMainLayout()),
      );
    } else {
      _showUpgradeModal(context);
    }
  }

  void _showUpgradeModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Color(0xFFD4AF37), size: 28),
            SizedBox(width: 10),
            Text(
              'Business Suite Eksklusif',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fitur Mode Kasir (POS) dan AMOLED Always-On Menu Display khusus bagi pengguna dengan langganan Business (bukan Pro).',
              style: TextStyle(color: Color(0xFFC7C7C7), fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 14),
            Text(
              'Keunggulan Mode Business:',
              style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12),
            ),
            SizedBox(height: 6),
            Text('• Layar Kiosk True Pitch-Black OLED (#000000)', style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text('• Anti Burn-In Pixel-Shifting & Kiosk PIN Lock', style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text('• Validasi Transparansi Foto Menu Otomatis', style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text('• Kasir POS Cepat dengan Transaksi Bar Terintegrasi', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Nanti Saja', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Upgrade ke Business (249K)', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B18), Color(0xFF141312)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: isBusiness ? 0.45 : 0.20),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: isBusiness ? 0.10 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(context, ref),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
                  ),
                  child: const Icon(
                    CupertinoIcons.device_laptop,
                    color: Color(0xFFD4AF37),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // Info Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Mode Business',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'BUSINESS',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isBusiness
                            ? 'Dashboard Kafe, Kasir POS, Display AOD & Stock Opname'
                            : 'Eksklusif Business: Dashboard, Kasir, Display & Stock',
                        style: const TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Trailing Arrow or Lock
                Icon(
                  isBusiness ? CupertinoIcons.chevron_right : CupertinoIcons.lock_fill,
                  color: isBusiness ? const Color(0xFFD4AF37) : Colors.white38,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
