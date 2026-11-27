import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../models/smart_scale_model.dart';
import '../../../services/language_service.dart';
import '../../../services/smart_scale_service.dart';
import '../../../theme/app_theme.dart';

/// Coffee Labs bright-theme Bluetooth 5.2 Smart Scale scanner sheet.
/// Scans exclusively for real physical BLE coffee scales — ZERO fake devices.
class ScaleDeviceSheet extends StatelessWidget {
  final SmartScaleService scaleService;

  const ScaleDeviceSheet({
    super.key,
    required this.scaleService,
  });

  static void show(BuildContext context, SmartScaleService service) {
    if (!service.isConnected) {
      service.startScan();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ScaleDeviceSheet(scaleService: service),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final canRequestTurnOn =
        !kIsWeb && !Platform.environment.containsKey('FLUTTER_TEST') && Platform.isAndroid;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: AnimatedBuilder(
        animation: scaleService,
        builder: (context, _) {
          final devices = scaleService.discoveredDevices;
          final isScanning = scaleService.isScanning;
          final isConnected = scaleService.isConnected;
          final activeDevice = scaleService.activeDevice;
          final statusNotice = scaleService.lastStatusMessage;
          final isBtOff = scaleService.isBluetoothSupported && !scaleService.isBluetoothOn;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderWarm,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: (isConnected
                              ? const Color(0xFF16A34A)
                              : AppTheme.primaryBrown)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isConnected
                          ? Icons.bluetooth_connected_rounded
                          : CupertinoIcons.bluetooth,
                      color: isConnected
                          ? const Color(0xFF16A34A)
                          : AppTheme.primaryBrown,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn
                              ? 'Bluetooth 5.2 Coffee Scales'
                              : 'Timbangan Bluetooth 5.2',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          isConnected
                              ? (isEn
                                  ? 'Connected to ${activeDevice!.name}'
                                  : 'Terhubung ke ${activeDevice!.name}')
                              : isScanning
                                  ? (isEn
                                      ? 'Scanning nearby real BLE scales...'
                                      : 'Memindai timbangan BLE fisik di sekitar...')
                                  : (isEn
                                      ? 'Turn on your scale and place it nearby'
                                      : 'Nyalakan timbangan & dekatkan ke ponsel'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isConnected ? FontWeight.w700 : FontWeight.w500,
                            color: isConnected
                                ? const Color(0xFF16A34A)
                                : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (isScanning) {
                        scaleService.stopScan();
                      } else {
                        scaleService.startScan();
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderWarm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isScanning
                                ? CupertinoIcons.stop_fill
                                : CupertinoIcons.arrow_clockwise,
                            size: 13,
                            color: AppTheme.primaryBrown,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isScanning
                                ? 'Stop'
                                : (isEn ? 'Scan' : 'Pindai'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (isScanning) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: AppTheme.borderWarm,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
                  ),
                ),
              ],
              if (statusNotice != null && statusNotice.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.info_circle_fill,
                        size: 16,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          statusNotice,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF92400E),
                            height: 1.35,
                          ),
                        ),
                      ),
                      if (isBtOff && canRequestTurnOn) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            final ok =
                                await scaleService.requestTurnOnBluetooth();
                            if (ok) {
                              await scaleService.startScan();
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isEn ? 'Turn On' : 'Nyalakan',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    // 0. Active Real Connected Scale Panel
                    if (isConnected && activeDevice != null) ...[
                      _buildActiveConnectedCard(context, activeDevice, isEn),
                      const SizedBox(height: 14),
                    ],

                    // 1. Scan Filter Toggle (All real BLE devices vs Smart Scale filter)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isEn
                                ? 'DISCOVERED DEVICES (${devices.length})'
                                : 'PERANGKAT TERDETEKSI (${devices.length})',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            final next = !scaleService.includeAllBleDevices;
                            scaleService.setIncludeAllBleDevices(next);
                            scaleService.startScan(includeAllDevices: next);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: scaleService.includeAllBleDevices
                                  ? AppTheme.primaryBrown.withValues(alpha: 0.12)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: scaleService.includeAllBleDevices
                                    ? AppTheme.primaryBrown
                                    : AppTheme.borderWarm,
                              ),
                            ),
                            child: Text(
                              scaleService.includeAllBleDevices
                                  ? (isEn ? 'All BLE: ON' : 'Semua BLE: ON')
                                  : (isEn ? 'Scale Only' : 'Filter Timbangan'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: scaleService.includeAllBleDevices
                                    ? AppTheme.primaryBrown
                                    : AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (devices.isNotEmpty) ...[
                      ...devices.map((d) => _buildDiscoveredTile(context, d, isEn)),
                      const SizedBox(height: 16),
                    ] else ...[
                      _buildEmptyScanCard(isEn: isEn, isScanning: isScanning),
                      const SizedBox(height: 16),
                    ],

                    // 2. Supported Hardware Catalog (TIMEMORE Dot + Coffee Labs Scale C3)
                    Text(
                      isEn
                          ? 'COMPATIBLE BLUETOOTH 5.2 SCALES'
                          : 'TIMBANGAN BLUETOOTH 5.2 DIDUKUNG',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...SupportedScaleHardware.catalog.map(
                      (hw) => _buildHardwareCard(hw),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveConnectedCard(
    BuildContext context,
    SmartScaleDevice device,
    bool isEn,
  ) {
    final weight = scaleService.currentWeight;
    final flow = scaleService.flowRate;
    final battery = scaleService.batteryLevel;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF16A34A).withValues(alpha: 0.5),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bluetooth_connected_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '${device.shortBrand} • ${isEn ? 'REAL BLE LIVE' : 'TERHUBUNG REAL BLE'}${battery != null ? ' • $battery%' : ''}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${weight.toStringAsFixed(1)} g',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        '${flow.toStringAsFixed(1)} g/s',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => scaleService.tare(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 9,
                  ),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isEn ? 'TARE' : 'NOL',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              OutlinedButton(
                onPressed: () async {
                  await scaleService.disconnect();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB91C1C),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isEn ? 'Disconnect' : 'Putus',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveredTile(
    BuildContext context,
    SmartScaleDevice device,
    bool isEn,
  ) {
    final isCurrent =
        scaleService.isConnected && scaleService.activeDevice?.id == device.id;
    final isConnectingThis = scaleService.connectingDeviceId == device.id;
    final isC3 = device.brand == ScaleBrand.coffeeLabsC3;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent
              ? const Color(0xFF16A34A)
              : AppTheme.borderWarm,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: (isCurrent
                      ? const Color(0xFF16A34A)
                      : (isC3 ? AppTheme.primaryBrown : const Color(0xFF0369A1)))
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              isCurrent
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.bluetooth,
              color: isCurrent
                  ? const Color(0xFF16A34A)
                  : (isC3 ? AppTheme.primaryBrown : const Color(0xFF0369A1)),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${device.shortBrand} • ${device.signalLabel} (${device.rssi} dBm)',
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
          ElevatedButton(
            onPressed: scaleService.isConnecting
                ? null
                : () async {
                    if (isCurrent) {
                      await scaleService.disconnect();
                    } else {
                      final ok = await scaleService.connect(device);
                      if (ok && context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isCurrent ? const Color(0xFFB91C1C) : AppTheme.primaryBrown,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 34),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isConnectingThis
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isCurrent
                        ? (isEn ? 'Disconnect' : 'Putus')
                        : (isEn ? 'Connect' : 'Hubungkan'),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScanCard({
    required bool isEn,
    required bool isScanning,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppTheme.bgCream,
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.bluetooth,
              color: isScanning ? AppTheme.primaryBrown : AppTheme.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isScanning
                ? (isEn
                    ? 'Searching for Bluetooth 5.2 Scale...'
                    : 'Mencari Timbangan Bluetooth 5.2...')
                : (isEn
                    ? 'No Physical Scale Detected Yet'
                    : 'Belum Ada Timbangan Fisik Terdeteksi'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            isEn
                ? 'Smart Scale works exclusively with real Bluetooth coffee scales. Ensure your TIMEMORE Dot, Acaia, Felicita, or Bookoo scale is powered on and disconnected from other apps.'
                : 'Smart Scale bekerja 100% langsung dengan timbangan kopi Bluetooth fisik. Pastikan timbangan menyala dan tidak terhubung ke aplikasi lain.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareCard(SupportedScaleHardware hw) {
    final badgeBg = hw.isUpcoming
        ? const Color(0xFFFFF7ED)
        : const Color(0xFFECFDF5);
    final badgeFg = hw.isUpcoming
        ? const Color(0xFFC2410C)
        : const Color(0xFF047857);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: hw.isUpcoming
              ? AppTheme.accentAmber.withValues(alpha: 0.45)
              : AppTheme.borderWarm,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hw.isUpcoming
                ? CupertinoIcons.sparkles
                : CupertinoIcons.checkmark_seal_fill,
            size: 18,
            color: hw.isUpcoming ? AppTheme.accentAmber : const Color(0xFF0F766E),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hw.name,
                  style: const TextStyle(
                    fontSize: 12.2,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  hw.protocol,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              hw.badgeText,
              style: TextStyle(
                fontSize: 9.2,
                fontWeight: FontWeight.w800,
                color: badgeFg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
