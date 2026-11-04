import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/oled_detector_service.dart';

class OledDiagnosticScreen extends StatefulWidget {
  const OledDiagnosticScreen({super.key});

  @override
  State<OledDiagnosticScreen> createState() => _OledDiagnosticScreenState();
}

class _OledDiagnosticScreenState extends State<OledDiagnosticScreen> {
  int _dailyHours = 14;
  Offset _simulatedShift = Offset.zero;
  bool _isBleedTestActive = false;

  void _triggerSimulatedShift() {
    setState(() {
      _simulatedShift = _simulatedShift == Offset.zero
          ? const Offset(3.0, 2.0)
          : (_simulatedShift == const Offset(3.0, 2.0) ? const Offset(-2.0, 3.0) : Offset.zero);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isBleedTestActive) {
      return Scaffold(
        backgroundColor: Colors.black, // #000000 True Black
        body: InkWell(
          onTap: () => setState(() => _isBleedTestActive = false),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                      ),
                      child: const Icon(Icons.local_cafe, color: Color(0xFFD4AF37), size: 48),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'OLED PITCH-BLACK BLEED TEST (#000000)',
                      style: TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Jika ruangan gelap dan layar tampak benar-benar mati, perangkat Anda bertipe OLED/AMOLED sejati.\nJika terdapat cahaya abu-abu di sekeliling layar, perangkat menggunakan LCD/IPS backlight.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 11.5, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Text('Ketuk di mana saja untuk kembali', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final savings = OledDetectorService.calculateCafeMonthlySavings(dailyHours: _dailyHours, isOled: true);

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181818),
        elevation: 0,
        title: const Row(
          children: [
            Icon(CupertinoIcons.waveform_path_badge_plus, color: Color(0xFFD4AF37), size: 20),
            SizedBox(width: 10),
            Text('Diagnostik Layar OLED & Anti-Burn-In', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Interactive Pitch Black Test
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.eye_fill, color: Color(0xFFD4AF37), size: 20),
                      SizedBox(width: 10),
                      Text(
                        '1. Uji Kebocoran Cahaya (#000000 Test)',
                        style: TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Uji coba visual layar penuh dalam warna hitam murni #000000 untuk memverifikasi apakah piksel tablet benar-benar mati (AMOLED) atau masih ditembus lampu backlight (IPS/LCD).',
                    style: TextStyle(color: Color(0xFFA5A5A5), fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _isBleedTestActive = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(CupertinoIcons.fullscreen, size: 16),
                    label: const Text('Mulai Uji Layar Hitam Penuh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 2. Anti-Burn-In Pixel Shift Visualizer
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.shield_lefthalf_fill, color: Colors.greenAccent, size: 20),
                      SizedBox(width: 10),
                      Text(
                        '2. Simulator OLED Pixel-Shifting',
                        style: TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sistem Coffee Labs secara cerdas menggeser posisi kartu menu dan border sebesar 1-3 piksel setiap 3 menit untuk menjaga masa pakai fosfor organik layar OLED.',
                    style: TextStyle(color: Color(0xFFA5A5A5), fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 14),

                  // Simulation Box
                  Center(
                    child: Container(
                      width: 220,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedSlide(
                            offset: Offset(_simulatedShift.dx / 100, _simulatedShift.dy / 100),
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF181818),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.local_cafe, color: Color(0xFFD4AF37), size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Offset: (${_simulatedShift.dx}px, ${_simulatedShift.dy}px)',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _triggerSimulatedShift,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD4AF37),
                        side: const BorderSide(color: Color(0xFFD4AF37)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(CupertinoIcons.arrow_2_circlepath, size: 14),
                      label: const Text('Simulasikan Geseran Piksel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 3. Kalkulator Hemat Energi Kedai Kopi
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.bolt_fill, color: Colors.amber, size: 20),
                      SizedBox(width: 10),
                      Text(
                        '3. Kalkulator Efisiensi Energi Kafe',
                        style: TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Jam Operasional Bar:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const Spacer(),
                      DropdownButton<int>(
                        value: _dailyHours,
                        dropdownColor: const Color(0xFF222222),
                        style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                        items: [8, 10, 12, 14, 16].map((h) => DropdownMenuItem(value: h, child: Text('$h Jam/Hari'))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _dailyHours = val);
                        },
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricTile(title: 'Penghematan Daya', value: '${savings['savedKwh'].toStringAsFixed(1)} kWh/bln'),
                      _buildMetricTile(title: 'Estimasi Penghematan', value: 'Rp ${savings['savedRupiah']}'),
                      _buildMetricTile(title: 'Suhu Tablet', value: savings['batteryTempDiffCelsius']),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
