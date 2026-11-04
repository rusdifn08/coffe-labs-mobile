import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../data/brew_visual_catalog.dart';
import '../../../../theme/app_theme.dart';

class EditorGrinderPickerModal {
  static void show({
    required BuildContext context,
    required GrinderModel selectedGrinder,
    required ValueChanged<GrinderModel> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String searchQuery = '';
        String typeFilter = 'Semua';

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredGrinders = BrewVisualCatalog.grinderModels.where((g) {
              final matchesQuery = g.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  g.brand.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  g.typeDescription.toLowerCase().contains(searchQuery.toLowerCase());
              if (!matchesQuery) return false;
              if (typeFilter == 'Hand Grinder') {
                return !g.isElectric;
              } else if (typeFilter == 'Electric') {
                return g.isElectric;
              }
              return true;
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: const BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                              'Pilih Grinder Kopi',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '18 Grinder populer dunia & favorit barista Indonesia',
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
                  const SizedBox(height: 10),

                  // Search Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari grinder (Comandante, Timemore, DF64, Latina...)',
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

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: ['Semua', 'Hand Grinder', 'Electric'].map((t) {
                        final isSel = typeFilter == t;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(t, style: TextStyle(fontSize: 11.5, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                            selected: isSel,
                            selectedColor: AppTheme.primaryBrown,
                            labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.textDark),
                            backgroundColor: AppTheme.bgCream,
                            onSelected: (_) => setModalState(() => typeFilter = t),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 16),

                  // 2-GRID CARD LAYOUT
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.74,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filteredGrinders.length,
                      itemBuilder: (context, index) {
                        final g = filteredGrinders[index];
                        final isSelected = selectedGrinder.id == g.id;

                        return GestureDetector(
                          onTap: () {
                            onSelected(g);
                            Navigator.pop(ctx);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryBrown.withValues(alpha: 0.08)
                                  : AppTheme.surfaceWhite,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryBrown : Colors.grey.shade300,
                                width: isSelected ? 2.2 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Image with badge
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.asset(
                                            g.imagePath,
                                            fit: BoxFit.contain,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: g.isElectric ? AppTheme.accentAmber : AppTheme.primaryBrown,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            g.isElectric ? 'ELEKTRIK' : 'MANUAL',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: const BoxDecoration(
                                              color: AppTheme.primaryBrown,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(CupertinoIcons.checkmark, size: 12, color: Colors.white),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Grinder Name
                                Text(
                                  g.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppTheme.primaryBrown : AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),

                                // Burr / Subtitle
                                Text(
                                  g.typeDescription,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 9.5, color: AppTheme.textMuted),
                                ),
                                const SizedBox(height: 4),

                                // Clicks range pill
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryBrown.withValues(alpha: 0.14)
                                        : AppTheme.bgCream,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${g.minClicks} - ${g.maxClicks} Klik',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppTheme.primaryBrown : Colors.black87,
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
                ],
              ),
            );
          },
        );
      },
    );
  }
}
