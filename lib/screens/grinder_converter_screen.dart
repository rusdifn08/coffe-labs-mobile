import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/grinder/models/grinder_models.dart';
import '../features/grinder/models/grinder_spec.dart';
import '../features/grinder/services/grinder_conversion_engine.dart';
import '../features/grinder/widgets/grinder_to_grinder_tab.dart';
import '../features/grinder/widgets/rdt_calculator_card.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';

/// Coffee Labs Precision Grinder Converter (102 Grinder: 70 Manual & 32 Elektrik).
///
/// Menyediakan 2 mode profesional:
/// 1. Konversi Grinder-ke-Grinder (Pilih Merek -> Pilih Model, Asal -> Tujuan)
/// 2. Matriks Mikron & 102 Grinder (Filter Merek, Tipe Manual/Elektrik, & RDT Optimizer)
class GrinderConverterScreen extends StatefulWidget {
  final int? initialMicrons;

  const GrinderConverterScreen({super.key, this.initialMicrons});

  @override
  State<GrinderConverterScreen> createState() => _GrinderConverterScreenState();
}

class _GrinderConverterScreenState extends State<GrinderConverterScreen> {
  late double _microns;
  int _activeTab = 0; // 0 = Grinder -> Grinder, 1 = Matriks Mikron 102 Grinder
  GrinderCategory? _categoryFilter;
  String? _selectedBrand;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _microns = (widget.initialMicrons ?? 650).toDouble().clamp(150, 1300);
    // Jika dibuka dari resep dengan target mikron spesifik, langsung sinkron kedua tab
    if (widget.initialMicrons != null) {
      _activeTab = 0;
    }
  }

  Color get _zoneColor {
    if (_microns < 380) return const Color(0xFF8D4925);
    if (_microns < 605) return const Color(0xFF5E35B1);
    if (_microns < 850) return const Color(0xFF00796B);
    return const Color(0xFF1E88E5);
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(
          isEn ? 'Precision Grinder Converter (102)' : 'Konversi Grinder Presisi (102)',
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Mode Switcher Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.14)),
              ),
              child: Row(
                children: [
                  _ModeTabButton(
                    title: isEn ? 'Grinder → Grinder' : 'Konversi Grinder',
                    icon: CupertinoIcons.arrow_right_arrow_left,
                    selected: _activeTab == 0,
                    onTap: () => setState(() => _activeTab = 0),
                  ),
                  _ModeTabButton(
                    title: isEn ? '102 Grinder Matrix' : 'Matriks 102 Grinder',
                    icon: CupertinoIcons.slider_horizontal_3,
                    selected: _activeTab == 1,
                    onTap: () => setState(() => _activeTab = 1),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: _activeTab == 0
                ? GrinderToGrinderTab(
                    initialMicrons: _microns,
                    onMicronsChanged: (m) => _microns = m.clamp(150, 1300),
                  )
                : _buildMatrixTab(isEn),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixTab(bool isEn) {
    final brands = GrinderConversionEngine.getBrands(category: _categoryFilter);
    final filteredSpecs = GrinderConversionEngine.searchGrinders(
      _searchQuery,
      category: _categoryFilter,
      brand: _selectedBrand,
    );
    final profiles = GrinderCatalog.getProfiles(
      category: _categoryFilter,
      brand: _selectedBrand,
    ).where((p) => filteredSpecs.any((s) => s.id == p.id)).toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
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
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        GrinderConversionEngine.brewZoneForMicrons(_microns),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tekstur: ${GrinderConversionEngine.textureForMicrons(_microns)}',
                style: const TextStyle(color: Colors.white70, fontSize: 11.5),
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: _microns,
                  min: 150,
                  max: 1300,
                  divisions: 115,
                  onChanged: (val) => setState(() => _microns = val),
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '150 µm (Fine)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '650 µm (V60)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '1300 µm (Coarse)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Champion Presets
        Text(
          isEn ? 'Brew Method Presets:' : 'Preset Metode Seduh (Honest Coffee Guide):',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPresetPill('Turkish (150 µm)', 150),
              const SizedBox(width: 8),
              _buildPresetPill('Espresso (280 µm)', 280),
              const SizedBox(width: 8),
              _buildPresetPill('Moka Pot (480 µm)', 480),
              const SizedBox(width: 8),
              _buildPresetPill('AeroPress (550 µm)', 550),
              const SizedBox(width: 8),
              _buildPresetPill('V60 (650 µm)', 650),
              const SizedBox(width: 8),
              _buildPresetPill('Kalita / Chemex (720 µm)', 720),
              const SizedBox(width: 8),
              _buildPresetPill('French Press (975 µm)', 975),
              const SizedBox(width: 8),
              _buildPresetPill('Cold Brew (1175 µm)', 1175),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // RDT & Static Estimator
        RdtCalculatorCard(currentMicrons: _microns),
        const SizedBox(height: 14),

        // Filter Tipe Manual / Elektrik + Search
        Row(
          children: [
            _FilterPill(
              label: 'Semua (102)',
              selected: _categoryFilter == null,
              onTap: () => setState(() {
                _categoryFilter = null;
                _selectedBrand = null;
              }),
            ),
            const SizedBox(width: 6),
            _FilterPill(
              label: 'Manual (70)',
              selected: _categoryFilter == GrinderCategory.manual,
              onTap: () => setState(() {
                _categoryFilter = GrinderCategory.manual;
                _selectedBrand = null;
              }),
            ),
            const SizedBox(width: 6),
            _FilterPill(
              label: 'Elektrik (32)',
              selected: _categoryFilter == GrinderCategory.electric,
              onTap: () => setState(() {
                _categoryFilter = GrinderCategory.electric;
                _selectedBrand = null;
              }),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Brand Filter Chips (Langkah 1: Merek -> Langkah 2: Model)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _BrandChip(
                label: 'Semua Merek',
                selected: _selectedBrand == null,
                onTap: () => setState(() => _selectedBrand = null),
              ),
              ...brands.map((brand) {
                final count = GrinderConversionEngine.modelCountForBrand(
                  brand,
                  category: _categoryFilter,
                );
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: _BrandChip(
                    label: '$brand ($count)',
                    selected: _selectedBrand == brand,
                    onTap: () => setState(() => _selectedBrand = brand),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 10),

        TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Cari model grinder atau burr (K6, C3 ESP, DF64, Blade R3...)',
            prefixIcon: const Icon(CupertinoIcons.search, size: 18),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.14)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.14)),
            ),
          ),
        ),
        const SizedBox(height: 12),

        Text(
          'Menampilkan ${profiles.length} Grinder (${_selectedBrand ?? 'Semua Merek'}):',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),

        ...profiles.map(_buildGrinderCard),
      ],
    );
  }

  Widget _buildPresetPill(String title, double targetMicrons) {
    final active = (_microns - targetMicrons).abs() < 25;
    return GestureDetector(
      onTap: () => setState(() => _microns = targetMicrons),
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
    final spec = grinder.spec;
    final targetVal = GrinderConversionEngine.micronsToSetting(spec, _microns);
    final reading = targetVal != null
        ? GrinderConversionEngine.formatDialReading(spec, targetVal, targetMicrons: _microns)
        : GrinderConversionEngine.formatDialReading(spec, 0, targetMicrons: _microns);
    final isFilterBlocked = spec.filterOnly &&
        spec.minRecommendedMicrons != null &&
        _microns < spec.minRecommendedMicrons!;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  spec.category == GrinderCategory.electric
                      ? CupertinoIcons.bolt_fill
                      : CupertinoIcons.circle_grid_hex_fill,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grinder.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${spec.burrSpec} · ${grinder.finesProfile}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      spec.dialStructureSummary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                constraints: const BoxConstraints(maxWidth: 132),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isFilterBlocked
                      ? Colors.amber.shade50
                      : (spec.isCalibrated ? color.withValues(alpha: 0.09) : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: isFilterBlocked
                        ? Colors.amber.shade400
                        : (spec.isCalibrated ? color.withValues(alpha: 0.28) : Colors.grey.shade300),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isFilterBlocked ? 'Khusus Filter' : reading.primaryDisplay,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: isFilterBlocked
                            ? Colors.brown.shade800
                            : (spec.isCalibrated ? color : Colors.grey.shade700),
                      ),
                    ),
                    if (spec.isCalibrated && !isFilterBlocked)
                      Text(
                        reading.physicalNotation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color.withValues(alpha: 0.85),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeTabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTabButton({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryBrown : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? Colors.white : AppTheme.textMuted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : AppTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryBrown : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppTheme.primaryBrown : AppTheme.primaryBrown.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : AppTheme.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BrandChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF00695C) : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? const Color(0xFF00695C) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
            color: selected ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}
