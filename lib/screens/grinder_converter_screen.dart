import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/grinder/models/grinder_models.dart';
import '../features/grinder/widgets/rdt_calculator_card.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';

/// Interactive Coffee Grinder Click Comparison Matrix, Particle Size & RDT Optimizer.
class GrinderConverterScreen extends StatefulWidget {
  final int? initialMicrons;

  const GrinderConverterScreen({super.key, this.initialMicrons});

  @override
  State<GrinderConverterScreen> createState() => _GrinderConverterScreenState();
}

class _GrinderConverterScreenState extends State<GrinderConverterScreen> {
  late double _microns;
  late List<GrinderProfile> _grinders;

  @override
  void initState() {
    super.initState();
    _microns = (widget.initialMicrons ?? 720).toDouble().clamp(180, 1300);
    _grinders = GrinderCatalog.getProfiles();
  }

  String get _brewZone {
    if (_microns < 240) return 'Turkish / Ibrik';
    if (_microns < 420) return 'Espresso (9 Bar)';
    if (_microns < 520) return 'Moka Pot / Stovetop';
    if (_microns < 660) return 'AeroPress / Delter';
    if (_microns < 820) return 'Pour Over (V60 / Origami)';
    if (_microns < 960) return 'Chemex / Flat Drip';
    if (_microns < 1150) return 'French Press / Cupping';
    return 'Cold Brew / Toddy';
  }

  Color get _zoneColor {
    if (_microns < 420) return const Color(0xFF8D4925);
    if (_microns < 660) return const Color(0xFF5E35B1);
    if (_microns < 960) return const Color(0xFF00796B);
    return const Color(0xFF1E88E5);
  }

  void _applyPreset(double targetMicrons) {
    setState(() => _microns = targetMicrons);
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(isEn ? 'Grinder Click Matrix & Particle Lab' : 'Matriks Grinder & Partikel Kopi'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Micron & Zone Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_zoneColor, _zoneColor.withValues(alpha: 0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: _zoneColor.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_microns.round()} µm',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _brewZone,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: _microns,
                    min: 180,
                    max: 1300,
                    divisions: 112,
                    onChanged: (val) => setState(() => _microns = val),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('180 µm (Fine)', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                    Text('750 µm (Medium)', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                    Text('1300 µm (Coarse)', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Champion Presets
          Text(isEn ? 'Champion Presets:' : 'Preset Metode Seduh Juara:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPresetPill('☕ Espresso 9 Bar (300 µm)', 300),
                const SizedBox(width: 8),
                _buildPresetPill('Aeropress Inverted (600 µm)', 600),
                const SizedBox(width: 8),
                _buildPresetPill('Hoffmann V60 (680 µm)', 680),
                const SizedBox(width: 8),
                _buildPresetPill('Lance Hedrick 1-2-1 (750 µm)', 750),
                const SizedBox(width: 8),
                _buildPresetPill('Tetsu Kasuya 4:6 (950 µm)', 950),
                const SizedBox(width: 8),
                _buildPresetPill('French Press (1100 µm)', 1100),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // RDT & Static Estimator (Fitur Eksklusif Baru Barista)
          RdtCalculatorCard(currentMicrons: _microns),
          const SizedBox(height: 16),

          // Grinder Conversions Grid
          Text(
            isEn ? 'Grinder Conversions (${_grinders.length} Grinders):' : 'Konversi Putaran & Klik (${_grinders.length} Grinder):',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          ),
          const SizedBox(height: 8),

          ..._grinders.map((g) => _buildGrinderCard(g)),
        ],
      ),
    );
  }

  Widget _buildPresetPill(String title, double targetMicrons) {
    final active = (_microns - targetMicrons).abs() < 25;
    return GestureDetector(
      onTap: () => _applyPreset(targetMicrons),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryBrown : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppTheme.primaryBrown : Colors.grey.shade300),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: active ? FontWeight.bold : FontWeight.w600,
            color: active ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildGrinderCard(GrinderProfile grinder) {
    final color = Color(grinder.colorHex);
    final value = grinder.calculateSetting(_microns);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(CupertinoIcons.circle_grid_hex_fill, color: color, size: 20),
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
                        grinder.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  '${grinder.burrType} • ${grinder.finesProfile}',
                  style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w600),
                ),
                Text(
                  grinder.origin,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 9.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
