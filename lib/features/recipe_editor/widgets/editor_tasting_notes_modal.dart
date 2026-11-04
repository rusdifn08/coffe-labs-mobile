import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../data/brew_visual_catalog.dart';
import '../../../../theme/app_theme.dart';

class EditorTastingNotesModal {
  static void show({
    required BuildContext context,
    required Set<String> initialSelectedNotes,
    required ValueChanged<Set<String>> onApplied,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String searchQuery = '';
        String selectedGroupFilter = '🍑 Fruity (Tropical & Stone)';
        final Set<String> tempSelected = Set.from(initialSelectedNotes);

        final groups = [
          '🍑 Fruity (Tropical & Stone)',
          '🍎 Orchard Fruit',
          '🍓 Berry',
          '🍋 Citrus',
          '🌸 Floral',
          '🍯 Sweet',
          '🍫 Cocoa',
          '🥜 Nutty',
          '🪵 Spices & Herbal',
          '🍷 Winey & Ferment',
          '🍵 Tea-like',
          '✨ Mouthfeel',
        ];

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredNotes = BrewVisualCatalog.flavorNotes.where((note) {
              final matchesQuery = searchQuery.isEmpty ||
                  note.label.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  note.group.toLowerCase().contains(searchQuery.toLowerCase());
              if (!matchesQuery) return false;
              if (selectedGroupFilter.contains('Fruity')) {
                return note.group == 'Stone Fruit' || note.group == 'Tropical';
              }
              if (selectedGroupFilter.contains('Orchard')) {
                return note.group == 'Orchard Fruit';
              }
              if (selectedGroupFilter.contains('Spices')) {
                return note.group == 'Herbal';
              }
              if (selectedGroupFilter.contains('Winey')) {
                return note.group == 'Winey';
              }
              if (selectedGroupFilter.contains('Tea')) {
                return note.group == 'Tea-like';
              }
              if (selectedGroupFilter.contains('Mouthfeel')) {
                return note.group == 'Mouthfeel';
              }
              final cleanGrp = selectedGroupFilter.replaceAll(RegExp(r'[^\w\s]'), '').trim().toLowerCase();
              return note.group.toLowerCase().contains(cleanGrp);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.86,
              decoration: const BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilih Tasting Notes Lengkap',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pilih aroma & rasa (bisa lebih dari satu)',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Search Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari notes (misal: jasmine, citrus, berry...)',
                        prefixIcon: const Icon(CupertinoIcons.search, size: 18, color: AppTheme.primaryBrown),
                        filled: true,
                        fillColor: AppTheme.bgCream.withValues(alpha: 0.6),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Group Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: groups.map((grp) {
                        final isSel = selectedGroupFilter == grp;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(grp, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                            selected: isSel,
                            selectedColor: AppTheme.primaryBrown,
                            labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.textDark),
                            backgroundColor: AppTheme.bgCream,
                            onSelected: (_) {
                              setModalState(() {
                                selectedGroupFilter = grp;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 16),

                  // Notes Grid / Wrap
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        children: filteredNotes.map((note) {
                          final isSelected = tempSelected.contains(note.label);
                          return FlavorNoteVisualBadge(
                            noteText: note.label,
                            selected: isSelected,
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  tempSelected.remove(note.label);
                                } else {
                                  tempSelected.add(note.label);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Floating Bottom Confirmation
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempSelected.clear();
                            });
                          },
                          child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBrown,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              onApplied(tempSelected);
                              Navigator.pop(ctx);
                            },
                            child: Text(
                              'Terapkan (${tempSelected.length} Notes)',
                              style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
