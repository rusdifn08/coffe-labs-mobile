import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class CuppingCoffeeInfoSection extends StatelessWidget {
  final TextEditingController beanNameController;
  final TextEditingController originController;
  final TextEditingController cupperController;
  final TextEditingController customVarietyController;
  final TextEditingController customProcessController;
  final String selectedVariety;
  final bool isCustomVariety;
  final String selectedProcess;
  final bool isCustomProcess;
  final String selectedRoast;
  final String effectiveVariety;
  final String effectiveProcess;
  final List<String> popularVarieties;
  final List<String> popularProcesses;
  final List<String> roastPresets;
  final VoidCallback onOpenBeanCatalog;
  final VoidCallback onOpenVarietyCatalog;
  final ValueChanged<String> onSelectVarietyChip;
  final ValueChanged<String> onSelectProcessChip;
  final ValueChanged<String> onRoastChanged;

  const CuppingCoffeeInfoSection({
    super.key,
    required this.beanNameController,
    required this.originController,
    required this.cupperController,
    required this.customVarietyController,
    required this.customProcessController,
    required this.selectedVariety,
    required this.isCustomVariety,
    required this.selectedProcess,
    required this.isCustomProcess,
    required this.selectedRoast,
    required this.effectiveVariety,
    required this.effectiveProcess,
    required this.popularVarieties,
    required this.popularProcesses,
    required this.roastPresets,
    required this.onOpenBeanCatalog,
    required this.onOpenVarietyCatalog,
    required this.onSelectVarietyChip,
    required this.onSelectProcessChip,
    required this.onRoastChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              const Row(
                children: [
                  Icon(Icons.coffee_rounded, color: AppTheme.primaryBrown, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '1. Sampel Biji Kopi Cupping',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onOpenBeanCatalog,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppTheme.accentAmber.withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
                icon: const Icon(CupertinoIcons.search, size: 12, color: AppTheme.primaryBrown),
                label: const Text(
                  'Katalog',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nama Kopi & Asal Daerah
          TextField(
            controller: beanNameController,
            decoration: InputDecoration(
              labelText: 'Nama Kopi / Single Origin',
              labelStyle: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
              prefixIcon: const Icon(Icons.coffee_rounded, size: 18, color: AppTheme.primaryBrown),
              filled: true,
              fillColor: AppTheme.bgCream,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: originController,
            decoration: InputDecoration(
              labelText: 'Asal Daerah / Negara',
              labelStyle: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
              prefixIcon: const Icon(CupertinoIcons.globe, size: 18, color: AppTheme.primaryBrown),
              filled: true,
              fillColor: AppTheme.bgCream,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 14),

          // Varietas Kopi Selector
          Row(
            children: [
              const Icon(Icons.eco_rounded, size: 16, color: Color(0xFF2E7D32)),
              const SizedBox(width: 6),
              const Text('Varietas Kopi', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const Spacer(),
              InkWell(
                onTap: onOpenVarietyCatalog,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.search, size: 11, color: Color(0xFF2E7D32)),
                      SizedBox(width: 4),
                      Text('Katalog Lengkap (30+)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Terpilih: ', style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted)),
              Expanded(
                child: Text(
                  effectiveVariety,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: popularVarieties.map((v) {
                final isSelected = (selectedVariety == v && !isCustomVariety) || (v == 'Custom...' && isCustomVariety);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(v, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppTheme.textDark)),
                    selected: isSelected,
                    selectedColor: const Color(0xFF2E7D32),
                    backgroundColor: AppTheme.bgCream,
                    onSelected: (_) => onSelectVarietyChip(v),
                  ),
                );
              }).toList(),
            ),
          ),
          if (isCustomVariety) ...[
            const SizedBox(height: 8),
            TextField(
              controller: customVarietyController,
              decoration: InputDecoration(
                hintText: 'Ketik varietas kustom (misal: Pacamara, Sidra, Typica)...',
                filled: true,
                fillColor: AppTheme.bgCream,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Proses Pasca-Panen Selector
          Row(
            children: [
              const Icon(Icons.science_rounded, size: 16, color: Color(0xFFE65100)),
              const SizedBox(width: 6),
              const Text('Proses Pasca-Panen:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const Spacer(),
              Text(effectiveProcess, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: popularProcesses.map((p) {
                final isSelected = (selectedProcess == p && !isCustomProcess) || (p == 'Custom...' && isCustomProcess);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(p, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppTheme.textDark)),
                    selected: isSelected,
                    selectedColor: const Color(0xFFE65100),
                    backgroundColor: AppTheme.bgCream,
                    onSelected: (_) => onSelectProcessChip(p),
                  ),
                );
              }).toList(),
            ),
          ),
          if (isCustomProcess) ...[
            const SizedBox(height: 8),
            TextField(
              controller: customProcessController,
              decoration: InputDecoration(
                hintText: 'Ketik proses kustom (misal: Yeast Fermentation, Carbonic Maceration)...',
                filled: true,
                fillColor: AppTheme.bgCream,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Tingkat Sangrai & Nama Cupper
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey('roast_dropdown_$selectedRoast'),
                  initialValue: roastPresets.contains(selectedRoast) ? selectedRoast : 'Light-Medium',
                  decoration: InputDecoration(
                    labelText: 'Roast Level',
                    filled: true,
                    fillColor: AppTheme.bgCream,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  items: roastPresets.map((r) {
                    String label = r;
                    if (r == 'Light') {
                      label = 'Light Roast';
                    } else if (r == 'Medium') {
                      label = 'Medium Roast';
                    } else if (r == 'Dark') {
                      label = 'Dark Roast';
                    }
                    return DropdownMenuItem(value: r, child: Text(label, style: const TextStyle(fontSize: 12.5)));
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) onRoastChanged(v);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: cupperController,
                  decoration: InputDecoration(
                    labelText: 'Nama Cupper',
                    filled: true,
                    fillColor: AppTheme.bgCream,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
