import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_pos_models.dart';
import '../models/subscription_plan.dart';
import '../services/auth_service.dart';
import '../services/subscription_service.dart';

class WorkspaceModeController extends Notifier<WorkspaceMode> {
  @override
  WorkspaceMode build() {
    return WorkspaceMode.personalBrewer;
  }

  /// Beralih mode workspace dengan validasi ketat Business Tier
  Future<bool> requestSwitchMode({
    required WorkspaceMode targetMode,
    required BuildContext context,
  }) async {
    if (targetMode == WorkspaceMode.personalBrewer) {
      state = WorkspaceMode.personalBrewer;
      return true;
    }

    // Periksa status lisensi Business
    final isAuthorized = await _checkBusinessTierAccess();
    if (!isAuthorized) {
      if (context.mounted) {
        _showUpgradeToBusinessDialog(context);
      }
      return false;
    }

    state = targetMode;
    return true;
  }

  void forceSetMode(WorkspaceMode mode) {
    state = mode;
  }

  static Future<bool> _checkBusinessTierAccess() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user?.role == 'admin') return true;
      final tier = await SubscriptionService.getCurrentTier();
      return tier == SubscriptionTier.business;
    } catch (_) {
      return false;
    }
  }

  static void _showUpgradeToBusinessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
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
              'Mode Kasir (POS) & AMOLED Always-On Menu Display dirancang khusus untuk operasional kedai kopi berlangganan Business.',
              style: TextStyle(color: Color(0xFFC7C7C7), fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 14),
            Text(
              'Fitur Unggulan Business:',
              style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12),
            ),
            SizedBox(height: 6),
            Text('• Layar Kiosk True Pitch-Black OLED (#000000)', style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text('• Anti Burn-In Pixel-Shifting & Kiosk PIN Lock', style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text('• Kasir POS Cepat & Sinkronisasi Pesanan Bar', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Upgrade ke Business', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

final workspaceModeProvider = NotifierProvider<WorkspaceModeController, WorkspaceMode>(
  WorkspaceModeController.new,
);
