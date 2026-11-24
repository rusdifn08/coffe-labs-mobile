import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../data/brew_visual_catalog.dart';
import '../../../../theme/app_theme.dart';
import '../data/cupping_constants.dart';

/// Reusable searchable multi-select popup bottom sheet for Cupping attributes:
/// - Post-Harvest Process (Washed, Natural, Anaerobic, etc.)
/// - Aftertaste Descriptors (Juicy, Lingering Sweetness, etc.)
/// - Mouthfeel / Body Descriptors (Silky & Smooth, Creamy, etc.)
class CuppingOptionPickerModal {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required List<String> options,
    required Set<String> selectedValues,
    required String customHint,
    required ValueChanged<Set<String>> onConfirm,
  }) async {
    final Set<String> working = Set<String>.from(selectedValues);
    final TextEditingController customCtrl = TextEditingController();
    String query = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (_, setModalState) {
            final allOpts = <String>{...options, ...working}.toList();
            final filtered = allOpts.where((item) {
              if (query.trim().isEmpty) return true;
              return item.toLowerCase().contains(query.trim().toLowerCase());
            }).toList();

            void toggle(String val) {
              setModalState(() {
                if (working.contains(val)) {
                  working.remove(val);
                } else {
                  working.add(val);
                }
              });
            }

            void addCustom(String raw) {
              final trimmed = raw.trim();
              if (trimmed.isEmpty) return;
              setModalState(() {
                working.add(trimmed);
                customCtrl.clear();
              });
            }

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.74,
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.bgCream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.borderWarm,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(icon, color: accentColor, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                            Text(
                              '$subtitle (${working.length} dipilih)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Search bar
                  TextField(
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Cari opsi...',
                      hintStyle: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textMuted,
                      ),
                      prefixIcon: Icon(
                        CupertinoIcons.search,
                        size: 17,
                        color: accentColor,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(color: AppTheme.borderWarm),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(color: AppTheme.borderWarm),
                      ),
                    ),
                    onChanged: (v) => setModalState(() => query = v),
                  ),
                  const SizedBox(height: 10),

                  // Options List
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 7),
                      itemBuilder: (_, idx) {
                        final item = filtered[idx];
                        final isSel = working.contains(item);
                        return InkWell(
                          onTap: () => toggle(item),
                          borderRadius: BorderRadius.circular(13),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? accentColor.withValues(alpha: 0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: isSel ? accentColor : AppTheme.borderWarm,
                                width: isSel ? 1.4 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSel
                                      ? CupertinoIcons.checkmark_circle_fill
                                      : CupertinoIcons.circle,
                                  size: 19,
                                  color:
                                      isSel ? accentColor : AppTheme.textMuted,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSel
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Custom input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: customCtrl,
                          style: const TextStyle(fontSize: 12.5),
                          decoration: InputDecoration(
                            hintText: customHint,
                            hintStyle: const TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.textMuted,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                              borderSide:
                                  const BorderSide(color: AppTheme.borderWarm),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                              borderSide:
                                  const BorderSide(color: AppTheme.borderWarm),
                            ),
                          ),
                          onSubmitted: addCustom,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => addCustom(customCtrl.text),
                        borderRadius: BorderRadius.circular(11),
                        child: Container(
                          height: 42,
                          width: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            CupertinoIcons.plus,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        onConfirm(working);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(CupertinoIcons.checkmark, size: 17),
                      label: Text(
                        'Terapkan Pilihan (${working.length})',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    customCtrl.dispose();
  }
}

/// Searchable, categorized SCA Flavor Wheel & Tasting Notes multi-select popup.
/// Keeps the main Cupping sheet super compact while offering full 70+ notes + custom notes.
class FlavorNotesPickerModal {
  static Future<void> show({
    required BuildContext context,
    required Set<String> selectedNotes,
    required ValueChanged<Set<String>> onConfirm,
  }) async {
    final Set<String> working = Set<String>.from(selectedNotes);
    final TextEditingController customCtrl = TextEditingController();
    String activeCategory = 'Semua';
    String query = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (_, setModalState) {
            final q = query.trim().toLowerCase();
            final catClean = activeCategory.toLowerCase();

            final displayedNotes = BrewVisualCatalog.flavorNotes.where((fn) {
              if (q.isNotEmpty) {
                return fn.label.toLowerCase().contains(q) ||
                    fn.group.toLowerCase().contains(q);
              }
              if (catClean == 'semua') return true;
              final g = fn.group.toLowerCase();
              if (catClean.contains('fruity')) {
                return g == 'stone fruit' || g == 'tropical';
              }
              if (catClean.contains('orchard')) return g == 'orchard fruit';
              if (catClean.contains('berry')) return g == 'berry';
              if (catClean.contains('citrus')) return g == 'citrus';
              if (catClean.contains('floral')) return g == 'floral';
              if (catClean.contains('cokelat') || catClean.contains('manis')) {
                return g == 'sweet' || g == 'cocoa';
              }
              if (catClean.contains('nutty') || catClean.contains('rempah')) {
                return g == 'nutty' || g == 'herbal';
              }
              if (catClean.contains('teh') || catClean.contains('fermentasi')) {
                return g == 'tea-like' || g == 'winey';
              }
              if (catClean.contains('body') || catClean.contains('finish')) {
                return g == 'mouthfeel';
              }
              return true;
            }).toList();

            void toggleNote(String note) {
              setModalState(() {
                if (working.contains(note)) {
                  working.remove(note);
                } else {
                  working.add(note);
                }
              });
            }

            void addCustom(String raw) {
              final trimmed = raw.trim();
              if (trimmed.isEmpty) return;
              setModalState(() {
                working.add(trimmed);
                customCtrl.clear();
              });
            }

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.85,
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.bgCream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.borderWarm,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentAmber.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          CupertinoIcons.sparkles,
                          color: AppTheme.primaryBrown,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SCA Flavor Wheel & Notes',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                            Text(
                              'Pilih semua profil rasa terdeteksi (${working.length} dipilih)',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Search notes
                  TextField(
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Cari rasa (Peach, Jasmine, Caramel, Berry)...',
                      hintStyle: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textMuted,
                      ),
                      prefixIcon: const Icon(
                        CupertinoIcons.search,
                        size: 17,
                        color: AppTheme.primaryBrown,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(color: AppTheme.borderWarm),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(color: AppTheme.borderWarm),
                      ),
                    ),
                    onChanged: (v) => setModalState(() => query = v),
                  ),
                  const SizedBox(height: 8),

                  // Category pills (clean Wrap)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: CuppingConstants.noteCategories.map((cat) {
                      final isSel = activeCategory == cat;
                      return InkWell(
                        onTap: () => setModalState(() => activeCategory = cat),
                        borderRadius: BorderRadius.circular(9),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isSel ? AppTheme.primaryBrown : Colors.white,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: isSel
                                  ? AppTheme.primaryBrown
                                  : AppTheme.borderWarm,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 10.8,
                              fontWeight: FontWeight.w700,
                              color: isSel ? Colors.white : AppTheme.textDark,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),

                  // Scrollable Flavor Badges Grid
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderWarm),
                      ),
                      child: displayedNotes.isEmpty
                          ? Center(
                              child: Text(
                                'Tidak ditemukan. Tambahkan langsung lewat kolom custom di bawah.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Wrap(
                                spacing: 7,
                                runSpacing: 7,
                                children: displayedNotes.map((fn) {
                                  final isSel = working.contains(fn.label);
                                  return FlavorNoteVisualBadge(
                                    noteText: fn.label,
                                    selected: isSel,
                                    onTap: () => toggleNote(fn.label),
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Custom Note Input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: customCtrl,
                          style: const TextStyle(fontSize: 12.5),
                          decoration: InputDecoration(
                            hintText:
                                'Tambah rasa custom (mis. Earl Grey, Gula Aren)...',
                            hintStyle: const TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.textMuted,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                              borderSide:
                                  const BorderSide(color: AppTheme.borderWarm),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                              borderSide:
                                  const BorderSide(color: AppTheme.borderWarm),
                            ),
                          ),
                          onSubmitted: addCustom,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => addCustom(customCtrl.text),
                        borderRadius: BorderRadius.circular(11),
                        child: Container(
                          height: 42,
                          width: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBrown,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            CupertinoIcons.plus,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        onConfirm(working);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(CupertinoIcons.checkmark, size: 17),
                      label: Text(
                        'Simpan Tasting Notes (${working.length})',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    customCtrl.dispose();
  }
}
