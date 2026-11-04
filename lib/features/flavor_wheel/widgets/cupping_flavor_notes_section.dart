import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../data/brew_visual_catalog.dart';

class CuppingFlavorNotesSection extends StatelessWidget {
  final String activeNoteCategory;
  final List<String> noteCategories;
  final Set<String> selectedNotes;
  final TextEditingController customNoteInputController;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<String> onToggleNote;
  final VoidCallback onAddCustomNote;
  final ValueChanged<String> onRemoveNote;

  const CuppingFlavorNotesSection({
    super.key,
    required this.activeNoteCategory,
    required this.noteCategories,
    required this.selectedNotes,
    required this.customNoteInputController,
    required this.onCategorySelected,
    required this.onToggleNote,
    required this.onAddCustomNote,
    required this.onRemoveNote,
  });

  @override
  Widget build(BuildContext context) {
    final catClean = activeNoteCategory.toLowerCase();
    final List<FlavorNoteVisualItem> displayedNotes = BrewVisualCatalog.flavorNotes.where((fn) {
      final g = fn.group.toLowerCase();
      if (catClean.contains('fruity')) return g == 'stone fruit' || g == 'tropical';
      if (catClean.contains('orchard')) return g == 'orchard fruit';
      if (catClean.contains('berry')) return g == 'berry';
      if (catClean.contains('citrus')) return g == 'citrus';
      if (catClean.contains('floral')) return g == 'floral';
      if (catClean.contains('cokelat') || catClean.contains('manis')) return g == 'sweet' || g == 'cocoa';
      if (catClean.contains('nutty') || catClean.contains('rempah')) return g == 'nutty' || g == 'herbal';
      if (catClean.contains('teh') || catClean.contains('fermentasi')) return g == 'tea-like' || g == 'winey';
      if (catClean.contains('body') || catClean.contains('finish')) return g == 'mouthfeel';
      return false;
    }).toList();

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
                  Icon(CupertinoIcons.sparkles, color: AppTheme.accentAmber, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '2. Flavor Wheel & Tasting Notes',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${selectedNotes.length} Terpilih',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Horizontal Category Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: noteCategories.map((cat) {
                final isSelected = activeNoteCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryBrown,
                    backgroundColor: AppTheme.bgCream,
                    labelStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.textDark,
                    ),
                    onSelected: (_) => onCategorySelected(cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Flavor Notes Wrap Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: displayedNotes.map((fn) {
              final isSelected = selectedNotes.contains(fn.label);
              return FlavorNoteVisualBadge(
                noteText: fn.label,
                selected: isSelected,
                onTap: () => onToggleNote(fn.label),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Custom Note Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: customNoteInputController,
                  decoration: InputDecoration(
                    hintText: 'Tambah rasa unik custom (misal: Earl Grey Apricot)...',
                    hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.bgCream,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => onAddCustomNote(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: onAddCustomNote,
                icon: const Icon(CupertinoIcons.plus, size: 18),
                style: IconButton.styleFrom(backgroundColor: AppTheme.primaryBrown),
              ),
            ],
          ),

          // Selected Notes Summary
          if (selectedNotes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: selectedNotes.map((note) {
                return Chip(
                  label: Text(note, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  backgroundColor: AppTheme.primaryBrown,
                  deleteIcon: const Icon(CupertinoIcons.xmark, size: 12, color: Colors.white),
                  onDeleted: () => onRemoveNote(note),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
