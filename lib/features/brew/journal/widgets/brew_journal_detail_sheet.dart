import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../services/language_service.dart';
import '../../../../theme/app_theme.dart';
import '../../controllers/brew_journal_controller.dart';
import '../models/brew_journal_entry.dart';
import 'brew_journal_editor_sheet.dart';
import 'brew_journal_sensory_chart.dart';

/// Tampilan Detail Jurnal Seduh lengkap dengan Grafik Sensorik (Radar & Batang),
/// Edit fleksibel, dan manajemen Catatan Tambahan (tambah, edit, hapus follow-up notes).
class BrewJournalDetailSheet extends ConsumerStatefulWidget {
  final BrewJournalEntry initialEntry;

  const BrewJournalDetailSheet({super.key, required this.initialEntry});

  static Future<void> show(
    BuildContext context, {
    required BrewJournalEntry entry,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BrewJournalDetailSheet(initialEntry: entry),
    );
  }

  @override
  ConsumerState<BrewJournalDetailSheet> createState() =>
      _BrewJournalDetailSheetState();
}

class _BrewJournalDetailSheetState
    extends ConsumerState<BrewJournalDetailSheet> {
  late BrewJournalEntry _entry;
  bool _showRadarChart = true;
  final TextEditingController _followUpCtrl = TextEditingController();
  bool _addingNote = false;

  @override
  void initState() {
    super.initState();
    _entry = widget.initialEntry;
  }

  @override
  void dispose() {
    _followUpCtrl.dispose();
    super.dispose();
  }

  Future<void> _openEditSheet({bool openSensory = false}) async {
    final updated = await BrewJournalEditorSheet.show(
      context,
      existing: _entry,
      openSensoryByDefault: openSensory,
    );
    if (updated != null && mounted) {
      setState(() => _entry = updated);
    }
  }

  Future<void> _addFollowUp() async {
    final text = _followUpCtrl.text.trim();
    if (text.isEmpty || _addingNote) return;
    setState(() => _addingNote = true);
    final updated = await ref
        .read(brewJournalControllerProvider.notifier)
        .addFollowUpNote(_entry, text);
    if (!mounted) return;
    _followUpCtrl.clear();
    setState(() {
      _entry = updated;
      _addingNote = false;
    });
  }

  Future<void> _editFollowUp(JournalFollowUpNote note) async {
    final isEn = LanguageService.isEnglish;
    final ctrl = TextEditingController(text: note.text);
    final savedText = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isEn ? 'Edit Additional Note' : 'Edit Catatan Tambahan',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          minLines: 2,
          autofocus: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.bgCream,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isEn ? 'Cancel' : 'Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrown,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(isEn ? 'Save' : 'Simpan'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (savedText == null || savedText.isEmpty) return;

    final updated = await ref
        .read(brewJournalControllerProvider.notifier)
        .editFollowUpNote(_entry, note.id, savedText);
    if (mounted) setState(() => _entry = updated);
  }

  Future<void> _deleteFollowUp(JournalFollowUpNote note) async {
    final updated = await ref
        .read(brewJournalControllerProvider.notifier)
        .deleteFollowUpNote(_entry, note.id);
    if (mounted) setState(() => _entry = updated);
  }

  Future<void> _confirmDeleteEntry() async {
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
              ? 'This brew journal and all its additional notes will be permanently removed.'
              : 'Catatan seduh ini beserta seluruh catatan tambahannya akan dihapus permanen.',
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
    await ref.read(brewJournalControllerProvider.notifier).deleteEntry(_entry.id);
    if (mounted) Navigator.pop(context);
  }

  Widget _chartModeTab({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryBrown : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildMetaPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryBrown.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5, color: AppTheme.primaryBrown),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final dateFmt = DateFormat('dd MMM yyyy • HH:mm');

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderWarm,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _entry.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < _entry.rating.round()
                                    ? CupertinoIcons.star_fill
                                    : CupertinoIcons.star,
                                size: 15,
                                color: AppTheme.accentAmber,
                              );
                            }),
                            const SizedBox(width: 6),
                            Text(
                              _entry.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryBrown,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dateFmt.format(_entry.createdAt.toLocal()),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_entry.updatedAt != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '${isEn ? "Updated" : "Diperbarui"} ${dateFmt.format(_entry.updatedAt!.toLocal())}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontStyle: FontStyle.italic,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark_circle_fill,
                        color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.borderWarm),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Metadata parameter pills
                    if (_entry.method.isNotEmpty ||
                        _entry.grindSize.isNotEmpty ||
                        _entry.beanName.isNotEmpty ||
                        _entry.doseGrams != null) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (_entry.method.isNotEmpty)
                            _buildMetaPill(CupertinoIcons.drop_fill, _entry.method),
                          if (_entry.grindSize.isNotEmpty)
                            _buildMetaPill(
                              CupertinoIcons.slider_horizontal_3,
                              _entry.grindSize,
                            ),
                          if (_entry.beanName.isNotEmpty)
                            _buildMetaPill(CupertinoIcons.sparkles, _entry.beanName),
                          if (_entry.doseGrams != null &&
                              _entry.waterGrams != null)
                            _buildMetaPill(
                              CupertinoIcons.gauge,
                              '${_entry.doseGrams!.toStringAsFixed(0)}g : ${_entry.waterGrams!.toStringAsFixed(0)}ml',
                            ),
                          if (_entry.tempCelsius != null)
                            _buildMetaPill(
                              CupertinoIcons.thermometer,
                              '${_entry.tempCelsius}°C',
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Grafik Profil Sensorik (Radar + Batang)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.borderWarm),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.chart_bar_alt_fill,
                                color: AppTheme.primaryBrown,
                                size: 17,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  isEn
                                      ? 'Sensory Chart'
                                      : 'Grafik Sensorik',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                              if (_entry.hasSensoryChart)
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.bgCream,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: AppTheme.borderWarm),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _chartModeTab(
                                        label: 'Radar',
                                        active: _showRadarChart,
                                        onTap: () => setState(
                                            () => _showRadarChart = true),
                                      ),
                                      _chartModeTab(
                                        label: isEn ? 'Bars' : 'Batang',
                                        active: !_showRadarChart,
                                        onTap: () => setState(
                                            () => _showRadarChart = false),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_entry.hasSensoryChart)
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              child: _showRadarChart
                                  ? Center(
                                      key: const ValueKey('radar_chart'),
                                      child: BrewJournalSensoryRadarChart(
                                        metrics: _entry.sensoryMetrics,
                                        maxScale: _entry.sensoryMaxScale,
                                        size: 225,
                                      ),
                                    )
                                  : Padding(
                                      key: const ValueKey('bar_chart'),
                                      padding: const EdgeInsets.only(top: 4),
                                      child: BrewJournalSensoryBarChart(
                                        metrics: _entry.sensoryMetrics,
                                        maxScale: _entry.sensoryMaxScale,
                                      ),
                                    ),
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isEn
                                        ? 'No sensory chart scores yet. Add acidity, sweetness, bitterness, body & clarity scores.'
                                        : 'Belum ada data grafik sensorik. Tambahkan skor Asam, Manis, Pahit, Body & Clarity.',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () =>
                                      _openEditSheet(openSensory: true),
                                  icon: const Icon(CupertinoIcons.plus_circle,
                                      size: 15),
                                  label: Text(isEn ? 'Add' : 'Isi Skor'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.primaryBrown,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Catatan Utama
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderWarm),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isEn ? 'Main Tasting Note' : 'Catatan Utama',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _openEditSheet(),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.primaryBrown,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                ),
                                icon: const Icon(CupertinoIcons.pencil, size: 14),
                                label: Text(
                                  isEn ? 'Edit' : 'Edit',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _entry.notes.isNotEmpty
                                ? _entry.notes
                                : (isEn
                                    ? 'No main notes recorded yet.'
                                    : 'Belum ada catatan utama.'),
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.45,
                              color: _entry.notes.isNotEmpty
                                  ? AppTheme.textDark
                                  : AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Catatan Tambahan (Follow-Up Notes)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderWarm),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.doc_append,
                                color: AppTheme.primaryBrown,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${isEn ? "Additional Notes" : "Catatan Tambahan"} (${_entry.additionalNotes.length})',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _followUpCtrl,
                                  minLines: 1,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText: isEn
                                        ? 'Add follow-up note (e.g. sweeter when cooled)...'
                                        : 'Tulis catatan tambahan (misal: lebih manis saat hangat)...',
                                    hintStyle: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                    ),
                                    filled: true,
                                    fillColor: AppTheme.bgCream,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: AppTheme.borderWarm),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: AppTheme.borderWarm),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _addingNote ? null : _addFollowUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBrown,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  isEn ? 'Add' : 'Tambah',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_entry.additionalNotes.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ..._entry.additionalNotes.map((note) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(11),
                                decoration: BoxDecoration(
                                  color: AppTheme.bgCream.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primaryBrown
                                        .withValues(alpha: 0.12),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      note.text,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.38,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${dateFmt.format(note.createdAt.toLocal())}${note.updatedAt != null ? (isEn ? " • edited" : " • diedit") : ""}',
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () => _editFollowUp(note),
                                              child: const Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Icon(
                                                  CupertinoIcons.pencil,
                                                  size: 14,
                                                  color: AppTheme.primaryBrown,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            InkWell(
                                              onTap: () =>
                                                  _deleteFollowUp(note),
                                              child: const Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Icon(
                                                  CupertinoIcons.trash,
                                                  size: 14,
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Footer
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _confirmDeleteEntry,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(CupertinoIcons.trash, size: 16),
                            label: Text(isEn ? 'Delete' : 'Hapus'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () => _openEditSheet(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBrown,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(CupertinoIcons.pencil, size: 16),
                            label: Text(
                              isEn ? 'Edit Full Journal' : 'Edit Jurnal Lengkap',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
