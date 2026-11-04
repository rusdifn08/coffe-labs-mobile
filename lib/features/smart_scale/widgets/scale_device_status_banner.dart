import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/smart_scale_model.dart';
import '../../../theme/app_theme.dart';

class ScaleDeviceStatusBanner extends StatelessWidget {
  final bool isEn;
  final bool isConnected;
  final SmartScaleDevice? currentDevice;
  final VoidCallback onOpenSheet;

  const ScaleDeviceStatusBanner({
    super.key,
    required this.isEn,
    required this.isConnected,
    required this.currentDevice,
    required this.onOpenSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1B18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isConnected ? Colors.blueAccent.withValues(alpha: 0.3) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
            color: isConnected ? Colors.blueAccent : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected
                      ? currentDevice?.name ?? 'Connected Scale'
                      : (isEn ? 'No Scale Connected' : 'Timbangan Belum Terhubung'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  isConnected
                      ? currentDevice?.brandLabel ?? 'Bluetooth BLE Scale'
                      : (isEn ? 'Tap to scan Timemore, Acaia, or BLE scale' : 'Ketuk untuk scan Timemore, Acaia, atau BLE'),
                  style: const TextStyle(fontSize: 10, color: Colors.white54),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onOpenSheet,
            child: Text(
              isConnected ? (isEn ? 'Change' : 'Ubah') : (isEn ? 'Connect' : 'Hubungkan'),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }
}
