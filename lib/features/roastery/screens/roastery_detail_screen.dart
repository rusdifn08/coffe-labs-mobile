import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/external_url_launcher.dart';
import '../../../../core/widgets/optimized_coffee_image.dart';
import '../../../../models/roastery.dart';
import '../../../../screens/brew_timer_screen.dart';
import '../../../../theme/app_theme.dart';
import '../controllers/roastery_catalog_controller.dart';
import '../utils/roastery_brew_recipe_builder.dart';
import '../widgets/coffee_lineup_editor_sheet.dart';
import 'business_roastery_studio_screen.dart';

class RoasteryDetailScreen extends ConsumerStatefulWidget {
  final Roastery roastery;

  const RoasteryDetailScreen({super.key, required this.roastery});

  @override
  ConsumerState<RoasteryDetailScreen> createState() =>
      _RoasteryDetailScreenState();
}

class _RoasteryDetailScreenState extends ConsumerState<RoasteryDetailScreen> {
  late Roastery _roastery;
  String _selectedRoastFilter = 'Semua Sangrai';
  String _lineupSearch = '';
  bool _isRefreshing = false;
  final TextEditingController _searchCtrl = TextEditingController();

  static const _roastOptions = [
    'Semua Sangrai',
    'Light',
    'Light to Medium',
    'Medium',
    'Medium to Dark',
    'Dark',
    'Omni',
  ];

  @override
  void initState() {
    super.initState();
    _roastery = widget.roastery;
    _refreshLatestIfBusiness();
  }

  Future<void> _refreshLatestIfBusiness() async {
    if (!_roastery.isVerifiedBusiness) return;
    setState(() => _isRefreshing = true);
    final fresh = await ref
        .read(roasteryCatalogProvider.notifier)
        .fetchLatestDetail(_roastery);
    if (mounted) {
      setState(() {
        _roastery = fresh;
        _isRefreshing = false;
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CoffeeLineupItem> get _filteredLineups {
    final q = _lineupSearch.trim().toLowerCase();
    return _roastery.lineups.where((item) {
      final matchesRoast = _selectedRoastFilter == 'Semua Sangrai' ||
          item.roastProfile
              .toLowerCase()
              .contains(_selectedRoastFilter.toLowerCase());
      if (!matchesRoast) return false;
      if (q.isEmpty) return true;
      return item.name.toLowerCase().contains(q) ||
          item.origin.toLowerCase().contains(q) ||
          item.variety.toLowerCase().contains(q) ||
          item.process.toLowerCase().contains(q) ||
          item.tastingNotes.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _openAddOrEditLineup({CoffeeLineupItem? existing}) async {
    final uploader = ref.read(roasteryMediaUploaderProvider);
    final result = await CoffeeLineupEditorSheet.show(
      context,
      initialItem: existing,
      uploader: uploader,
    );
    if (result == null || !mounted) return;

    try {
      await ref.read(roasteryCatalogProvider.notifier).saveLineup(
            existingLineupId: existing?.id,
            item: result,
          );
      final updatedMine = ref.read(roasteryCatalogProvider).myRoastery;
      if (mounted && updatedMine != null && updatedMine.id == _roastery.id) {
        setState(() => _roastery = updatedMine);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(existing != null
                ? 'Varian "${result.name}" diperbarui.'
                : 'Varian "${result.name}" ditambahkan ke lineup!'),
            backgroundColor: AppTheme.primaryBrown,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan varian: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _deleteLineup(CoffeeLineupItem item) async {
    final id = item.id;
    if (id == null || id.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Varian Kopi?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
          'Varian "${item.name}" akan dihapus permanen dari katalog roastery Anda.',
          style: const TextStyle(fontSize: 13.5, color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(roasteryCatalogProvider.notifier).removeLineup(id);
      final updatedMine = ref.read(roasteryCatalogProvider).myRoastery;
      if (mounted && updatedMine != null && updatedMine.id == _roastery.id) {
        setState(() => _roastery = updatedMine);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus varian: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _copyRoasterySummary() {
    final text = StringBuffer()
      ..writeln('${_roastery.name} (${_roastery.location})')
      ..writeln('Alamat: ${_roastery.address}')
      ..writeln('Klaster: ${_roastery.cluster}')
      ..writeln('Varian tersedia: ${_roastery.effectiveLineupCount}');
    if ((_roastery.whatsappNumber ?? '').isNotEmpty) {
      text.writeln('WhatsApp: ${_roastery.whatsappNumber}');
    }
    if ((_roastery.instagramHandle ?? '').isNotEmpty) {
      text.writeln('Instagram: ${_roastery.instagramHandle}');
    }
    Clipboard.setData(ClipboardData(text: text.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Info Roastery disalin ke clipboard.'),
        backgroundColor: AppTheme.primaryBrown,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _launchWhatsApp(String rawPhone) async {
    final digits = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final normalized =
        digits.startsWith('0') ? '62${digits.substring(1)}' : digits;
    final uri = Uri.parse('https://wa.me/$normalized');
    if (!await launchExternalUri(uri)) {
      await Clipboard.setData(ClipboardData(text: rawPhone));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nomor WhatsApp disalin: $rawPhone')),
        );
      }
    }
  }

  void _brewLineup(CoffeeLineupItem item) {
    final recipe = RoasteryBrewRecipeBuilder.buildRecipeForLineup(
      roastery: _roastery,
      item: item,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrewTimerScreen(recipeData: recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(roasteryCatalogProvider);
    final isOwner = catalogState.isOwnedByCurrentUser(_roastery);
    if (isOwner &&
        catalogState.myRoastery != null &&
        catalogState.myRoastery!.id == _roastery.id) {
      _roastery = catalogState.myRoastery!;
    }

    final filtered = _filteredLineups;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 148,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF4A2E1B),
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.32),
                child: IconButton(
                  icon: const Icon(CupertinoIcons.back,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              if (isOwner)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Center(
                    child: FilledButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const BusinessRoasteryStudioScreen(),
                          ),
                        );
                        await _refreshLatestIfBusiness();
                      },
                      icon: const Icon(Icons.storefront_rounded, size: 15),
                      label: const Text('Kelola',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800)),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: const Color(0xFF2B1A0E),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.32),
                  child: IconButton(
                    tooltip: 'Salin Info Roastery',
                    icon: const Icon(CupertinoIcons.share,
                        color: Colors.white, size: 18),
                    onPressed: _copyRoasterySummary,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (_roastery.bannerUrl != null &&
                      _roastery.bannerUrl!.isNotEmpty)
                    OptimizedCoffeeImage(
                      imageUrlOrAsset: _roastery.bannerUrl!,
                      width: 1200,
                      height: 360,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF2E1A0E),
                            Color(0xFF5C3A21),
                            Color(0xFF7B4E2D),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.18),
                          Colors.black.withValues(alpha: 0.62),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Row(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.22),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: OptimizedCoffeeImage(
                              imageUrlOrAsset: _roastery.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      _roastery.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        height: 1.15,
                                      ),
                                    ),
                                  ),
                                  if (_roastery.isVerifiedBusiness) ...[
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.verified_rounded,
                                      color: Color(0xFFFFD56B),
                                      size: 20,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 13, color: Color(0xFFFFD56B)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _roastery.location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star_rounded,
                                            size: 14, color: Colors.amber),
                                        const SizedBox(width: 3),
                                        Text(
                                          _roastery.rating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isRefreshing)
            const SliverToBoxAdapter(
              child: LinearProgressIndicator(
                minHeight: 2,
                color: AppTheme.primaryBrown,
                backgroundColor: Color(0xFFE7DED2),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetaChipsRow(),
                  const SizedBox(height: 12),
                  _buildStoreProfileCard(),
                  if (isOwner) ...[
                    const SizedBox(height: 12),
                    _buildOwnerActionRow(),
                  ],
                  const SizedBox(height: 18),
                  _buildLineupSectionHeader(),
                  const SizedBox(height: 10),
                  _buildLineupSearchAndRoastFilters(),
                ],
              ),
            ),
          ),
          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(CupertinoIcons.cube_box,
                          size: 40, color: AppTheme.textMuted),
                      const SizedBox(height: 10),
                      Text(
                        _roastery.lineups.isEmpty
                            ? 'Roastery ini belum menambahkan lineup kopi.'
                            : 'Tidak ada varian kopi sesuai filter "$_selectedRoastFilter".',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      if (isOwner) ...[
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () => _openAddOrEditLineup(),
                          icon: const Icon(CupertinoIcons.add),
                          label: const Text('Tambah Kopi Pertama'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBrown,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 36),
              sliver: SliverList.builder(
                itemCount: filtered.length,
                itemBuilder: (context, idx) => RepaintBoundary(
                  child: _buildLineupCard(filtered[idx], isOwner: isOwner),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetaChipsRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (_roastery.isVerifiedBusiness)
          _pill(
            icon: Icons.verified_rounded,
            label: 'Official Business Roastery',
            bgColor: const Color(0xFFFDF3D7),
            fgColor: const Color(0xFF7D5808),
          ),
        _pill(
          icon: CupertinoIcons.tag_fill,
          label: _roastery.cluster,
          bgColor: const Color(0xFFF1E8D7),
          fgColor: AppTheme.primaryBrown,
        ),
        _pill(
          icon: CupertinoIcons.square_grid_2x2_fill,
          label: '${_roastery.effectiveLineupCount} Varian Kopi',
          bgColor: const Color(0xFFEBE4DA),
          fgColor: AppTheme.textDark,
        ),
        if ((_roastery.whatsappNumber ?? '').isNotEmpty)
          InkWell(
            onTap: () => _launchWhatsApp(_roastery.whatsappNumber!),
            borderRadius: BorderRadius.circular(10),
            child: _pill(
              icon: CupertinoIcons.chat_bubble_2_fill,
              label: 'WhatsApp Roastery',
              bgColor: const Color(0xFFE5F4EA),
              fgColor: const Color(0xFF1F6A3B),
            ),
          ),
        if ((_roastery.instagramHandle ?? '').isNotEmpty)
          InkWell(
            onTap: () {
              Clipboard.setData(
                  ClipboardData(text: _roastery.instagramHandle!));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Instagram ${_roastery.instagramHandle} disalin!')),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: _pill(
              icon: CupertinoIcons.at,
              label: _roastery.instagramHandle!,
              bgColor: const Color(0xFFF3E9F1),
              fgColor: const Color(0xFF723764),
            ),
          ),
      ],
    );
  }

  Widget _pill({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color fgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fgColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: fgColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBE2D5)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_roastery.specialties.trim().isNotEmpty) ...[
            Text(
              _roastery.specialties,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryBrown,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            _roastery.description,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: AppTheme.textDark,
            ),
          ),
          if (_roastery.address.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF0E7DB)),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: _roastery.address));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alamat roastery disalin.')),
                );
              },
              child: Row(
                children: [
                  const Icon(CupertinoIcons.map_pin_ellipse,
                      size: 15, color: Color(0xFFC49228)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _roastery.address,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(CupertinoIcons.doc_on_doc,
                      size: 14, color: AppTheme.textMuted),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOwnerActionRow() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _openAddOrEditLineup(),
            icon: const Icon(CupertinoIcons.add_circled_solid, size: 17),
            label: const Text(
              'Tambah Kopi Baru',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BusinessRoasteryStudioScreen(),
              ),
            );
            await _refreshLatestIfBusiness();
          },
          icon: const Icon(Icons.tune_rounded, size: 17),
          label: const Text(
            'Studio',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryBrown,
            side: const BorderSide(color: AppTheme.primaryBrown),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLineupSectionHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Katalog Lineup Kopi (${_roastery.effectiveLineupCount})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
            ),
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (v) => setState(() => _selectedRoastFilter = v),
          itemBuilder: (_) => _roastOptions
              .map((opt) => PopupMenuItem<String>(value: opt, child: Text(opt)))
              .toList(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedRoastFilter,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBrown,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(CupertinoIcons.chevron_down,
                  size: 14, color: AppTheme.primaryBrown),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLineupSearchAndRoastFilters() {
    return Column(
      children: [
        TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _lineupSearch = v),
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Cari varian kopi, origin, atau tasting notes...',
            hintStyle:
                const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
            prefixIcon: const Icon(CupertinoIcons.search,
                size: 18, color: AppTheme.textMuted),
            suffixIcon: _lineupSearch.isNotEmpty
                ? IconButton(
                    icon: const Icon(CupertinoIcons.clear_circled_solid,
                        size: 18, color: AppTheme.textMuted),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _lineupSearch = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: AppTheme.surfaceWhite,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE7DED2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE7DED2)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _roastOptions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final opt = _roastOptions[idx];
              final selected = _selectedRoastFilter == opt;
              return ChoiceChip(
                label: Text(opt),
                selected: selected,
                onSelected: (_) => setState(() => _selectedRoastFilter = opt),
                selectedColor: AppTheme.primaryBrown,
                backgroundColor: AppTheme.surfaceWhite,
                labelStyle: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppTheme.textDark,
                ),
                side: BorderSide(
                  color: selected
                      ? AppTheme.primaryBrown
                      : const Color(0xFFE2D8CA),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLineupCard(CoffeeLineupItem item, {required bool isOwner}) {
    final hasBagPhoto =
        item.bagImageUrl != null && item.bagImageUrl!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBE2D5)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasBagPhoto) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: OptimizedCoffeeImage(
                    imageUrlOrAsset: item.bagImageUrl!,
                    width: 68,
                    height: 82,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        if (item.badge != null && item.badge!.trim().isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBF1D6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.badge!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF8C6209),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.origin} • ${item.variety}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _specBadge(
                          label: item.roastProfile,
                          bg: const Color(0xFFEFEAE1),
                          fg: AppTheme.primaryBrown,
                        ),
                        _specBadge(
                          label: item.process,
                          bg: const Color(0xFFE7F0F4),
                          fg: const Color(0xFF2D5566),
                        ),
                        if (!item.isAvailable)
                          _specBadge(
                            label: 'Stok Habis',
                            bg: const Color(0xFFFCE8E8),
                            fg: Colors.red.shade800,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✨', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.tastingNotes,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textDark,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (item.recommendedBrewMethod != null ||
              item.recommendedTempC != null) ...[
            const SizedBox(height: 8),
            Text(
              'Rekomendasi Roaster: ${item.recommendedBrewMethod ?? "Pour Over"}'
              '${item.recommendedTempC != null ? " • ${item.recommendedTempC}°C" : ""}'
              '${item.recommendedRatio != null ? " • ${item.recommendedRatio}" : ""}',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBrown,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.price100g} / 100g  •  ${item.price200g} / 200g',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                    Text(
                      item.originalPackage,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Salin Spesifikasi Kopi',
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text:
                          '${_roastery.name} — ${item.name} (${item.origin}, ${item.roastProfile}, ${item.process})\nNotes: ${item.tastingNotes}\n${item.originalPackage}',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Spec "${item.name}" disalin.'),
                      backgroundColor: AppTheme.primaryBrown,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(CupertinoIcons.doc_on_doc,
                    size: 19, color: AppTheme.primaryBrown),
              ),
              ElevatedButton.icon(
                onPressed: () => _brewLineup(item),
                icon: const Icon(CupertinoIcons.play_fill, size: 13),
                label: const Text(
                  'Seduh',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          if (isOwner) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF0E7DB)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _openAddOrEditLineup(existing: item),
                  icon: const Icon(CupertinoIcons.pencil, size: 14),
                  label: const Text('Edit', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryBrown,
                  ),
                ),
                const SizedBox(width: 6),
                TextButton.icon(
                  onPressed: () => _deleteLineup(item),
                  icon: const Icon(CupertinoIcons.trash, size: 14),
                  label: const Text('Hapus', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _specBadge({
    required String label,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
