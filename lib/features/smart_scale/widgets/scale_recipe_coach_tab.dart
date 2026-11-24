import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/smart_scale_model.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';

/// Tab 2 of Smart Scale Studio: Pro Recipes & Coffee Coach selector.
/// Allows picking any recipe from Coffee Labs' catalog (plus built-in Pro Coach
/// templates) to load its target ghost curve onto the Smart Scale or launch
/// Guided Brewing Time (`BrewTimerScreen`) directly with the connected BLE scale.
class ScaleRecipeCoachTab extends StatefulWidget {
  final bool isEn;
  final Map<String, dynamic>? activeRecipe;
  final ValueChanged<Map<String, dynamic>> onSelectForScale;
  final ValueChanged<Map<String, dynamic>> onOpenBrewTimer;

  const ScaleRecipeCoachTab({
    super.key,
    required this.isEn,
    required this.activeRecipe,
    required this.onSelectForScale,
    required this.onOpenBrewTimer,
  });

  /// Curated Coffee Coach Pro recipes always available offline and in tests.
  static List<Map<String, dynamic>> builtInCoachRecipes() => [
        {
          'id': 'coach_v60_tetsu_46',
          'title': 'V60 4:6 Sweet Balance (Pro Coach)',
          'author': 'Coffee Labs Coach',
          'method': 'Hario V60 02',
          'category': 'Pour-Over',
          'coffeeWeightGrams': 15,
          'totalWaterWeightGrams': 225,
          'totalTimeSeconds': 180,
          'waterTempCelsius': 92,
          'grindSize': 'Medium-Coarse',
          'description':
              'Metode 4:6 seimbang dengan debit tuang lembut 4.0 g/s untuk kejernihan rasa manis dan acidity bersih.',
          'steps': [
            {
              'stepOrder': 1,
              'title': 'Bloom & Acidity',
              'durationSeconds': 45,
              'waterAddedGrams': 45,
              'instruction': 'Tuang melingkar perlahan hingga 45g, biarkan degassing.',
            },
            {
              'stepOrder': 2,
              'title': 'Sweetness Pour',
              'durationSeconds': 45,
              'waterAddedGrams': 45,
              'instruction': 'Tuang stabil ke total 90g untuk menonjolkan sweetness.',
            },
            {
              'stepOrder': 3,
              'title': 'Body Pour 1',
              'durationSeconds': 30,
              'waterAddedGrams': 45,
              'instruction': 'Tuang tengah ke luar hingga 135g dengan debit 4.0 g/s.',
            },
            {
              'stepOrder': 4,
              'title': 'Body Pour 2',
              'durationSeconds': 30,
              'waterAddedGrams': 45,
              'instruction': 'Tuang konsisten hingga 180g.',
            },
            {
              'stepOrder': 5,
              'title': 'Final Drawdown',
              'durationSeconds': 30,
              'waterAddedGrams': 45,
              'instruction': 'Selesaikan ke 225g, beri swirl halus dan tunggu tuntas.',
            },
          ],
        },
        {
          'id': 'coach_v60_single_pour',
          'title': 'V60 Clarity High-Flow (1:16)',
          'author': 'Coffee Labs Coach',
          'method': 'Hario V60 02',
          'category': 'Pour-Over',
          'coffeeWeightGrams': 15,
          'totalWaterWeightGrams': 240,
          'totalTimeSeconds': 155,
          'waterTempCelsius': 93,
          'grindSize': 'Medium-Fine',
          'description':
              'Profil floral modern untuk single origin washed/natural dengan kurva air mulus dan ekstraksi bersih.',
          'steps': [
            {
              'stepOrder': 1,
              'title': 'Blooming 3x',
              'durationSeconds': 40,
              'waterAddedGrams': 45,
              'instruction': 'Basahi seluruh bubuk hingga 45g lalu swirl ringan.',
            },
            {
              'stepOrder': 2,
              'title': 'Main Center-Spiral Pour',
              'durationSeconds': 55,
              'waterAddedGrams': 115,
              'instruction': 'Tuang kontinyu 4.5 g/s hingga mencapai 160g.',
            },
            {
              'stepOrder': 3,
              'title': 'Finishing Pour & Drawdown',
              'durationSeconds': 60,
              'waterAddedGrams': 80,
              'instruction': 'Tuang lembut hingga 240g dan biarkan drawdown selesai.',
            },
          ],
        },
        {
          'id': 'coach_espresso_modern_1_2',
          'title': 'Modern Espresso 1:2 (36g Yield)',
          'author': 'Coffee Labs Coach',
          'method': 'Espresso Machine',
          'category': 'Espresso',
          'coffeeWeightGrams': 18,
          'totalWaterWeightGrams': 36,
          'totalTimeSeconds': 28,
          'waterTempCelsius': 93,
          'grindSize': 'Fine Espresso',
          'description':
              'Standar modern specialty espresso 18g in → 36g out dalam 28 detik (laju ideal 1.4–1.8 g/s).',
          'steps': [
            {
              'stepOrder': 1,
              'title': 'Pre-Infusion',
              'durationSeconds': 7,
              'waterAddedGrams': 3,
              'instruction': 'Tunggu tetesan pertama (first drip) muncul di detik ke-6–8.',
            },
            {
              'stepOrder': 2,
              'title': 'Main Extraction',
              'durationSeconds': 15,
              'waterAddedGrams': 23,
              'instruction': 'Jaga aliran stabil ~1.5 g/s hingga 26g.',
            },
            {
              'stepOrder': 3,
              'title': 'Cutoff & Yield Finish',
              'durationSeconds': 6,
              'waterAddedGrams': 10,
              'instruction': 'Hentikan ekstraksi tepat di 36g untuk keseimbangan manis & body.',
            },
          ],
        },
        {
          'id': 'coach_espresso_lungo_light',
          'title': 'Light Roast Turbo Espresso 1:2.5',
          'author': 'Coffee Labs Coach',
          'method': 'Espresso Machine',
          'category': 'Espresso',
          'coffeeWeightGrams': 18,
          'totalWaterWeightGrams': 45,
          'totalTimeSeconds': 24,
          'waterTempCelsius': 94,
          'grindSize': 'Medium-Fine Espresso',
          'description':
              'Rasio 1:2.5 untuk biji light roast agar ekstraksi fruity lebih tinggi tanpa astringency.',
          'steps': [
            {
              'stepOrder': 1,
              'title': 'Fast Pre-Infusion',
              'durationSeconds': 5,
              'waterAddedGrams': 5,
              'instruction': 'Pre-infusion cepat hingga 5g.',
            },
            {
              'stepOrder': 2,
              'title': 'High-Clarity Extraction',
              'durationSeconds': 19,
              'waterAddedGrams': 40,
              'instruction': 'Ekstraksi stabil ~2.0 g/s hingga yield 45g.',
            },
          ],
        },
      ];

  /// Builds target weight-over-time ghost curve from a recipe's steps.
  static List<WeightDataPoint> buildTargetCurve(Map<String, dynamic>? recipe) {
    if (recipe == null) return const [];
    final rawSteps = recipe['steps'];
    if (rawSteps is! List || rawSteps.isEmpty) {
      final totalWater =
          (recipe['totalWaterWeightGrams'] as num?)?.toDouble() ?? 225.0;
      final totalSec =
          (recipe['totalTimeSeconds'] as num?)?.toDouble() ?? 150.0;
      return [
        const WeightDataPoint(elapsedSeconds: 0, weight: 0, flowRate: 0),
        WeightDataPoint(
          elapsedSeconds: totalSec,
          weight: totalWater,
          flowRate: totalSec > 0 ? totalWater / totalSec : 0,
        ),
      ];
    }

    final points = <WeightDataPoint>[
      const WeightDataPoint(elapsedSeconds: 0, weight: 0, flowRate: 0),
    ];
    double accTime = 0;
    double accWeight = 0;

    for (final raw in rawSteps) {
      if (raw is! Map) continue;
      final dur = ((raw['durationSeconds'] ?? raw['timeSeconds']) as num?)
              ?.toDouble() ??
          30.0;
      final addWater = ((raw['waterAddedGrams'] ?? raw['waterGrams']) as num?)
              ?.toDouble() ??
          0.0;
      final pourDur = dur > 10 ? dur * 0.45 : dur * 0.7;
      if (addWater > 0) {
        final flow = pourDur > 0 ? addWater / pourDur : 0.0;
        accWeight += addWater;
        points.add(
          WeightDataPoint(
            elapsedSeconds: accTime + pourDur,
            weight: accWeight,
            flowRate: flow,
          ),
        );
      }
      accTime += dur;
      points.add(
        WeightDataPoint(
          elapsedSeconds: accTime,
          weight: accWeight,
          flowRate: 0,
        ),
      );
    }

    return points;
  }

  @override
  State<ScaleRecipeCoachTab> createState() => _ScaleRecipeCoachTabState();
}

class _ScaleRecipeCoachTabState extends State<ScaleRecipeCoachTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filter = 'all'; // all | pour_over | espresso
  List<Map<String, dynamic>> _recipes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _recipes = ScaleRecipeCoachTab.builtInCoachRecipes();
    _loadAppRecipes();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAppRecipes() async {
    try {
      final remote = await ApiService.getRecipes();
      final merged = <Map<String, dynamic>>[
        ...ScaleRecipeCoachTab.builtInCoachRecipes(),
      ];
      final seenTitles = merged
          .map((e) => (e['title'] ?? '').toString().toLowerCase())
          .toSet();

      for (final item in remote) {
        if (item is Map) {
          final sanitized = ApiService.sanitizeRecipe(item);
          final title = (sanitized['title'] ?? '').toString().toLowerCase();
          if (title.isNotEmpty && !seenTitles.contains(title)) {
            seenTitles.add(title);
            merged.add(sanitized);
          }
        }
      }
      if (mounted) {
        setState(() {
          _recipes = merged;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isEspressoRecipe(Map<String, dynamic> r) {
    final text =
        '${r['method'] ?? ''} ${r['category'] ?? ''} ${r['title'] ?? ''}'
            .toLowerCase();
    return text.contains('espresso') || text.contains('ristretto');
  }

  List<Map<String, dynamic>> get _filteredRecipes {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _recipes.where((r) {
      if (_filter == 'espresso' && !_isEspressoRecipe(r)) return false;
      if (_filter == 'pour_over' && _isEspressoRecipe(r)) return false;
      if (q.isEmpty) return true;
      final hay =
          '${r['title'] ?? ''} ${r['method'] ?? ''} ${r['author'] ?? ''} ${r['category'] ?? ''}'
              .toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isEn = widget.isEn;
    final items = _filteredRecipes;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        // Coffee Coach intro card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderWarm),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.sparkles,
                  color: AppTheme.primaryBrown,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn
                          ? 'Coffee Coach & Recipe Sync'
                          : 'Coffee Coach & Sinkron Resep',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEn
                          ? 'Pick any recipe to overlay its target pour curve on the Smart Scale or start Guided Brewing Time.'
                          : 'Pilih resep untuk menampilkan garis panduan kurva air di Timbangan atau langsung buka Guided Brewing Time.',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Search input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderWarm),
          ),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
            decoration: InputDecoration(
              hintText: isEn
                  ? 'Search V60, Espresso, Tetsu 4:6...'
                  : 'Cari resep V60, Espresso, 4:6...',
              hintStyle: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
              prefixIcon: const Icon(
                CupertinoIcons.search,
                size: 17,
                color: AppTheme.textMuted,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Category Filter Chips
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _buildFilterChip('all', isEn ? 'All Recipes' : 'Semua'),
            _buildFilterChip('pour_over', 'Pour-Over'),
            _buildFilterChip('espresso', 'Espresso'),
          ],
        ),
        const SizedBox(height: 12),

        if (_loading && items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBrown),
            ),
          )
        else if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderWarm),
            ),
            child: Text(
              isEn
                  ? 'No recipes match your search.'
                  : 'Tidak ada resep yang cocok dengan pencarian Anda.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          )
        else
          ...items.map((r) => _buildRecipeCard(r, isEn)),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final active = _filter == key;
    return InkWell(
      onTap: () => setState(() => _filter = key),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryBrown : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? AppTheme.primaryBrown : AppTheme.borderWarm,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe, bool isEn) {
    final title = (recipe['title'] ?? 'Resep Kopi').toString();
    final method = (recipe['method'] ?? 'Manual Brew').toString();
    final dose = (recipe['coffeeWeightGrams'] as num?)?.toDouble() ?? 15.0;
    final water =
        (recipe['totalWaterWeightGrams'] as num?)?.toDouble() ?? 225.0;
    final timeSec = (recipe['totalTimeSeconds'] as num?)?.toInt() ?? 150;
    final stepsCount =
        (recipe['steps'] is List) ? (recipe['steps'] as List).length : 0;
    final ratio = dose > 0 ? water / dose : 15.0;
    final isSelected = widget.activeRecipe != null &&
        (widget.activeRecipe!['title'] ?? '') == title;
    final isEsp = _isEspressoRecipe(recipe);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.primaryBrown : AppTheme.borderWarm,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isEsp
                      ? const Color(0xFFFFF7ED)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isEsp ? 'ESPRESSO' : 'POUR-OVER',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isEsp
                        ? const Color(0xFFC2410C)
                        : const Color(0xFF0F766E),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  method,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  size: 17,
                  color: Color(0xFF0F766E),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.8,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _specPill('${dose.toStringAsFixed(0)}g → ${water.toStringAsFixed(0)}g'),
              _specPill('1:${ratio.toStringAsFixed(1)}'),
              _specPill(_formatDuration(timeSec)),
              if (stepsCount > 0)
                _specPill('$stepsCount ${isEn ? 'steps' : 'tahap'}'),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => widget.onSelectForScale(recipe),
                  icon: const Icon(CupertinoIcons.gauge, size: 15),
                  label: Text(
                    isSelected
                        ? (isEn ? 'Active on Scale' : 'Aktif di Timbangan')
                        : (isEn ? 'Load to Scale' : 'Pakai di Timbangan'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? const Color(0xFF0F766E)
                        : AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => widget.onOpenBrewTimer(recipe),
                icon: const Icon(CupertinoIcons.timer, size: 14),
                label: Text(
                  isEn ? 'Brew Timer' : 'Brew Time',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryBrown,
                  side: const BorderSide(color: AppTheme.primaryBrown),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _specPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: AppTheme.textDark,
        ),
      ),
    );
  }
}
