import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/business_pos_models.dart';
import '../../../services/business_pos_api_service.dart';
import '../../../services/menu_asset_inspector_service.dart';

class MenuGridConfiguratorModal extends StatefulWidget {
  final BusinessStoreConfig config;
  final VoidCallback onConfigUpdated;

  const MenuGridConfiguratorModal({
    super.key,
    required this.config,
    required this.onConfigUpdated,
  });

  @override
  State<MenuGridConfiguratorModal> createState() => _MenuGridConfiguratorModalState();
}

class _MenuGridConfiguratorModalState extends State<MenuGridConfiguratorModal> {
  late int _columns;
  late int _rows;
  late bool _pixelShift;
  bool _isSaving = false;

  // New Menu Form State
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _selectedCategory = 'Signature Coffee';
  File? _selectedAssetFile;
  InspectionResult? _inspectionResult;
  bool _isInspecting = false;
  bool _isUploadingMenu = false;

  @override
  void initState() {
    super.initState();
    _columns = widget.config.aodGridColumns;
    _rows = widget.config.aodGridRows;
    _pixelShift = widget.config.pixelShiftEnabled;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickAndInspectAsset() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _isInspecting = true;
      _selectedAssetFile = file;
      _inspectionResult = null;
    });

    final result = await MenuAssetInspectorService.inspectFile(file);

    setState(() {
      _isInspecting = false;
      _inspectionResult = result;
    });
  }

  Future<void> _saveGridConfig() async {
    setState(() => _isSaving = true);
    final res = await BusinessPosApiService.updateStoreConfig({
      'aod_grid_columns': _columns,
      'aod_grid_rows': _rows,
      'pixel_shift_enabled': _pixelShift,
    });
    setState(() => _isSaving = false);

    if (res != null && mounted) {
      widget.onConfigUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Konfigurasi Grid AOD ($_columns Kolom x $_rows Baris) tersimpan!'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _submitNewMenu() async {
    if (_nameController.text.trim().isEmpty || _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan harga menu wajib diisi.')),
      );
      return;
    }

    if (_inspectionResult == null || !_inspectionResult!.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih foto menu dengan transparansi valid (PNG/WebP/SVG tanpa background).'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isUploadingMenu = true);

    try {
      // 1. Upload & Validasi Biner di Server
      final uploadRes = await BusinessPosApiService.uploadAndValidateAsset(_selectedAssetFile!);
      final assetUrl = uploadRes?['asset_url'] ?? '';
      final format = uploadRes?['format'] ?? 'PNG';

      final price = int.tryParse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 35000;

      // 2. Simpan Item Menu
      final created = await BusinessPosApiService.createMenuItem({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'category': _selectedCategory,
        'price_cents': price,
        'currency': 'IDR',
        'asset_url': assetUrl,
        'asset_format': format,
      });

      if (created != null && mounted) {
        widget.onConfigUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menu baru berhasil ditambahkan ke katalog & AOD!'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingMenu = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Tab Bar
            const TabBar(
              indicatorColor: Color(0xFFD4AF37),
              labelColor: Color(0xFFD4AF37),
              unselectedLabelColor: Colors.white54,
              tabs: [
                Tab(icon: Icon(CupertinoIcons.square_grid_2x2), text: 'Matriks Grid AOD'),
                Tab(icon: Icon(CupertinoIcons.plus_circle_fill), text: 'Tambah Menu Custom'),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [
                  _buildGridConfigTab(),
                  _buildAddMenuTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridConfigTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Konfigurasi Tampilan Layar Kiosk (AOD)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            'Atur rasio kolom dan baris menu agar kartu pas di layar tablet kasir Anda tanpa perlu scroll.',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 20),

          // Stepper Kolom (Ke Samping)
          _buildCounterRow(
            label: 'Kolom Ke Samping (X):',
            value: _columns,
            min: 1,
            max: 8,
            onChanged: (v) => setState(() => _columns = v),
          ),
          const SizedBox(height: 14),

          // Stepper Baris (Ke Bawah)
          _buildCounterRow(
            label: 'Baris Ke Bawah (Y):',
            value: _rows,
            min: 1,
            max: 6,
            onChanged: (v) => setState(() => _rows = v),
          ),
          const SizedBox(height: 20),

          // Pixel Shift Switch
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.shield_fill, color: Color(0xFFD4AF37), size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OLED Pixel-Shifting (Anti Burn-In)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'Menggeser posisi tampilan 1–3 px tiap 3 menit untuk menjaga layar AMOLED.',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _pixelShift,
                  activeThumbColor: const Color(0xFFD4AF37),
                  onChanged: (v) => setState(() => _pixelShift = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Live Mini Grid Preview
          const Text(
            'Pratinjau Layout Layar Tablet:',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Container(
            height: 140,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _columns,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1.4,
              ),
              itemCount: _columns * _rows,
              itemBuilder: (ctx, i) => Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1C),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveGridConfig,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isSaving
                ? const CupertinoActivityIndicator(color: Colors.black)
                : const Text('Simpan Pengaturan Grid', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterRow({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          Row(
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.minus_circle_fill, color: Colors.white38),
                onPressed: value > min ? () => onChanged(value - 1) : null,
              ),
              Container(
                width: 36,
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.plus_circle_fill, color: Color(0xFFD4AF37)),
                onPressed: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddMenuTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Unggah Foto Menu Transparan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sistem OLED Always-On mewajibkan foto berformat PNG/WebP tanpa background (transparan) atau SVG.',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // File Picker & Transparency Badge
          InkWell(
            onTap: _pickAndInspectAsset,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _inspectionResult?.isValid == true
                      ? Colors.greenAccent
                      : (_inspectionResult != null ? Colors.redAccent : Colors.white24),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  if (_isInspecting)
                    const CupertinoActivityIndicator(color: Color(0xFFD4AF37))
                  else if (_selectedAssetFile != null) ...[
                    const Icon(CupertinoIcons.checkmark_seal_fill, color: Colors.greenAccent, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      _selectedAssetFile!.path.split(Platform.pathSeparator).last,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ] else ...[
                    const Icon(CupertinoIcons.photo_fill_on_rectangle_fill, color: Color(0xFFD4AF37), size: 36),
                    const SizedBox(height: 8),
                    const Text('Pilih Foto PNG/WebP Transparan / SVG', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                  if (_inspectionResult != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _inspectionResult!.isValid ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _inspectionResult!.isValid
                            ? '✅ Alpha Channel Terverifikasi (${_inspectionResult!.format})'
                            : '❌ ${_inspectionResult!.errorMessage}',
                        style: TextStyle(
                          color: _inspectionResult!.isValid ? Colors.greenAccent : Colors.redAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Nama Menu',
              labelStyle: const TextStyle(color: Colors.white60),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Deskripsi Singkat / Tasting Notes',
              labelStyle: const TextStyle(color: Colors.white60),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Harga (Contoh: 38000)',
              labelStyle: const TextStyle(color: Colors.white60),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _isUploadingMenu ? null : _submitNewMenu,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isUploadingMenu
                ? const CupertinoActivityIndicator(color: Colors.black)
                : const Text('Validasi & Tambah Menu', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
