import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../services/business_pos_api_service.dart';
import '../../../services/menu_asset_inspector_service.dart';
import 'business_menu_asset_image.dart';

class AddMenuItemModal extends StatefulWidget {
  final VoidCallback onMenuAdded;

  const AddMenuItemModal({
    super.key,
    required this.onMenuAdded,
  });

  static void show(BuildContext context, {required VoidCallback onMenuAdded}) {
    final isWide = MediaQuery.of(context).size.width > 650;
    if (isWide) {
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620, maxHeight: 780),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AddMenuItemModal(onMenuAdded: onMenuAdded),
              ),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => AddMenuItemModal(onMenuAdded: onMenuAdded),
      );
    }
  }

  @override
  State<AddMenuItemModal> createState() => _AddMenuItemModalState();
}

class _AddMenuItemModalState extends State<AddMenuItemModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController(text: '35000');
  final _descController = TextEditingController();

  String _selectedCategory = 'Signature Coffee';
  String _selectedAssetUrl = 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=500&q=80';
  String _assetFormat = 'PNG';
  bool _isCustomUpload = false;
  File? _pickedFile;
  bool _isSaving = false;
  String? _uploadStatusText;
  bool _uploadIsValid = true;

  // Dual-Menu Assignment Flags (Pembeda Menu Kasir vs Menu Display AOD)
  bool _showInAod = true;
  bool _showInPos = true;

  final List<String> _categories = [
    'Signature Coffee',
    'Filter Coffee',
    'Espresso Based',
    'Milk Based',
    'Cold Brew',
    'Mocktail Coffee',
    'Bakery & Pastry',
    'Biji Kopi (Retail)',
    'Add-ons & Sirup',
  ];

  final List<Map<String, String>> _presetVisuals = [
    {
      'label': 'Espresso Crema',
      'url': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=500&q=80',
    },
    {
      'label': 'V60 Filter Brew',
      'url': 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?auto=format&fit=crop&w=500&q=80',
    },
    {
      'label': 'Iced Oat Latte',
      'url': 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?auto=format&fit=crop&w=500&q=80',
    },
    {
      'label': 'Japanese Flash Brew',
      'url': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=500&q=80',
    },
    {
      'label': 'Cold Brew 12H',
      'url': 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?auto=format&fit=crop&w=500&q=80',
    },
    {
      'label': 'Pastry Croissant',
      'url': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=500&q=80',
    },
    {
      'label': 'Artisan Toast',
      'url': 'https://images.unsplash.com/photo-1562376552-0d160a2f238d?auto=format&fit=crop&w=500&q=80',
    },
    {
      'label': 'Matcha Green Latte',
      'url': 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=500&q=80',
    },
    {
      'label': 'Vanilla Cold Foam',
      'url': 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=500&q=80',
    },
    {
      'label': 'Cinnamon Roll',
      'url': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=500&q=80',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final file = File(picked.path);
      setState(() {
        _isSaving = true;
        _uploadStatusText = 'Memeriksa transparansi piksel AOD...';
      });

      final result = await MenuAssetInspectorService.inspectFile(file);
      if (!result.isValid) {
        setState(() {
          _isSaving = false;
          _uploadIsValid = false;
          _uploadStatusText = result.errorMessage ?? 'Gunakan gambar berlatar transparan (PNG/WebP/SVG).';
        });
        return;
      }

      // Simpan file permanen ke internal storage aplikasi agar tidak hilang saat cache OS dibersihkan
      final appDir = await getApplicationDocumentsDirectory();
      final menuImagesDir = Directory('${appDir.path}/coffee_menu_assets');
      if (!menuImagesDir.existsSync()) {
        menuImagesDir.createSync(recursive: true);
      }
      final fileExt = picked.path.contains('.') ? picked.path.split('.').last : 'png';
      final persistentFileName = 'menu_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final persistentFile = await file.copy('${menuImagesDir.path}/$persistentFileName');

      setState(() {
        _pickedFile = persistentFile;
        _isCustomUpload = true;
        _selectedAssetUrl = persistentFile.path;
        _assetFormat = result.format;
        _uploadIsValid = true;
        _isSaving = false;
        _uploadStatusText = 'Gambar valid! Memiliki kanal alpha untuk layar OLED.';
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
        _uploadIsValid = false;
        _uploadStatusText = 'Gagal memilih gambar dari galeri: $e';
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 35000;
    final desc = _descController.text.trim();

    setState(() => _isSaving = true);

    String finalAssetUrl = _selectedAssetUrl;
    if (_isCustomUpload && _pickedFile != null) {
      try {
        final uploadRes = await BusinessPosApiService.uploadAndValidateAsset(_pickedFile!);
        if (uploadRes != null && uploadRes['asset_url'] != null) {
          finalAssetUrl = uploadRes['asset_url'] as String;
        }
      } catch (_) {}
    }

    final payload = {
      'name': name,
      'description': desc.isNotEmpty ? desc : 'Koleksi menu artisan spesial Coffee Labs.',
      'category': _selectedCategory,
      'price_cents': price,
      'currency': 'IDR',
      'asset_url': finalAssetUrl,
      'asset_format': _assetFormat,
      'has_verified_transparency': true,
      'display_order': 1,
      'is_available': true,
      'show_in_aod': _showInAod,
      'show_in_pos': _showInPos,
    };

    final created = await BusinessPosApiService.createMenuItem(payload);
    setState(() => _isSaving = false);

    if (mounted) {
      if (created != null) {
        widget.onMenuAdded();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E1E1E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(CupertinoIcons.checkmark_circle_fill, color: Color(0xFFD4AF37), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Menu "$name" berhasil disimpan! (${_showInAod ? "Tayang di AOD & Kasir" : "Kasir Saja"})',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Gagal menyimpan menu. Periksa input data.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final formattedPrice = 'Rp ${_priceController.text.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.plus_circle_fill, color: Color(0xFFD4AF37), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tambah Menu Baru (POS & AOD)',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Atur menu jualan kasir dan menu display pelanggan secara mandiri',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.white38),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dual-Menu Switchers (Pembeda Jualan Kasir vs Pajangan AOD)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.25)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          children: [
                            SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            activeTrackColor: const Color(0xFFD4AF37),
                            title: const Row(
                              children: [
                                Icon(CupertinoIcons.tv_fill, color: Color(0xFFD4AF37), size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text('Tayangkan di Display Pelanggan (AOD)', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            subtitle: const Text(
                              'Aktifkan agar menu tampil di layar tablet meja bar pelanggan.',
                              style: TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                            value: _showInAod,
                            onChanged: (val) => setState(() => _showInAod = val),
                          ),
                          const Divider(color: Colors.white10, height: 16),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            activeTrackColor: const Color(0xFFD4AF37),
                            title: const Row(
                              children: [
                                Icon(CupertinoIcons.bag_fill, color: Colors.greenAccent, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text('Tersedia untuk Transaksi Kasir (POS)', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            subtitle: const Text(
                              'Aktifkan agar barista bisa memilih menu ini saat mencatat pesanan.',
                              style: TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                            value: _showInPos,
                            onChanged: (val) => setState(() => _showInPos = val),
                          ),
                        ],
                      ),
                    ),
                  ),

                    const SizedBox(height: 18),

                    // 1. Nama Menu
                    const Text('Nama Menu *', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Misal: Iced Spanish Latte / V60 Geisha Anaerobic',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Nama menu wajib diisi' : null,
                    ),

                    const SizedBox(height: 16),

                    // 2. Kategori Menu
                    const Text('Kategori Menu', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSel = cat == _selectedCategory;
                        return ChoiceChip(
                          label: Text(cat, style: TextStyle(color: isSel ? Colors.black : Colors.white70, fontSize: 11.5, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                          selected: isSel,
                          selectedColor: const Color(0xFFD4AF37),
                          backgroundColor: const Color(0xFF1E1E1E),
                          side: BorderSide(color: isSel ? const Color(0xFFD4AF37) : Colors.white12),
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // 3. Harga Jual
                    const Text('Harga Jual (Rp) *', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixText: 'Rp  ',
                        prefixStyle: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Harga wajib diisi';
                        final n = int.tryParse(val.replaceAll(RegExp(r'[^\d]'), ''));
                        if (n == null || n < 0) return 'Format harga tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [20000, 25000, 35000, 42000, 48000, 60000].map((amount) {
                        return ActionChip(
                          label: Text('${amount ~/ 1000}K', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          backgroundColor: const Color(0xFF222222),
                          side: const BorderSide(color: Colors.white12),
                          onPressed: () => setState(() => _priceController.text = amount.toString()),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // 4. Deskripsi
                    const Text('Deskripsi Singkat / Tasting Notes', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Misal: Single Origin Colombia Washed, aroma peach dan melati.',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 18),

                    // 5. Visual Foto Menu AOD
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text('Visual Menu (AOD Pitch-Black)', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12.5, fontWeight: FontWeight.bold)),
                        ),
                        TextButton.icon(
                          onPressed: _pickImage,
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFFD4AF37)),
                          icon: const Icon(CupertinoIcons.photo_on_rectangle, size: 14),
                          label: const Text('Pilih dari Galeri', style: TextStyle(fontSize: 11.5)),
                        ),
                      ],
                    ),

                    if (_uploadStatusText != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _uploadIsValid ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _uploadIsValid ? Colors.greenAccent : Colors.redAccent, width: 0.8),
                        ),
                        child: Text(_uploadStatusText!, style: TextStyle(color: _uploadIsValid ? Colors.greenAccent : Colors.redAccent, fontSize: 11)),
                      ),
                      const SizedBox(height: 8),
                    ],

                    const SizedBox(height: 6),

                    // Preset Icon Grid
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _presetVisuals.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 10),
                        itemBuilder: (ctx, i) {
                          final v = _presetVisuals[i];
                          final isSel = !_isCustomUpload && _selectedAssetUrl == v['url'];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _isCustomUpload = false;
                                _selectedAssetUrl = v['url']!;
                                _assetFormat = 'PNG';
                                _uploadStatusText = null;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 82,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSel ? const Color(0xFFD4AF37) : Colors.white12, width: isSel ? 1.5 : 1.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      v['url']!,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_cafe, color: Color(0xFFD4AF37), size: 28),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    v['label']!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: isSel ? const Color(0xFFD4AF37) : Colors.white70, fontSize: 9.5, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Live AOD OLED Preview Card
                    const Text('Live Preview di Layar Display AOD Pelanggan:', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      height: 140,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black, // #000000 True Black OLED Preview
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF262626), width: 1.0),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BusinessMenuAssetImage(
                              assetUrl: _selectedAssetUrl,
                              assetFormat: _assetFormat,
                              width: 80,
                              height: 80,
                              fit: (_isCustomUpload || _selectedAssetUrl.startsWith('data:image/'))
                                  ? BoxFit.contain
                                  : BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _nameController.text.isNotEmpty ? _nameController.text : 'Nama Menu Kopi',
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _descController.text.isNotEmpty ? _descController.text : 'Deskripsi rasa seduhan kopi pilihan...',
                                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  formattedPrice,
                                  style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        icon: _isSaving
                            ? const CupertinoActivityIndicator(color: Colors.black)
                            : const Icon(CupertinoIcons.checkmark_seal_fill, size: 18),
                        label: Text(
                          _isSaving ? 'Menyimpan Menu...' : 'Simpan Menu ke Kasir & Display',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
