import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/optimized_coffee_image.dart';
import '../../../../models/roastery.dart';
import '../../../../theme/app_theme.dart';
import '../../bean_scanner/services/bean_vision_scanner_service.dart';
import '../../bean_scanner/services/cognitive_bean_analyzer.dart';
import '../data/services/roastery_media_uploader.dart';

class CoffeeLineupEditorSheet extends StatefulWidget {
  final CoffeeLineupItem? initialItem;
  final RoasteryMediaUploader? uploader;

  const CoffeeLineupEditorSheet({
    super.key,
    this.initialItem,
    this.uploader,
  });

  static Future<CoffeeLineupItem?> show(
    BuildContext context, {
    CoffeeLineupItem? initialItem,
    RoasteryMediaUploader? uploader,
  }) {
    return showModalBottomSheet<CoffeeLineupItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CoffeeLineupEditorSheet(
        initialItem: initialItem,
        uploader: uploader,
      ),
    );
  }

  @override
  State<CoffeeLineupEditorSheet> createState() =>
      _CoffeeLineupEditorSheetState();
}

class _CoffeeLineupEditorSheetState extends State<CoffeeLineupEditorSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _originCtrl;
  late final TextEditingController _varietyCtrl;
  late final TextEditingController _tastingNotesCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _badgeCtrl;
  late final TextEditingController _tempCtrl;
  late final TextEditingController _ratioCtrl;
  late final TextEditingController _grindCtrl;

  String _selectedRoast = 'Light to Medium';
  String _selectedProcess = 'Washed';
  String _selectedBrewMethod = 'V60';
  bool _isAvailable = true;
  bool _showBrewSpecSection = false;

  String? _bagImageUrl;
  String? _bagImagePublicId;
  Uint8List? _localBagPreviewBytes;
  double? _uploadProgress;
  bool _isScanningOcr = false;

  static const _roastOptions = [
    'Light',
    'Light to Medium',
    'Medium',
    'Medium to Dark',
    'Dark',
    'Omni',
  ];

  static const _processOptions = [
    'Washed',
    'Natural',
    'Honey',
    'Anaerobic Natural',
    'Wet-Hulled',
    'Carbonic Maceration',
  ];

  static const _varietySuggestions = [
    'Typica',
    'Bourbon',
    'Gesha',
    'Kartika',
    'Ateng Super',
    'Sigararutang',
  ];

  static const _noteSuggestions = [
    'Floral Jasmine',
    'Dark Chocolate',
    'Berry Jam',
    'Citrus Peel',
    'Palm Sugar',
    'Caramel',
  ];

  static const _weightPresets = [100, 200, 250, 500, 1000];
  static const _brewMethods = ['V60', 'Origami', 'Kalita', 'Espresso', 'Aeropress', 'Tubruk'];

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _originCtrl = TextEditingController(text: item?.origin ?? '');
    _varietyCtrl = TextEditingController(text: item?.variety ?? '');
    _tastingNotesCtrl = TextEditingController(text: item?.tastingNotes ?? '');
    _weightCtrl = TextEditingController(
      text: (item?.resolvedNetWeightGrams ?? 250).toString(),
    );
    _priceCtrl = TextEditingController(
      text: (item?.resolvedPriceIdr ?? 135000).toString(),
    );
    _badgeCtrl = TextEditingController(text: item?.badge ?? '');
    _tempCtrl = TextEditingController(
      text: item?.recommendedTempC?.toString() ?? '92',
    );
    _ratioCtrl = TextEditingController(
      text: item?.recommendedRatio ?? '1:15',
    );
    _grindCtrl = TextEditingController(
      text: item?.recommendedGrindSize ?? 'Medium-Fine',
    );

    if (item != null) {
      _selectedRoast = _roastOptions.contains(item.roastProfile)
          ? item.roastProfile
          : item.roastProfile;
      _selectedProcess = item.process;
      _isAvailable = item.isAvailable;
      _bagImageUrl = item.bagImageUrl;
      _bagImagePublicId = item.bagImagePublicId;
      if (item.recommendedBrewMethod != null &&
          item.recommendedBrewMethod!.isNotEmpty) {
        _selectedBrewMethod = item.recommendedBrewMethod!;
        _showBrewSpecSection = true;
      }
    }

    _weightCtrl.addListener(_onPriceInputChanged);
    _priceCtrl.addListener(_onPriceInputChanged);
  }

  void _onPriceInputChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _originCtrl.dispose();
    _varietyCtrl.dispose();
    _tastingNotesCtrl.dispose();
    _weightCtrl.dispose();
    _priceCtrl.dispose();
    _badgeCtrl.dispose();
    _tempCtrl.dispose();
    _ratioCtrl.dispose();
    _grindCtrl.dispose();
    super.dispose();
  }

  ({String price100g, String price200g, String originalPackage})
      get _liveUnitPricing {
    final g = int.tryParse(_weightCtrl.text.trim()) ?? 250;
    final p = int.tryParse(_priceCtrl.text.trim()) ?? 0;
    return CoffeeLineupItem.computeUnitLabels(g, p);
  }

  Future<void> _handleAiScanFromBag(ImageSource source) async {
    setState(() => _isScanningOcr = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 92,
      );
      if (picked == null) {
        if (mounted) setState(() => _isScanningOcr = false);
        return;
      }

      final file = File(picked.path);
      final scan = await BeanVisionScannerService.processPhoto(file);
      final resolved = CognitiveBeanAnalyzer.analyze(
        rawFullText: scan.rawFullText,
        blocksDto: scan.blocks,
        localImagePath: scan.croppedImageFile.path,
      );

      final croppedBytes = await scan.croppedImageFile.readAsBytes();
      if (!mounted) return;

      setState(() {
        _localBagPreviewBytes = croppedBytes;
        if (resolved.beanName.isNotEmpty) _nameCtrl.text = resolved.beanName;
        if (resolved.origin.isNotEmpty) _originCtrl.text = resolved.origin;
        if (resolved.variety.isNotEmpty) _varietyCtrl.text = resolved.variety;
        if (resolved.process.isNotEmpty) _selectedProcess = resolved.process;
        if (resolved.roastLevel.isNotEmpty) _selectedRoast = resolved.roastLevel;
        if (resolved.tastingNotes.isNotEmpty) {
          _tastingNotesCtrl.text = resolved.tastingNotes.join(', ');
        }
        _tempCtrl.text = resolved.recommendedWaterTempC.toString();
      });

      if (widget.uploader != null) {
        await _uploadBytesToCloudinary(croppedBytes);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              scan.rawFullText.trim().isNotEmpty
                  ? 'Info kemasan "${resolved.beanName}" berhasil diekstrak!'
                  : 'Foto kemasan dipasang. Lengkapi nama/notes jika belum terbaca.',
            ),
            backgroundColor: AppTheme.primaryBrown,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memindai kemasan: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanningOcr = false);
    }
  }

  Future<void> _pickAndUploadBagPhoto(ImageSource source) async {
    if (widget.uploader == null) return;
    try {
      setState(() => _uploadProgress = 0.05);
      final res = await widget.uploader!.pickAndUpload(
        kind: RoasteryAssetKind.lineup,
        source: source,
        onProgress: (p) {
          if (mounted) setState(() => _uploadProgress = p);
        },
      );
      if (res != null && mounted) {
        setState(() {
          _bagImageUrl = res.secureUrl;
          _bagImagePublicId = res.publicId;
          _localBagPreviewBytes = res.previewBytes;
          _uploadProgress = null;
        });
      } else if (mounted) {
        setState(() => _uploadProgress = null);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploadProgress = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload foto kemasan gagal: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _uploadBytesToCloudinary(Uint8List bytes) async {
    if (widget.uploader == null) return;
    try {
      setState(() => _uploadProgress = 0.1);
      final res = await widget.uploader!.compressAndUploadBytes(
        rawBytes: bytes,
        kind: RoasteryAssetKind.lineup,
        onProgress: (p) {
          if (mounted) setState(() => _uploadProgress = p);
        },
      );
      if (mounted) {
        setState(() {
          _bagImageUrl = res.secureUrl;
          _bagImagePublicId = res.publicId;
          _localBagPreviewBytes = res.previewBytes;
          _uploadProgress = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _uploadProgress = null);
    }
  }

  void _appendNoteSuggestion(String note) {
    final current = _tastingNotesCtrl.text.trim();
    if (current.toLowerCase().contains(note.toLowerCase())) return;
    _tastingNotesCtrl.text = current.isEmpty ? note : '$current, $note';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final weight = int.tryParse(_weightCtrl.text.trim()) ?? 250;
    final price = int.tryParse(_priceCtrl.text.trim()) ?? 100000;
    final labels = CoffeeLineupItem.computeUnitLabels(weight, price);

    final item = CoffeeLineupItem(
      id: widget.initialItem?.id,
      name: _nameCtrl.text.trim(),
      origin: _originCtrl.text.trim(),
      roastProfile: _selectedRoast,
      variety: _varietyCtrl.text.trim(),
      process: _selectedProcess,
      tastingNotes: _tastingNotesCtrl.text.trim(),
      netWeightGrams: weight,
      priceIdr: price,
      price100g: labels.price100g,
      price200g: labels.price200g,
      originalPackage: labels.originalPackage,
      bagImageUrl: _bagImageUrl,
      bagImagePublicId: _bagImagePublicId,
      badge: _badgeCtrl.text.trim().isEmpty ? null : _badgeCtrl.text.trim(),
      isAvailable: _isAvailable,
      displayOrder: widget.initialItem?.displayOrder ?? 0,
      recommendedBrewMethod: _showBrewSpecSection ? _selectedBrewMethod : null,
      recommendedTempC:
          _showBrewSpecSection ? int.tryParse(_tempCtrl.text.trim()) : null,
      recommendedRatio:
          _showBrewSpecSection && _ratioCtrl.text.trim().isNotEmpty
              ? _ratioCtrl.text.trim()
              : null,
      recommendedGrindSize:
          _showBrewSpecSection && _grindCtrl.text.trim().isNotEmpty
              ? _grindCtrl.text.trim()
              : null,
    );

    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialItem != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final pricing = _liveUnitPricing;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD6CBBF),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    CupertinoIcons.sparkles,
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
                        isEdit ? 'Edit Varian Kopi' : 'Tambah Lineup Kopi Baru',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const Text(
                        'Publikasikan ke katalog global & Brew Timer',
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(CupertinoIcons.xmark_circle_fill,
                      color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE7DED2)),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                children: [
                  _buildAiScanBanner(),
                  const SizedBox(height: 14),
                  _buildBagPhotoCard(),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: '1. Identitas Kopi',
                    children: [
                      _buildTextField(
                        controller: _nameCtrl,
                        label: 'Nama Varian Kopi',
                        hint: 'cth. Gayo Pantan Musara Anaerobic',
                        validator: (v) => (v == null || v.trim().length < 2)
                            ? 'Nama kopi minimal 2 karakter'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _originCtrl,
                        label: 'Asal / Origin',
                        hint: 'cth. Aceh Gayo, 1650 MDPL',
                        validator: (v) => (v == null || v.trim().length < 2)
                            ? 'Origin wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _varietyCtrl,
                        label: 'Varietas',
                        hint: 'cth. Abyssinia, Timtim, Typica',
                        validator: (v) => (v == null || v.trim().length < 2)
                            ? 'Varietas wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _varietySuggestions
                            .map((v) => _buildQuickChip(
                                  v,
                                  onTap: () => _varietyCtrl.text = v,
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildSectionCard(
                    title: '2. Profil Sangrai, Proses & Rasa',
                    children: [
                      const Text(
                        'Profil Sangrai',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _roastOptions.map((r) {
                          final selected = _selectedRoast == r;
                          return ChoiceChip(
                            label: Text(r),
                            selected: selected,
                            onSelected: (_) => setState(() => _selectedRoast = r),
                            selectedColor: AppTheme.primaryBrown,
                            backgroundColor: const Color(0xFFF3ECE2),
                            labelStyle: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : AppTheme.textDark,
                            ),
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Proses Pasca Panen',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _processOptions.map((p) {
                          final selected = _selectedProcess == p;
                          return ChoiceChip(
                            label: Text(p),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => _selectedProcess = p),
                            selectedColor: const Color(0xFF426A7D),
                            backgroundColor: const Color(0xFFEAF1F4),
                            labelStyle: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : const Color(0xFF2D4C5A),
                            ),
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _tastingNotesCtrl,
                        label: 'Tasting Notes',
                        hint: 'cth. Jasmine, Bergamot, Caramel, Honey',
                        maxLines: 2,
                        validator: (v) => (v == null || v.trim().length < 3)
                            ? 'Tasting notes minimal 3 karakter'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _noteSuggestions
                            .map((n) => _buildQuickChip(
                                  '+ $n',
                                  onTap: () => _appendNoteSuggestion(n),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildSectionCard(
                    title: '3. Berat Kemasan & Harga Cerdas',
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _weightPresets.map((g) {
                          final active = _weightCtrl.text.trim() == g.toString();
                          return ChoiceChip(
                            label: Text('${g}g'),
                            selected: active,
                            onSelected: (_) =>
                                setState(() => _weightCtrl.text = g.toString()),
                            selectedColor: AppTheme.primaryBrown,
                            backgroundColor: const Color(0xFFF3ECE2),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: active ? Colors.white : AppTheme.textDark,
                            ),
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _weightCtrl,
                              label: 'Berat (gram)',
                              hint: '250',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                if (n == null || n < 50 || n > 10000) {
                                  return '50 - 10.000g';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              controller: _priceCtrl,
                              label: 'Harga Kemasan (Rp)',
                              hint: '135000',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                if (n == null || n < 1000) {
                                  return 'Minimal Rp1.000';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF6F0),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE8DFD1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kalkulasi Otomatis Tampilan Katalog:',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${pricing.price100g} / 100g • ${pricing.price200g} / 200g',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryBrown,
                              ),
                            ),
                            Text(
                              pricing.originalPackage,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildSectionCard(
                    title: '4. Label, Stok & Rekomendasi Seduh',
                    children: [
                      _buildTextField(
                        controller: _badgeCtrl,
                        label: 'Badge Opsional (Misal: Seasonal, Micro-Lot)',
                        hint: 'Signature',
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Stok Kopi Tersedia (Available)',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                            Switch.adaptive(
                              activeTrackColor: AppTheme.primaryBrown,
                              value: _isAvailable,
                              onChanged: (val) =>
                                  setState(() => _isAvailable = val),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(
                            () => _showBrewSpecSection = !_showBrewSpecSection),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.slider_horizontal_3,
                                size: 17,
                                color: AppTheme.primaryBrown,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Tambahkan Rekomendasi Seduh Roaster',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryBrown,
                                  ),
                                ),
                              ),
                              Icon(
                                _showBrewSpecSection
                                    ? CupertinoIcons.chevron_up
                                    : CupertinoIcons.chevron_down,
                                size: 16,
                                color: AppTheme.primaryBrown,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showBrewSpecSection) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _brewMethods.map((m) {
                            final selected = _selectedBrewMethod == m;
                            return ChoiceChip(
                              label: Text(m),
                              selected: selected,
                              onSelected: (_) =>
                                  setState(() => _selectedBrewMethod = m),
                              selectedColor: AppTheme.primaryBrown,
                              backgroundColor: const Color(0xFFF3ECE2),
                              labelStyle: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: selected ? Colors.white : AppTheme.textDark,
                              ),
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _tempCtrl,
                                label: 'Suhu Air (°C)',
                                hint: '92',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                controller: _ratioCtrl,
                                label: 'Rasio',
                                hint: '1:15',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _grindCtrl,
                          label: 'Ukuran Gilingan',
                          hint: 'Medium-Fine (24 Klik Comandante)',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceWhite,
              border: Border(top: BorderSide(color: Color(0xFFE7DED2))),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _uploadProgress != null ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isEdit ? 'Simpan Perubahan Kopi' : 'Tambahkan ke Katalog Publik',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiScanBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A2E1B), Color(0xFF6B4429)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _isScanningOcr
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFFD56B),
                    ),
                  )
                : const Icon(
                    CupertinoIcons.camera_viewfinder,
                    color: Color(0xFFFFD56B),
                    size: 24,
                  ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✨ Auto-Isi dari Foto Kemasan (AI Scan)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Foto label pouch kopi untuk isi nama, origin, notes & pasang foto otomatis.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _isScanningOcr
                ? null
                : () => _handleAiScanFromBag(ImageSource.gallery),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF2B1A0E),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Scan',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBagPhotoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBE2D5)),
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 82,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EFE6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE6DCCE)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: _localBagPreviewBytes != null
                  ? Image.memory(_localBagPreviewBytes!, fit: BoxFit.cover)
                  : (_bagImageUrl != null && _bagImageUrl!.isNotEmpty)
                      ? OptimizedCoffeeImage(
                          imageUrlOrAsset: _bagImageUrl!,
                          width: 66,
                          height: 82,
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          CupertinoIcons.photo,
                          color: AppTheme.textMuted,
                          size: 26,
                        ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Foto Kemasan Kopi (Cloudinary CDN)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _uploadProgress != null
                      ? 'Mengunggah ke Cloudinary (${(_uploadProgress! * 100).round()}%)...'
                      : (_bagImageUrl != null
                          ? 'Foto terpasang & teroptimasi WebP.'
                          : 'Rasio 4:5 ideal untuk katalog (opsional).'),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.textMuted,
                  ),
                ),
                if (_uploadProgress != null) ...[
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: const Color(0xFFEFECE6),
                    color: AppTheme.primaryBrown,
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () =>
                            _pickAndUploadBagPhoto(ImageSource.gallery),
                        icon: const Icon(CupertinoIcons.photo_on_rectangle,
                            size: 14),
                        label: const Text('Galeri',
                            style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBrown,
                          side: const BorderSide(color: AppTheme.primaryBrown),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _pickAndUploadBagPhoto(ImageSource.camera),
                        icon: const Icon(CupertinoIcons.camera, size: 14),
                        label: const Text('Kamera',
                            style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textDark,
                          side: const BorderSide(color: Color(0xFFD0C4B5)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBE2D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryBrown,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(fontSize: 13.5, color: AppTheme.textDark),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
        filled: true,
        fillColor: const Color(0xFFFAF7F2),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE4DACB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE4DACB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppTheme.primaryBrown, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, {required VoidCallback onTap}) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppTheme.textDark),
      ),
      onPressed: onTap,
      backgroundColor: const Color(0xFFF6F1E8),
      side: const BorderSide(color: Color(0xFFE3D8C8)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
