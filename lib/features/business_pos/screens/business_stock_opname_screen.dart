import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/business_theme.dart';
import '../models/business_stock_models.dart';
import '../services/business_stock_service.dart';

class BusinessStockOpnameScreen extends StatefulWidget {
  const BusinessStockOpnameScreen({super.key});

  @override
  State<BusinessStockOpnameScreen> createState() =>
      _BusinessStockOpnameScreenState();
}

class _BusinessStockOpnameScreenState extends State<BusinessStockOpnameScreen> {
  List<StockItem> _items = [];
  bool _isLoading = true;
  StockCategory? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStock();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStock() async {
    setState(() => _isLoading = true);
    final list = await BusinessStockService.loadStockItems();
    if (mounted) {
      setState(() {
        _items = list;
        _isLoading = false;
      });
    }
  }

  List<StockItem> get _filteredItems {
    return _items.where((item) {
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchName = item.name.toLowerCase().contains(query);
        final matchSupplier = item.supplier.toLowerCase().contains(query);
        final matchNotes = item.notes.toLowerCase().contains(query);
        return matchName || matchSupplier || matchNotes;
      }
      return true;
    }).toList();
  }

  void _showRestockDialog(StockItem item) {
    final qtyController = TextEditingController();
    final noteController = TextEditingController(text: 'Restock bahan operasional');
    final baristaController = TextEditingController(text: 'Barista Utama');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BusinessTheme.cardElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(CupertinoIcons.plus_circle_fill, color: BusinessTheme.goldAccent, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Restock: ${item.name}',
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stok saat ini: ${item.formattedQty} (Min: ${item.minQty.toInt()} ${item.unit})',
              style: const TextStyle(color: BusinessTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Jumlah Tambahan (${item.unit})',
                labelStyle: const TextStyle(color: BusinessTheme.goldAccent, fontSize: 13),
                hintText: 'Contoh: 1000',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: BusinessTheme.bgSurface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Catatan Pengiriman / Supplier',
                labelStyle: const TextStyle(color: BusinessTheme.textMuted, fontSize: 12),
                filled: true,
                fillColor: BusinessTheme.bgSurface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              final qty = double.tryParse(qtyController.text) ?? 0.0;
              if (qty > 0) {
                Navigator.pop(ctx);
                await BusinessStockService.restockItem(
                  itemId: item.id,
                  addQty: qty,
                  barista: baristaController.text,
                  note: noteController.text,
                );
                _loadStock();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BusinessTheme.goldAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan Restock', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showUsageDialog(StockItem item) {
    final qtyController = TextEditingController();
    final noteController = TextEditingController();
    final baristaController = TextEditingController(text: 'Barista Utama');
    bool isWaste = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: BusinessTheme.cardElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                isWaste ? CupertinoIcons.trash_fill : CupertinoIcons.minus_circle_fill,
                color: isWaste ? BusinessTheme.statusDanger : BusinessTheme.amberWarm,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isWaste ? 'Catat Waste: ${item.name}' : 'Pemakaian: ${item.name}',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stok saat ini: ${item.formattedQty}',
                style: const TextStyle(color: BusinessTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Pemakaian Bar'),
                    selected: !isWaste,
                    onSelected: (val) => setDialogState(() => isWaste = !val),
                    selectedColor: BusinessTheme.amberWarm.withValues(alpha: 0.3),
                    labelStyle: TextStyle(
                      color: !isWaste ? BusinessTheme.amberWarm : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Waste / Rusak / Tumpah'),
                    selected: isWaste,
                    onSelected: (val) => setDialogState(() => isWaste = val),
                    selectedColor: BusinessTheme.statusDanger.withValues(alpha: 0.3),
                    labelStyle: TextStyle(
                      color: isWaste ? BusinessTheme.statusDanger : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Jumlah (${item.unit})',
                  labelStyle: TextStyle(
                    color: isWaste ? BusinessTheme.statusDanger : BusinessTheme.amberWarm,
                    fontSize: 13,
                  ),
                  hintText: 'Contoh: 250',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: BusinessTheme.bgSurface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Alasan / Catatan Barista',
                  hintText: isWaste ? 'Susu overheat / biji dial-in' : 'Pemakaian batch seduh',
                  labelStyle: const TextStyle(color: BusinessTheme.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: BusinessTheme.bgSurface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                final qty = double.tryParse(qtyController.text) ?? 0.0;
                if (qty > 0) {
                  Navigator.pop(ctx);
                  await BusinessStockService.recordUsage(
                    itemId: item.id,
                    deductQty: qty,
                    barista: baristaController.text,
                    note: noteController.text,
                    isWaste: isWaste,
                  );
                  _loadStock();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isWaste ? BusinessTheme.statusDanger : BusinessTheme.amberWarm,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isWaste ? 'Catat Waste' : 'Simpan Pemakaian',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogsModal() async {
    final logs = await BusinessStockService.loadRecentLogs();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: BusinessTheme.modalBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(CupertinoIcons.clock_fill, color: BusinessTheme.goldAccent, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Riwayat Mutasi & Opname Stok',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: logs.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada catatan mutasi stok.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollCtrl,
                        itemCount: logs.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: BusinessTheme.borderSubtle),
                        itemBuilder: (ctx, idx) {
                          final log = logs[idx];
                          final isAdd = log.isAddition;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (isAdd
                                            ? BusinessTheme.statusSuccess
                                            : BusinessTheme.amberWarm)
                                        .withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isAdd
                                        ? CupertinoIcons.arrow_down_left
                                        : CupertinoIcons.arrow_up_right,
                                    size: 16,
                                    color: isAdd
                                        ? BusinessTheme.statusSuccess
                                        : BusinessTheme.amberWarm,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        log.itemName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${log.actionType} • ${log.barista} • ${DateFormat('dd/MM HH:mm').format(log.timestamp)}',
                                        style: const TextStyle(
                                          color: BusinessTheme.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                      if (log.note.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          log.note,
                                          style: const TextStyle(
                                            color: BusinessTheme.textSecondary,
                                            fontSize: 11,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Text(
                                  log.formattedDelta,
                                  style: TextStyle(
                                    color: isAdd
                                        ? BusinessTheme.statusSuccess
                                        : BusinessTheme.amberWarm,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lowStockCount = BusinessStockService.getLowStockAlertCount(_items);
    final capacity = BusinessStockService.calculateTotalBrewCapacity(_items);

    return Scaffold(
      backgroundColor: BusinessTheme.bgDark,
      appBar: AppBar(
        backgroundColor: BusinessTheme.bgSurface,
        elevation: 0,
        title: const Row(
          children: [
            Icon(CupertinoIcons.archivebox_fill, color: BusinessTheme.goldAccent, size: 20),
            SizedBox(width: 8),
            Text(
              'Stock Opname Bahan Baku',
              style: TextStyle(
                color: BusinessTheme.textLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.time, color: BusinessTheme.goldAccent),
            tooltip: 'Riwayat Log Opname',
            onPressed: _showLogsModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: BusinessTheme.goldAccent),
            )
          : RefreshIndicator(
              color: BusinessTheme.goldAccent,
              backgroundColor: BusinessTheme.cardBg,
              onRefresh: _loadStock,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. KPI Top Summary Card
                          _buildSummaryRow(_items.length, lowStockCount, capacity),
                          const SizedBox(height: 16),

                          // 2. Search Box
                          _buildSearchBar(),
                          const SizedBox(height: 12),

                          // 3. Category Filter Chips
                          _buildCategoryFilters(),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'DAFTAR BAHAN BAKU (${_filteredItems.length})',
                                style: const TextStyle(
                                  color: BusinessTheme.goldAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                _selectedCategory == null
                                    ? 'Semua Kategori'
                                    : _selectedCategory!.label,
                                style: const TextStyle(
                                  color: BusinessTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Stock Items Sliver List
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: _filteredItems.isEmpty
                        ? const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  'Tidak ada bahan baku yang cocok.',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, idx) => _buildStockCard(_filteredItems[idx]),
                              childCount: _filteredItems.length,
                            ),
                          ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 40),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryRow(int totalItems, int lowCount, int capacity) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BusinessTheme.cardDecoration(hasGoldGlow: true),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            label: 'Total Bahan',
            value: '$totalItems Item',
            color: Colors.white,
          ),
          Container(width: 1, height: 32, color: BusinessTheme.borderSubtle),
          _buildSummaryItem(
            label: 'Stok Menipis',
            value: '$lowCount Item',
            color: lowCount > 0 ? BusinessTheme.statusWarning : BusinessTheme.statusSuccess,
          ),
          Container(width: 1, height: 32, color: BusinessTheme.borderSubtle),
          _buildSummaryItem(
            label: 'Kapasitas Seduh',
            value: '~$capacity Cup',
            color: BusinessTheme.goldAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: BusinessTheme.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: BusinessTheme.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BusinessTheme.borderSubtle),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white, fontSize: 13.5),
        decoration: InputDecoration(
          hintText: 'Cari nama bahan, biji kopi, susu, sirup...',
          hintStyle: const TextStyle(color: BusinessTheme.textMuted, fontSize: 13),
          prefixIcon: const Icon(CupertinoIcons.search, color: BusinessTheme.goldAccent, size: 18),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(CupertinoIcons.clear_circled_solid, color: Colors.white54, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (val) => setState(() => _searchQuery = val),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: const Text('Semua'),
              selected: _selectedCategory == null,
              onSelected: (_) => setState(() => _selectedCategory = null),
              selectedColor: BusinessTheme.goldAccent,
              labelStyle: TextStyle(
                color: _selectedCategory == null ? Colors.black : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
              ),
              backgroundColor: BusinessTheme.bgSurface,
            ),
          ),
          ...StockCategory.values.map((cat) {
            final isSelected = _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                avatar: Icon(
                  cat.icon,
                  size: 14,
                  color: isSelected ? Colors.black : BusinessTheme.goldAccent,
                ),
                label: Text(cat.label),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedCategory = cat),
                selectedColor: BusinessTheme.goldAccent,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                ),
                backgroundColor: BusinessTheme.bgSurface,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStockCard(StockItem item) {
    final status = item.status;
    final isAlert = status == StockStatus.low || status == StockStatus.outOfStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BusinessTheme.cardDecoration(
        borderColor: isAlert
            ? status.color.withValues(alpha: 0.5)
            : BusinessTheme.borderSubtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Category Icon, Name, Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: BusinessTheme.goldAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.category.icon, color: BusinessTheme.goldAccent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.supplier} • Min: ${item.minQty.toInt()} ${item.unit}',
                      style: const TextStyle(
                        color: BusinessTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: status.color, width: 0.8),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    color: status.color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quantity Level & Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sisa Stok: ${item.formattedQty}',
                style: const TextStyle(
                  color: BusinessTheme.textLight,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '~${item.estimatedServingsRemaining} porsi saji',
                style: const TextStyle(
                  color: BusinessTheme.goldAccent,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.stockPercentage,
              minHeight: 6,
              backgroundColor: BusinessTheme.borderSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(status.color),
            ),
          ),
          if (item.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.notes,
              style: const TextStyle(
                color: BusinessTheme.textSecondary,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Action Buttons: [+ Restock] and [- Catat Pemakaian / Waste]
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRestockDialog(item),
                  icon: const Icon(CupertinoIcons.plus_circle, size: 14),
                  label: const Text('Restock', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BusinessTheme.goldAccent,
                    side: const BorderSide(color: BusinessTheme.goldAccent, width: 1.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showUsageDialog(item),
                  icon: const Icon(CupertinoIcons.minus_circle, size: 14),
                  label: const Text('Pakai / Waste', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: BusinessTheme.borderHighlighted, width: 1.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
