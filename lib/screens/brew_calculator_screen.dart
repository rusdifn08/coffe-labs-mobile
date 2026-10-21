import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/barista_utils.dart';
import 'brew_timer_screen.dart';

class BrewCalculatorScreen extends StatefulWidget {
  const BrewCalculatorScreen({super.key});

  @override
  State<BrewCalculatorScreen> createState() => _BrewCalculatorScreenState();
}

class _BrewCalculatorScreenState extends State<BrewCalculatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Ratio & Iced Calculator State
  double _coffeeGrams = 15;
  double _ratio = 15.0;
  bool _isJapaneseIced = false;
  double _icePercent = 35; // 35% ice, 65% hot water
  String _roastLevel = 'Light Roast';

  // Grinder Converter State
  int _c40Clicks = 22;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _recommendedTemp {
    if (_roastLevel == 'Light Roast') return 93;
    if (_roastLevel == 'Medium Roast') return 90;
    return 86;
  }

  void _startQuickBrew({
    required int coffee,
    required int hotWater,
    required int iceGrams,
    required int bloomWater,
    required int pour1Water,
    required int pour2Water,
  }) {
    final recipe = {
      'id': 999999,
      'title': _isJapaneseIced
          ? 'Quick Japanese Iced (${coffee}g · 1:${_ratio.toStringAsFixed(1)})'
          : 'Quick Pour Over (${coffee}g · 1:${_ratio.toStringAsFixed(1)})',
      'author': 'Quick Brew Calculator 🇮🇩',
      'category': _isJapaneseIced ? 'Japanese' : 'V60',
      'method': _isJapaneseIced ? 'V60 + Es di Server' : 'Hario V60 02',
      'grindSize': _isJapaneseIced ? 'Medium-Fine (19 Klik Comandante)' : 'Medium (22 Klik Comandante)',
      'coffeeWeightGrams': coffee,
      'totalWaterWeightGrams': hotWater,
      'iceWeightGrams': iceGrams,
      'waterTempCelsius': _recommendedTemp,
      'totalTimeSeconds': 140,
      'steps': [
        {
          'stepOrder': 1,
          'title': '1. Blooming (0:00 - 0:40)',
          'durationSeconds': 40,
          'waterAddedGrams': bloomWater,
          'instruction': 'Tuang ${bloomWater}g air panas merata membasahi seluruh kopi, swirl lembut dan tunggu degassing.',
        },
        {
          'stepOrder': 2,
          'title': '2. Main Pour Pertama (0:40 - 1:25)',
          'durationSeconds': 45,
          'waterAddedGrams': pour1Water,
          'instruction': 'Tuang +${pour1Water}g gerakan spiral stabil hingga timbangan mencapai ${bloomWater + pour1Water}g.',
        },
        {
          'stepOrder': 3,
          'title': '3. Final Pour & Drawdown (1:25 - 2:20)',
          'durationSeconds': 55,
          'waterAddedGrams': pour2Water,
          'instruction': 'Tuang sisa +${pour2Water}g hingga total air panas ${hotWater}g dan biarkan tiris sempurna.',
        },
      ],
    };

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BrewTimerScreen(recipeData: recipe)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Kalkulator & Konverter Brew'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBrown,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primaryBrown,
          tabs: const [
            Tab(icon: Icon(CupertinoIcons.drop_fill, size: 18), text: 'Kalkulator Rasio & Es'),
            Tab(icon: Icon(CupertinoIcons.circle_grid_hex, size: 18), text: 'Konverter Grinder'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRatioCalculatorTab(),
          _buildGrinderConverterTab(),
        ],
      ),
    );
  }

  Widget _buildRatioCalculatorTab() {
    final int coffee = _coffeeGrams.round();
    final int totalLiquid = (_coffeeGrams * _ratio).round();
    final int iceGrams = _isJapaneseIced ? (totalLiquid * (_icePercent / 100)).round() : 0;
    final int hotWater = totalLiquid - iceGrams;
    final int bloomWater = (coffee * 3).clamp(20, (hotWater * 0.4).round());
    final int remainingWater = (hotWater - bloomWater).clamp(0, 2000);
    final int pour1Water = (remainingWater * 0.55).round();
    final int pour2Water = remainingWater - pour1Water;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Live Summary Banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.primaryBrown,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBrown.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryStat('Kopi', '${coffee}g'),
                  _summaryStat('Air Panas', '${hotWater}g'),
                  if (_isJapaneseIced) _summaryStat('Es Batu', '${iceGrams}g'),
                  _summaryStat('Rasio', '1:${_ratio.toStringAsFixed(1)}'),
                  _summaryStat('Suhu', '$_recommendedTemp°C'),
                ],
              ),
              const Divider(color: Colors.white24, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Bloom: ${bloomWater}g', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('Pour 1: +${pour1Water}g', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('Pour 2: +${pour2Water}g', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Roast Level Selector
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih Level Sangrai (Otomatis Atur Suhu Air)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: ['Light Roast', 'Medium Roast', 'Dark Roast'].map((r) {
                  final selected = _roastLevel == r;
                  return ChoiceChip(
                    label: Text(r, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppTheme.textDark)),
                    selected: selected,
                    selectedColor: AppTheme.primaryBrown,
                    onSelected: (_) => setState(() => _roastLevel = r),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Coffee Dose Slider
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dosis Biji Kopi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  Text('${coffee}g', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBrown)),
                ],
              ),
              Slider(
                value: _coffeeGrams,
                min: 8,
                max: 45,
                divisions: 37,
                activeColor: AppTheme.primaryBrown,
                onChanged: (v) => setState(() => _coffeeGrams = v),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [12, 15, 18, 20, 25, 30].map((d) {
                  return ActionChip(
                    label: Text('${d}g', style: const TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _coffeeGrams = d.toDouble()),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Ratio Slider
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Rasio Seduh (Kopi : Total Air)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  Text('1:${_ratio.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBrown)),
                ],
              ),
              Slider(
                value: _ratio,
                min: 10.0,
                max: 18.0,
                divisions: 16,
                activeColor: AppTheme.accentAmber,
                onChanged: (v) => setState(() => _ratio = v),
              ),
              Text(
                _ratio <= 13.5
                    ? 'Karakter: Intense, Heavy Body (Cocok untuk Japanese Iced / Susu)'
                    : _ratio <= 15.5
                        ? 'Karakter: Sweet & Balanced (Standar Juara Kompetisi V60)'
                        : 'Karakter: Tea-like, High Clarity (Cocok untuk Gesha / Washed)',
                style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Japanese Iced Toggle & Ice %
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mode Japanese Iced (V60 Pakai Es)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                subtitle: const Text('Bagi total cairan menjadi es batu di server + air panas seduhan', style: TextStyle(fontSize: 11.5)),
                activeThumbColor: Colors.blueAccent,
                value: _isJapaneseIced,
                onChanged: (v) => setState(() => _isJapaneseIced = v),
              ),
              if (_isJapaneseIced) ...[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Porsi Es Batu (${_icePercent.round()}%)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                    Text('${iceGrams}g Es + ${hotWater}g Air Panas', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.blueAccent)),
                  ],
                ),
                Slider(
                  value: _icePercent,
                  min: 20,
                  max: 45,
                  divisions: 25,
                  activeColor: Colors.blueAccent,
                  onChanged: (v) => setState(() => _icePercent = v),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _startQuickBrew(
              coffee: coffee,
              hotWater: hotWater,
              iceGrams: iceGrams,
              bloomWater: bloomWater,
              pour1Water: pour1Water,
              pour2Water: pour2Water,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(CupertinoIcons.play_fill, color: Colors.white),
            label: const Text(
              'Brew Sekarang dengan Takaran Ini',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrinderConverterTab() {
    final rawDesc = '$_c40Clicks Klik Comandante';
    final conversions = BaristaUtils.grinderConversions(rawDesc);

    String recommendedMethod = 'V60 Pour Over / Origami / Kalita Wave';
    if (_c40Clicks <= 15) {
      recommendedMethod = 'AeroPress Short Steep / Mokapot / Espresso';
    } else if (_c40Clicks <= 19) {
      recommendedMethod = 'Japanese Iced V60 / AeroPress / V60 1-Cup';
    } else if (_c40Clicks <= 25) {
      recommendedMethod = 'V60 Pour Over / Origami / Flat Bottom / Switch';
    } else {
      recommendedMethod = 'French Press / Clever Dripper / Kasuya 4:6 Method';
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Geser Klik Referensi (Comandante C40)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_c40Clicks Klik',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              Slider(
                value: _c40Clicks.toDouble(),
                min: 10,
                max: 34,
                divisions: 24,
                activeColor: AppTheme.primaryBrown,
                onChanged: (v) => setState(() => _c40Clicks = v.round()),
              ),
              Text(
                'Cocok untuk: $recommendedMethod',
                style: const TextStyle(fontSize: 12, color: AppTheme.primaryBrown, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...conversions.entries.map(
          (e) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textMuted, fontSize: 13)),
                Flexible(
                  child: Text(
                    e.value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
      ],
    );
  }
}
