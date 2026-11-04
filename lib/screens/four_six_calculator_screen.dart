import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/four_six/widgets/four_six_flavor_barometer.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';
import 'brew_timer_screen.dart';

/// Interactive Tetsu Kasuya 4:6 Method Brewing Calculator (WBrC 2016)
/// with Split-Temperature Championship Profiling & Sensory Barometer.
class FourSixCalculatorScreen extends StatefulWidget {
  const FourSixCalculatorScreen({super.key});

  @override
  State<FourSixCalculatorScreen> createState() => _FourSixCalculatorScreenState();
}

class _FourSixCalculatorScreenState extends State<FourSixCalculatorScreen> {
  double _coffeeDose = 20.0;
  final double _brewRatio = 15.0;

  // 40% Stage 1: Taste Balance ('sweetness', 'balanced', 'acidity')
  String _stage1Balance = 'balanced';

  // 60% Stage 2: Strength & Body (1 Light, 2 Medium, 3 Strong)
  int _stage2Pours = 3;

  // Split-Temperature Championship Mode
  bool _splitTempMode = true;

  double get _totalWater => _coffeeDose * _brewRatio;
  double get _stage1Total => _totalWater * 0.40;
  double get _stage2Total => _totalWater * 0.60;

  List<double> _calculatePours() {
    double p1, p2;
    if (_stage1Balance == 'sweetness') {
      p1 = _stage1Total * 0.40;
      p2 = _stage1Total * 0.60;
    } else if (_stage1Balance == 'acidity') {
      p1 = _stage1Total * 0.60;
      p2 = _stage1Total * 0.40;
    } else {
      p1 = _stage1Total * 0.50;
      p2 = _stage1Total * 0.50;
    }

    final double stage2Each = _stage2Total / _stage2Pours;
    final List<double> pours = [p1, p2];
    for (int i = 0; i < _stage2Pours; i++) {
      pours.add(stage2Each);
    }
    return pours;
  }

  void _startTimer() {
    final pours = _calculatePours();
    final List<Map<String, dynamic>> steps = [];

    for (int i = 0; i < pours.length; i++) {
      final w = pours[i].round();
      final temp = _splitTempMode ? (i < 2 ? 93 : 78) : 92;
      String title = '';
      if (i == 0) {
        title = 'Pour 1 (Bloom & ${_stage1Balance == "sweetness" ? "Sweetness" : _stage1Balance == "acidity" ? "Acidity" : "Balance"}) • $temp°C';
      } else if (i == 1) {
        title = 'Pour 2 (Finish 40% Flavor Balance) • $temp°C';
      } else {
        title = 'Pour ${i + 1} (Strength Stage: ${_stage2Pours == 1 ? "Light" : _stage2Pours == 2 ? "Medium" : "Strong Body"}) • $temp°C';
      }

      steps.add({
        'stepOrder': i + 1,
        'title': title,
        'durationSeconds': 45,
        'waterAddedGrams': w,
      });
    }

    final recipe = {
      'id': 88846,
      'title': 'Tetsu Kasuya 4:6 Method (${_coffeeDose.round()}g : ${_totalWater.round()}g)',
      'author': 'Tetsu Kasuya (WBrC Champion) 🇯🇵',
      'category': 'V60',
      'method': 'Hario V60 02',
      'beanName': 'Single Origin Coarse Grind',
      'variety': 'Arabica Selection',
      'process': 'Washed',
      'waterTempCelsius': _splitTempMode ? 93 : 92,
      'grindSize': 'Coarse (900-1000 µm)',
      'coffeeWeightGrams': _coffeeDose.round(),
      'totalWaterWeightGrams': _totalWater.round(),
      'totalTimeSeconds': pours.length * 45,
      'description': 'Kalkulasi presisi metode 4:6 Tetsu Kasuya. 40% air pertama mengatur keasaman vs rasa manis, dan 60% air sisanya mengatur kekuatan body cangkir.',
      'steps': steps,
    };

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BrewTimerScreen(recipeData: recipe)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final pours = _calculatePours();

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(isEn ? '4:6 Method Calculator' : 'Kalkulator Metode 4:6'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Tetsu Kasuya
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('🇯🇵', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tetsu Kasuya 4:6 Concept',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEn
                            ? '40% Water: Acidity & Sweetness\n60% Water: Body & Strength'
                            : '40% Air: Rasa Manis & Keasaman\n60% Air: Kekuatan Body & Tekstur',
                        style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Dose Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEn ? 'Coffee Dose' : 'Dosis Kopi Bubuk', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    Text('${_coffeeDose.round()} g', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown)),
                  ],
                ),
                Slider(
                  value: _coffeeDose,
                  min: 12,
                  max: 35,
                  divisions: 23,
                  activeColor: AppTheme.primaryBrown,
                  inactiveColor: AppTheme.primaryBrown.withValues(alpha: 0.15),
                  onChanged: (val) => setState(() => _coffeeDose = val),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Air: ${_totalWater.round()}g (Rasio 1:15)', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                    Text('${pours.length}x Tuangan (45s)', style: const TextStyle(color: AppTheme.primaryBrown, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Split-Temperature Championship Mode Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _splitTempMode ? const Color(0xFFFFF8E1) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _splitTempMode ? const Color(0xFFFFB300) : Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.thermometer, size: 20, color: Color(0xFFE65100)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Split-Temperature (WBrC Technique)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF2C1810)),
                      ),
                      Text(
                        'Tuang 1-2 di 93°C (manis), Tuang 3+ di 78°C (bersih)',
                        style: TextStyle(fontSize: 10, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: _splitTempMode,
                  activeTrackColor: const Color(0xFFE65100),
                  onChanged: (val) => setState(() => _splitTempMode = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Stage 1 (40%): Sweetness vs Acidity
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tahap 1 (40% Air = ${_stage1Total.round()}g): Profil Rasa',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildOptionTab(
                      title: '🍋 Asam Cerah',
                      selected: _stage1Balance == 'acidity',
                      onTap: () => setState(() => _stage1Balance = 'acidity'),
                    ),
                    const SizedBox(width: 8),
                    _buildOptionTab(
                      title: '⚖️ Seimbang',
                      selected: _stage1Balance == 'balanced',
                      onTap: () => setState(() => _stage1Balance = 'balanced'),
                    ),
                    const SizedBox(width: 8),
                    _buildOptionTab(
                      title: '🍯 Manis Legit',
                      selected: _stage1Balance == 'sweetness',
                      onTap: () => setState(() => _stage1Balance = 'sweetness'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Stage 2 (60%): Strength / Body
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tahap 2 (60% Air = ${_stage2Total.round()}g): Kekuatan Body',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildOptionTab(
                      title: '🌱 Ringan (1x)',
                      selected: _stage2Pours == 1,
                      onTap: () => setState(() => _stage2Pours = 1),
                    ),
                    const SizedBox(width: 8),
                    _buildOptionTab(
                      title: '☕ Sedang (2x)',
                      selected: _stage2Pours == 2,
                      onTap: () => setState(() => _stage2Pours = 2),
                    ),
                    const SizedBox(width: 8),
                    _buildOptionTab(
                      title: '🏆 Bold (3x)',
                      selected: _stage2Pours == 3,
                      onTap: () => setState(() => _stage2Pours = 3),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Dynamic Cup Flavor Predictor (Eksklusif Barista)
          FourSixFlavorBarometer(
            stage1Balance: _stage1Balance,
            stage2Pours: _stage2Pours,
            splitTempMode: _splitTempMode,
          ),
          const SizedBox(height: 16),

          // Timeline Table of Pours
          const Text('Jadwal Tuangan Air & Target Timbangan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Column(
              children: [
                ...List.generate(pours.length, (idx) {
                  final pourAmount = pours[idx].round();
                  int accum = 0;
                  for (int j = 0; j <= idx; j++) {
                    accum += pours[j].round();
                  }
                  final int min = (idx * 45) ~/ 60;
                  final int sec = (idx * 45) % 60;
                  final timeStr = '${min.toString().padLeft(2, "0")}:${sec.toString().padLeft(2, "0")}';
                  final targetTemp = _splitTempMode ? (idx < 2 ? '93°C' : '78°C') : '92°C';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: idx < 2 ? AppTheme.accentGold.withValues(alpha: 0.2) : AppTheme.primaryBrown.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${idx + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: idx < 2 ? const Color(0xFFB78103) : AppTheme.primaryBrown,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                idx < 2
                                    ? 'Tahap Rasa (Tuang $pourAmount g • $targetTemp)'
                                    : 'Tahap Body (Tuang $pourAmount g • $targetTemp)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text('Waktu mulai: $timeStr (tunggu hingga tiris)', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF3EC),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            'Skala: $accum g',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.primaryBrown),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Start Timer Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              icon: const Icon(CupertinoIcons.play_arrow_solid, size: 18),
              label: Text(
                'Mulai Timer Seduh 4:6 (${pours.length * 45}s)',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOptionTab({required String title, required bool selected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryBrown : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppTheme.primaryBrown : Colors.grey.shade300,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
