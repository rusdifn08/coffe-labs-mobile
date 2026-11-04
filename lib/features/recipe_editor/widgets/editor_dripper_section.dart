import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../data/brew_visual_catalog.dart';
import '../../../../theme/app_theme.dart';

class EditorDripperSection extends StatelessWidget {
  final bool customDripperManual;
  final String selectedDripperName;
  final String selectedCategory;
  final TextEditingController methodController;
  final List<Map<String, dynamic>> categories;
  final void Function(DripperVisualItem item) onSelectDripper;
  final VoidCallback onSelectManual;
  final ValueChanged<String> onCategorySelected;

  const EditorDripperSection({
    super.key,
    required this.customDripperManual,
    required this.selectedDripperName,
    required this.selectedCategory,
    required this.methodController,
    required this.categories,
    required this.onSelectDripper,
    required this.onSelectManual,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            '2. Pilih Alat Dripper & Metode Seduh',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const Text(
          'Tap gambar alat seduh di bawah tanpa perlu ketik manual (atau pilih Lainnya):',
          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 112,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...BrewVisualCatalog.drippers.map((d) {
                final selected = !customDripperManual && selectedDripperName == d.name;
                return GestureDetector(
                  onTap: () => onSelectDripper(d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 108,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected ? d.color.withValues(alpha: 0.14) : AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? d.color : Colors.grey.shade300,
                        width: selected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DripperGraphicBadge(item: d, size: 42),
                        const SizedBox(height: 6),
                        Text(
                          d.shortName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                            color: selected ? d.color : AppTheme.textDark,
                          ),
                        ),
                        Text(
                          d.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: onSelectManual,
                child: Container(
                  width: 108,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: customDripperManual
                        ? AppTheme.primaryBrown.withValues(alpha: 0.14)
                        : AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: customDripperManual ? AppTheme.primaryBrown : Colors.grey.shade300,
                      width: customDripperManual ? 2.0 : 1.0,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.bgCream,
                        child: Icon(CupertinoIcons.pencil, color: AppTheme.primaryBrown, size: 20),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Lainnya',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                      ),
                      Text(
                        'Ketik Manual',
                        style: TextStyle(fontSize: 9, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (customDripperManual) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: methodController,
            decoration: InputDecoration(
              labelText: 'Ketik Nama Alat Dripper Manual',
              labelStyle: const TextStyle(fontSize: 13),
              prefixIcon: const Icon(CupertinoIcons.wrench_fill, size: 18, color: AppTheme.primaryBrown),
              filled: true,
              fillColor: AppTheme.bgCream.withValues(alpha: 0.5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final label = cat['label'] as String;
            final icon = cat['icon'] as IconData;
            final isSelected = selectedCategory == label;
            return ChoiceChip(
              avatar: Icon(icon, size: 15, color: isSelected ? Colors.white : AppTheme.primaryBrown),
              label: Text(label),
              selected: isSelected,
              selectedColor: AppTheme.primaryBrown,
              backgroundColor: AppTheme.surfaceWhite,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
              onSelected: (_) => onCategorySelected(label),
            );
          }).toList(),
        ),
      ],
    );
  }
}
