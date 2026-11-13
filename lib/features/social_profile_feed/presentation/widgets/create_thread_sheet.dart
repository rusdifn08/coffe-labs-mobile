import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/api_service.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/models/social_profile_models.dart';
import '../../domain/models/social_thread_models.dart';
import '../controllers/social_profile_controllers.dart';

class CreateThreadSheet extends ConsumerStatefulWidget {
  final ValueChanged<SocialThreadItem>? onCreated;

  const CreateThreadSheet({super.key, this.onCreated});

  static Future<SocialThreadItem?> show(
    BuildContext context, {
    ValueChanged<SocialThreadItem>? onCreated,
  }) {
    return showModalBottomSheet<SocialThreadItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CreateThreadSheet(onCreated: onCreated),
      ),
    );
  }

  @override
  ConsumerState<CreateThreadSheet> createState() => _CreateThreadSheetState();
}

class _CreateThreadSheetState extends ConsumerState<CreateThreadSheet> {
  final _bodyController = TextEditingController();
  final _beanNameController = TextEditingController();
  final _roasteryController = TextEditingController();

  String _kind = 'STANDARD_POST';
  bool _pinOnProfile = false;
  bool _submitting = false;
  List<Map<String, dynamic>> _recipes = const [];
  Map<String, dynamic>? _selectedRecipe;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    try {
      final raw = await ApiService.getRecipes();
      if (!mounted) return;
      final list = raw.whereType<Map<String, dynamic>>().toList();
      setState(() {
        _recipes = list;
        if (list.isNotEmpty) {
          _selectedRecipe = list.first;
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _beanNameController.dispose();
    _roasteryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _bodyController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tulis catatan atau cerita kopimu dulu.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      ThreadAttachment? attachment;
      RecentBrewSnapshot? brewSnapshot;

      if (_kind == 'CREATED_RECIPE' && _selectedRecipe != null) {
        final r = _selectedRecipe!;
        final rawSteps = (r['steps'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .take(4)
            .toList();

        attachment = ThreadAttachment.interactiveRecipeCard(
          recipeId: r['id']?.toString() ?? 'custom',
          title: r['title']?.toString() ?? 'Resep Kustom',
          brewerName: r['brewer']?.toString() ?? 'Community Barista',
          method: r['method']?.toString() ?? 'V60',
          coffeeDoseG: (r['coffeeWeightGrams'] as num?)?.toDouble() ?? 15.0,
          totalWaterMl: (r['waterWeightGrams'] as num?)?.toDouble() ?? 240.0,
          primaryTempC: (r['waterTempCelsius'] as num?)?.toInt() ?? 92,
          targetDurationSec: (r['totalTimeSeconds'] as num?)?.toInt() ?? 150,
          stepsPreview: [
            for (var i = 0; i < rawSteps.length; i++)
              RecipeStepMiniDto(
                stepNumber: i + 1,
                title: rawSteps[i]['title']?.toString() ?? 'Tuangan ${i + 1}',
                durationSec:
                    (rawSteps[i]['durationSeconds'] as num?)?.toInt() ?? 30,
                waterAddedMl:
                    (rawSteps[i]['waterAddedGrams'] as num?)?.toDouble() ?? 60,
                instruction: rawSteps[i]['instruction']?.toString(),
              ),
          ],
        );
      } else if (_kind == 'BREW_LOG') {
        final bean = _beanNameController.text.trim().isNotEmpty
            ? _beanNameController.text.trim()
            : 'Single Origin V60';
        final roastery = _roasteryController.text.trim().isNotEmpty
            ? _roasteryController.text.trim()
            : 'Coffee Labs Roasters';
        final recipeTitle =
            _selectedRecipe?['title']?.toString() ?? 'Pour Over Precision';

        attachment = ThreadAttachment.pouringTelemetryCurve(
          sessionId: 'brew_${DateTime.now().millisecondsSinceEpoch}',
          recipeTitle: recipeTitle,
          beanName: bean,
          accuracyScorePct: 94.5,
          totalDurationSec:
              (_selectedRecipe?['totalTimeSeconds'] as num?)?.toInt() ?? 150,
          curvePoints: const [
            PourCurvePoint(tSec: 0, actualMl: 0, targetMl: 0, tempC: 93),
            PourCurvePoint(tSec: 35, actualMl: 48, targetMl: 50, tempC: 92),
            PourCurvePoint(tSec: 75, actualMl: 132, targetMl: 130, tempC: 91),
            PourCurvePoint(tSec: 115, actualMl: 198, targetMl: 195, tempC: 90),
            PourCurvePoint(tSec: 150, actualMl: 242, targetMl: 240, tempC: 89),
          ],
        );

        brewSnapshot = RecentBrewSnapshot(
          recipeId: _selectedRecipe?['id']?.toString(),
          recipeTitle: recipeTitle,
          beanName: bean,
          roastery: roastery,
          process: 'Washed / Natural',
          method: _selectedRecipe?['method']?.toString() ?? 'V60',
          primaryTempC:
              (_selectedRecipe?['waterTempCelsius'] as num?)?.toInt() ?? 92,
          coffeeDoseG:
              (_selectedRecipe?['coffeeWeightGrams'] as num?)?.toDouble() ?? 15,
          totalWaterMl:
              (_selectedRecipe?['waterWeightGrams'] as num?)?.toDouble() ?? 240,
          targetDurationSec:
              (_selectedRecipe?['totalTimeSeconds'] as num?)?.toInt() ?? 150,
          brewedAt: DateTime.now(),
          isLive: false,
          accuracyScore: 94.5,
        );
      }

      final created = await ref
          .read(socialProfileApiServiceProvider)
          .createThread(
            kind: _kind,
            bodyText: text,
            attachment: attachment,
            recentBrewSnapshot: brewSnapshot,
            pinOnProfile: _pinOnProfile,
          );

      widget.onCreated?.call(created);
      if (mounted) Navigator.of(context).pop(created);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memposting thread: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderWarm,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Buat Thread & Aktivitas Kopi',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Diskusi'),
                selected: _kind == 'STANDARD_POST',
                onSelected: (_) => setState(() => _kind = 'STANDARD_POST'),
              ),
              ChoiceChip(
                label: const Text('Log Seduhan'),
                selected: _kind == 'BREW_LOG',
                onSelected: (_) => setState(() => _kind = 'BREW_LOG'),
              ),
              ChoiceChip(
                label: const Text('Bagikan Resep'),
                selected: _kind == 'CREATED_RECIPE',
                onSelected: (_) => setState(() => _kind = 'CREATED_RECIPE'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            maxLines: 4,
            minLines: 3,
            decoration: InputDecoration(
              hintText: _kind == 'BREW_LOG'
                  ? 'Ceritakan rasa, grind size, dan flow seduhanmu hari ini...'
                  : 'Tulis insight seduh, review beans, atau pertanyaan barista...',
              filled: true,
              fillColor: AppTheme.bgCream,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.borderWarm),
              ),
            ),
          ),
          if (_kind == 'BREW_LOG') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _beanNameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Kopi / Origin',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _roasteryController,
                    decoration: InputDecoration(
                      labelText: 'Roastery',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (_kind != 'STANDARD_POST' && _recipes.isNotEmpty) ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<Map<String, dynamic>>(
              initialValue: _selectedRecipe,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Lampirkan Resep',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _recipes
                  .map(
                    (r) => DropdownMenuItem<Map<String, dynamic>>(
                      value: r,
                      child: Text(
                        '${r['title']} (${r['method'] ?? 'V60'})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedRecipe = v),
            ),
          ],
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Sematkan di Profil Utama (Pin)',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            value: _pinOnProfile,
            activeThumbColor: AppTheme.primaryBrown,
            onChanged: (v) => setState(() => _pinOnProfile = v),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(CupertinoIcons.paperplane_fill, size: 16),
              label: Text(_submitting ? 'Memposting...' : 'Publikasikan Thread'),
            ),
          ),
        ],
      ),
    );
  }
}
