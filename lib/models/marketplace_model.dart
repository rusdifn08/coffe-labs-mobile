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
  final String altitudeMasl;
  final String producer;
  final String recommendedMethod;
  final String description;

  const MarketplaceProduct({
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
    this.altitudeMasl = '1,400 - 1,750 MASL',
    this.producer = 'Estate Specialty Lot',
    this.recommendedMethod = 'V60 / Pour Over (1:15, 92°C)',
    required this.description,
  });

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
      'altitudeMasl': altitudeMasl,
      'producer': producer,
      'recommendedMethod': recommendedMethod,
      'description': description,
    };
  }

  factory MarketplaceProduct.fromJson(Map<String, dynamic> json) {
    return MarketplaceProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      roasteryId: json['roasteryId'] as String,
      roasteryName: json['roasteryName'] as String,
      roasteryCity: json['roasteryCity'] as String? ?? 'Indonesia',
      origin: json['origin'] as String,
      roastProfile: json['roastProfile'] as String,
      variety: json['variety'] as String,
      process: json['process'] as String,
      tastingNotes: List<String>.from(json['tastingNotes'] as List<dynamic>),
      price100g: json['price100g'] as int,
      price200g: json['price200g'] as int,
      price250g: json['price250g'] as int,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewCount: json['reviewCount'] as int? ?? 50,
      stock: json['stock'] as int? ?? 30,
      roastDate: json['roastDate'] as String? ?? 'Fresh Roast',
      badge: json['badge'] as String?,
      imageUrl: json['imageUrl'] as String,
      altitudeMasl: json['altitudeMasl'] as String? ?? '1,400+ MASL',
      producer: json['producer'] as String? ?? 'Specialty Farm',
      recommendedMethod: json['recommendedMethod'] as String? ?? 'Filter / Pour Over',
      description: json['description'] as String,
    );
  }
}

class CartItem {
  final MarketplaceProduct product;
  final String bagSize; // '100g', '200g', '250g'
  final String grindOption; // 'Whole Beans', 'V60 / Filter', 'Espresso', etc.
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
      product: MarketplaceProduct.fromJson(json['product'] as Map<String, dynamic>),
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
    required this.paymentMethod,
    this.status = 'Confirmed & Roasting',
    this.estimatedDelivery = '2-3 Business Days',
  });

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
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String? ?? 'Confirmed & Roasting',
      estimatedDelivery: json['estimatedDelivery'] as String? ?? '2-3 Days',
    );
  }
}
