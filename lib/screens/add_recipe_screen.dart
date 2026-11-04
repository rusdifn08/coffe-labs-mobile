import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../data/brew_visual_catalog.dart';
import '../features/recipe_editor/data/recipe_editor_templates.dart';
import '../features/recipe_editor/models/recipe_editor_controllers.dart';
import '../features/recipe_editor/models/recipe_step_draft.dart';
import '../features/recipe_editor/services/recipe_submission_service.dart';
import '../features/recipe_editor/widgets/editor_bean_notes_section.dart';
import '../features/recipe_editor/widgets/editor_bean_selector_modal.dart';
import '../features/recipe_editor/widgets/editor_dripper_section.dart';
import '../features/recipe_editor/widgets/editor_grinder_picker_modal.dart';
import '../features/recipe_editor/widgets/editor_grinder_section.dart';
import '../features/recipe_editor/widgets/editor_live_summary_banner.dart';
import '../features/recipe_editor/widgets/editor_quick_templates_bar.dart';
import '../features/recipe_editor/widgets/editor_steps_section.dart';
import '../features/recipe_editor/widgets/editor_tasting_notes_modal.dart';
import '../features/recipe_editor/widgets/editor_tech_params_section.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';

class AddRecipeScreen extends StatefulWidget {
  final Map<String, dynamic>? initialRecipe;

  const AddRecipeScreen({super.key, this.initialRecipe});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _c = RecipeEditorControllers();

  String _selectedCategory = 'V60';
  String _selectedGrindPreset = 'Medium';
  GrinderModel _selectedGrinder = BrewVisualCatalog.grinderModels.first;
  int _currentClicks = 23;

  String _selectedDripperName = 'Hario V60 02';
  bool _customDripperManual = false;

  String _selectedBeanName = 'Aceh Gayo Wine';
  String _selectedVariety = 'Bourbon / Ateng';
  String _selectedRoast = 'Light-Medium';
  String _selectedProcess = 'Natural Anaerobic';
  bool _customBeanManual = false;

  final Set<String> _selectedNoteLabels = {'Jasmine', 'Sweet Orange', 'Dark Chocolate'};

  final List<RecipeStepDraft> _steps = [];
  bool _isSubmitting = false;
  bool _autoSyncWater = true;

  bool get _isIcedMethod =>
      _selectedCategory == 'Japanese' ||
      _selectedCategory == 'Japanese Iced' ||
      _c.method.text.toLowerCase().contains('es') ||
      _c.method.text.toLowerCase().contains('iced');

  @override
  void initState() {
    super.initState();
    _currentClicks = _selectedGrinder.getClicksForPreset(_selectedGrindPreset);

    if (widget.initialRecipe != null) {
      _populateFromInitial(widget.initialRecipe!);
    } else {
      _loadAuthorName();
      _syncBeanText();
      _syncGrindText();
      _syncTastingFromSelectedIds();
      _applyTemplate('v60_3pour', updateMeta: false);
    }

    _c.coffee.addListener(_onParamChanged);
    _c.water.addListener(_onParamChanged);
    _c.ice.addListener(_onParamChanged);
  }

  @override
  void dispose() {
    _c.dispose();
    for (final s in _steps) {
      s.dispose();
    }
    super.dispose();
  }

  void _syncBeanText() {
    _c.bean.text = '$_selectedBeanName ($_selectedVariety • $_selectedProcess • $_selectedRoast)';
  }

  void _syncGrindText() {
    final unit = _selectedGrinder.isElectric ? 'Setting' : 'Klik';
    _c.grind.text =
        '$_selectedGrindPreset ($_currentClicks $unit ${_selectedGrinder.name} • ${_selectedGrinder.estimateMicrons(_currentClicks)})';
  }

  void _syncTastingFromSelectedIds() {
    _c.tasting.text = _selectedNoteLabels.join(', ');
  }

  void _populateFromInitial(Map<String, dynamic> r) {
    _c.title.text = (r['title'] ?? '') + ' (Kloning)';
    _c.author.text = r['author'] ?? 'Barista';
    _c.coffee.text = (r['coffeeWeightGrams'] ?? 15).toString();
    _c.water.text = (r['totalWaterWeightGrams'] ?? 225).toString();
    _c.ice.text = (r['iceWeightGrams'] ?? 0).toString();
    _c.temp.text = (r['waterTempCelsius'] ?? 92).toString();
    _c.grind.text = r['grindSize'] ?? 'Medium';
    _c.method.text = r['method'] ?? 'V60';
    _selectedCategory = r['category'] ?? 'V60';
    _c.bean.text = r['beanName'] ?? 'Arabika Single Origin';
    _c.tasting.text = r['tastingNotes'] ?? '';
    _c.desc.text = r['description'] ?? '';

    final rawSteps = r['steps'];
    if (rawSteps is List && rawSteps.isNotEmpty) {
      for (final st in rawSteps) {
        if (st is Map) {
          final d = RecipeStepDraft(
            title: st['title']?.toString() ?? '',
            duration: (st['timeSeconds'] ?? st['durationSeconds'] ?? 30).toString(),
            water: (st['waterGrams'] ?? st['waterAddedGrams'] ?? 50).toString(),
            instruction: st['instruction']?.toString() ?? '',
          );
          _attachStepListeners(d);
          _steps.add(d);
        }
      }
    }
    if (_steps.isEmpty) {
      _applyTemplate('v60_3pour', updateMeta: false);
    }
  }

  Future<void> _loadAuthorName() async {
    final name = await ProfileService.getUserName();
    if (mounted && name.isNotEmpty) {
      _c.author.text = name;
    }
  }

  void _onParamChanged() {
    if (mounted) setState(() {});
  }

  int _sumStepWater() =>
      _steps.fold<int>(0, (sum, s) => sum + (int.tryParse(s.waterCtrl.text.trim()) ?? 0));

  int _sumStepDuration() =>
      _steps.fold<int>(0, (sum, s) => sum + (int.tryParse(s.durationCtrl.text.trim()) ?? 0));

  void _attachStepListeners(RecipeStepDraft draft) {
    draft.waterCtrl.addListener(() {
      if (_autoSyncWater) {
        final sum = _sumStepWater();
        if (sum > 0) {
          _c.water.text = sum.toString();
        }
      }
      _onParamChanged();
    });
    draft.durationCtrl.addListener(_onParamChanged);
    draft.titleCtrl.addListener(_onParamChanged);
  }

  void _clearSteps() {
    for (final s in _steps) {
      s.dispose();
    }
    _steps.clear();
  }

  void _addStep() {
    final newStep = RecipeStepDraft(
      title: 'Tuangan ${_steps.length + 1}',
      duration: '35',
      water: '50',
      instruction: 'Tuang air melingkar secara perlahan dan merata.',
    );
    _attachStepListeners(newStep);
    setState(() {
      _steps.add(newStep);
      if (_autoSyncWater) {
        _c.water.text = _sumStepWater().toString();
      }
    });
  }

  void _removeStep(int index) {
    if (_steps.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal harus ada 1 step!')),
      );
      return;
    }
    setState(() {
      _steps[index].dispose();
      _steps.removeAt(index);
      if (_autoSyncWater) {
        _c.water.text = _sumStepWater().toString();
      }
    });
  }

  void _applyTemplate(String key, {bool updateMeta = true}) {
    _clearSteps();
    if (updateMeta) {
      final meta = RecipeEditorTemplates.getTemplateMeta(key);
      _selectedCategory = meta['category']!;
      _c.method.text = meta['method']!;
      _c.coffee.text = meta['coffee']!;
      _c.water.text = meta['water']!;
      _c.ice.text = meta['ice']!;
      _c.temp.text = meta['temp']!;
    }
    for (final st in RecipeEditorTemplates.getTemplateSteps(key)) {
      _attachStepListeners(st);
      _steps.add(st);
    }
    if (mounted) setState(() {});
  }

  void _showBeanSelectionModal() {
    EditorBeanSelectorModal.show(
      context: context,
      initialBeanName: _selectedBeanName,
      initialVariety: _selectedVariety,
      initialRoast: _selectedRoast,
      initialProcess: _selectedProcess,
      onSelected: (name, variety, roast, process) {
        setState(() {
          _customBeanManual = false;
          _selectedBeanName = name;
          _selectedVariety = variety;
          _selectedRoast = roast;
          _selectedProcess = process;
          _syncBeanText();
        });
      },
    );
  }

  void _showTastingNotesModal() {
    EditorTastingNotesModal.show(
      context: context,
      initialSelectedNotes: _selectedNoteLabels,
      onApplied: (newNotes) {
        setState(() {
          _selectedNoteLabels.clear();
          _selectedNoteLabels.addAll(newNotes);
          _syncTastingFromSelectedIds();
        });
      },
    );
  }

  void _showGrinderPickerModal() {
    EditorGrinderPickerModal.show(
      context: context,
      selectedGrinder: _selectedGrinder,
      onSelected: (g) {
        setState(() {
          _selectedGrinder = g;
          _currentClicks = g.getClicksForPreset(_selectedGrindPreset);
          _syncGrindText();
        });
      },
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await RecipeSubmissionService.submitRecipe(
      context: context,
      steps: _steps,
      selectedCategory: _selectedCategory,
      isIcedMethod: _isIcedMethod,
      controllers: _c,
    );
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final coffee = num.tryParse(_c.coffee.text.trim()) ?? 15;
    final water = int.tryParse(_c.water.text.trim()) ?? _sumStepWater();
    final ice = _isIcedMethod ? (int.tryParse(_c.ice.text.trim()) ?? 90) : 0;
    final totalLiquid = water + ice;
    final ratio = coffee > 0 ? (totalLiquid / coffee).toStringAsFixed(1) : '15.0';
    final totalTime = _sumStepDuration();

    const popularNotes = [
      'Jasmine',
      'Sweet Orange',
      'White Peach',
      'Caramel & Brown Sugar',
      'Dark Chocolate',
    ];

    final popularBeans = BrewVisualCatalog.beans.take(5).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Buat Resep Brew Baru'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            // LIVE SUMMARY BANNER
            EditorLiveSummaryBanner(
              selectedCategory: _selectedCategory,
              coffee: coffee,
              water: water,
              ice: ice,
              isIcedMethod: _isIcedMethod,
              ratio: ratio,
              totalTimeFormatted: _formatTime(totalTime),
            ),
            const SizedBox(height: 20),

            // QUICK TEMPLATES
            EditorQuickTemplatesBar(
              onSelectTemplate: _applyTemplate,
            ),
            const SizedBox(height: 22),

            // CATEGORY & VISUAL DRIPPER PICKER
            EditorDripperSection(
              customDripperManual: _customDripperManual,
              selectedDripperName: _selectedDripperName,
              selectedCategory: _selectedCategory,
              methodController: _c.method,
              categories: RecipeEditorTemplates.categories,
              onSelectDripper: (d) {
                setState(() {
                  _customDripperManual = false;
                  _selectedDripperName = d.name;
                  _selectedCategory = d.defaultCategory;
                  _c.method.text = d.name;
                  if (d.defaultCategory == 'Japanese' || d.defaultCategory == 'Japanese Iced') {
                    _c.ice.text = '90';
                  } else {
                    _c.ice.text = '0';
                  }
                });
              },
              onSelectManual: () => setState(() => _customDripperManual = true),
              onCategorySelected: (label) {
                setState(() {
                  _selectedCategory = label;
                  if (label == 'Japanese' || label == 'Japanese Iced') {
                    _c.ice.text = '90';
                  } else {
                    _c.ice.text = '0';
                  }
                });
              },
            ),
            const SizedBox(height: 22),

            // SECTION 3: BEAN & TASTING NOTES
            EditorBeanNotesSection(
              titleController: _c.title,
              authorController: _c.author,
              beanController: _c.bean,
              tastingController: _c.tasting,
              customBeanManual: _customBeanManual,
              selectedBeanName: _selectedBeanName,
              selectedNoteLabels: _selectedNoteLabels,
              popularNotes: popularNotes,
              popularBeans: popularBeans,
              onShowBeanModal: _showBeanSelectionModal,
              onShowNotesModal: _showTastingNotesModal,
              onSelectPopularBean: (bean) {
                setState(() {
                  _customBeanManual = false;
                  _selectedBeanName = bean.name;
                  _selectedVariety = bean.defaultVariety;
                  _selectedProcess = bean.process;
                  _selectedRoast = bean.roast;
                  _syncBeanText();
                });
              },
              onToggleCustomBeanManual: () => setState(() => _customBeanManual = !_customBeanManual),
              onToggleNote: (label) {
                setState(() {
                  if (_selectedNoteLabels.contains(label)) {
                    _selectedNoteLabels.remove(label);
                  } else {
                    _selectedNoteLabels.add(label);
                  }
                  _syncTastingFromSelectedIds();
                });
              },
            ),
            const SizedBox(height: 22),

            // SECTION 4: TECHNICAL PARAMETERS
            EditorTechParamsSection(
              coffeeController: _c.coffee,
              tempController: _c.temp,
              waterController: _c.water,
              iceController: _c.ice,
              isIcedMethod: _isIcedMethod,
              onParamChanged: () => setState(() {}),
            ),
            const SizedBox(height: 22),

            // SECTION 5: GRINDER SELECTOR & CLICKS
            EditorGrinderSection(
              selectedGrinder: _selectedGrinder,
              selectedGrindPreset: _selectedGrindPreset,
              currentClicks: _currentClicks,
              grindPresets: RecipeEditorTemplates.grindPresets,
              descController: _c.desc,
              onOpenGrinderPicker: _showGrinderPickerModal,
              onPresetSelected: (label) {
                setState(() {
                  _selectedGrindPreset = label;
                  _currentClicks = _selectedGrinder.getClicksForPreset(label);
                  _syncGrindText();
                });
              },
              onClicksChanged: (clicks) {
                setState(() {
                  _currentClicks = clicks;
                  _syncGrindText();
                });
              },
            ),
            const SizedBox(height: 22),

            // SECTION 6: BREWING STEPS
            EditorStepsSection(
              steps: _steps,
              autoSyncWater: _autoSyncWater,
              onAddStep: _addStep,
              onRemoveStep: _removeStep,
              onAutoSyncChanged: (v) {
                setState(() {
                  _autoSyncWater = v ?? true;
                  if (_autoSyncWater) {
                    final sum = _sumStepWater();
                    if (sum > 0) _c.water.text = sum.toString();
                  }
                });
              },
            ),

            const SizedBox(height: 20),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox.shrink()
                    : const Icon(CupertinoIcons.checkmark_seal_fill, color: Colors.white),
                label: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Simpan Resep Saya',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
