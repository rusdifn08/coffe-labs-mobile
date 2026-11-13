import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../services/api_service.dart';
import '../../../../theme/app_theme.dart';
import '../../../scanner/data/local/prototype_database.dart';
import '../../domain/chat_protocol.dart';

class QuickShareSelection {
  final InteractiveAttachment attachment;
  final String? optionalCaption;

  const QuickShareSelection({
    required this.attachment,
    this.optionalCaption,
  });
}

class ChatQuickShareSheet extends StatefulWidget {
  const ChatQuickShareSheet({super.key});

  static Future<QuickShareSelection?> show(BuildContext context) {
    return showModalBottomSheet<QuickShareSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatQuickShareSheet(),
    );
  }

  @override
  State<ChatQuickShareSheet> createState() => _ChatQuickShareSheetState();
}

class _ChatQuickShareSheetState extends State<ChatQuickShareSheet> {
  int _tabIndex = 0; // 0: Resep Seduh, 1: Biji Kopi
  String _query = '';
  bool _loading = true;
  List<Map<String, dynamic>> _recipes = [];
  List<CoffeePrototypeRecord> _beans = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final rawRecipes = await ApiService.getRecipes();
      final recipeMaps = rawRecipes
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      List<CoffeePrototypeRecord> beanRecords = [];
      try {
        beanRecords = await PrototypeDatabase.loadAllPrototypes();
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _recipes = recipeMaps;
        _beans = beanRecords;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderWarm,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.sparkles,
                  color: AppTheme.primaryBrown,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Bagikan ke Ruang Obrolan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill,
                      color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _TabPill(
                    label: '+ Bagikan Resep V60',
                    selected: _tabIndex == 0,
                    onTap: () => setState(() => _tabIndex = 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TabPill(
                    label: '+ Bagikan Biji Kopi',
                    selected: _tabIndex == 1,
                    onTap: () => setState(() => _tabIndex = 1),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: _tabIndex == 0
                    ? 'Cari resep V60, Origami, Juara WBrC...'
                    : 'Cari roastery atau nama biji kopi...',
                prefixIcon: const Icon(CupertinoIcons.search, size: 18),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.borderWarm),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.borderWarm),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryBrown),
                  )
                : (_tabIndex == 0 ? _buildRecipesList() : _buildBeansList()),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesList() {
    final filtered = _recipes.where((r) {
      if (_query.isEmpty) return true;
      final hay =
          '${r['title'] ?? ''} ${r['method'] ?? ''} ${r['author'] ?? ''}'
              .toLowerCase();
      return hay.contains(_query);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada resep yang cocok.',
          style: TextStyle(color: AppTheme.textMuted),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        final r = filtered[idx];
        final title = r['title']?.toString() ?? 'Resep Seduh';
        final method = r['method']?.toString() ?? 'Hario V60';
        final dose = (r['coffeeWeightGrams'] as num?)?.toDouble() ?? 15.0;
        final water = (r['totalWaterWeightGrams'] as num?)?.toDouble() ?? 225.0;
        final temp = (r['waterTempCelsius'] as num?)?.toInt() ?? 92;
        final time = (r['totalTimeSeconds'] as num?)?.toInt() ?? 150;
        final stepsList = (r['steps'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((s) => s['title']?.toString() ?? '')
            .where((t) => t.isNotEmpty)
            .take(3)
            .toList();

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              final card = InteractiveAttachment.v60RecipeCard(
                recipeId: r['id']?.toString() ?? '1',
                title: title,
                brewerName: method,
                doseGrams: dose,
                waterMl: water,
                tempC: temp,
                targetDurationSec: time,
                stepsPreview: stepsList,
              );
              Navigator.pop(
                context,
                QuickShareSelection(attachment: card),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderWarm),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      CupertinoIcons.drop_fill,
                      color: AppTheme.primaryBrown,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$method • ${dose.toStringAsFixed(0)}g : ${water.toStringAsFixed(0)}ml • $temp°C',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.arrow_up_right_circle_fill,
                    color: AppTheme.primaryBrown,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBeansList() {
    final sourceBeans = _beans.isNotEmpty
        ? _beans
            .map(
              (b) => InteractiveAttachment.coffeeBeanCard(
                beanId: b.id?.toString(),
                roastery: b.roastery,
                beanName: b.coffeeName,
                origin: b.origin,
                process: b.process,
                tastingNotes: b.tastingNotes,
              ),
            )
            .cast<CoffeeBeanCardAttachment>()
            .toList()
        : const [
            CoffeeBeanCardAttachment(
              roastery: 'Fugol Coffee Roasters',
              beanName: 'Halu Banana Wine',
              origin: 'Gunung Halu, Jawa Barat',
              process: 'Wine',
              tastingNotes: ['Banana', 'Jackfruit', 'Caramel'],
            ),
            CoffeeBeanCardAttachment(
              roastery: 'Space Roastery',
              beanName: 'Gayo Pantan Musara Carbonic',
              origin: 'Aceh Gayo, Sumatra',
              process: 'Carbonic Maceration',
              tastingNotes: ['Berries', 'Floral', 'Sweet Tea'],
            ),
            CoffeeBeanCardAttachment(
              roastery: 'Two Hands Full',
              beanName: 'Ijen Raung Honey',
              origin: 'Bondowoso, Jawa Timur',
              process: 'Honey',
              tastingNotes: ['Brown Sugar', 'Citrus', 'Chocolate'],
            ),
          ];

    final filtered = sourceBeans.where((b) {
      if (_query.isEmpty) return true;
      final hay = '${b.roastery} ${b.beanName} ${b.origin} ${b.process}'
          .toLowerCase();
      return hay.contains(_query);
    }).toList();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        final bean = filtered[idx];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.pop(
              context,
              QuickShareSelection(attachment: bean),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderWarm),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentAmber.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      CupertinoIcons.rosette,
                      color: AppTheme.primaryBrown,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bean.beanName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${bean.roastery} • ${bean.process} • ${bean.origin}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.arrow_up_right_circle_fill,
                    color: AppTheme.primaryBrown,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryBrown : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.primaryBrown : AppTheme.borderWarm,
          ),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppTheme.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
