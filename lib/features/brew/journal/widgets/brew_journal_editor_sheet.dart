import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/language_service.dart';
import '../../../../theme/app_theme.dart';
import '../../../../utils/barista_utils.dart';
import '../../../recipes/controllers/recipe_list_controller.dart';
import '../../controllers/brew_journal_controller.dart';
import '../models/brew_journal_entry.dart';
import 'brew_journal_sensory_chart.dart';

/// Modal bottom sheet fleksibel untuk membuat catatan Jurnal Seduh baru
/// maupun mengedit catatan yang sudah ada (termasuk slider grafik sensorik live).
class BrewJournalEditorSheet extends ConsumerStatefulWidget {
  final BrewJournalEntry? existing;
  final Map<String, dynamic>? initialRecipe;
  final bool openSensoryByDefault;

  const BrewJournalEditorSheet({
    super.key,
    this.existing,
    this.initialRecipe,
    this.openSensoryByDefault = false,
  });

  static Future<BrewJournalEntry?> show(
    BuildContext context, {
    BrewJournalEntry? existing,
    Map<String, dynamic>? initialRecipe,
    bool openSensoryByDefault = false,
  }) {
    return showModalBottomSheet<BrewJournalEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BrewJournalEditorSheet(
        existing: existing,
        initialRecipe: initialRecipe,
        openSensoryByDefault: openSensoryByDefault,
      ),
    );
  }

  @override
  ConsumerState<BrewJournalEditorSheet> createState() =>
      _BrewJournalEditorSheetState();
}

class _BrewJournalEditorSheetState
    extends ConsumerState<BrewJournalEditorSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _methodCtrl;
  late final TextEditingController _beanCtrl;
  late final TextEditingController _grindCtrl;
  late final TextEditingController _noteCtrl;

  int? _selectedRecipeId;
  String _author = '';
  String? _imageUrl;
  String? _coverImageUrl;
  double? _doseGrams;
  double? _waterGrams;
  int? _tempCelsius;
  late double _rating;

  late bool _includeSensory;
  late double _sensoryMaxScale;
  late Map<String, double> _sensoryMetrics;
  bool _saving = false;

  static const Map<String, double> _defaultSensory = {
    'Asam': 3.5,
    'Manis': 3.5,
    'Pahit': 2.5,
    'Body': 3.5,
    'Clarity': 3.5,
  };

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final r = widget.initialRecipe;

    _selectedRecipeId = e?.recipeId ?? (r?['id'] as int?);
    _author = e?.author ?? r?['author']?.toString() ?? '';
    _imageUrl = r != null ? BaristaUtils.imageUrlFromRecipe(r) : null;
    _coverImageUrl = r != null ? BaristaUtils.coverUrlFromRecipe(r) : null;
    _doseGrams = e?.doseGrams ?? (r?['coffeeWeightGrams'] as num?)?.toDouble();
    _waterGrams =
        e?.waterGrams ?? (r?['totalWaterWeightGrams'] as num?)?.toDouble();
    _tempCelsius = e?.tempCelsius ?? (r?['waterTempCelsius'] as num?)?.toInt();

    _titleCtrl = TextEditingController(
      text: e?.title ?? r?['title']?.toString() ?? '',
    );
    _methodCtrl = TextEditingController(
      text: e?.method ?? r?['method']?.toString() ?? '',
    );
    _beanCtrl = TextEditingController(
      text: e?.beanName ?? r?['beanName']?.toString() ?? '',
    );
    _grindCtrl = TextEditingController(
      text: e?.grindSize ?? r?['grindSize']?.toString() ?? '',
    );
    _noteCtrl = TextEditingController(text: e?.notes ?? '');
    _rating = e?.rating ?? 4.0;

    if (e != null && e.sensoryMetrics.length >= 3) {
      _includeSensory = true;
      _sensoryMaxScale = e.sensoryMaxScale;
      _sensoryMetrics = Map<String, double>.from(e.sensoryMetrics);
    } else {
      _includeSensory = widget.openSensoryByDefault;
      _sensoryMaxScale = 5.0;
      _sensoryMetrics = Map<String, double>.from(_defaultSensory);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _methodCtrl.dispose();
    _beanCtrl.dispose();
    _grindCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final isEn = LanguageService.isEnglish;
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEn
                ? 'Please enter a brew title or select a recipe.'
                : 'Isi judul seduhan atau pilih resep terlebih dahulu.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final now = DateTime.now();
    final existing = widget.existing;
    final entry = BrewJournalEntry(
      id: existing?.id ?? now.millisecondsSinceEpoch,
      recipeId: _selectedRecipeId,
      title: title,
      author: _author,
      method: _methodCtrl.text.trim(),
      beanName: _beanCtrl.text.trim(),
      grindSize: _grindCtrl.text.trim(),
      doseGrams: _doseGrams,
      waterGrams: _waterGrams,
      tempCelsius: _tempCelsius,
      rating: _rating,
      notes: _noteCtrl.text.trim(),
      sensoryMetrics: _includeSensory
          ? Map<String, double>.from(_sensoryMetrics)
          : const {},
      sensoryMaxScale: _sensoryMaxScale,
      additionalNotes: existing?.additionalNotes ?? const [],
      createdAt: existing?.createdAt ?? now,
      updatedAt: existing != null ? now : null,
      rawExtra: {
        if (existing != null) ...existing.rawExtra,
        if (_imageUrl != null) 'imageUrl': _imageUrl,
        if (_coverImageUrl != null) 'coverImageUrl': _coverImageUrl,
      },
    );

    if (existing != null) {
      await ref.read(brewJournalControllerProvider.notifier).updateEntry(entry);
    } else {
      await ref
          .read(brewJournalControllerProvider.notifier)
          .addEntry(entry.toMap());
    }

    if (mounted) {
      Navigator.pop(context, entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final isEdit = widget.existing != null;
    final allRecipes = ref.watch(recipeListControllerProvider).value ?? [];
    final dropdownValue = allRecipes.any((r) => r['id'] == _selectedRecipeId)
        ? _selectedRecipeId
        : null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
                children: [
                  Icon(
                    isEdit
                        ? CupertinoIcons.pencil_circle_fill
                        : CupertinoIcons.book_fill,
                    color: AppTheme.primaryBrown,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isEdit
                          ? (isEn ? 'Edit Brew Journal' : 'Edit Jurnal Seduh')
                          : (isEn ? 'New Brew Journal' : 'Catat Hasil Seduh'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
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
                    if (allRecipes.isNotEmpty) ...[
                      DropdownButtonFormField<int>(
                        initialValue: dropdownValue,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: isEn
                              ? 'Pick Recipe (Optional)'
                              : 'Pilih dari Resep (Opsional)',
                          filled: true,
                          fillColor: AppTheme.surfaceWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: allRecipes.map((r) {
                          return DropdownMenuItem<int>(
                            value: r['id'] as int,
                            child: Text(
                              r['title']?.toString() ?? 'Recipe',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          final match = allRecipes.firstWhere(
                            (e) => e['id'] == val,
                            orElse: () => {},
                          );
                          setState(() {
                            _selectedRecipeId = val;
                            _titleCtrl.text = match['title']?.toString() ?? '';
                            _author = match['author']?.toString() ?? '';
                            _methodCtrl.text =
                                match['method']?.toString() ?? '';
                            _beanCtrl.text =
                                match['beanName']?.toString() ?? '';
                            _grindCtrl.text =
                                match['grindSize']?.toString() ?? '';
                            _doseGrams =
                                (match['coffeeWeightGrams'] as num?)?.toDouble();
                            _waterGrams =
                                (match['totalWaterWeightGrams'] as num?)
                                    ?.toDouble();
                            _tempCelsius =
                                (match['waterTempCelsius'] as num?)?.toInt();
                            _imageUrl = BaristaUtils.imageUrlFromRecipe(match);
                            _coverImageUrl =
                                BaristaUtils.coverUrlFromRecipe(match);
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: _titleCtrl,
                      decoration: InputDecoration(
                        labelText: isEn
                            ? 'Brew / Recipe Title *'
                            : 'Judul Seduhan / Resep *',
                        hintText: isEn
                            ? 'e.g. V60 Gayo Honey Morning Dial-In'
                            : 'misal: V60 Gayo Honey Seduhan Pagi',
                        filled: true,
                        fillColor: AppTheme.surfaceWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _methodCtrl,
                            decoration: InputDecoration(
                              labelText: isEn ? 'Method' : 'Metode',
                              hintText: 'V60 / Origami / Espresso',
                              filled: true,
                              fillColor: AppTheme.surfaceWhite,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _grindCtrl,
                            decoration: InputDecoration(
                              labelText: isEn ? 'Grind Size' : 'Gilingan',
                              hintText: '24 Klik / Medium',
                              filled: true,
                              fillColor: AppTheme.surfaceWhite,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _beanCtrl,
                      decoration: InputDecoration(
                        labelText: isEn
                            ? 'Coffee Beans / Origin (Optional)'
                            : 'Biji Kopi / Origin (Opsional)',
                        hintText: 'Aceh Gayo Wine / Bali Kintamani',
                        filled: true,
                        fillColor: AppTheme.surfaceWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteCtrl,
                      maxLines: 4,
                      minLines: 3,
                      decoration: InputDecoration(
                        labelText: isEn
                            ? 'Main Tasting Notes & Evaluation'
                            : 'Catatan Utama & Evaluasi Rasa',
                        hintText: isEn
                            ? 'Describe acidity, sweetness, aroma, body, and adjustments...'
                            : 'Tulis rasa asam, manis, aroma, body, dan penyesuaian seduhan...',
                        filled: true,
                        fillColor: AppTheme.surfaceWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderWarm),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEn ? 'Overall Rating' : 'Penilaian Rasa',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (idx) {
                              final filled = idx < _rating.round();
                              return IconButton(
                                visualDensity: VisualDensity.compact,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  filled
                                      ? CupertinoIcons.star_fill
                                      : CupertinoIcons.star,
                                  color: AppTheme.accentAmber,
                                  size: 24,
                                ),
                                onPressed: () =>
                                    setState(() => _rating = idx + 1.0),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
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
                              Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.chart_pie_fill,
                                    color: AppTheme.primaryBrown,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isEn
                                        ? 'Sensory Chart Profile'
                                        : 'Grafik Profil Sensorik',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.5,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                              Switch.adaptive(
                                value: _includeSensory,
                                activeTrackColor: AppTheme.primaryBrown,
                                onChanged: (val) =>
                                    setState(() => _includeSensory = val),
                              ),
                            ],
                          ),
                          if (_includeSensory) ...[
                            const SizedBox(height: 6),
                            Center(
                              child: BrewJournalSensoryRadarChart(
                                metrics: _sensoryMetrics,
                                maxScale: _sensoryMaxScale,
                                size: 195,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ..._sensoryMetrics.entries.map((m) {
                              final stepDivisions =
                                  (_sensoryMaxScale * 2).round();
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        m.key,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        m.value.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primaryBrown,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 4,
                                      thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 7),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                              overlayRadius: 14),
                                    ),
                                    child: Slider(
                                      value: m.value
                                          .clamp(0.0, _sensoryMaxScale),
                                      min: 0.0,
                                      max: _sensoryMaxScale,
                                      divisions: stepDivisions,
                                      activeColor: AppTheme.primaryBrown,
                                      inactiveColor: AppTheme.primaryBrown
                                          .withValues(alpha: 0.16),
                                      onChanged: (v) {
                                        setState(() {
                                          _sensoryMetrics[m.key] =
                                              double.parse(v.toStringAsFixed(1));
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBrown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(CupertinoIcons.checkmark_seal_fill,
                                size: 18),
                        label: Text(
                          isEdit
                              ? (isEn
                                  ? 'Update Journal Entry'
                                  : 'Simpan Perubahan Jurnal')
                              : (isEn
                                  ? 'Save Journal Entry'
                                  : 'Simpan Catatan Jurnal'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
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
