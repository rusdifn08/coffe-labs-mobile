import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../data/world_indonesia_beans_service.dart';
import '../../../../theme/app_theme.dart';
import '../data/coffee_varieties_catalog.dart';

/// Multi-select, searchable Coffee Variety popup bottom sheet (30+ varieties + custom).
/// Eliminates cramped horizontal scrolling and allows picking 1 or multiple varieties
/// (e.g., mixed heirloom / multi-varietal lots).
class VarietyPickerModal {
  static Future<void> show({
    required BuildContext context,
    required Set<String> selectedVarieties,
    required ValueChanged<Set<String>> onConfirmVarieties,
  }) async {
    WorldIndonesiaBeansService.instance.ensureLoaded();
    String searchQuery = '';
    String selectedCategory = 'Semua';
    bool triggeredLoad = false;
    final Set<String> workingSelection = Set<String>.from(selectedVarieties);
    final TextEditingController customController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            if (!triggeredLoad &&
                !WorldIndonesiaBeansService.instance.isLoaded) {
              triggeredLoad = true;
              WorldIndonesiaBeansService.instance.ensureLoaded().then((_) {
                if (modalCtx.mounted) setModalState(() {});
              });
            }

            final allVarieties = CoffeeVarietiesCatalog.getMergedVarieties();
            final filtered = allVarieties.where((v) {
              final matchCat = selectedCategory == 'Semua' ||
                  v.category.contains(selectedCategory);
              final q = searchQuery.trim().toLowerCase();
              final matchQuery = q.isEmpty ||
                  v.name.toLowerCase().contains(q) ||
                  v.origin.toLowerCase().contains(q) ||
                  v.tasteProfile.toLowerCase().contains(q);
              return matchCat && matchQuery;
            }).toList();

            void toggleVariety(String name) {
              setModalState(() {
                if (workingSelection.contains(name)) {
                  workingSelection.remove(name);
                } else {
                  workingSelection.add(name);
                }
              });
            }

            void addCustomVariety(String raw) {
              final trimmed = raw.trim();
              if (trimmed.isEmpty) return;
              setModalState(() {
                workingSelection.add(trimmed);
                customController.clear();
              });
            }

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.84,
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

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: Color(0xFF2E7D32),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pilih Varietas Kopi',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                            Text(
                              'Bisa pilih lebih dari 1 varietas (${workingSelection.length} dipilih)',
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

                  // Selected preview strip
                  if (workingSelection.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
                        ),
                      ),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: workingSelection.map((v) {
                          return InkWell(
                            onTap: () => toggleVariety(v),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      v,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    CupertinoIcons.xmark,
                                    size: 11,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Search field
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari varietas (Bourbon, Typica, Gesha, S-795)...',
                      hintStyle: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textMuted,
                      ),
                      prefixIcon: const Icon(
                        CupertinoIcons.search,
                        size: 17,
                        color: Color(0xFF2E7D32),
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
                    onChanged: (val) => setModalState(() => searchQuery = val),
                  ),
                  const SizedBox(height: 8),

                  // Category Wrap chips (no cramped horizontal scroll)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      'Semua',
                      'Bourbon',
                      'Nusantara',
                      'Eksotik',
                      'Spesies',
                    ].map((cat) {
                      final isSel = selectedCategory == cat;
                      return InkWell(
                        onTap: () => setModalState(() => selectedCategory = cat),
                        borderRadius: BorderRadius.circular(9),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isSel
                                ? const Color(0xFF2E7D32)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: isSel
                                  ? const Color(0xFF2E7D32)
                                  : AppTheme.borderWarm,
                            ),
                          ),
                          child: Text(
                            cat == 'Semua'
                                ? 'Semua (${allVarieties.length})'
                                : cat,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSel ? Colors.white : AppTheme.textDark,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),

                  // Variety List
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Varietas tidak ditemukan di katalog.',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                if (searchQuery.trim().isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    onPressed: () => addCustomVariety(searchQuery),
                                    icon: const Icon(CupertinoIcons.plus, size: 15),
                                    label: Text('Tambah "${searchQuery.trim()}"'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 7),
                            itemBuilder: (_, idx) {
                              final item = filtered[idx];
                              final isSelected =
                                  workingSelection.contains(item.name);
                              return InkWell(
                                onTap: () => toggleVariety(item.name),
                                borderRadius: BorderRadius.circular(13),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFECFDF5)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(13),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF2E7D32)
                                          : AppTheme.borderWarm,
                                      width: isSelected ? 1.4 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? CupertinoIcons.checkmark_circle_fill
                                            : CupertinoIcons.circle,
                                        color: isSelected
                                            ? const Color(0xFF2E7D32)
                                            : AppTheme.textMuted,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: AppTheme.textDark,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF2E7D32)
                                                          .withValues(alpha: 0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      item.origin,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 9.5,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Color(0xFF2E7D32),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              item.tasteProfile,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textMuted,
                                              ),
                                            ),
                                          ],
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

                  // Quick custom variety input inside popup
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: customController,
                          style: const TextStyle(fontSize: 12.5),
                          decoration: InputDecoration(
                            hintText: 'Tambah varietas kustom (mis. Sidra, Chiroso)...',
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
                          onSubmitted: addCustomVariety,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => addCustomVariety(customController.text),
                        borderRadius: BorderRadius.circular(11),
                        child: Container(
                          height: 42,
                          width: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
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

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        onConfirmVarieties(workingSelection);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(CupertinoIcons.checkmark, size: 17),
                      label: Text(
                        workingSelection.isEmpty
                            ? 'Simpan Tanpa Varietas'
                            : 'Terapkan Varietas (${workingSelection.length})',
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

    customController.dispose();
  }
}
