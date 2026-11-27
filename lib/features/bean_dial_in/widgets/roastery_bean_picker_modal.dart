import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/assets/cloud_asset_manager.dart';
import '../../../models/bean_recommendation_models.dart';
import '../../../models/curated_roastery_bean.dart';
import '../../../theme/app_theme.dart';
import 'roastery_bean_catalog_card.dart';

class _RoasteryGroup {
  final String name;
  final String location;
  final String logoUrl;
  final List<CuratedRoasteryBean> beans;
  final List<String> roastTags;

  const _RoasteryGroup({
    required this.name,
    required this.location,
    required this.logoUrl,
    required this.beans,
    required this.roastTags,
  });
}

/// 2-Step Roastery-First Coffee Bean Picker Modal for Smart Brew Dial-In:
/// Step 1: Browse & pick a Roastery (no overwhelming 770+ bean dump!)
/// Step 2: Browse & filter ONLY that Roastery's beans, or preview bean details before confirming!
/// Typing in the search bar seamlessly searches both Roasteries and Coffee Beans.
class RoasteryBeanPickerModal extends StatefulWidget {
  final List<CuratedRoasteryBean> allBeans;
  final CuratedRoasteryBean? selectedBean;
  final String? initialRoasteryName;
  final ValueChanged<CuratedRoasteryBean> onBeanSelected;

  const RoasteryBeanPickerModal({
    super.key,
    required this.allBeans,
    required this.selectedBean,
    this.initialRoasteryName,
    required this.onBeanSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required List<CuratedRoasteryBean> allBeans,
    required CuratedRoasteryBean? selectedBean,
    String? initialRoasteryName,
    required ValueChanged<CuratedRoasteryBean> onBeanSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RoasteryBeanPickerModal(
        allBeans: allBeans,
        selectedBean: selectedBean,
        initialRoasteryName: initialRoasteryName,
        onBeanSelected: onBeanSelected,
      ),
    );
  }

  @override
  State<RoasteryBeanPickerModal> createState() => _RoasteryBeanPickerModalState();
}

class _RoasteryBeanPickerModalState extends State<RoasteryBeanPickerModal> {
  final TextEditingController _searchCtrl = TextEditingController();
  late List<_RoasteryGroup> _roasteries;
  String? _activeRoasteryName;
  String _activeFilter = 'Semua';
  CuratedRoasteryBean? _previewBean;

  static const List<String> _filters = [
    'Semua',
    'Light',
    'Medium',
    'Dark',
    'Washed',
    'Natural',
    'Honey',
    'Anaerobic',
  ];

  @override
  void initState() {
    super.initState();
    _roasteries = _groupByRoastery(widget.allBeans);
    if (widget.initialRoasteryName != null &&
        _roasteries.any((r) => r.name == widget.initialRoasteryName)) {
      _activeRoasteryName = widget.initialRoasteryName;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static List<_RoasteryGroup> _groupByRoastery(List<CuratedRoasteryBean> beans) {
    final map = <String, List<CuratedRoasteryBean>>{};
    for (final b in beans) {
      final key = b.roasteryName.trim().isEmpty ? 'Roastery Lainnya' : b.roasteryName.trim();
      map.putIfAbsent(key, () => []).add(b);
    }
    final groups = map.entries.map((entry) {
      final list = entry.value;
      final first = list.first;
      final tags = <String>{};
      for (final b in list) {
        tags.add(b.roastLevel.label.split(' ').first);
        if (b.process == BeanProcess.anaerobic) tags.add('Anaerobic');
        if (b.process == BeanProcess.natural) tags.add('Natural');
      }
      return _RoasteryGroup(
        name: entry.key,
        location: first.roasteryLocation,
        logoUrl: first.roasteryLogoUrl,
        beans: list,
        roastTags: tags.take(3).toList(),
      );
    }).toList();

    groups.sort((a, b) {
      final cmp = b.beans.length.compareTo(a.beans.length);
      if (cmp != 0) return cmp;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return groups;
  }

  _RoasteryGroup? get _currentRoastery {
    if (_activeRoasteryName == null) return null;
    for (final r in _roasteries) {
      if (r.name == _activeRoasteryName) return r;
    }
    return null;
  }

  bool _matchesFilter(CuratedRoasteryBean bean) {
    final roast = bean.roastProfileRaw.toLowerCase();
    final proc = bean.processRaw.toLowerCase();
    switch (_activeFilter) {
      case 'Light':
        return roast.contains('light') || bean.roastLevel == BeanRoastLevel.light;
      case 'Medium':
        return roast.contains('medium') || bean.roastLevel == BeanRoastLevel.medium;
      case 'Dark':
        return roast.contains('dark') ||
            bean.roastLevel == BeanRoastLevel.dark ||
            bean.roastLevel == BeanRoastLevel.mediumDark;
      case 'Washed':
        return proc.contains('wash') || bean.process == BeanProcess.washed;
      case 'Natural':
        return proc.contains('natural') || bean.process == BeanProcess.natural;
      case 'Honey':
        return proc.contains('honey') || bean.process == BeanProcess.honey;
      case 'Anaerobic':
        return proc.contains('anaerob') ||
            proc.contains('carbonic') ||
            bean.process == BeanProcess.anaerobic;
      default:
        return true;
    }
  }

  bool _matchesQuery(CuratedRoasteryBean bean, String q) {
    return bean.name.toLowerCase().contains(q) ||
        bean.roasteryName.toLowerCase().contains(q) ||
        bean.origin.toLowerCase().contains(q) ||
        bean.variety.toLowerCase().contains(q) ||
        bean.processRaw.toLowerCase().contains(q) ||
        bean.tastingNotes.toLowerCase().contains(q);
  }

  void _confirmSelect(CuratedRoasteryBean bean) {
    widget.onBeanSelected(bean);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim().toLowerCase();
    final activeRoastery = _currentRoastery;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppTheme.borderWarm,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header (adapts cleanly between Step 1: Roastery Directory, Step 2: Roastery Beans, Step 3: Preview)
          _buildHeader(activeRoastery),

          if (_previewBean != null)
            Expanded(child: _buildBeanPreviewStep(_previewBean!))
          else ...[
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
                decoration: InputDecoration(
                  hintText: activeRoastery != null
                      ? 'Cari biji di ${activeRoastery.name}...'
                      : 'Cari roastery (Fugol, Space, MKND) atau biji...',
                  hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  prefixIcon: const Icon(
                    CupertinoIcons.search,
                    size: 18,
                    color: AppTheme.primaryBrown,
                  ),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            CupertinoIcons.clear_circled_solid,
                            size: 16,
                            color: AppTheme.textMuted,
                          ),
                          onPressed: () => setState(() => _searchCtrl.clear()),
                        )
                      : null,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  fillColor: AppTheme.surfaceWhite,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderWarm),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderWarm),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppTheme.accentAmber, width: 1.5),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            if (activeRoastery != null)
              Expanded(child: _buildRoasteryBeansStep(activeRoastery, query))
            else
              Expanded(child: _buildRoasteryDirectoryStep(query)),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(_RoasteryGroup? activeRoastery) {
    final bool inPreview = _previewBean != null;
    final bool inRoastery = activeRoastery != null && !inPreview;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 12, 6),
      child: Row(
        children: [
          if (inPreview || inRoastery)
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                setState(() {
                  if (inPreview) {
                    _previewBean = null;
                  } else {
                    _activeRoasteryName = null;
                    _activeFilter = 'Semua';
                    _searchCtrl.clear();
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(7),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderWarm),
                ),
                child: const Icon(
                  CupertinoIcons.chevron_back,
                  size: 17,
                  color: AppTheme.primaryBrown,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(7),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                CupertinoIcons.building_2_fill,
                size: 18,
                color: AppTheme.primaryBrown,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inPreview
                      ? 'Pratinjau Biji Kopi'
                      : (inRoastery ? activeRoastery.name : 'Pilih Roastery'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  inPreview
                      ? 'Periksa karakter biji sebelum masuk ke Smart Brew'
                      : (inRoastery
                          ? '${activeRoastery.beans.length} koleksi biji • ${activeRoastery.location}'
                          : 'Langkah 1 dari 2 • Pilih roastery terlebih dahulu'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              CupertinoIcons.xmark_circle_fill,
              color: AppTheme.textMuted,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// STEP 1: Clean Roastery Directory (no 770+ bean dump!)
  Widget _buildRoasteryDirectoryStep(String query) {
    final matchingRoasteries = query.isEmpty
        ? _roasteries
        : _roasteries.where((r) {
            return r.name.toLowerCase().contains(query) ||
                r.location.toLowerCase().contains(query) ||
                r.beans.any((b) => _matchesQuery(b, query));
          }).toList();

    final directMatchingBeans = query.length >= 2
        ? widget.allBeans.where((b) => _matchesQuery(b, query)).take(20).toList()
        : const <CuratedRoasteryBean>[];

    if (matchingRoasteries.isEmpty && directMatchingBeans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.search, size: 40, color: AppTheme.textMuted),
              const SizedBox(height: 8),
              Text(
                'Tidak ditemukan roastery atau biji untuk "${_searchCtrl.text}"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${matchingRoasteries.length} Roastery Tersedia',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'Ketuk roastery untuk lihat biji',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...matchingRoasteries.map((r) => _buildRoasteryTile(r)),
        if (directMatchingBeans.isNotEmpty) ...[
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 2),
            child: Text(
              'Hasil Biji Kopi Langsung (${directMatchingBeans.length})',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: directMatchingBeans.length,
            itemBuilder: (_, idx) {
              final bean = directMatchingBeans[idx];
              return RoasteryBeanCatalogCard(
                bean: bean,
                isSelected: widget.selectedBean?.id == bean.id,
                onPreview: () => setState(() => _previewBean = bean),
                onSelect: _confirmSelect,
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildRoasteryTile(_RoasteryGroup roastery) {
    final bool hasSelectedBean =
        widget.selectedBean?.roasteryName == roastery.name;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasSelectedBean ? AppTheme.accentAmber : AppTheme.borderWarm,
          width: hasSelectedBean ? 1.6 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              _activeRoasteryName = roastery.name;
              _activeFilter = 'Semua';
              _searchCtrl.clear();
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.bgCream,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: AppTheme.borderWarm),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CloudAssetImage(
                    roastery.logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      CupertinoIcons.flame_fill,
                      size: 20,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roastery.name,
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
                        roastery.location.isNotEmpty
                            ? roastery.location
                            : 'Specialty Coffee Roastery',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.8,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: roastery.roastTags
                            .map(
                              (t) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.bgCream,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  t,
                                  style: const TextStyle(
                                    fontSize: 9.2,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryBrown,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${roastery.beans.length} Biji',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Icon(
                      CupertinoIcons.chevron_right,
                      size: 14,
                      color: AppTheme.textMuted,
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

  /// STEP 2: Beans ONLY from the chosen Roastery
  Widget _buildRoasteryBeansStep(_RoasteryGroup roastery, String query) {
    final beans = roastery.beans.where((b) {
      if (!_matchesFilter(b)) return false;
      if (query.isNotEmpty && !_matchesQuery(b, query)) return false;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scoped Filter Chips
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            itemCount: _filters.length,
            itemBuilder: (_, idx) {
              final f = _filters[idx];
              final sel = _activeFilter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(
                    f,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: sel ? FontWeight.bold : FontWeight.w600,
                      color: sel ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                  selected: sel,
                  selectedColor: AppTheme.primaryBrown,
                  backgroundColor: AppTheme.surfaceWhite,
                  side: BorderSide(
                    color: sel ? AppTheme.primaryBrown : AppTheme.borderWarm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  showCheckmark: false,
                  onSelected: (v) {
                    if (v) setState(() => _activeFilter = f);
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${beans.length} biji dari ${roastery.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Ketuk kartu untuk detail',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBrown,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: beans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.search,
                          size: 36, color: AppTheme.textMuted),
                      const SizedBox(height: 8),
                      const Text(
                        'Tidak ada biji dengan filter ini.',
                        style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _activeFilter = 'Semua';
                          _searchCtrl.clear();
                        }),
                        child: const Text('Reset Filter'),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.58,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: beans.length,
                  itemBuilder: (_, idx) {
                    final bean = beans[idx];
                    return RoasteryBeanCatalogCard(
                      bean: bean,
                      isSelected: widget.selectedBean?.id == bean.id,
                      onPreview: () => setState(() => _previewBean = bean),
                      onSelect: _confirmSelect,
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// STEP 3: Friendly Bean Detail Preview before entering Smart Brew
  Widget _buildBeanPreviewStep(CuratedRoasteryBean bean) {
    final quickPreview = BeanRecommenderEngine.calculate(
      beanName: '${bean.roasteryName} • ${bean.name}',
      origin: bean.origin,
      variety: bean.variety,
      tastingNotes: bean.tastingNotesList,
      roast: bean.roastLevel,
      process: bean.process,
      goal: FlavorGoal.sweetBalanced,
      dripper: bean.recommendedDripper,
      dose: 15.0,
    );

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
            children: [
              // Packaging & Identity Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderWarm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 82,
                        height: 98,
                        child: CloudAssetImage(
                          bean.packageImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: AppTheme.bgCream,
                            child: const Icon(
                              CupertinoIcons.bag_fill,
                              size: 28,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bean.roasteryName,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bean.name,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${bean.origin} • ${bean.variety}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _metaBadge(bean.roastProfileRaw, AppTheme.primaryBrown),
                              _metaBadge(bean.processRaw, const Color(0xFFB45309)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tasting Notes
              if (bean.tastingNotesList.isNotEmpty) ...[
                const Text(
                  'Karakter Rasa (Tasting Notes)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: bean.tastingNotesList
                      .map(
                        (n) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderWarm),
                          ),
                          child: Text(
                            n,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Smart SCA Quick Preview Card
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.accentAmber.withValues(alpha: 0.45),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          CupertinoIcons.sparkles,
                          size: 14,
                          color: Color(0xFFB45309),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Rekomendasi Standar SCA Otomatis',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF78350F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      quickPreview.roastGuidanceSummary,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textDark,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Alat Ideal: ${bean.recommendedDripper.label.split('(').first.trim()} • ${quickPreview.waterTemp}°C • Rasio 1:${quickPreview.brewRatio.toStringAsFixed(1)} • ${quickPreview.grindMicrons} µm',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Barista Opinion
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderWarm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Catatan Barista',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bean.baristaOpinion,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _confirmSelect(bean),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(CupertinoIcons.sparkles, size: 16),
                label: const Text(
                  'Gunakan Biji Ini untuk Smart Brew',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _metaBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
