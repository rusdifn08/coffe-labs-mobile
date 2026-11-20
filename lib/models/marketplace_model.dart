class MarketplaceProduct {
  final String id;
  final String name;
  final String roasteryId;
  final String roasteryName;
  final String roasteryCity;
  final String origin;
  final String roastProfile;
  final String variety;
  final String process;
  final List<String> tastingNotes;
  final int price100g;
  final int price200g;
  final int price250g;
  final double rating;
  final int reviewCount;
  final int stock;
  final String roastDate;
  final String? badge;
  final String imageUrl;
  final String roasteryLogoUrl;
  final bool hasVerifiedBagPhoto;
  final List<String> galleryImages;
  final String altitudeMasl;
  final String producer;
  final String recommendedMethod;
  final String description;
  final String category;
  final int soldCount;
  final int discountPct;
  final int? originalPrice200g;
  final bool isMallRoastery;
  final bool isFlashSale;
  final int flashSaleStockLeft;
  final DateTime createdAt;

  MarketplaceProduct({
    required this.id,
    required this.name,
    required this.roasteryId,
    required this.roasteryName,
    required this.roasteryCity,
    required this.origin,
    required this.roastProfile,
    required this.variety,
    required this.process,
    required this.tastingNotes,
    required this.price100g,
    required this.price200g,
    required this.price250g,
    this.rating = 4.9,
    this.reviewCount = 56,
    this.stock = 35,
    this.roastDate = 'Freshly Roasted (2-3 days ago)',
    this.badge,
    required this.imageUrl,
    this.roasteryLogoUrl = '',
    this.hasVerifiedBagPhoto = false,
    this.galleryImages = const [],
    this.altitudeMasl = '1,400 - 1,750 MASL',
    this.producer = 'Estate Specialty Lot',
    this.recommendedMethod = 'V60 / Pour Over (1:15, 92°C)',
    required this.description,
    this.category = 'Single Origin',
    this.soldCount = 120,
    this.discountPct = 0,
    this.originalPrice200g,
    this.isMallRoastery = true,
    this.isFlashSale = false,
    this.flashSaleStockLeft = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime(2026, 11, 1);

  int getPriceForSize(String size) {
    switch (size) {
      case '100g':
        return price100g;
      case '250g':
        return price250g;
      case '200g':
      default:
        return price200g;
    }
  }

  String get formattedSoldCount {
    if (soldCount >= 1000) {
      final thousands = (soldCount / 1000).toStringAsFixed(1).replaceAll('.', ',');
      return '${thousands}rb terjual';
    }
    return '$soldCount terjual';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'roasteryId': roasteryId,
      'roasteryName': roasteryName,
      'roasteryCity': roasteryCity,
      'origin': origin,
      'roastProfile': roastProfile,
      'variety': variety,
      'process': process,
      'tastingNotes': tastingNotes,
      'price100g': price100g,
      'price200g': price200g,
      'price250g': price250g,
      'rating': rating,
      'reviewCount': reviewCount,
      'stock': stock,
      'roastDate': roastDate,
      'badge': badge,
      'imageUrl': imageUrl,
      'roasteryLogoUrl': roasteryLogoUrl,
      'hasVerifiedBagPhoto': hasVerifiedBagPhoto,
      'galleryImages': galleryImages,
      'altitudeMasl': altitudeMasl,
      'producer': producer,
      'recommendedMethod': recommendedMethod,
      'description': description,
      'category': category,
      'soldCount': soldCount,
      'discountPct': discountPct,
      'originalPrice200g': originalPrice200g,
      'isMallRoastery': isMallRoastery,
      'isFlashSale': isFlashSale,
      'flashSaleStockLeft': flashSaleStockLeft,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MarketplaceProduct.fromJson(Map<String, dynamic> json) {
    final p200 = (json['price200g'] as num?)?.toInt() ??
        (json['price_idr'] as num?)?.toInt() ??
        145000;
    final p100 = (json['price100g'] as num?)?.toInt() ?? (p200 * 0.52).round();
    final p250 = (json['price250g'] as num?)?.toInt() ?? (p200 * 1.22).round();

    return MarketplaceProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? 'Roasted Beans',
      roasteryId: json['roasteryId']?.toString() ?? json['roastery_id']?.toString() ?? '',
      roasteryName: json['roasteryName']?.toString() ??
          json['roastery_name']?.toString() ??
          'Specialty Roastery',
      roasteryCity: json['roasteryCity']?.toString() ??
          json['city_origin']?.toString() ??
          'Indonesia',
      origin: json['origin']?.toString() ??
          json['origin_region']?.toString() ??
          'Indonesia',
      roastProfile: json['roastProfile']?.toString() ??
          json['roast_level']?.toString() ??
          'Medium',
      variety: json['variety']?.toString() ?? 'Arabika',
      process: json['process']?.toString() ??
          json['post_harvest_process']?.toString() ??
          'Washed',
      tastingNotes: List<String>.from(
        (json['tastingNotes'] ?? json['tasting_notes'] ?? const ['Chocolate', 'Caramel'])
            as List<dynamic>,
      ),
      price100g: p100,
      price200g: p200,
      price250g: p250,
      rating: (json['rating'] ?? json['avg_rating'] as num?)?.toDouble() ?? 4.9,
      reviewCount: (json['reviewCount'] ?? json['reviews_count'] as num?)?.toInt() ?? 50,
      stock: (json['stock'] ?? json['stock_qty'] as num?)?.toInt() ?? 30,
      roastDate: json['roastDate']?.toString() ?? 'Fresh Roast 48h',
      badge: json['badge']?.toString(),
      imageUrl: json['imageUrl']?.toString() ??
          json['primary_image_url']?.toString() ??
          '',
      roasteryLogoUrl: json['roasteryLogoUrl']?.toString() ?? '',
      hasVerifiedBagPhoto: json['hasVerifiedBagPhoto'] as bool? ??
          (json['primary_image_url']?.toString().startsWith('http') ?? false),
      galleryImages: List<String>.from(
        (json['galleryImages'] ?? json['gallery_image_urls'] ?? const []) as List<dynamic>,
      ),
      altitudeMasl: json['altitudeMasl']?.toString() ??
          json['altitude_masl']?.toString() ??
          '1,400+ MASL',
      producer: json['producer']?.toString() ?? 'Specialty Farm',
      recommendedMethod:
          json['recommendedMethod']?.toString() ?? 'Filter / Pour Over',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Single Origin',
      soldCount: (json['soldCount'] ?? json['sold_count'] as num?)?.toInt() ?? 120,
      discountPct:
          (json['discountPct'] ?? json['discount_pct'] as num?)?.toInt() ?? 0,
      originalPrice200g:
          (json['originalPrice200g'] ?? json['original_price_idr'] as num?)?.toInt(),
      isMallRoastery:
          json['isMallRoastery'] as bool? ?? json['is_mall_roastery'] as bool? ?? true,
      isFlashSale:
          json['isFlashSale'] as bool? ?? json['is_flash_sale'] as bool? ?? false,
      flashSaleStockLeft:
          (json['flashSaleStockLeft'] ?? json['flash_sale_stock_left'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

class CartItem {
  final MarketplaceProduct product;
  final String bagSize;
  final String grindOption;
  int quantity;
  final int unitPrice;

  CartItem({
    required this.product,
    required this.bagSize,
    required this.grindOption,
    this.quantity = 1,
    required this.unitPrice,
  });

  int get totalPrice => unitPrice * quantity;

  String get cartKey => '${product.id}_${bagSize}_$grindOption';

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'bagSize': bagSize,
      'grindOption': grindOption,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product:
          MarketplaceProduct.fromJson(json['product'] as Map<String, dynamic>),
      bagSize: json['bagSize'] as String,
      grindOption: json['grindOption'] as String,
      quantity: json['quantity'] as int,
      unitPrice: json['unitPrice'] as int,
    );
  }
}

class MarketplaceOrder {
  final String orderId;
  final DateTime createdAt;
  final List<CartItem> items;
  final int subtotal;
  final int shippingFee;
  final int discount;
  final String? voucherCode;
  final int total;
  final String recipientName;
  final String phoneNumber;
  final String shippingAddress;
  final String courierName;
  final String paymentMethod;
  final String paymentStatus;
  final String? qrisReference;
  final String? qrisPayload;
  final DateTime? paidAt;
  final String status;
  final String estimatedDelivery;

  const MarketplaceOrder({
    required this.orderId,
    required this.createdAt,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    this.voucherCode,
    required this.total,
    required this.recipientName,
    required this.phoneNumber,
    required this.shippingAddress,
    required this.courierName,
    this.paymentMethod = 'QRIS',
    this.paymentStatus = 'PAID',
    this.qrisReference,
    this.qrisPayload,
    this.paidAt,
    this.status = 'Confirmed & Roasting',
    this.estimatedDelivery = '2-3 Business Days',
  });

  MarketplaceOrder copyWith({
    String? paymentStatus,
    String? status,
    DateTime? paidAt,
  }) {
    return MarketplaceOrder(
      orderId: orderId,
      createdAt: createdAt,
      items: items,
      subtotal: subtotal,
      shippingFee: shippingFee,
      discount: discount,
      voucherCode: voucherCode,
      total: total,
      recipientName: recipientName,
      phoneNumber: phoneNumber,
      shippingAddress: shippingAddress,
      courierName: courierName,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      qrisReference: qrisReference,
      qrisPayload: qrisPayload,
      paidAt: paidAt ?? this.paidAt,
      status: status ?? this.status,
      estimatedDelivery: estimatedDelivery,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'discount': discount,
      'voucherCode': voucherCode,
      'total': total,
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'shippingAddress': shippingAddress,
      'courierName': courierName,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'qrisReference': qrisReference,
      'qrisPayload': qrisPayload,
      'paidAt': paidAt?.toIso8601String(),
      'status': status,
      'estimatedDelivery': estimatedDelivery,
    };
  }

  factory MarketplaceOrder.fromJson(Map<String, dynamic> json) {
    return MarketplaceOrder(
      orderId: json['orderId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: (json['items'] as List<dynamic>)
          .map((i) => CartItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      subtotal: json['subtotal'] as int,
      shippingFee: json['shippingFee'] as int,
      discount: json['discount'] as int,
      voucherCode: json['voucherCode'] as String?,
      total: json['total'] as int,
      recipientName: json['recipientName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      shippingAddress: json['shippingAddress'] as String,
      courierName: json['courierName'] as String,
      paymentMethod: json['paymentMethod'] as String? ?? 'QRIS',
      paymentStatus: json['paymentStatus'] as String? ?? 'PAID',
      qrisReference: json['qrisReference'] as String?,
      qrisPayload: json['qrisPayload'] as String?,
      paidAt: json['paidAt'] != null
          ? DateTime.tryParse(json['paidAt'].toString())
          : null,
      status: json['status'] as String? ?? 'Confirmed & Roasting',
      estimatedDelivery: json['estimatedDelivery'] as String? ?? '2-3 Days',
    );
  }
}
