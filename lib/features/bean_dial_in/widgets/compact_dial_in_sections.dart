import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/bean_ai_customization_models.dart';
import '../../../models/bean_recommendation_models.dart';
import '../../../models/curated_roastery_bean.dart';
import '../../../theme/app_theme.dart';
import '../../brew/widgets/brew_flow_curve_chart.dart';
import '../../brew/widgets/brew_radar_chart.dart';
import 'bean_ai_customizer_card.dart';
import 'roastery_bean_picker_modal.dart';

void showDialInInfoSheet({
  required BuildContext context,
  required String title,
  required List<({IconData icon, Color color, String heading, String body})> items,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.72),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppTheme.primaryBrown, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppTheme.textMuted),
                ),
              ],
            ),
            const Divider(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: items
                      .map(
                        (it) => Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: it.color.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: it.color.withValues(alpha: 0.18)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(it.icon, size: 17, color: it.color),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      it.heading,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: it.color,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      it.body,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textDark,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class CompactInfoButton extends StatelessWidget {
  final VoidCallback onTap;
  final String tooltip;

  const CompactInfoButton({
    super.key,
    required this.onTap,
    this.tooltip = 'Lihat penjelasan',
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.bgCream,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.borderWarm),
          ),
          child: const Icon(Icons.info_outline_rounded, size: 15, color: AppTheme.primaryBrown),
        ),
      ),
    );
  }
}

/// Section 1: Ultra-compact Catalog & Custom Bean selector with hidden `ⓘ` Barista Notes.
class CompactBeanSelectorSection extends StatelessWidget {
  final bool isCatalogMode;
  final List<CuratedRoasteryBean> allBeans;
  final CuratedRoasteryBean selectedBean;
  final ValueChanged<CuratedRoasteryBean> onBeanSelected;
  final TextEditingController customBeanCtrl;
  final BeanRoastLevel customRoast;
  final BeanProcess customProcess;
  final List<String> popularOrigins;
  final ValueChanged<BeanRoastLevel> onCustomRoastChanged;
  final ValueChanged<BeanProcess> onCustomProcessChanged;
  final VoidCallback onRecalculate;

  const CompactBeanSelectorSection({
    super.key,
    required this.isCatalogMode,
    required this.allBeans,
    required this.selectedBean,
    required this.onBeanSelected,
    required this.customBeanCtrl,
    required this.customRoast,
    required this.customProcess,
    required this.popularOrigins,
    required this.onCustomRoastChanged,
    required this.onCustomProcessChanged,
    required this.onRecalculate,
  });

  void _openBeanInfo(BuildContext context) {
    if (!isCatalogMode) {
      showDialInInfoSheet(
        context: context,
        title: 'Karakter Roast & Proses',
        items: [
          (
            icon: CupertinoIcons.flame_fill,
            color: AppTheme.primaryBrown,
            heading: customRoast.label,
            body: customRoast.desc,
          ),
          (
            icon: CupertinoIcons.drop_fill,
            color: const Color(0xFF0369A1),
            heading: customProcess.label,
            body: customProcess.desc,
          ),
        ],
      );
      return;
    }

    showDialInInfoSheet(
      context: context,
      title: selectedBean.name,
      items: [
        (
          icon: CupertinoIcons.lightbulb_fill,
          color: const Color(0xFFB45309),
          heading:
              'Opini Barista • Alat Ideal: ${selectedBean.recommendedDripper.label.split('(').first.trim()}',
          body: selectedBean.baristaOpinion,
        ),
        (
          icon: CupertinoIcons.flame_fill,
          color: Colors.red.shade700,
          heading: 'Suhu Panas (>65°C)',
          body: selectedBean.tempNotesHot,
        ),
        (
          icon: CupertinoIcons.sparkles,
          color: Colors.amber.shade800,
          heading: 'Suhu Hangat (50–60°C • Puncak Manis)',
          body: selectedBean.tempNotesWarm,
        ),
        (
          icon: CupertinoIcons.snow,
          color: Colors.blue.shade700,
          heading: 'Suhu Sejuk (<40°C • Aftertaste)',
          body: selectedBean.tempNotesCool,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final featuredBeans = allBeans.take(12).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.checkmark_seal_fill, size: 15, color: AppTheme.accentGold),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Biji Kopi',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                ),
              ),
              CompactInfoButton(
                tooltip: 'Info karakter rasa & opini barista',
                onTap: () => _openBeanInfo(context),
              ),
              if (isCatalogMode) ...[
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    RoasteryBeanPickerModal.show(
                      context: context,
                      allBeans: allBeans,
                      selectedBean: selectedBean,
                      onBeanSelected: onBeanSelected,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCream,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.borderWarm),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Katalog',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(CupertinoIcons.chevron_right, size: 11, color: AppTheme.primaryBrown),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          if (isCatalogMode) ...[
            _buildCompactSelectedRow(),
            const SizedBox(height: 10),
            SizedBox(
              height: 76,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredBeans.length,
                itemBuilder: (_, idx) {
                  final b = featuredBeans[idx];
                  final sel = b.id == selectedBean.id;
                  return GestureDetector(
                    onTap: () => onBeanSelected(b),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 118,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFFFAF3EC) : const Color(0xFFFDFBF8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel ? AppTheme.accentGold : AppTheme.borderWarm,
                          width: sel ? 1.6 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 40,
                              height: 62,
                              child: Image.asset(
                                b.packageImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: AppTheme.bgCream,
                                  child: const Icon(CupertinoIcons.drop_fill, size: 14, color: AppTheme.primaryBrown),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  b.roastProfileRaw,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
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
          ] else
            _buildCompactCustomForm(),
        ],
      ),
    );
  }

  Widget _buildCompactSelectedRow() {
    final notes = selectedBean.tastingNotesList.take(3).toList();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: SizedBox(
              width: 50,
              height: 58,
              child: Image.asset(
                selectedBean.packageImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: Colors.white,
                  child: const Icon(CupertinoIcons.bag_fill, size: 20, color: AppTheme.primaryBrown),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedBean.roasteryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBrown,
                  ),
                ),
                Text(
                  selectedBean.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${selectedBean.origin} • ${selectedBean.roastProfileRaw} • ${selectedBean.processRaw}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: notes
                        .map(
                          (n) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppTheme.borderWarm),
                            ),
                            child: Text(
                              n,
                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCustomForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: customBeanCtrl,
          onChanged: (_) => onRecalculate(),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Nama Biji / Origin Kopi...',
            prefixIcon: const Icon(CupertinoIcons.tag_fill, size: 16, color: AppTheme.primaryBrown),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: AppTheme.bgCream,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: popularOrigins.map((org) {
              final sel = customBeanCtrl.text == org;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(org, style: TextStyle(fontSize: 10.5, color: sel ? Colors.white : AppTheme.textDark)),
                  selected: sel,
                  selectedColor: AppTheme.primaryBrown,
                  backgroundColor: AppTheme.bgCream,
                  onSelected: (v) {
                    if (v) {
                      customBeanCtrl.text = org;
                      onRecalculate();
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<BeanRoastLevel>(
                initialValue: customRoast,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Sangrai',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: BeanRoastLevel.values
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.label, style: const TextStyle(fontSize: 11.5))))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onCustomRoastChanged(v);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<BeanProcess>(
                initialValue: customProcess,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Proses',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: BeanProcess.values
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.label.split('/').first.trim(), style: const TextStyle(fontSize: 11.5)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onCustomProcessChanged(v);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Section 2: Compact Flavor Goal, Dripper, Dose Slider & Collapsible AI Calibration Drawer.
class CompactBrewConfigSection extends StatefulWidget {
  final FlavorGoal selectedGoal;
  final BeanDripper selectedDripper;
  final double dose;
  final double totalWater;
  final double brewRatio;
  final BeanRoastAge roastAge;
  final WaterProfile waterProfile;
  final PouringParadigm pouringParadigm;
  final ValueChanged<FlavorGoal> onGoalChanged;
  final ValueChanged<BeanDripper> onDripperChanged;
  final ValueChanged<double> onDoseChanged;
  final ValueChanged<BeanRoastAge> onRoastAgeChanged;
  final ValueChanged<WaterProfile> onWaterProfileChanged;
  final ValueChanged<PouringParadigm> onParadigmChanged;
  final ValueChanged<AiTweakAction> onApplyTweak;

  const CompactBrewConfigSection({
    super.key,
    required this.selectedGoal,
    required this.selectedDripper,
    required this.dose,
    required this.totalWater,
    required this.brewRatio,
    required this.roastAge,
    required this.waterProfile,
    required this.pouringParadigm,
    required this.onGoalChanged,
    required this.onDripperChanged,
    required this.onDoseChanged,
    required this.onRoastAgeChanged,
    required this.onWaterProfileChanged,
    required this.onParadigmChanged,
    required this.onApplyTweak,
  });

  @override
  State<CompactBrewConfigSection> createState() => _CompactBrewConfigSectionState();
}

class _CompactBrewConfigSectionState extends State<CompactBrewConfigSection> {
  bool _showAdvanced = false;

  void _openConfigInfo(BuildContext context) {
    showDialInInfoSheet(
      context: context,
      title: 'Panduan Pengaturan Seduh',
      items: [
        (
          icon: Icons.auto_awesome_rounded,
          color: AppTheme.primaryBrown,
          heading: 'Target Rasa: ${widget.selectedGoal.label}',
          body: widget.selectedGoal.desc,
        ),
        (
          icon: CupertinoIcons.drop_fill,
          color: const Color(0xFF0284C7),
          heading: 'Alat: ${widget.selectedDripper.label}',
          body: widget.selectedDripper.desc,
        ),
        (
          icon: CupertinoIcons.timer,
          color: const Color(0xFF007A87),
          heading: 'Umur Sangrai: ${widget.roastAge.label}',
          body: widget.roastAge.description,
        ),
        (
          icon: Icons.science_outlined,
          color: const Color(0xFF7C3AED),
          heading: 'Teknik Tuang: ${widget.pouringParadigm.label}',
          body: widget.pouringParadigm.desc,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, size: 16, color: AppTheme.primaryBrown),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Target & Parameter',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                ),
              ),
              CompactInfoButton(
                tooltip: 'Penjelasan target rasa & tuning',
                onTap: () => _openConfigInfo(context),
              ),
              const SizedBox(width: 6),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => AiTweakDoctorModal(onApplyTweak: widget.onApplyTweak),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFD54F)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.sparkles, size: 12, color: Color(0xFFB45309)),
                      SizedBox(width: 4),
                      Text(
                        'Koreksi',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF78350F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Target Rasa compact horizontal strip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: FlavorGoal.values.map((goal) {
                final sel = widget.selectedGoal == goal;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      goal.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        color: sel ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                    selected: sel,
                    selectedColor: AppTheme.primaryBrown,
                    backgroundColor: AppTheme.bgCream,
                    onSelected: (v) {
                      if (v) widget.onGoalChanged(goal);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Unified Dripper & Dose Bar
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCream,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<BeanDripper>(
                      value: widget.selectedDripper,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.primaryBrown),
                      items: BeanDripper.values
                          .map(
                            (d) => DropdownMenuItem(
                              value: d,
                              child: Text(
                                d.label.split('(').first.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) widget.onDripperChanged(val);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCream,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.dose.round()}g Kopi',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                      Text(
                        '→ ${widget.totalWater.round()}ml (1:${widget.brewRatio.toStringAsFixed(1)})',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.5),
            ),
            child: Slider(
              value: widget.dose,
              min: 12,
              max: 30,
              divisions: 18,
              activeColor: AppTheme.primaryBrown,
              inactiveColor: AppTheme.bgCream,
              onChanged: widget.onDoseChanged,
            ),
          ),

          // Collapsible Advanced AI Calibration Toggle (hidden by default to prevent overwhelm)
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _showAdvanced = !_showAdvanced),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.slider_horizontal_3, size: 13, color: Color(0xFF007A87)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Tuning Lanjutan: ${widget.pouringParadigm.label} • ${widget.roastAge.label.split('(').first.trim()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF007A87),
                      ),
                    ),
                  ),
                  Icon(
                    _showAdvanced ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: const Color(0xFF007A87),
                  ),
                ],
              ),
            ),
          ),

          if (_showAdvanced) ...[
            const Divider(height: 14),
            const Text('Umur Sangrai', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Wrap(
              spacing: 6,
              children: BeanRoastAge.values.map((a) {
                final sel = widget.roastAge == a;
                return ChoiceChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(a.label.split('(').first.trim(), style: TextStyle(fontSize: 10.5, color: sel ? Colors.white : AppTheme.textDark)),
                  selected: sel,
                  selectedColor: const Color(0xFF007A87),
                  onSelected: (_) => widget.onRoastAgeChanged(a),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            const Text('Profil Air (PPM)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: WaterProfile.values.map((w) {
                final sel = widget.waterProfile == w;
                return ChoiceChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(w.label.split('(').first.trim(), style: TextStyle(fontSize: 10.5, color: sel ? Colors.white : AppTheme.textDark)),
                  selected: sel,
                  selectedColor: const Color(0xFF007A87),
                  onSelected: (_) => widget.onWaterProfileChanged(w),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            const Text('Teknik Tuang', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: PouringParadigm.values.map((p) {
                final sel = widget.pouringParadigm == p;
                return ChoiceChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(p.label, style: TextStyle(fontSize: 10.5, color: sel ? Colors.white : AppTheme.textDark)),
                  selected: sel,
                  selectedColor: AppTheme.primaryBrown,
                  onSelected: (_) => widget.onParadigmChanged(p),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Section 3: Unified Minimalist Result Card with 3 compact detail tabs (Jadwal | Sains | Radar) + `ⓘ` rationale.
class CompactDialInResultSection extends StatefulWidget {
  final RecommendedBrewRecipe recipe;
  final BeanRoastAge roastAge;
  final WaterProfile waterProfile;

  const CompactDialInResultSection({
    super.key,
    required this.recipe,
    required this.roastAge,
    required this.waterProfile,
  });

  @override
  State<CompactDialInResultSection> createState() => _CompactDialInResultSectionState();
}

class _CompactDialInResultSectionState extends State<CompactDialInResultSection> {
  int _detailTab = 0; // 0 = Jadwal, 1 = Sains, 2 = Radar

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final science = AiExtractionScience.calculate(
      coffeeDose: recipe.coffeeDose,
      totalWater: recipe.totalWater,
      waterTemp: recipe.waterTemp,
      grindMicrons: recipe.grindMicrons,
      roast: recipe.roastLevel,
      roastAge: widget.roastAge,
      water: widget.waterProfile,
    );

    final mins = recipe.totalTimeSeconds ~/ 60;
    final secs = (recipe.totalTimeSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.55), width: 1.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.checkmark_seal_fill, size: 17, color: AppTheme.accentGold),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Resep Rekomendasi',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '1:${recipe.brewRatio.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryBrown),
                ),
              ),
              const SizedBox(width: 6),
              CompactInfoButton(
                tooltip: 'Alasan ilmiah resep',
                onTap: () {
                  showDialInInfoSheet(
                    context: context,
                    title: 'Analisis Ilmiah Resep',
                    items: [
                      (
                        icon: Icons.science_rounded,
                        color: const Color(0xFF007A87),
                        heading: 'Golden Cup Status: ${science.goldenCupStatus}',
                        body: recipe.scientificReason,
                      ),
                      (
                        icon: Icons.grain_rounded,
                        color: Colors.purple,
                        heading: 'Referensi Klik Grinder',
                        body: recipe.grindClickLabel,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 4 Compact KPI Tiles
          Row(
            children: [
              _kpi('Air', '${recipe.totalWater.round()}g', Colors.blue.shade700),
              _kpi('Suhu', '${recipe.waterTemp}°C', Colors.deepOrange),
              _kpi('Giling', '${recipe.grindMicrons}µm', Colors.purple.shade700),
              _kpi('Waktu', '$mins:${secs}s', AppTheme.primaryBrown),
            ],
          ),
          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.bgCream,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              recipe.grindClickLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textDark),
            ),
          ),
          const SizedBox(height: 12),

          // Compact 3-Tab Switcher
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppTheme.bgCream,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                _tabPill(0, 'Jadwal (${recipe.steps.length})'),
                _tabPill(1, 'Sains EY/TDS'),
                _tabPill(2, 'Radar Rasa'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (_detailTab == 0) _buildScheduleView(recipe),
          if (_detailTab == 1) _buildScienceView(science),
          if (_detailTab == 2) _buildRadarView(recipe),
        ],
      ),
    );
  }

  Widget _kpi(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2.5),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: color),
            ),
            Text(label, style: const TextStyle(fontSize: 9.5, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _tabPill(int index, String label) {
    final active = _detailTab == index;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: () => setState(() => _detailTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              color: active ? AppTheme.primaryBrown : AppTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleView(RecommendedBrewRecipe recipe) {
    return Column(
      children: [
        BrewFlowCurveChart(
          steps: recipe.steps,
          totalWaterGrams: recipe.totalWater.round(),
          totalTimeSeconds: recipe.totalTimeSeconds,
          height: 110,
        ),
        const SizedBox(height: 10),
        ...recipe.steps.map(
          (st) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.12),
                  child: Text(
                    '${st["stepOrder"]}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    st['title'].toString(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${st["durationSeconds"]}s • +${st["waterAddedGrams"]}g',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScienceView(AiExtractionScience science) {
    return Column(
      children: [
        Row(
          children: [
            _kpi('TDS', '${science.estimatedTds}%', Colors.teal.shade800),
            _kpi('EY', '${science.estimatedExtractionYield}%', const Color(0xFF007A87)),
            _kpi('Flow', '${science.targetFlowRate}ml/s', Colors.indigo.shade700),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Status: ${science.goldenCupStatus}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.green.shade800),
          ),
        ),
      ],
    );
  }

  Widget _buildRadarView(RecommendedBrewRecipe recipe) {
    return Column(
      children: [
        Center(
          child: BrewRadarChart(
            acidity: recipe.expectedAcidity,
            sweetness: recipe.expectedSweetness,
            body: recipe.expectedBody,
            bitterness: recipe.expectedBitterness,
            clarity: recipe.expectedClarity,
            size: 185,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: recipe.predictedTastingNotes
              .map(
                (n) => Chip(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Colors.amber.shade50,
                  label: Text(n, style: TextStyle(fontSize: 10.5, color: Colors.brown.shade800)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
