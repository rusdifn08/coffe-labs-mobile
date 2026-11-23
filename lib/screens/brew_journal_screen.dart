import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/brew/controllers/brew_journal_controller.dart';
import '../features/brew/journal/models/brew_journal_entry.dart';
import '../features/brew/journal/widgets/brew_journal_detail_sheet.dart';
import '../features/brew/journal/widgets/brew_journal_editor_sheet.dart';
import '../features/brew/journal/widgets/brew_journal_sensory_chart.dart';
import '../services/coffee_translator.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';

/// Halaman Jurnal Seduh Kopi interaktif dengan Detail Grafik Sensorik (Radar & Batang),
/// Edit fleksibel, Catatan Tambahan (follow-up notes), dan pencarian cepat.
class BrewJournalScreen extends ConsumerStatefulWidget {
  const BrewJournalScreen({super.key});

  @override
  ConsumerState<BrewJournalScreen> createState() => _BrewJournalScreenState();
}

class _BrewJournalScreenState extends ConsumerState<BrewJournalScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openCreateSheet({Map<String, dynamic>? recipe}) async {
    await BrewJournalEditorSheet.show(context, initialRecipe: recipe);
  }

  Future<void> _openEditSheet(BrewJournalEntry entry) async {
    await BrewJournalEditorSheet.show(context, existing: entry);
  }

  Future<void> _openDetailSheet(BrewJournalEntry entry) async {
    await BrewJournalDetailSheet.show(context, entry: entry);
  }

  Future<void> _confirmDelete(BrewJournalEntry entry) async {
    final isEn = LanguageService.isEnglish;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isEn ? 'Delete Journal Entry?' : 'Hapus Catatan Jurnal?',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          isEn
              ? 'Delete "${entry.title}" and all its additional notes?'
              : 'Hapus "${entry.title}" beserta seluruh catatan tambahannya?',
          style: const TextStyle(fontSize: 13.5, color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isEn ? 'Cancel' : 'Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isEn ? 'Delete' : 'Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(brewJournalControllerProvider.notifier).deleteEntry(entry.id);
  }

  List<BrewJournalEntry> _filterEntries(List<BrewJournalEntry> all) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((e) {
      if (e.title.toLowerCase().contains(q)) return true;
      if (e.notes.toLowerCase().contains(q)) return true;
      if (e.grindSize.toLowerCase().contains(q)) return true;
      if (e.method.toLowerCase().contains(q)) return true;
      if (e.beanName.toLowerCase().contains(q)) return true;
      if (e.additionalNotes.any((n) => n.text.toLowerCase().contains(q))) {
        return true;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final journalAsync = ref.watch(brewJournalControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(isEn ? 'Brew Journal' : 'Jurnal Seduh'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: isEn ? 'Add Brew Note' : 'Tambah Catatan Seduh',
            icon: const Icon(
              CupertinoIcons.plus_circle,
              color: AppTheme.primaryBrown,
            ),
            onPressed: () => _openCreateSheet(),
          ),
        ],
      ),
      body: journalAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBrown),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Gagal memuat jurnal: $err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
        data: (rawEntries) {
          final entries = rawEntries.map(BrewJournalEntry.fromMap).toList();
          if (entries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.book,
                      size: 54,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isEn
                          ? 'No brew notes yet.\nLog your extraction grind, sensory chart, notes, and ratings.'
                          : 'Belum ada catatan seduh.\nCatat rasa, grafik sensorik, grind size, dan rating hasil seduhanmu.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _openCreateSheet(),
                      icon: const Icon(CupertinoIcons.plus),
                      label: Text(
                        isEn ? 'Write First Note' : 'Tulis Catatan Pertama',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final filtered = _filterEntries(entries);
          final avgRating = entries.fold<double>(0, (s, e) => s + e.rating) /
              entries.length;
          final totalFollowUps = entries.fold<int>(
            0,
            (s, e) => s + e.additionalNotes.length,
          );

          return RefreshIndicator(
            color: AppTheme.primaryBrown,
            onRefresh: () async => ref.invalidate(brewJournalControllerProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
              children: [
                // Pencarian cepat
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: isEn
                        ? 'Search recipes, beans, or notes...'
                        : 'Cari resep, biji kopi, atau catatan...',
                    prefixIcon: const Icon(CupertinoIcons.search, size: 18),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              CupertinoIcons.clear_circled_solid,
                              size: 18,
                            ),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.surfaceWhite,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
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
                const SizedBox(height: 12),

                // Grafik Tren Kualitas Seduhan
                BrewJournalRatingTrendCard(
                  recentRatings: entries.map((e) => e.rating).toList(),
                  averageRating: avgRating,
                  totalEntries: entries.length,
                  totalFollowUps: totalFollowUps,
                ),
                const SizedBox(height: 14),

                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        isEn
                            ? 'No journal notes match "$_searchQuery".'
                            : 'Tidak ada catatan cocok untuk "$_searchQuery".',
                        style: const TextStyle(color: AppTheme.textMuted),
                      ),
                    ),
                  )
                else
                  ...filtered.map((entry) => _buildJournalCard(entry, isEn)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJournalCard(BrewJournalEntry entry, bool isEn) {
    final title =
        isEn ? CoffeeTranslator.translateTitle(entry.title) : entry.title;
    final dateText =
        '${entry.createdAt.day.toString().padLeft(2, '0')}/${entry.createdAt.month.toString().padLeft(2, '0')}/${entry.createdAt.year}';
    final previewMetrics = entry.sensoryMetrics.entries.take(3).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primaryBrown.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openDetailSheet(entry),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (starIdx) {
                        return Icon(
                          starIdx < entry.rating.round()
                              ? CupertinoIcons.star_fill
                              : CupertinoIcons.star,
                          color: AppTheme.accentAmber,
                          size: 14,
                        );
                      }),
                    ),
                  ],
                ),
                if (entry.grindSize.isNotEmpty || entry.method.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (entry.method.isNotEmpty)
                        _miniChip(CupertinoIcons.drop_fill, entry.method),
                      if (entry.grindSize.isNotEmpty)
                        _miniChip(
                          CupertinoIcons.slider_horizontal_3,
                          entry.grindSize,
                        ),
                    ],
                  ),
                ],
                if (previewMetrics.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final m in previewMetrics)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${m.key}: ${m.value.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ),
                      if (entry.hasSensoryChart)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBrown.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                CupertinoIcons.chart_pie_fill,
                                size: 11,
                                color: AppTheme.primaryBrown,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                isEn ? 'Chart' : 'Grafik',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryBrown,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
                if (entry.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    entry.notes,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textDark,
                      height: 1.4,
                    ),
                  ),
                ],
                if (entry.additionalNotes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCream,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.doc_append,
                          size: 12.5,
                          color: AppTheme.primaryBrown,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '+${entry.additionalNotes.length} ${isEn ? "additional notes" : "catatan tambahan"}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppTheme.borderWarm),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$dateText${entry.updatedAt != null ? (isEn ? " • edited" : " • diedit") : ""}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _cardActionBtn(
                      icon: CupertinoIcons.chart_bar_alt_fill,
                      label: isEn ? 'Detail' : 'Detail',
                      color: AppTheme.primaryBrown,
                      onTap: () => _openDetailSheet(entry),
                    ),
                    const SizedBox(width: 6),
                    _cardActionBtn(
                      icon: CupertinoIcons.pencil,
                      label: isEn ? 'Edit' : 'Edit',
                      color: const Color(0xFF0F766E),
                      onTap: () => _openEditSheet(entry),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _confirmDelete(entry),
                      child: const Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          CupertinoIcons.trash,
                          color: Colors.redAccent,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.5, color: AppTheme.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12.5, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
