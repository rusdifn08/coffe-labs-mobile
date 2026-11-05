import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business_stock_models.dart';

class BusinessStockService {
  static const String _stockPrefsKey = 'coffe_labs_business_stock_items_v1';
  static const String _logsPrefsKey = 'coffe_labs_business_stock_logs_v1';

  static List<StockItem>? _memoryCache;
  static List<StockMovementLog>? _logsCache;

  /// Daftar stok awal realistis kafe specialty coffee
  static List<StockItem> getInitialSeedStock() {
    final now = DateTime.now();
    return [
      // 1. BIJI KOPI
      StockItem(
        id: 'stock_bean_house_blend',
        name: 'House Blend Espresso (70% Arabica / 30% Robusta)',
        category: StockCategory.beans,
        currentQty: 3200,
        minQty: 1000,
        unit: 'g',
        costPerUnit: 180,
        supplier: 'Coffee Labs Roastery',
        usagePerServing: 18.0,
        lastUpdated: now,
        notes: 'Roast Date: 4 hari lalu • Profil Dark-Medium Chocolate Nougat',
      ),
      StockItem(
        id: 'stock_bean_ethiopia_v60',
        name: 'Single Origin Ethiopia Yirgacheffe Washed',
        category: StockCategory.beans,
        currentQty: 850,
        minQty: 400,
        unit: 'g',
        costPerUnit: 350,
        supplier: 'Specialty Green Importer',
        usagePerServing: 15.0,
        lastUpdated: now,
        notes: 'Notes: Jasmine, Bergamot, Peach • Filter Roast',
      ),
      StockItem(
        id: 'stock_bean_geisha_panama',
        name: 'Geisha Panama Boquete Natural Reserve',
        category: StockCategory.beans,
        currentQty: 280,
        minQty: 200,
        unit: 'g',
        costPerUnit: 1200,
        supplier: 'Hacienda La Esmeralda',
        usagePerServing: 15.0,
        lastUpdated: now,
        notes: 'Limited Competition Lot #04 • Manual Pour Over Only',
      ),

      // 2. SUSU & DAIRY
      StockItem(
        id: 'stock_milk_pasteurized',
        name: 'Fresh Milk Pasteurisasi (Greenfields Barista)',
        category: StockCategory.dairy,
        currentQty: 4500,
        minQty: 2000,
        unit: 'ml',
        costPerUnit: 25,
        supplier: 'Greenfields Distribution',
        usagePerServing: 150.0,
        lastUpdated: now,
        notes: 'Chiller temperature 3°C • Expired 8 hari ke depan',
      ),
      StockItem(
        id: 'stock_milk_oat',
        name: 'Oat Milk Barista Edition (Oatside)',
        category: StockCategory.dairy,
        currentQty: 1400,
        minQty: 1500, // Sengaja menipis agar alert low-stock menyala informatif
        unit: 'ml',
        costPerUnit: 42,
        supplier: 'Oatside Direct',
        usagePerServing: 150.0,
        lastUpdated: now,
        notes: 'Bahan favorit Iced Oat Flat White & Caramel Macchiato',
      ),
      StockItem(
        id: 'stock_dairy_condensed',
        name: 'Krimer Kental Manis Carnation Premium',
        category: StockCategory.dairy,
        currentQty: 1200,
        minQty: 500,
        unit: 'ml',
        costPerUnit: 18,
        supplier: 'Mitra Sembako Grosir',
        usagePerServing: 30.0,
        lastUpdated: now,
        notes: 'Komposisi Kopi Susu Gula Aren & Vietnam Drip',
      ),

      // 3. SIRUP & PERISA
      StockItem(
        id: 'stock_syrup_vanilla',
        name: 'Artisan Vanilla Madagascar Pure Extract Syrup',
        category: StockCategory.syrup,
        currentQty: 620,
        minQty: 250,
        unit: 'ml',
        costPerUnit: 80,
        supplier: 'DRiPP Flavour',
        usagePerServing: 20.0,
        lastUpdated: now,
        notes: 'Biji vanilla asli Madagascar tanpa pewarna buatan',
      ),
      StockItem(
        id: 'stock_syrup_hazelnut',
        name: 'Roasted Hazelnut Artisan Syrup',
        category: StockCategory.syrup,
        currentQty: 190,
        minQty: 250, // Sengaja menipis untuk visual status
        unit: 'ml',
        costPerUnit: 75,
        supplier: 'Monin Specialty',
        usagePerServing: 20.0,
        lastUpdated: now,
        notes: 'Sisa botol terakhir di bar counter',
      ),
      StockItem(
        id: 'stock_sauce_caramel',
        name: 'Salted Caramel Gourmet Sauce & Drizzle',
        category: StockCategory.syrup,
        currentQty: 380,
        minQty: 200,
        unit: 'ml',
        costPerUnit: 90,
        supplier: 'Torani Puremade',
        usagePerServing: 25.0,
        lastUpdated: now,
        notes: 'Topping pour over caramel & iced latte',
      ),

      // 4. PACKAGING & CUP
      StockItem(
        id: 'stock_cup_hot_8oz',
        name: 'Hot Paper Cup Double Wall 8oz + Lid Hitam',
        category: StockCategory.packaging,
        currentQty: 145,
        minQty: 50,
        unit: 'pcs',
        costPerUnit: 950,
        supplier: 'EcoCup Packaging',
        usagePerServing: 1.0,
        lastUpdated: now,
        notes: 'Food Grade Biodegradable PLA Coating',
      ),
      StockItem(
        id: 'stock_cup_iced_12oz',
        name: 'Iced Cup PET Tebal 12oz + Strawless Lid',
        category: StockCategory.packaging,
        currentQty: 210,
        minQty: 60,
        unit: 'pcs',
        costPerUnit: 850,
        supplier: 'EcoCup Packaging',
        usagePerServing: 1.0,
        lastUpdated: now,
        notes: 'Khusus pesanan take away es kopi',
      ),
      StockItem(
        id: 'stock_paper_filter_v60',
        name: 'Paper Filter Hario V60-02 White Box',
        category: StockCategory.packaging,
        currentQty: 85,
        minQty: 30,
        unit: 'lembar',
        costPerUnit: 450,
        supplier: 'Hario Indonesia Official',
        usagePerServing: 1.0,
        lastUpdated: now,
        notes: 'Tabung akrilik bar seduh manual brew',
      ),
    ];
  }

  static List<StockMovementLog> getInitialSeedLogs() {
    final now = DateTime.now();
    return [
      StockMovementLog(
        id: 'log_01',
        stockItemId: 'stock_bean_house_blend',
        itemName: 'House Blend Espresso (70/30)',
        deltaQty: 2000,
        unit: 'g',
        actionType: 'Restock',
        barista: 'Barista Utama',
        timestamp: now.subtract(const Duration(hours: 4)),
        note: 'Restock 2 pack 1kg fresh roast dari Roastery',
      ),
      StockMovementLog(
        id: 'log_02',
        stockItemId: 'stock_milk_pasteurized',
        itemName: 'Fresh Milk Pasteurisasi',
        deltaQty: -1500,
        unit: 'ml',
        actionType: 'Pemakaian',
        barista: 'Barista Shift Pagi',
        timestamp: now.subtract(const Duration(hours: 2)),
        note: 'Pemakaian 10 cup latte & cappuccino rush morning',
      ),
      StockMovementLog(
        id: 'log_03',
        stockItemId: 'stock_milk_oat',
        itemName: 'Oat Milk Barista Edition',
        deltaQty: -300,
        unit: 'ml',
        actionType: 'Waste/Tumpah',
        barista: 'Barista Shift Pagi',
        timestamp: now.subtract(const Duration(minutes: 50)),
        note: 'Kelebihan dial-in steaming pitcher pertama',
      ),
    ];
  }

  /// Memuat daftar stok lengkap (dari SharedPreferences atau memory cache)
  static Future<List<StockItem>> loadStockItems() async {
    if (_memoryCache != null) return List.unmodifiable(_memoryCache!);

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_stockPrefsKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        final List decoded = json.decode(rawJson);
        _memoryCache = decoded.map((e) => StockItem.fromJson(e)).toList();
        return List.unmodifiable(_memoryCache!);
      }
    } catch (e) {
      debugPrint('Error loading stock items: $e');
    }

    _memoryCache = getInitialSeedStock();
    await _persistStockItems();
    return List.unmodifiable(_memoryCache!);
  }

  static Future<void> _persistStockItems() async {
    if (_memoryCache == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = json.encode(_memoryCache!.map((e) => e.toJson()).toList());
      await prefs.setString(_stockPrefsKey, raw);
    } catch (e) {
      debugPrint('Error persisting stock: $e');
    }
  }

  /// Catat penambahan stok (Restock)
  static Future<bool> restockItem({
    required String itemId,
    required double addQty,
    required String barista,
    required String note,
  }) async {
    final items = await loadStockItems();
    final index = items.indexWhere((i) => i.id == itemId);
    if (index == -1) return false;

    final current = items[index];
    final updated = current.copyWith(
      currentQty: current.currentQty + addQty,
      lastUpdated: DateTime.now(),
    );

    _memoryCache![index] = updated;
    await _persistStockItems();

    await _recordLog(StockMovementLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      stockItemId: itemId,
      itemName: current.name,
      deltaQty: addQty,
      unit: current.unit,
      actionType: 'Restock',
      barista: barista,
      timestamp: DateTime.now(),
      note: note.isEmpty ? 'Penambahan stok inventaris' : note,
    ));

    return true;
  }

  /// Catat pengurangan stok (Pemakaian rutin atau Waste/Tumpah)
  static Future<bool> recordUsage({
    required String itemId,
    required double deductQty,
    required String barista,
    required String note,
    bool isWaste = false,
  }) async {
    final items = await loadStockItems();
    final index = items.indexWhere((i) => i.id == itemId);
    if (index == -1) return false;

    final current = items[index];
    final newQty = (current.currentQty - deductQty).clamp(0.0, 9999999.0);
    final updated = current.copyWith(
      currentQty: newQty,
      lastUpdated: DateTime.now(),
    );

    _memoryCache![index] = updated;
    await _persistStockItems();

    await _recordLog(StockMovementLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      stockItemId: itemId,
      itemName: current.name,
      deltaQty: -deductQty,
      unit: current.unit,
      actionType: isWaste ? 'Waste/Tumpah' : 'Pemakaian',
      barista: barista,
      timestamp: DateTime.now(),
      note: note.isEmpty ? (isWaste ? 'Pencatatan waste barista' : 'Pemakaian operasional bar') : note,
    ));

    return true;
  }

  /// Perbarui parameter item stok (misal minQty, nama, harga satuan)
  static Future<bool> updateItem(StockItem updated) async {
    final items = await loadStockItems();
    final index = items.indexWhere((i) => i.id == updated.id);
    if (index == -1) return false;

    _memoryCache![index] = updated.copyWith(lastUpdated: DateTime.now());
    await _persistStockItems();
    return true;
  }

  /// Memuat riwayat pergerakan stok
  static Future<List<StockMovementLog>> loadRecentLogs() async {
    if (_logsCache != null) return List.unmodifiable(_logsCache!);

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_logsPrefsKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        final List decoded = json.decode(rawJson);
        _logsCache = decoded.map((e) => StockMovementLog.fromJson(e)).toList();
        return List.unmodifiable(_logsCache!);
      }
    } catch (e) {
      debugPrint('Error loading stock logs: $e');
    }

    _logsCache = getInitialSeedLogs();
    await _persistLogs();
    return List.unmodifiable(_logsCache!);
  }

  static Future<void> _recordLog(StockMovementLog log) async {
    final logs = await loadRecentLogs();
    final mutable = List<StockMovementLog>.from(logs);
    mutable.insert(0, log);
    if (mutable.length > 50) {
      mutable.removeRange(50, mutable.length);
    }
    _logsCache = mutable;
    await _persistLogs();
  }

  static Future<void> _persistLogs() async {
    if (_logsCache == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = json.encode(_logsCache!.map((e) => e.toJson()).toList());
      await prefs.setString(_logsPrefsKey, raw);
    } catch (e) {
      debugPrint('Error persisting stock logs: $e');
    }
  }

  /// Menghitung estimasi total cangkir kopi yang bisa disajikan hari ini
  /// berdasarkan bahan pembatas utama (Biji Kopi House Blend & Cup)
  static int calculateTotalBrewCapacity(List<StockItem> items) {
    int beanCapacity = 0;
    int cupCapacity = 0;

    for (final item in items) {
      if (item.category == StockCategory.beans) {
        beanCapacity += item.estimatedServingsRemaining;
      } else if (item.category == StockCategory.packaging && item.unit == 'pcs') {
        cupCapacity += item.currentQty.toInt();
      }
    }

    if (beanCapacity == 0 && cupCapacity == 0) return 0;
    if (cupCapacity == 0) return beanCapacity;
    if (beanCapacity == 0) return cupCapacity;
    return beanCapacity < cupCapacity ? beanCapacity : cupCapacity;
  }

  /// Menghitung jumlah item yang stoknya menipis atau habis
  static int getLowStockAlertCount(List<StockItem> items) {
    return items.where((i) => i.status == StockStatus.low || i.status == StockStatus.outOfStock).length;
  }
}
