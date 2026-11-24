import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/roastery_catalog.dart';
import '../features/marketplace/utils/coffee_bag_image_resolver.dart';
import '../features/marketplace/utils/qris_payload_builder.dart';
import '../models/marketplace_model.dart';

class MarketplaceService extends ChangeNotifier {
  static final MarketplaceService instance = MarketplaceService._internal();

  MarketplaceService._internal() {
    _initCatalog();
    _loadCartAndOrders();
  }

  static const String _keyCart = 'coffee_marketplace_cart_items';
  static const String _keyOrders = 'coffee_marketplace_orders_list';
  static const String _keyFavorites = 'coffee_marketplace_favorite_ids_v1';

  final List<MarketplaceProduct> _allProducts = [];
  final Map<String, CartItem> _cartMap = {};
  final List<MarketplaceOrder> _orders = [];
  final Set<String> _favoriteIds = {};

  List<MarketplaceProduct> get products => List.unmodifiable(_allProducts);
  List<MarketplaceProduct> get flashSaleProducts => const [];
  List<CartItem> get cartItems => _cartMap.values.toList();
  List<MarketplaceOrder> get orders => List.unmodifiable(_orders);
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  List<MarketplaceProduct> get favoriteProducts =>
      _allProducts.where((p) => _favoriteIds.contains(p.id)).toList(growable: false);
  int get favoriteCount => _favoriteIds.length;
  bool isFavorite(String productId) => _favoriteIds.contains(productId);
  int get cartCount =>
      _cartMap.values.fold(0, (sum, item) => sum + item.quantity);
  String? get appliedVoucher => null;
  int get voucherDiscount => 0;
  int get cartSubtotal =>
      _cartMap.values.fold(0, (sum, item) => sum + item.totalPrice);

  String _inferCategory(String name, String origin, String process) {
    final combined = '$name $origin $process'.toLowerCase();
    if (combined.contains('wine') ||
        combined.contains('anaerob') ||
        combined.contains('carbonic') ||
        combined.contains('koji')) {
      return 'Wine / Anaerob';
    }
    if (combined.contains('espresso')) {
      return 'Espresso';
    }
    if (combined.contains('blend') || combined.contains('susu')) {
      return 'House Blend';
    }
    if (combined.contains('filter') || combined.contains('gesha') || combined.contains('v60')) {
      return 'Filter V60';
    }
    return 'Single Origin';
  }

  void _initCatalog() {
    final List<MarketplaceProduct> compiled = [];
    var idx = 0;

    for (final roastery in RoasteryCatalog.list) {
      for (final lineup in roastery.lineups) {
        final slug = lineup.name
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '_');
        final id = '${roastery.id}_$slug';

        final p100 = _parsePrice(lineup.price100g, defaultVal: 75000);
        final p200 = _parsePrice(lineup.price200g, defaultVal: 145000);
        final p250 = (p200 * 1.22).round();

        final notes = lineup.tastingNotes
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        // Gunakan Resolver ketat agar potret barista (avatars/covers/*) TIDAK pernah dipakai!
        final assetMeta = CoffeeBagImageResolver.resolve(
          roasteryId: roastery.id,
          coffeeName: lineup.name,
          explicitBagUrl: lineup.bagImageUrl,
        );

        final sold = 180 + ((roastery.name.length * 73 + idx * 41) % 2400);

        compiled.add(
          MarketplaceProduct(
            id: id,
            name: lineup.name,
            roasteryId: roastery.id,
            roasteryName: roastery.name,
            roasteryCity: roastery.location,
            origin: lineup.origin,
            roastProfile: lineup.roastProfile,
            variety: lineup.variety,
            process: lineup.process,
            tastingNotes: notes.isNotEmpty
                ? notes
                : const ['Chocolate', 'Citrus', 'Caramel'],
            price100g: p100,
            price200g: p200,
            price250g: p250,
            rating: roastery.rating,
            reviewCount: 45 + (roastery.name.length * 4),
            stock: 25 + (roastery.name.length % 20),
            roastDate: 'Fresh Roast < 48 Jam',
            badge: lineup.badge ?? (roastery.rating >= 4.9 ? 'Terlaris' : null),
            imageUrl: assetMeta.imageUrl,
            roasteryLogoUrl: assetMeta.roasteryLogoAsset,
            hasVerifiedBagPhoto: assetMeta.isVerifiedPhoto,
            galleryImages: assetMeta.isVerifiedPhoto
                ? [assetMeta.imageUrl]
                : const [],
            altitudeMasl: '1,350 - 1,750 MASL',
            producer: '${roastery.name} Artisan Lineup',
            recommendedMethod:
                lineup.recommendedBrewMethod ?? 'V60 / Kalita / Aeropress (1:15)',
            description:
                '${roastery.description} Profil sangrai ${lineup.roastProfile} dengan proses ${lineup.process} menonjolkan ${lineup.tastingNotes}.',
            category: _inferCategory(lineup.name, lineup.origin, lineup.process),
            soldCount: sold,
            discountPct: 0,
            originalPrice200g: null,
            isMallRoastery: true,
            isFlashSale: false,
            flashSaleStockLeft: 0,
            createdAt: DateTime(2026, 11, 19).subtract(Duration(hours: idx * 3)),
          ),
        );
        idx++;
      }
    }

    // Tambahkan kategori Alat Seduh untuk melengkapi menu ikon Shopee
    compiled.addAll([
      MarketplaceProduct(
        id: 'equip_hario_v60_02_ceramic',
        name: 'Hario V60 Ceramic Dripper 02 Putih',
        roasteryId: 'otten_coffee',
        roasteryName: 'Otten Coffee Gear',
        roasteryCity: 'Medan & Jakarta',
        origin: 'Jepang (Original)',
        roastProfile: 'Alat Seduh',
        variety: 'Keramik Arita-Yaki',
        process: 'Pour-Over Filter',
        tastingNotes: const ['Clean Cup', 'Clarity Tinggi', 'Retensi Panas Stabil'],
        price100g: 315000,
        price200g: 315000,
        price250g: 385000,
        rating: 4.9,
        reviewCount: 420,
        stock: 18,
        roastDate: 'Garansi Resmi 1 Tahun',
        badge: 'Original',
        imageUrl: '',
        roasteryLogoUrl: 'assets/images/roasteries/otten_coffee.png',
        hasVerifiedBagPhoto: false,
        altitudeMasl: 'Kapasitas 1-4 Cups',
        producer: 'Hario Japan Official',
        recommendedMethod: 'Paper Filter V60 02',
        description:
            'Dripper keramik V60 ukuran 02 standar kompetisi dunia untuk ekstraksi clean & manis optimal.',
        category: 'Alat Seduh',
        soldCount: 1450,
        discountPct: 0,
        originalPrice200g: null,
        isMallRoastery: true,
        isFlashSale: false,
        flashSaleStockLeft: 0,
      ),
      MarketplaceProduct(
        id: 'equip_timemore_c3_esp_pro',
        name: 'Timemore Chestnut C3 ESP Pro Grinder',
        roasteryId: 'fugol_coffee',
        roasteryName: 'Coffee Labs Official Gear',
        roasteryCity: 'Jakarta Selatan',
        origin: 'S2C660 Stainless Burr',
        roastProfile: 'Alat Seduh',
        variety: '30 Klik/Putaran Presisi',
        process: 'Manual Grinder',
        tastingNotes: const ['Bisa Espresso', 'Bisa V60 Filter', 'Bodi Full CNC'],
        price100g: 980000,
        price200g: 980000,
        price250g: 1050000,
        rating: 4.9,
        reviewCount: 312,
        stock: 9,
        roastDate: 'Ready Stock',
        badge: 'Pilihan Barista',
        imageUrl: '',
        roasteryLogoUrl: 'assets/images/coffee_labs_emblem.png',
        hasVerifiedBagPhoto: false,
        altitudeMasl: 'Kapasitas 25g Hopper',
        producer: 'Timemore Authorized',
        recommendedMethod: 'Dial-In Espresso & Pour-Over',
        description:
            'Hand grinder baja presisi tinggi dengan penyesuaian mikro untuk espresso hingga V60.',
        category: 'Alat Seduh',
        soldCount: 890,
        discountPct: 0,
        originalPrice200g: null,
        isMallRoastery: true,
        isFlashSale: false,
        flashSaleStockLeft: 0,
      ),
    ]);

    _allProducts.clear();
    _allProducts.addAll(compiled);
  }

  int _parsePrice(String text, {required int defaultVal}) {
    try {
      final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.isNotEmpty) return int.parse(digits);
    } catch (_) {}
    return defaultVal;
  }

  // ==========================================
  // CART OPERATIONS
  // ==========================================
  Future<void> addToCart({
    required MarketplaceProduct product,
    required String bagSize,
    required String grindOption,
    int quantity = 1,
  }) async {
    final unitPrice = product.getPriceForSize(bagSize);
    final key = '${product.id}_${bagSize}_$grindOption';

    if (_cartMap.containsKey(key)) {
      _cartMap[key]!.quantity += quantity;
    } else {
      _cartMap[key] = CartItem(
        product: product,
        bagSize: bagSize,
        grindOption: grindOption,
        quantity: quantity,
        unitPrice: unitPrice,
      );
    }

    await _saveCart();
    notifyListeners();
  }

  Future<void> updateQuantity(String cartKey, int newQuantity) async {
    if (!_cartMap.containsKey(cartKey)) return;
    if (newQuantity <= 0) {
      _cartMap.remove(cartKey);
    } else {
      _cartMap[cartKey]!.quantity = newQuantity;
    }
    await _saveCart();
    notifyListeners();
  }

  Future<void> removeCartItem(String cartKey) async {
    _cartMap.remove(cartKey);
    await _saveCart();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _cartMap.clear();
    await _saveCart();
    notifyListeners();
  }

  Future<void> toggleFavorite(String productId) async {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyFavorites, _favoriteIds.toList());
    } catch (e) {
      debugPrint('Error saving marketplace favorites: $e');
    }
  }

  /// Sistem voucher dinonaktifkan secara permanen — harga transparan langsung dari roastery.
  bool applyVoucher(String code) => false;

  void removeVoucher() {}

  // ==========================================
  // CHECKOUT QRIS-ONLY & ORDERS
  // ==========================================
  Future<MarketplaceOrder> createQrisOrder({
    required String recipientName,
    required String phoneNumber,
    required String shippingAddress,
    required String courierName,
    required int shippingFee,
  }) async {
    final randId = 1000 + math.Random().nextInt(9000);
    final orderId = 'CL-${DateTime.now().year}-$randId';
    final qrisRef = 'QRIS-${DateTime.now().year}-$randId';

    final finalShipping = shippingFee;
    final total = math.max(0, cartSubtotal + finalShipping);
    final qrPayload = MarketplaceQrisPayloadBuilder.buildDynamicPayload(
      orderCode: orderId,
      totalIdr: total,
    );

    final order = MarketplaceOrder(
      orderId: orderId,
      createdAt: DateTime.now(),
      items: List<CartItem>.from(cartItems),
      subtotal: cartSubtotal,
      shippingFee: finalShipping,
      discount: 0,
      voucherCode: null,
      total: total,
      recipientName: recipientName,
      phoneNumber: phoneNumber,
      shippingAddress: shippingAddress,
      courierName: courierName,
      paymentMethod: 'QRIS',
      paymentStatus: 'PENDING_QRIS',
      qrisReference: qrisRef,
      qrisPayload: qrPayload,
      status: 'Menunggu Pembayaran QRIS',
      estimatedDelivery: courierName.contains('Instant')
          ? 'Hari Ini (3-4 Jam)'
          : '2-3 Hari Kerja',
    );

    _orders.insert(0, order);
    await _saveOrders();
    notifyListeners();
    return order;
  }

  Future<MarketplaceOrder> confirmQrisOrderPayment(String orderId) async {
    final idx = _orders.indexWhere((o) => o.orderId == orderId);
    MarketplaceOrder finalized;
    if (idx != -1) {
      finalized = _orders[idx].copyWith(
        paymentStatus: 'PAID',
        status: 'Confirmed & Roasting',
        paidAt: DateTime.now(),
      );
      _orders[idx] = finalized;
    } else {
      finalized = MarketplaceOrder(
        orderId: orderId,
        createdAt: DateTime.now(),
        items: const [],
        subtotal: 0,
        shippingFee: 0,
        discount: 0,
        total: 0,
        recipientName: '-',
        phoneNumber: '-',
        shippingAddress: '-',
        courierName: '-',
        paymentMethod: 'QRIS',
        paymentStatus: 'PAID',
        paidAt: DateTime.now(),
        status: 'Confirmed & Roasting',
      );
    }
    await clearCart();
    await _saveOrders();
    notifyListeners();
    return finalized;
  }

  /// Backwards-compatible wrapper yang selalu memaksa metode QRIS.
  Future<MarketplaceOrder> placeOrder({
    required String recipientName,
    required String phoneNumber,
    required String shippingAddress,
    required String courierName,
    required int shippingFee,
    String paymentMethod = 'QRIS',
  }) async {
    if (paymentMethod.trim().toUpperCase() != 'QRIS') {
      throw ArgumentError('Pembayaran marketplace saat ini hanya mendukung QRIS.');
    }
    final pending = await createQrisOrder(
      recipientName: recipientName,
      phoneNumber: phoneNumber,
      shippingAddress: shippingAddress,
      courierName: courierName,
      shippingFee: shippingFee,
    );
    return confirmQrisOrderPayment(pending.orderId);
  }

  // ==========================================
  // PERSISTENCE
  // ==========================================
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _cartMap.values.map((i) => i.toJson()).toList();
      await prefs.setString(_keyCart, jsonEncode(list));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _orders.map((o) => o.toJson()).toList();
      await prefs.setString(_keyOrders, jsonEncode(list));
    } catch (e) {
      debugPrint('Error saving orders: $e');
    }
  }

  Future<void> _loadCartAndOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartRaw = prefs.getString(_keyCart);
      if (cartRaw != null) {
        final List<dynamic> decoded = jsonDecode(cartRaw);
        for (final itemJson in decoded) {
          final item = CartItem.fromJson(itemJson as Map<String, dynamic>);
          _cartMap[item.cartKey] = item;
        }
      }

      final ordersRaw = prefs.getString(_keyOrders);
      if (ordersRaw != null) {
        final List<dynamic> decoded = jsonDecode(ordersRaw);
        _orders.clear();
        for (final oJson in decoded) {
          _orders.add(MarketplaceOrder.fromJson(oJson as Map<String, dynamic>));
        }
      }

      final favList = prefs.getStringList(_keyFavorites);
      if (favList != null) {
        _favoriteIds
          ..clear()
          ..addAll(favList);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading marketplace data: $e');
    }
  }
}
