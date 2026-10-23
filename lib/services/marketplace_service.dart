import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/roastery_catalog.dart';
import '../models/marketplace_model.dart';

class MarketplaceService extends ChangeNotifier {
  static final MarketplaceService instance = MarketplaceService._internal();

  MarketplaceService._internal() {
    _initCatalog();
    _loadCartAndOrders();
  }

  static const String _keyCart = 'coffee_marketplace_cart_items';
  static const String _keyOrders = 'coffee_marketplace_orders_list';

  final List<MarketplaceProduct> _allProducts = [];
  final Map<String, CartItem> _cartMap = {};
  final List<MarketplaceOrder> _orders = [];

  String? _appliedVoucher;
  int _voucherDiscount = 0;

  List<MarketplaceProduct> get products => List.unmodifiable(_allProducts);
  List<CartItem> get cartItems => _cartMap.values.toList();
  List<MarketplaceOrder> get orders => List.unmodifiable(_orders);
  int get cartCount => _cartMap.values.fold(0, (sum, item) => sum + item.quantity);
  String? get appliedVoucher => _appliedVoucher;
  int get voucherDiscount => _voucherDiscount;

  int get cartSubtotal => _cartMap.values.fold(0, (sum, item) => sum + item.totalPrice);

  void _initCatalog() {
    final List<MarketplaceProduct> compiled = [];

    // Parse all roasteries from RoasteryCatalog
    for (final roastery in RoasteryCatalog.list) {
      for (final lineup in roastery.lineups) {
        final id = '${roastery.id}_${lineup.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';

        // Parse prices (remove 'Rp' and '.')
        final p100 = _parsePrice(lineup.price100g, defaultVal: 75000);
        final p200 = _parsePrice(lineup.price200g, defaultVal: 145000);
        final p250 = (p200 * 1.22).round();

        final notes = lineup.tastingNotes
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

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
            tastingNotes: notes.isNotEmpty ? notes : ['Chocolate', 'Citrus', 'Sweet Sugar'],
            price100g: p100,
            price200g: p200,
            price250g: p250,
            rating: roastery.rating,
            reviewCount: 35 + (roastery.name.length * 3),
            stock: 25 + (roastery.name.length % 20),
            roastDate: 'Roasted within 48h (Fresh)',
            badge: lineup.badge ?? (roastery.rating >= 4.9 ? 'Top Rated' : null),
            imageUrl: roastery.imageUrl,
            altitudeMasl: '1,350 - 1,750 MASL',
            producer: '${roastery.name} Artisan Lineup',
            recommendedMethod: 'V60 / Kalita / Aeropress (1:15 - 1:16)',
            description: '${roastery.description} Profil sangrai ${lineup.roastProfile} dengan proses ${lineup.process} yang menonjolkan karakter rasa ${lineup.tastingNotes}. Sangat direkomendasikan untuk pour-over maupun espresso.',
          ),
        );
      }
    }

    _allProducts.clear();
    _allProducts.addAll(compiled);
  }

  int _parsePrice(String text, {required int defaultVal}) {
    try {
      final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.isNotEmpty) {
        return int.parse(digits);
      }
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

    _recalculateVoucher();
    await _saveCart();
    notifyListeners();
  }

  Future<void> updateQuantity(String cartKey, int delta) async {
    if (_cartMap.containsKey(cartKey)) {
      final item = _cartMap[cartKey]!;
      item.quantity += delta;
      if (item.quantity <= 0) {
        _cartMap.remove(cartKey);
      }
      _recalculateVoucher();
      await _saveCart();
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String cartKey) async {
    _cartMap.remove(cartKey);
    _recalculateVoucher();
    await _saveCart();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _cartMap.clear();
    _appliedVoucher = null;
    _voucherDiscount = 0;
    await _saveCart();
    notifyListeners();
  }

  // ==========================================
  // PROMO & VOUCHERS
  // ==========================================
  bool applyVoucher(String code) {
    final clean = code.trim().toUpperCase();
    if (clean == 'COFFEEFIRST') {
      _appliedVoucher = 'COFFEEFIRST (15% OFF)';
      _recalculateVoucher();
      notifyListeners();
      return true;
    } else if (clean == 'BARISTA20') {
      _appliedVoucher = 'BARISTA20 (20% OFF)';
      _recalculateVoucher();
      notifyListeners();
      return true;
    } else if (clean == 'FREESHIP') {
      _appliedVoucher = 'FREESHIP (Free Courier Delivery)';
      _recalculateVoucher();
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeVoucher() {
    _appliedVoucher = null;
    _voucherDiscount = 0;
    notifyListeners();
  }

  void _recalculateVoucher() {
    if (_appliedVoucher == null) {
      _voucherDiscount = 0;
      return;
    }
    if (_appliedVoucher!.contains('15%')) {
      _voucherDiscount = (cartSubtotal * 0.15).round();
    } else if (_appliedVoucher!.contains('20%')) {
      _voucherDiscount = (cartSubtotal * 0.20).round();
    } else if (_appliedVoucher!.contains('FREESHIP')) {
      _voucherDiscount = 18000; // standard delivery fee
    }
  }

  // ==========================================
  // CHECKOUT & ORDERS
  // ==========================================
  Future<MarketplaceOrder> placeOrder({
    required String recipientName,
    required String phoneNumber,
    required String shippingAddress,
    required String courierName,
    required int shippingFee,
    required String paymentMethod,
  }) async {
    final randId = 1000 + math.Random().nextInt(9000);
    final orderId = 'CL-${DateTime.now().year}-$randId';

    int finalShipping = shippingFee;
    if (_appliedVoucher != null && _appliedVoucher!.contains('FREESHIP')) {
      finalShipping = 0;
    }

    final total = math.max(0, cartSubtotal + finalShipping - _voucherDiscount);

    final order = MarketplaceOrder(
      orderId: orderId,
      createdAt: DateTime.now(),
      items: cartItems,
      subtotal: cartSubtotal,
      shippingFee: finalShipping,
      discount: _voucherDiscount,
      voucherCode: _appliedVoucher,
      total: total,
      recipientName: recipientName,
      phoneNumber: phoneNumber,
      shippingAddress: shippingAddress,
      courierName: courierName,
      paymentMethod: paymentMethod,
      status: 'Confirmed & Roasting',
      estimatedDelivery: courierName.contains('Instant') ? 'Today (3-4 Hours)' : '2-3 Business Days',
    );

    _orders.insert(0, order);
    await clearCart();
    await _saveOrders();
    notifyListeners();

    return order;
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
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading marketplace data: $e');
    }
  }
}
