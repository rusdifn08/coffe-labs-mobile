import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/smart_scale_model.dart';
import '../../../services/language_service.dart';
import '../../../services/smart_scale_service.dart';
import '../../../theme/app_theme.dart';

class ScaleDeviceSheet extends StatelessWidget {
  final SmartScaleService scaleService;

  const ScaleDeviceSheet({
    super.key,
    required this.scaleService,
  });

  static void show(BuildContext context, SmartScaleService service) {
    service.startScan();
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

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1C19),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEn ? 'Bluetooth Coffee Scales' : 'Pindai Timbangan Bluetooth',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.arrow_clockwise, color: AppTheme.accentGold, size: 18),
                    onPressed: () {
                      scaleService.startScan();
                      setSheetState(() {});
                    },
                  ),
                ],
              ),
              Text(
                isEn
                    ? 'Compatible with Timemore (Dot / Black Mirror), Acaia, Felicita, and standard BLE scales.'
                    : 'Kompatibel dengan Timemore Dot Scale, Black Mirror, Acaia, Felicita, & BLE standar.',
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
              const Divider(height: 20, color: Colors.white12),
              Expanded(
                child: AnimatedBuilder(
                  animation: scaleService,
                  builder: (context, _) {
                    final devices = scaleService.discoveredDevices;
                    return ListView.separated(
                      itemCount: devices.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final d = devices[idx];
                        final isCur = scaleService.activeDevice?.id == d.id;
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF282521),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCur ? Colors.blueAccent : Colors.white10,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              d.brand == ScaleBrand.simulated ? CupertinoIcons.sparkles : CupertinoIcons.bluetooth,
                              color: isCur ? Colors.blueAccent : AppTheme.accentGold,
                            ),
                            title: Text(
                              d.name,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            subtitle: Text(
                              d.brandLabel,
                              style: const TextStyle(fontSize: 10.5, color: Colors.white54),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                if (isCur) {
                                  await scaleService.disconnect();
                                } else {
                                  await scaleService.connect(d);
                                }
                                if (context.mounted) Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCur ? Colors.redAccent : AppTheme.primaryBrown,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                isCur ? (isEn ? 'Disconnect' : 'Putus') : (isEn ? 'Connect' : 'Hubungkan'),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
