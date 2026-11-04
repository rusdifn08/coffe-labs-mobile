import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/dial_in/models/dial_in_models.dart';
import '../features/dial_in/widgets/bypass_rescue_dialog.dart';
import '../features/dial_in/widgets/dial_in_result_card.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';

/// Clinical Espresso and Filter Coffee Dial-In Diagnostic Assistant & Bypass Rescue.
class DialInAssistantScreen extends StatefulWidget {
  const DialInAssistantScreen({super.key});

  @override
  State<DialInAssistantScreen> createState() => _DialInAssistantScreenState();
}

class _DialInAssistantScreenState extends State<DialInAssistantScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // Espresso State
  int _espressoTimeSeconds = 20;
  String _espressoTaste = 'sour'; // 'sour', 'bitter', 'watery', 'channeling', 'balanced'

  // Filter State
  int _filterTimeMinutes = 2;
  int _filterTimeSeconds = 10;
  String _filterTaste = 'sour'; // 'sour', 'bitter', 'hollow', 'sweet'

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(isEn ? 'Coffee Dial-In Assistant' : 'Asisten Dial-In Kopi'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.drop_fill, color: AppTheme.primaryBrown),
            tooltip: isEn ? 'Bypass Rescue' : 'Penyelamat Bypass Air',
            onPressed: () => BypassRescueDialog.show(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppTheme.primaryBrown,
          labelColor: AppTheme.primaryBrown,
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(
              icon: const Icon(CupertinoIcons.flame_fill, size: 18),
              text: isEn ? 'Espresso Dial-In' : 'Dial-In Espresso',
            ),
            Tab(
              icon: const Icon(CupertinoIcons.drop_fill, size: 18),
              text: isEn ? 'Filter / Pour-Over' : 'Dial-In Filter V60',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildEspressoTab(isEn),
          _buildFilterTab(isEn),
        ],
      ),
    );
  }

  Widget _buildEspressoTab(bool isEn) {
    final diag = DialInDiagnosticsEngine.getEspressoDiagnosis(
      taste: _espressoTaste,
      timeSeconds: _espressoTimeSeconds,
      isEn: isEn,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCard(
          title: isEn ? '1. Extraction Time (Liquid Flow)' : '1. Waktu Ekstraksi (Detik Aliran)',
          icon: CupertinoIcons.timer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_espressoTimeSeconds ${isEn ? "seconds" : "detik"}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                  ),
                  Text(
                    _espressoTimeSeconds < 24
                        ? (isEn ? '⚡ Too Fast (<24s)' : '⚡ Terlalu Cepat (<24s)')
                        : _espressoTimeSeconds > 32
                            ? (isEn ? '🐢 Choking / Slow (>32s)' : '🐢 Terlalu Lambat (>32s)')
                            : (isEn ? '🎯 Sweet Spot (25-30s)' : '🎯 Sweet Spot (25-30s)'),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: (_espressoTimeSeconds >= 24 && _espressoTimeSeconds <= 32)
                          ? Colors.green.shade700
                          : Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _espressoTimeSeconds.toDouble(),
                min: 12,
                max: 48,
                divisions: 36,
                activeColor: AppTheme.primaryBrown,
                inactiveColor: AppTheme.primaryBrown.withValues(alpha: 0.15),
                onChanged: (val) => setState(() => _espressoTimeSeconds = val.round()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildCard(
          title: isEn ? '2. Dominant Taste on Palate' : '2. Karakter Rasa Utama di Lidah',
          icon: CupertinoIcons.sparkles,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip(
                label: isEn ? '🍋 Sour / Sharp Acidity' : '🍋 Asam Menusuk / Kecut',
                selected: _espressoTaste == 'sour',
                onTap: () => setState(() => _espressoTaste = 'sour'),
              ),
              _buildChoiceChip(
                label: isEn ? '🪵 Bitter / Dry Ashy' : '🪵 Pahit Kering / Sepet',
                selected: _espressoTaste == 'bitter',
                onTap: () => setState(() => _espressoTaste = 'bitter'),
              ),
              _buildChoiceChip(
                label: isEn ? '💧 Watery / Thin Body' : '💧 Encer Hambar / Low Body',
                selected: _espressoTaste == 'watery',
                onTap: () => setState(() => _espressoTaste = 'watery'),
              ),
              _buildChoiceChip(
                label: isEn ? '⚡ Sour & Bitter (Channeled)' : '⚡ Asam & Pahit Bersamaan',
                selected: _espressoTaste == 'channeling',
                onTap: () => setState(() => _espressoTaste = 'channeling'),
              ),
              _buildChoiceChip(
                label: isEn ? '✨ Sweet & Balanced' : '✨ Manis, Bulat & Harmonis',
                selected: _espressoTaste == 'balanced',
                onTap: () => setState(() => _espressoTaste = 'balanced'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        DialInResultCard(res: diag, isEn: isEn),
        const SizedBox(height: 12),
        _buildBypassBanner(isEn),
      ],
    );
  }

  Widget _buildFilterTab(bool isEn) {
    final diag = DialInDiagnosticsEngine.getFilterDiagnosis(
      taste: _filterTaste,
      isEn: isEn,
    );
    final totalSecs = _filterTimeMinutes * 60 + _filterTimeSeconds;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCard(
          title: isEn ? '1. Total Drawdown Time' : '1. Total Waktu Seduh (Drawdown)',
          icon: CupertinoIcons.stopwatch,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filterTimeMinutes}m ${String.fromCharCodes([_filterTimeSeconds < 10 ? 48 : 0]).trim()}${_filterTimeSeconds}s',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                  ),
                  Text(
                    totalSecs < 135
                        ? (isEn ? '⚡ Fast Drain' : '⚡ Terlalu Cepat')
                        : totalSecs > 240
                            ? (isEn ? '🐢 Slow / Clogged' : '🐢 Tersumbat / Lambat')
                            : (isEn ? '🎯 Optimal Flow' : '🎯 Flow Ideal'),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: (totalSecs >= 135 && totalSecs <= 240) ? Colors.green.shade700 : Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
              Slider(
                value: totalSecs.toDouble(),
                min: 90,
                max: 360,
                divisions: 54,
                activeColor: AppTheme.primaryBrown,
                inactiveColor: AppTheme.primaryBrown.withValues(alpha: 0.15),
                onChanged: (val) {
                  final s = val.round();
                  setState(() {
                    _filterTimeMinutes = s ~/ 60;
                    _filterTimeSeconds = s % 60;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildCard(
          title: isEn ? '2. Cup Sensation' : '2. Rasa Seduhan di Cangkir',
          icon: CupertinoIcons.heart_fill,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip(
                label: isEn ? '🍋 Sour, Grassy, Lacks Sweetness' : '🍋 Terlalu Asam / Kurang Manis',
                selected: _filterTaste == 'sour',
                onTap: () => setState(() => _filterTaste = 'sour'),
              ),
              _buildChoiceChip(
                label: isEn ? '🪵 Bitter, Chalky, Dry Throat' : '🪵 Pahit / Tenggorokan Kering',
                selected: _filterTaste == 'bitter',
                onTap: () => setState(() => _filterTaste = 'bitter'),
              ),
              _buildChoiceChip(
                label: isEn ? '💧 Hollow, Dilute, Weak' : '💧 Encer Hambar / Kurang Ekstrak',
                selected: _filterTaste == 'hollow',
                onTap: () => setState(() => _filterTaste = 'hollow'),
              ),
              _buildChoiceChip(
                label: isEn ? '✨ Juicy, Sweet, Clean Finish' : '✨ Juicy, Manis & Aftertaste Bersih',
                selected: _filterTaste == 'sweet',
                onTap: () => setState(() => _filterTaste = 'sweet'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        DialInResultCard(res: diag, isEn: isEn),
        const SizedBox(height: 12),
        _buildBypassBanner(isEn),
      ],
    );
  }

  Widget _buildBypassBanner(bool isEn) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF80CBC4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00796B).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(CupertinoIcons.drop_fill, color: Color(0xFF00796B), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'Cup Too Heavy or Bitter?' : 'Seduhan Terlalu Pahit / Pekat?',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF004D40)),
                ),
                Text(
                  isEn
                      ? 'Calculate emergency hot water bypass dilution.'
                      : 'Kalkulasikan air bypass penyelamat cangkir instan.',
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF00695C)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => BypassRescueDialog.show(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00796B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              isEn ? 'Bypass' : 'Bypass',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryBrown),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildChoiceChip({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryBrown : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.primaryBrown : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
