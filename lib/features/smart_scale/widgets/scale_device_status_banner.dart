import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/smart_scale_model.dart';
import '../../../theme/app_theme.dart';

/// Coffee Labs bright-theme Bluetooth 5.2 Smart Scale status banner.
class ScaleDeviceStatusBanner extends StatelessWidget {
  final bool isEn;
  final bool isConnected;
  final SmartScaleDevice? currentDevice;
  final int? batteryLevel;
  final VoidCallback onOpenSheet;

  const ScaleDeviceStatusBanner({
    super.key,
    required this.isEn,
    required this.isConnected,
    required this.currentDevice,
    this.batteryLevel,
    required this.onOpenSheet,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isConnected ? const Color(0xFF0F766E) : AppTheme.primaryBrown;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConnected
              ? const Color(0xFF0F766E).withValues(alpha: 0.35)
              : AppTheme.borderWarm,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              isConnected
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.bluetooth,
              color: accent,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        isConnected
                            ? (currentDevice?.name ?? 'Bluetooth Scale')
                            : (isEn
                                ? 'No Scale Connected'
                                : 'Timbangan Belum Terhubung'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.8,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    if (isConnected && batteryLevel != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$batteryLevel%',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isConnected
                      ? (currentDevice?.brandLabel ?? 'Bluetooth 5.2 Scale')
                      : (isEn
                          ? 'Pair TIMEMORE Dot, Coffee Labs C3, or BLE 5.2 scale'
                          : 'Hubungkan TIMEMORE Dot, Coffee Labs C3, atau BLE 5.2'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onOpenSheet,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: isConnected ? AppTheme.bgCream : AppTheme.primaryBrown,
                borderRadius: BorderRadius.circular(10),
                border: isConnected
                    ? Border.all(color: AppTheme.borderWarm)
                    : null,
              ),
              child: Text(
                isConnected
                    ? (isEn ? 'Manage' : 'Kelola')
                    : (isEn ? 'Pair' : 'Pindai'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isConnected ? AppTheme.primaryBrown : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
