import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/grinder_spec.dart';
import '../services/grinder_conversion_engine.dart';

/// Kartu pemilih 2 tahap (Langkah 1: Pilih Merek -> Langkah 2: Pilih Model Grinder)
/// dengan filter Manual / Elektrik & pencarian instan.
class BrandModelSelectorCard extends StatelessWidget {
  final String roleLabel;
  final Color accentColor;
  final GrinderSpec selectedGrinder;
  final ValueChanged<GrinderSpec> onGrinderSelected;

  const BrandModelSelectorCard({
    super.key,
    required this.roleLabel,
    required this.accentColor,
    required this.selectedGrinder,
    required this.onGrinderSelected,
  });

  Future<void> _openBrandPicker(BuildContext context) async {
    GrinderCategory? categoryFilter;
    String query = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final brands = GrinderConversionEngine.getBrands(category: categoryFilter)
              .where((b) => query.trim().isEmpty || b.toLowerCase().contains(query.trim().toLowerCase()))
              .toList(growable: false);

          return FractionallySizedBox(
            heightFactor: 0.80,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Langkah 1 · Pilih Merek ($roleLabel)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Filter tipe: Semua / Manual / Elektrik
                  Row(
                    children: [
                      _CategoryChip(
                        label: 'Semua (102)',
                        selected: categoryFilter == null,
                        onTap: () => setSheetState(() => categoryFilter = null),
                      ),
                      const SizedBox(width: 8),
                      _CategoryChip(
                        label: 'Manual (70)',
                        selected: categoryFilter == GrinderCategory.manual,
                        onTap: () => setSheetState(() => categoryFilter = GrinderCategory.manual),
                      ),
                      const SizedBox(width: 8),
                      _CategoryChip(
                        label: 'Elektrik (32)',
                        selected: categoryFilter == GrinderCategory.electric,
                        onTap: () => setSheetState(() => categoryFilter = GrinderCategory.electric),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (v) => setSheetState(() => query = v),
                    decoration: InputDecoration(
                      hintText: 'Cari merek (1Zpresso, Timemore, KINGrinder, DF...)',
                      prefixIcon: const Icon(CupertinoIcons.search, size: 18),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      itemCount: brands.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final brand = brands[index];
                        final models = GrinderConversionEngine.getModelsForBrand(
                          brand,
                          category: categoryFilter,
                        );
                        final isSelected = brand == selectedGrinder.brand;
                        final hasManual = models.any((m) => m.category == GrinderCategory.manual);
                        final hasElectric = models.any((m) => m.category == GrinderCategory.electric);
                        final catSummary = hasManual && hasElectric
                            ? 'Manual & Elektrik'
                            : (hasElectric ? 'Elektrik' : 'Manual');

                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.pop(ctx);
                            if (models.length == 1) {
                              onGrinderSelected(models.first);
                            } else {
                              // Pilih default sementara lalu buka pemilih model untuk merek ini
                              final defaultModel = models.firstWhere(
                                (m) => m.isCalibrated,
                                orElse: () => models.first,
                              );
                              onGrinderSelected(defaultModel);
                              _openModelPicker(
                                context,
                                brand: brand,
                                categoryFilter: categoryFilter,
                                highlightedId: defaultModel.id,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? accentColor.withValues(alpha: 0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? accentColor
                                    : AppTheme.primaryBrown.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        brand,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isSelected ? accentColor : AppTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        catSummary,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.bgCream,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${models.length} model',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryBrown,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(CupertinoIcons.chevron_right, size: 15, color: AppTheme.textMuted),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openModelPicker(
    BuildContext context, {
    required String brand,
    GrinderCategory? categoryFilter,
    String? highlightedId,
  }) async {
    final models = GrinderConversionEngine.getModelsForBrand(
      brand,
      category: categoryFilter,
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.75,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBrown.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Langkah 2 · Pilih Model $brand',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          '${models.length} model tersedia · pilih sesuai grinder Anda',
                          style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: models.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final spec = models[index];
                    final active = spec.id == (highlightedId ?? selectedGrinder.id);
                    final isElectric = spec.category == GrinderCategory.electric;

                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        onGrinderSelected(spec);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: active ? accentColor.withValues(alpha: 0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: active
                                ? accentColor
                                : AppTheme.primaryBrown.withValues(alpha: 0.1),
                            width: active ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    spec.model,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: active ? accentColor : AppTheme.textDark,
                                    ),
                                  ),
                                ),
                                _SmallTag(
                                  label: isElectric ? 'Elektrik' : 'Manual',
                                  color: isElectric ? const Color(0xFF1565C0) : AppTheme.primaryBrown,
                                ),
                                const SizedBox(width: 6),
                                _CalibrationBadge(tier: spec.calibrationTier),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${spec.burrSpec} · ${spec.dialPlacement}',
                              style: const TextStyle(fontSize: 11.5, color: AppTheme.textDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              spec.dialStructureSummary,
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modelCount = GrinderConversionEngine.modelCountForBrand(selectedGrinder.brand);
    final isElectric = selectedGrinder.category == GrinderCategory.electric;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openBrandPicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1. MEREK',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedGrinder.brand,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ),
                          Icon(CupertinoIcons.chevron_down, size: 13, color: accentColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openModelPicker(
                  context,
                  brand: selectedGrinder.brand,
                  highlightedId: selectedGrinder.id,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '2. MODEL ($modelCount opsi)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            isElectric ? '⚡ Elektrik' : '✋ Manual',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: isElectric ? const Color(0xFF1565C0) : AppTheme.primaryBrown,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedGrinder.model,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                          Icon(CupertinoIcons.chevron_down, size: 13, color: accentColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${selectedGrinder.burrSpec} · ${selectedGrinder.dialStructureSummary}',
          style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
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

class _SmallTag extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _CalibrationBadge extends StatelessWidget {
  final CalibrationTier tier;

  const _CalibrationBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (tier) {
      CalibrationTier.fullMultiAnchor => ('Terverifikasi', const Color(0xFF15803D)),
      CalibrationTier.partialAnchor => ('Parsial', const Color(0xFFB45309)),
      CalibrationTier.specOnly => ('Spec-Only', const Color(0xFF64748B)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
