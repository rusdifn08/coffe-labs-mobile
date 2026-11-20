import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class LiveBrewQrScannerModal extends StatefulWidget {
  const LiveBrewQrScannerModal({super.key});

  static Future<String?> scan(BuildContext context) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const LiveBrewQrScannerModal()),
    );
  }

  @override
  State<LiveBrewQrScannerModal> createState() => _LiveBrewQrScannerModalState();
}

class _LiveBrewQrScannerModalState extends State<LiveBrewQrScannerModal> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _popped = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12100E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12100E),
        foregroundColor: const Color(0xFFF9F5EE),
        iconTheme: const IconThemeData(color: Color(0xFFF9F5EE)),
        title: const Text(
          'Pindai QR Live Brew / Meja',
          style: TextStyle(
            color: Color(0xFFF9F5EE),
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Senter Kamera',
            onPressed: () {
              setState(() => _torchOn = !_torchOn);
              _controller.toggleTorch();
            },
            icon: Icon(
              _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: const Color(0xFFD4A373),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_popped) return;
              for (final barcode in capture.barcodes) {
                final raw = barcode.rawValue?.trim();
                if (raw != null && raw.isNotEmpty) {
                  _popped = true;
                  Navigator.of(context).pop(raw);
                  break;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFD4A373),
                  width: 3,
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 36,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF12100E).withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4A373).withValues(alpha: 0.4)),
              ),
              child: const Text(
                'Arahkan kamera ke QR Meja/Kursi Kafe atau QR Siaran Brewer Coffee Labs.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF9F5EE),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
