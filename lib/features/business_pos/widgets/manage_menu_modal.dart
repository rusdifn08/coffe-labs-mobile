import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/business_pos_models.dart';
import '../../../services/business_pos_api_service.dart';
import 'add_menu_item_modal.dart';

class ManageMenuModal extends StatefulWidget {
  final List<BusinessMenuItem> menuItems;
  final VoidCallback onMenuChanged;

  const ManageMenuModal({
    super.key,
    required this.menuItems,
    required this.onMenuChanged,
  });

  static void show(
    BuildContext context, {
    required List<BusinessMenuItem> menuItems,
    required VoidCallback onMenuChanged,
  }) {
    final isWide = MediaQuery.of(context).size.width > 650;
    if (isWide) {
      showDialog(
        context: context,
        barrierColor: Colors.black87,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680, maxHeight: 800),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: ManageMenuModal(menuItems: menuItems, onMenuChanged: onMenuChanged),
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
        builder: (ctx) => ManageMenuModal(
          menuItems: menuItems,
          onMenuChanged: onMenuChanged,
        ),
      );
    }
  }

  @override
  State<ManageMenuModal> createState() => _ManageMenuModalState();
}

class _ManageMenuModalState extends State<ManageMenuModal> {
  late List<BusinessMenuItem> _items;
  String _activeTab = 'all'; // 'all', 'aod_only', 'pos_only'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.menuItems);
  }

  Future<void> _toggleAodDisplay(BusinessMenuItem item) async {
    final updated = item.copyWith(showInAod: !item.showInAod);
    setState(() {
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = updated;
      }
    });

    // Simpan perubahan ke backend & local cache
    await BusinessPosApiService.createMenuItem(updated.toJson());
    widget.onMenuChanged();
  }

  Future<void> _deleteItem(BusinessMenuItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(CupertinoIcons.trash_fill, color: Colors.redAccent, size: 22),
            SizedBox(width: 8),
            Text('Hapus Menu', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Text(
          'Hapus "${item.name}" dari Menu Display dan Kasir?',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus Menu'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await BusinessPosApiService.deleteMenuItem(item.id);
      setState(() {
        _items.removeWhere((i) => i.id == item.id);
      });
      widget.onMenuChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((i) {
      if (_searchQuery.isNotEmpty && !i.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_activeTab == 'aod_only') return i.showInAod;
      if (_activeTab == 'pos_only') return !i.showInAod && i.showInPos;
      return true;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFFD4AF37), width: 1.2),
          left: BorderSide(color: Colors.white12),
          right: BorderSide(color: Colors.white12),
        ),
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
                const Icon(CupertinoIcons.square_grid_2x2_fill, color: Color(0xFFD4AF37), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kelola Katalog & Display AOD',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Pisahkan menu transaksi kasir dengan menu pajangan meja bar',
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    AddMenuItemModal.show(context, onMenuAdded: widget.onMenuChanged);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(CupertinoIcons.plus, size: 14),
                  label: const Text('Tambah', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.white38),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Box & Segmented Tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                // Search Field
                TextFormField(
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(CupertinoIcons.search, color: Colors.white38, size: 18),
                    hintText: 'Cari menu kopi, minuman, atau pastry...',
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),

                const SizedBox(height: 10),

                // Tabs: All vs AOD vs Kasir Saja
                Row(
                  children: [
                    _buildTabChip('all', 'Semua (${_items.length})'),
                    const SizedBox(width: 8),
                    _buildTabChip('aod_only', 'Pajangan AOD (${_items.where((i) => i.showInAod).length})'),
                    const SizedBox(width: 8),
                    _buildTabChip('pos_only', 'Kasir Saja (${_items.where((i) => !i.showInAod).length})'),
                  ],
                ),
              ],
            ),
          ),

          // List of Items
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('Tidak ada menu pada kategori ini.', style: TextStyle(color: Colors.white54)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final item = filtered[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: item.showInAod ? const Color(0xFFD4AF37).withValues(alpha: 0.3) : Colors.white10,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 50,
                                height: 50,
                                color: Colors.black,
                                child: Image.network(
                                  item.assetUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.local_cafe,
                                    color: Color(0xFFD4AF37),
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Detail Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text(
                                        item.formattedPrice,
                                        style: const TextStyle(
                                          color: Color(0xFFD4AF37),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '• ${item.category}',
                                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // AOD Display Toggle Button
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CupertinoSwitch(
                                  value: item.showInAod,
                                  activeTrackColor: const Color(0xFFD4AF37),
                                  onChanged: (_) => _toggleAodDisplay(item),
                                ),
                                Text(
                                  item.showInAod ? 'AOD AKTIF' : 'KASIR SAJA',
                                  style: TextStyle(
                                    color: item.showInAod ? const Color(0xFFD4AF37) : Colors.white38,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(width: 4),

                            // Delete Action
                            IconButton(
                              icon: const Icon(CupertinoIcons.trash, color: Colors.redAccent, size: 18),
                              onPressed: () => _deleteItem(item),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(String key, String label) {
    final isSel = _activeTab == key;
    return InkWell(
      onTap: () => setState(() => _activeTab = key),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFFD4AF37) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSel ? const Color(0xFFD4AF37) : Colors.white12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSel ? Colors.black : Colors.white70,
            fontSize: 11.5,
            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
