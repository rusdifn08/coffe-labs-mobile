import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../../data/barista_toolkit_api_service.dart';
import '../../data/barista_toolkit_seed_data.dart';
import '../../domain/barista_toolkit_models.dart';

void showCoffeeDictionaryTermSheet(
  BuildContext context,
  CoffeeDictionaryEntryModel entry,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFFFFFBF5),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD7CCC8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Ref: ${entry.relatedBookCode} • Bab ${entry.relatedChapterNum}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF8D6E63)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.termTitle,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2C1810),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            entry.shortDefinitionId,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4E342E),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            entry.deepExplanationId,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF5D4037),
              height: 1.45,
            ),
          ),
          if (entry.relatedFormulaLatex != null &&
              entry.relatedFormulaLatex!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2B1B12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                entry.relatedFormulaLatex!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: AppTheme.accentGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class CoffeeDictionaryAzScreen extends ConsumerStatefulWidget {
  const CoffeeDictionaryAzScreen({super.key});

  @override
  ConsumerState<CoffeeDictionaryAzScreen> createState() =>
      _CoffeeDictionaryAzScreenState();
}

class _CoffeeDictionaryAzScreenState
    extends ConsumerState<CoffeeDictionaryAzScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<CoffeeDictionaryEntryModel> _all = const [];
  String _selectedLetter = 'ALL';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final offline = await BaristaToolkitFallbackSeed.offlineDictionary();
    if (!mounted) return;
    setState(() {
      _all = offline;
      _loading = false;
    });
    try {
      final remote = await ref.read(baristaToolkitApiProvider).fetchCoffeeDictionary();
      if (mounted && remote.isNotEmpty) {
        setState(() => _all = remote);
      }
    } catch (_) {}
  }

  List<CoffeeDictionaryEntryModel> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _all.where((e) {
      final okLetter = _selectedLetter == 'ALL' ||
          e.alphabetLetter.toUpperCase() == _selectedLetter;
      final okQ = q.isEmpty ||
          e.termTitle.toLowerCase().contains(q) ||
          e.shortDefinitionId.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q);
      return okLetter && okQ;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final letters = [
      'ALL',
      ...{for (final e in _all) e.alphabetLetter.toUpperCase()}.toList()..sort(),
    ];
    final items = _filtered;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kamus Kopi A–Z (Buku #8)',
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
            ),
            Text(
              '${_all.length} istilah sains, origin & manual brew',
              style: const TextStyle(fontSize: 11, color: Color(0xFF795548)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari istilah (contoh: Darcy, Bypass, GH, Rao)...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE7DDD3)),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: letters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, idx) {
                final l = letters[idx];
                final selected = _selectedLetter == l;
                return ChoiceChip(
                  label: Text(l == 'ALL' ? 'Semua' : l),
                  selected: selected,
                  selectedColor: AppTheme.primaryBrown,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : AppTheme.primaryBrown,
                  ),
                  onSelected: (_) => setState(() => _selectedLetter = l),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(
                    child: Text(
                      'Menyiapkan Kamus Kopi A–Z...',
                      style: TextStyle(color: Color(0xFF795548), fontWeight: FontWeight.w600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: items.length,
                    itemBuilder: (_, idx) {
                      final e = items[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          onTap: () => showCoffeeDictionaryTermSheet(context, e),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.12),
                            child: Text(
                              e.alphabetLetter,
                              style: const TextStyle(
                                color: AppTheme.primaryBrown,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          title: Text(
                            e.termTitle,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          subtitle: Text(
                            e.shortDefinitionId,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
