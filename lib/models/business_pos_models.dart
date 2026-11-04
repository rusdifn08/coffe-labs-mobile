enum WorkspaceMode {
  personalBrewer,
  businessCashier,
  customerAodDisplay,
}

class BusinessStoreConfig {
  final String id;
  final String ownerUserId;
  final String storeName;
  final int aodGridColumns;
  final int aodGridRows;
  final String aodCardBorderColor;
  final String aodAccentColor;
  final double aodIdleBrightness;
  final double aodActiveBrightness;
  final bool pixelShiftEnabled;

  const BusinessStoreConfig({
    required this.id,
    required this.ownerUserId,
    required this.storeName,
    this.aodGridColumns = 3,
    this.aodGridRows = 2,
    this.aodCardBorderColor = '#262626',
    this.aodAccentColor = '#D4AF37',
    this.aodIdleBrightness = 0.35,
    this.aodActiveBrightness = 0.90,
    this.pixelShiftEnabled = true,
  });

  factory BusinessStoreConfig.fromJson(Map<String, dynamic> json) {
    return BusinessStoreConfig(
      id: json['id']?.toString() ?? '',
      ownerUserId: json['owner_user_id']?.toString() ?? '',
      storeName: json['store_name']?.toString() ?? 'Coffee Labs Bar',
      aodGridColumns: (json['aod_grid_columns'] as num?)?.toInt() ?? 3,
      aodGridRows: (json['aod_grid_rows'] as num?)?.toInt() ?? 2,
      aodCardBorderColor: json['aod_card_border_color']?.toString() ?? '#262626',
      aodAccentColor: json['aod_accent_color']?.toString() ?? '#D4AF37',
      aodIdleBrightness: (json['aod_idle_brightness'] as num?)?.toDouble() ?? 0.35,
      aodActiveBrightness: (json['aod_active_brightness'] as num?)?.toDouble() ?? 0.90,
      pixelShiftEnabled: json['pixel_shift_enabled'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_user_id': ownerUserId,
      'store_name': storeName,
      'aod_grid_columns': aodGridColumns,
      'aod_grid_rows': aodGridRows,
      'aod_card_border_color': aodCardBorderColor,
      'aod_accent_color': aodAccentColor,
      'aod_idle_brightness': aodIdleBrightness,
      'aod_active_brightness': aodActiveBrightness,
      'pixel_shift_enabled': pixelShiftEnabled,
    };
  }

  BusinessStoreConfig copyWith({
    String? storeName,
    int? aodGridColumns,
    int? aodGridRows,
    String? aodCardBorderColor,
    String? aodAccentColor,
    double? aodIdleBrightness,
    double? aodActiveBrightness,
    bool? pixelShiftEnabled,
  }) {
    return BusinessStoreConfig(
      id: id,
      ownerUserId: ownerUserId,
      storeName: storeName ?? this.storeName,
      aodGridColumns: aodGridColumns ?? this.aodGridColumns,
      aodGridRows: aodGridRows ?? this.aodGridRows,
      aodCardBorderColor: aodCardBorderColor ?? this.aodCardBorderColor,
      aodAccentColor: aodAccentColor ?? this.aodAccentColor,
      aodIdleBrightness: aodIdleBrightness ?? this.aodIdleBrightness,
      aodActiveBrightness: aodActiveBrightness ?? this.aodActiveBrightness,
      pixelShiftEnabled: pixelShiftEnabled ?? this.pixelShiftEnabled,
    );
  }

  static BusinessStoreConfig defaultBarConfig() {
    return const BusinessStoreConfig(
      id: 'default',
      ownerUserId: '',
      storeName: 'Coffee Labs Bar & Roastery',
      aodGridColumns: 3,
      aodGridRows: 2,
    );
  }
}

class BusinessMenuItem {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final String category;
  final int priceCents;
  final String currency;
  final String assetUrl;
  final String assetFormat; // PNG, WEBP, SVG
  final bool hasVerifiedTransparency;
  final int displayOrder;
  final bool isAvailable;
  final bool showInAod; // Tampil di Mode Pajangan (AOD Display Pelanggan)
  final bool showInPos; // Tersedia untuk Transaksi Kasir POS
  final List<String> tags; // e.g. ['Best Seller', 'Signature', 'Seasonal']

  const BusinessMenuItem({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.category,
    required this.priceCents,
    this.currency = 'IDR',
    required this.assetUrl,
    required this.assetFormat,
    this.hasVerifiedTransparency = true,
    this.displayOrder = 0,
    this.isAvailable = true,
    this.showInAod = true,
    this.showInPos = true,
    this.tags = const [],
  });

  String get formattedPrice {
    final thousands = priceCents.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $thousands';
  }

  BusinessMenuItem copyWith({
    String? name,
    String? description,
    String? category,
    int? priceCents,
    String? currency,
    String? assetUrl,
    String? assetFormat,
    bool? hasVerifiedTransparency,
    int? displayOrder,
    bool? isAvailable,
    bool? showInAod,
    bool? showInPos,
    List<String>? tags,
  }) {
    return BusinessMenuItem(
      id: id,
      storeId: storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      priceCents: priceCents ?? this.priceCents,
      currency: currency ?? this.currency,
      assetUrl: assetUrl ?? this.assetUrl,
      assetFormat: assetFormat ?? this.assetFormat,
      hasVerifiedTransparency: hasVerifiedTransparency ?? this.hasVerifiedTransparency,
      displayOrder: displayOrder ?? this.displayOrder,
      isAvailable: isAvailable ?? this.isAvailable,
      showInAod: showInAod ?? this.showInAod,
      showInPos: showInPos ?? this.showInPos,
      tags: tags ?? this.tags,
    );
  }

  factory BusinessMenuItem.fromJson(Map<String, dynamic> json) {
    return BusinessMenuItem(
      id: json['id']?.toString() ?? '',
      storeId: json['store_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Menu Item',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Signature Coffee',
      priceCents: (json['price_cents'] as num?)?.toInt() ?? 35000,
      currency: json['currency']?.toString() ?? 'IDR',
      assetUrl: json['asset_url']?.toString() ?? '',
      assetFormat: json['asset_format']?.toString() ?? 'PNG',
      hasVerifiedTransparency: json['has_verified_transparency'] != false,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      isAvailable: json['is_available'] != false,
      showInAod: json['show_in_aod'] != false,
      showInPos: json['show_in_pos'] != false,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'description': description,
      'category': category,
      'price_cents': priceCents,
      'currency': currency,
      'asset_url': assetUrl,
      'asset_format': assetFormat,
      'has_verified_transparency': hasVerifiedTransparency,
      'display_order': displayOrder,
      'is_available': isAvailable,
      'show_in_aod': showInAod,
      'show_in_pos': showInPos,
      'tags': tags,
    };
  }
}

class PosCartItem {
  final BusinessMenuItem menuItem;
  final int quantity;
  final Map<String, String> modifiers;

  const PosCartItem({
    required this.menuItem,
    this.quantity = 1,
    this.modifiers = const {},
  });

  int get totalPrice => menuItem.priceCents * quantity;

  PosCartItem copyWith({
    int? quantity,
    Map<String, String>? modifiers,
  }) {
    return PosCartItem(
      menuItem: menuItem,
      quantity: quantity ?? this.quantity,
      modifiers: modifiers ?? this.modifiers,
    );
  }
}
