import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/optimized_coffee_image.dart';
import '../../../../models/roastery.dart';
import '../../../../models/subscription_plan.dart';
import '../../../../theme/app_theme.dart';
import '../../profile/widgets/subscription_checkout_sheet.dart';
import '../controllers/roastery_catalog_controller.dart';
import '../data/services/roastery_media_uploader.dart';
import '../widgets/coffee_lineup_editor_sheet.dart';
import '../widgets/roastery_grid_card.dart';
import 'roastery_detail_screen.dart';

class BusinessRoasteryStudioScreen extends ConsumerStatefulWidget {
  final bool openAddLineupImmediately;

  const BusinessRoasteryStudioScreen({
    super.key,
    this.openAddLineupImmediately = false,
  });

  @override
  ConsumerState<BusinessRoasteryStudioScreen> createState() =>
      _BusinessRoasteryStudioScreenState();
}

class _BusinessRoasteryStudioScreenState
    extends ConsumerState<BusinessRoasteryStudioScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _specialtiesCtrl = TextEditingController();
  final _highlightCtrl =
      TextEditingController(text: 'Roastery Bisnis Terverifikasi');
  final _whatsappCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();

  String _selectedCluster = RoasteryCatalogController.businessClusterLabel;
  String _logoUrl = 'assets/images/avatars/generic_fallback.jpg';
  String? _logoPublicId;
  Uint8List? _localLogoPreview;
  double? _logoUploadProgress;

  String? _bannerUrl;
  String? _bannerPublicId;
  double? _bannerUploadProgress;

  bool _isEditingProfile = false;
  bool _isSaving = false;
  bool _didPopulateForm = false;

  static const _clusterChoices = [
    'Roastery Bisnis',
    'Klaster I: Ritel Nasional & Skala Industri',
    'Klaster II: Pelopor & Kurator Gelombang Ketiga',
    'Klaster III: Spesialis Kompetisi & Eksperimental',
    'Klaster IV: Roastery Regional & Komunitas Lokal',
    'Klaster V: Roastery Boutique, Mikro & Artisanal',
  ];

  @override
  void initState() {
    super.initState();
    for (final ctrl in [
      _nameCtrl,
      _cityCtrl,
      _addressCtrl,
      _descCtrl,
      _highlightCtrl,
    ]) {
      ctrl.addListener(_onFormChanged);
    }

    if (widget.openAddLineupImmediately) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ref.read(roasteryCatalogProvider).myRoastery != null) {
          _openLineupEditor();
        }
      });
    }
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _descCtrl.dispose();
    _specialtiesCtrl.dispose();
    _highlightCtrl.dispose();
    _whatsappCtrl.dispose();
    _instagramCtrl.dispose();
    super.dispose();
  }

  void _populateFromExisting(Roastery r) {
    if (_didPopulateForm && !_isEditingProfile) return;
    _nameCtrl.text = r.name;
    _cityCtrl.text = r.location;
    _addressCtrl.text = r.address;
    _descCtrl.text = r.description;
    _specialtiesCtrl.text = r.specialties;
    _highlightCtrl.text = r.salesHighlight;
    _whatsappCtrl.text = r.whatsappNumber ?? '';
    _instagramCtrl.text = r.instagramHandle ?? '';
    _selectedCluster = _clusterChoices.contains(r.cluster)
        ? r.cluster
        : RoasteryCatalogController.businessClusterLabel;
    _logoUrl = r.imageUrl;
    _logoPublicId = r.logoPublicId;
    _bannerUrl = r.bannerUrl;
    _bannerPublicId = r.bannerPublicId;
    _didPopulateForm = true;
  }

  Roastery _buildLivePreviewRoastery() {
    return Roastery(
      id: 'preview',
      name: _nameCtrl.text.trim().isEmpty
          ? 'Nama Roastery Anda'
          : _nameCtrl.text.trim(),
      location:
          _cityCtrl.text.trim().isEmpty ? 'Kota Anda' : _cityCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      latitude: -6.2088,
      longitude: 106.8456,
      description: _descCtrl.text.trim(),
      specialties: _specialtiesCtrl.text.trim(),
      cluster: _selectedCluster,
      imageUrl: _logoUrl,
      rating: 4.9,
      salesHighlight: _highlightCtrl.text.trim().isEmpty
          ? 'Roastery Bisnis Terverifikasi'
          : _highlightCtrl.text.trim(),
      isVerifiedBusiness: true,
      lineups: const [],
      totalLineupsCount: 0,
    );
  }

  Future<void> _pickAndUploadLogo(ImageSource source) async {
    final uploader = ref.read(roasteryMediaUploaderProvider);
    try {
      setState(() => _logoUploadProgress = 0.08);
      final asset = await uploader.pickAndUpload(
        kind: RoasteryAssetKind.logo,
        source: source,
        onProgress: (p) {
          if (mounted) setState(() => _logoUploadProgress = p);
        },
      );
      if (asset != null && mounted) {
        setState(() {
          _logoUrl = asset.secureUrl;
          _logoPublicId = asset.publicId;
          _localLogoPreview = asset.previewBytes;
          _logoUploadProgress = null;
        });
      } else if (mounted) {
        setState(() => _logoUploadProgress = null);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _logoUploadProgress = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload logo gagal: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadBanner() async {
    final uploader = ref.read(roasteryMediaUploaderProvider);
    try {
      setState(() => _bannerUploadProgress = 0.08);
      final asset = await uploader.pickAndUpload(
        kind: RoasteryAssetKind.banner,
        source: ImageSource.gallery,
        onProgress: (p) {
          if (mounted) setState(() => _bannerUploadProgress = p);
        },
      );
      if (asset != null && mounted) {
        setState(() {
          _bannerUrl = asset.secureUrl;
          _bannerPublicId = asset.publicId;
          _bannerUploadProgress = null;
        });
      } else if (mounted) {
        setState(() => _bannerUploadProgress = null);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _bannerUploadProgress = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload banner gagal: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _submitRoasteryProfile({required bool isUpdate}) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final ctrl = ref.read(roasteryCatalogProvider.notifier);
      if (isUpdate) {
        await ctrl.updateMyRoastery({
          'name': _nameCtrl.text.trim(),
          'city': _cityCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'specialties': _specialtiesCtrl.text.trim(),
          'cluster': _selectedCluster,
          'sales_highlight': _highlightCtrl.text.trim(),
          'logo_url': _logoUrl.trim(),
          if (_logoPublicId != null) 'logo_public_id': _logoPublicId,
          if (_bannerUrl != null) 'banner_url': _bannerUrl,
          if (_bannerPublicId != null) 'banner_public_id': _bannerPublicId,
          'whatsapp_number': _whatsappCtrl.text.trim(),
          'instagram_handle': _instagramCtrl.text.trim(),
        });
        if (mounted) {
          setState(() => _isEditingProfile = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil Roastery berhasil diperbarui!'),
              backgroundColor: AppTheme.primaryBrown,
            ),
          );
        }
      } else {
        await ctrl.registerRoastery(
          name: _nameCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          specialties: _specialtiesCtrl.text.trim(),
          cluster: _selectedCluster,
          salesHighlight: _highlightCtrl.text.trim(),
          logoUrl: _logoUrl.trim(),
          logoPublicId: _logoPublicId,
          bannerUrl: _bannerUrl,
          bannerPublicId: _bannerPublicId,
          whatsappNumber: _whatsappCtrl.text.trim(),
          instagramHandle: _instagramCtrl.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Selamat! Roastery Anda resmi terdaftar & tampil di katalog publik.',
              ),
              backgroundColor: AppTheme.primaryBrown,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan Roastery: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _openLineupEditor({CoffeeLineupItem? existing}) async {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(existing != null
                ? 'Varian "${result.name}" diperbarui.'
                : 'Varian "${result.name}" berhasil ditambahkan!'),
            backgroundColor: AppTheme.primaryBrown,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan varian kopi: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _toggleLineupStock(CoffeeLineupItem item) async {
    if (item.id == null) return;
    try {
      await ref.read(roasteryCatalogProvider.notifier).saveLineup(
            existingLineupId: item.id,
            item: item.copyWith(isAvailable: !item.isAvailable),
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update stok: $e')),
        );
      }
    }
  }

  Future<void> _deleteLineup(CoffeeLineupItem item) async {
    if (item.id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Varian Kopi?'),
        content: Text('Hapus "${item.name}" dari etalase roastery Anda?'),
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
    if (ok == true && mounted) {
      await ref.read(roasteryCatalogProvider.notifier).removeLineup(item.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(roasteryCatalogProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Business Roastery Studio',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        actions: [
          if (catalog.isBusinessUser && catalog.myRoastery != null)
            IconButton(
              tooltip: _isEditingProfile ? 'Kembali ke Kelola' : 'Edit Profil',
              onPressed: () {
                setState(() {
                  _isEditingProfile = !_isEditingProfile;
                  if (_isEditingProfile && catalog.myRoastery != null) {
                    _populateFromExisting(catalog.myRoastery!);
                  }
                });
              },
              icon: Icon(
                _isEditingProfile
                    ? CupertinoIcons.list_bullet
                    : CupertinoIcons.pencil_circle,
                color: AppTheme.primaryBrown,
              ),
            ),
        ],
      ),
      body: !catalog.isBusinessUser
          ? _buildBusinessUpgradeGate()
          : (catalog.isLoading && catalog.myRoastery == null)
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryBrown),
                )
              : (catalog.myRoastery == null || _isEditingProfile)
                  ? _buildRegistrationOrEditForm(
                      isUpdate: catalog.myRoastery != null,
                    )
                  : _buildStudioDashboard(catalog.myRoastery!),
    );
  }

  Widget _buildBusinessUpgradeGate() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE7D8C2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFDF3D7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xFFC28E1A),
                size: 42,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Eksklusif Coffee Labs Business',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Daftarkan 1 Profil Roastery resmi toko Anda, upload lineup biji kopi unlimited dengan foto kemasan AI Scan & Cloudinary CDN, dan tampilkan langsung kepada seluruh pengguna Coffee Labs.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  SubscriptionCheckoutSheet.show(
                    context,
                    plan: SubscriptionPlan.business,
                  );
                },
                icon: const Icon(Icons.bolt_rounded),
                label: const Text(
                  'Upgrade ke Business (Rp 249.000)',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationOrEditForm({required bool isUpdate}) {
    final preview = _buildLivePreviewRoastery();

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF3D7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEDD99E)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_rounded,
                    size: 16, color: Color(0xFF8C6209)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '1 Akun Business = 1 Profil Roastery Resmi (Dapat diedit kapan saja)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF714E06),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Pratinjau Kartu Direktori Anda',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              width: 196,
              height: 222,
              child: RoasteryGridCard(
                roastery: preview,
                onTap: () {},
              ),
            ),
          ),
          const SizedBox(height: 16),
          _formSection(
            title: 'Logo & Banner Storefront (Cloudinary CDN)',
            children: [
              Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5EFE6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE3D8C8)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: _localLogoPreview != null
                          ? Image.memory(_localLogoPreview!, fit: BoxFit.cover)
                          : OptimizedCoffeeImage(
                              imageUrlOrAsset: _logoUrl,
                              width: 68,
                              height: 68,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Logo Persegi (Crop 1:1)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (_logoUploadProgress != null)
                          LinearProgressIndicator(
                            value: _logoUploadProgress,
                            color: AppTheme.primaryBrown,
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _pickAndUploadLogo(ImageSource.gallery),
                                icon: const Icon(CupertinoIcons.photo, size: 14),
                                label: const Text('Galeri',
                                    style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryBrown,
                                  side: const BorderSide(
                                      color: AppTheme.primaryBrown),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _pickAndUploadLogo(ImageSource.camera),
                                icon:
                                    const Icon(CupertinoIcons.camera, size: 14),
                                label: const Text('Kamera',
                                    style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.textDark,
                                  side:
                                      const BorderSide(color: Color(0xFFD0C4B5)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_bannerUploadProgress != null)
                LinearProgressIndicator(
                  value: _bannerUploadProgress,
                  color: AppTheme.primaryBrown,
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickAndUploadBanner,
                  icon: const Icon(CupertinoIcons.photo_on_rectangle, size: 15),
                  label: Text(
                    _bannerUrl != null
                        ? 'Ganti Banner Header Roastery'
                        : 'Upload Banner Header 16:9 (Opsional)',
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBrown,
                    side: const BorderSide(color: Color(0xFFD9CCBC)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _formSection(
            title: 'Identitas Roastery Anda',
            children: [
              _input(
                controller: _nameCtrl,
                label: 'Nama Resmi Roastery',
                hint: 'cth. Senja Sangrai Coffee Labs',
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'Minimal 2 karakter'
                    : null,
              ),
              const SizedBox(height: 12),
              _input(
                controller: _cityCtrl,
                label: 'Kota / Lokasi',
                hint: 'cth. Bandung & Jakarta',
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'Kota wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              _input(
                controller: _addressCtrl,
                label: 'Alamat Lengkap',
                hint: 'cth. Jl. Ir. H. Juanda No. 88, Dago, Bandung',
                maxLines: 2,
                validator: (v) => (v == null || v.trim().length < 5)
                    ? 'Alamat minimal 5 karakter'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedCluster,
                decoration: _inputDecoration('Kategori Klaster'),
                items: _clusterChoices
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            c,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5),
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCluster = val);
                },
              ),
              const SizedBox(height: 12),
              _input(
                controller: _specialtiesCtrl,
                label: 'Spesialisasi Roastery',
                hint: 'cth. Omni-Roast Single Origin & Anaerobic Fermentation',
              ),
              const SizedBox(height: 12),
              _input(
                controller: _highlightCtrl,
                label: 'Badge Highlight Pendek (Kartu)',
                hint: 'cth. Fresh Roast Setiap Senin',
              ),
              const SizedBox(height: 12),
              _input(
                controller: _descCtrl,
                label: 'Tentang Roastery',
                hint:
                    'Ceritakan filosofi roasting, mesin yang dipakai, & visi toko Anda...',
                maxLines: 3,
                validator: (v) => (v == null || v.trim().length < 10)
                    ? 'Deskripsi minimal 10 karakter'
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _formSection(
            title: 'Kontak Pelanggan (Opsional)',
            children: [
              _input(
                controller: _whatsappCtrl,
                label: 'Nomor WhatsApp Toko',
                hint: '081234567890',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _input(
                controller: _instagramCtrl,
                label: 'Instagram Handle',
                hint: '@senjasangrai.roastery',
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () => _submitRoasteryProfile(isUpdate: isUpdate),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isUpdate
                          ? 'Simpan Perubahan Roastery'
                          : 'Daftarkan & Publikasikan Roastery',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
          if (isUpdate) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => setState(() => _isEditingProfile = false),
              child: const Text('Batal Edit Profil'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStudioDashboard(Roastery myRoastery) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 36),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE7D8C2)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBrown.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F1E8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: OptimizedCoffeeImage(
                        imageUrlOrAsset: myRoastery.imageUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                myRoastery.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded,
                                size: 17, color: Color(0xFFD4AF37)),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${myRoastery.location} • ${myRoastery.effectiveLineupCount} Varian Kopi',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isEditingProfile = true;
                          _populateFromExisting(myRoastery);
                        });
                      },
                      icon: const Icon(CupertinoIcons.pencil, size: 15),
                      label: const Text('Edit Profil Toko',
                          style: TextStyle(fontSize: 12.5)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBrown,
                        side: const BorderSide(color: AppTheme.primaryBrown),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RoasteryDetailScreen(roastery: myRoastery),
                          ),
                        );
                      },
                      icon: const Icon(CupertinoIcons.eye, size: 15),
                      label: const Text('Halaman Publik',
                          style: TextStyle(fontSize: 12.5)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3ECE2),
                        foregroundColor: AppTheme.primaryBrown,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openLineupEditor(),
            icon: const Icon(CupertinoIcons.add_circled_solid, size: 19),
            label: const Text(
              '+ Tambah Lineup Kopi Baru',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Etalase Biji Kopi Anda (${myRoastery.lineups.length})',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 10),
        if (myRoastery.lineups.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEBE2D5)),
            ),
            child: const Column(
              children: [
                Icon(CupertinoIcons.cube_box,
                    size: 38, color: AppTheme.textMuted),
                SizedBox(height: 8),
                Text(
                  'Belum ada lineup kopi.\nTap "+ Tambah Lineup Kopi Baru" atau gunakan AI Scan kemasan!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
              ],
            ),
          )
        else
          ...myRoastery.lineups.map((item) => _buildStudioLineupTile(item)),
      ],
    );
  }

  Widget _buildStudioLineupTile(CoffeeLineupItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBE2D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (item.bagImageUrl != null && item.bagImageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: OptimizedCoffeeImage(
                    imageUrlOrAsset: item.bagImageUrl!,
                    width: 48,
                    height: 58,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '${item.origin} • ${item.roastProfile} • ${item.process}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.price100g}/100g • ${item.originalPackage}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: item.isAvailable,
                activeTrackColor: AppTheme.primaryBrown,
                onChanged: (_) => _toggleLineupStock(item),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.isAvailable ? 'Stok Tersedia' : 'Stok Habis',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: item.isAvailable
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _openLineupEditor(existing: item),
                icon: const Icon(CupertinoIcons.pencil, size: 14),
                label: const Text('Edit', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryBrown,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: () => _deleteLineup(item),
                icon: const Icon(CupertinoIcons.trash, size: 14),
                label: const Text('Hapus', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _formSection({
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
              fontSize: 13.5,
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

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
      filled: true,
      fillColor: const Color(0xFFFAF7F2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 1.5),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 13.5, color: AppTheme.textDark),
      decoration: _inputDecoration(label, hint: hint),
    );
  }
}
