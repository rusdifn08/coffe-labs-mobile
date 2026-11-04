import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/bean_recommendation_models.dart';
import '../../../theme/app_theme.dart';

class BeanInputSelectorCard extends StatelessWidget {
  final TextEditingController beanNameCtrl;
  final BeanRoastLevel selectedRoast;
  final BeanProcess selectedProcess;
  final List<String> popularOrigins;
  final ValueChanged<BeanRoastLevel> onRoastChanged;
  final ValueChanged<BeanProcess> onProcessChanged;
  final VoidCallback onRecalculate;

  const BeanInputSelectorCard({
    super.key,
    required this.beanNameCtrl,
    required this.selectedRoast,
    required this.selectedProcess,
    required this.popularOrigins,
    required this.onRoastChanged,
    required this.onProcessChanged,
    required this.onRecalculate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. Karakter Biji Kopi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
          const SizedBox(height: 10),
          TextField(
            controller: beanNameCtrl,
            decoration: InputDecoration(
              labelText: 'Nama Biji / Origin Kopi',
              hintText: 'Contoh: Aceh Gayo Pantan Musara',
              prefixIcon: const Icon(CupertinoIcons.tag_fill, size: 18, color: AppTheme.primaryBrown),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (_) => onRecalculate(),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: popularOrigins.map((org) {
                final isSel = beanNameCtrl.text == org;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(org, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : AppTheme.textDark)),
                    selected: isSel,
                    selectedColor: AppTheme.primaryBrown,
                    backgroundColor: AppTheme.bgCream,
                    onSelected: (val) {
                      if (val) {
                        beanNameCtrl.text = org;
                        onRecalculate();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Tingkat Sangrai (Roast Level)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: BeanRoastLevel.values.map((r) {
              final isSel = selectedRoast == r;
              return ChoiceChip(
                label: Text(
                  r.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    color: isSel ? Colors.white : AppTheme.textDark,
                  ),
                ),
                selected: isSel,
                selectedColor: AppTheme.primaryBrown,
                backgroundColor: AppTheme.bgCream,
                onSelected: (val) {
                  if (val) onRoastChanged(r);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          const Text('Metode Pasca-Panen (Process)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: BeanProcess.values.map((p) {
              final isSel = selectedProcess == p;
              return ChoiceChip(
                label: Text(
                  p.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    color: isSel ? Colors.white : AppTheme.textDark,
                  ),
                ),
                selected: isSel,
                selectedColor: AppTheme.primaryBrown,
                backgroundColor: AppTheme.bgCream,
                onSelected: (val) {
                  if (val) onProcessChanged(p);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
