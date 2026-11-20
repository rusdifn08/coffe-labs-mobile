class CoffeeLineupItem {
  final String? id;
  final String name;
  final String origin;
  final String roastProfile;
  final String variety;
  final String process;
  final String tastingNotes;
  final String price100g;
  final String price200g;
  final String originalPackage;
  final String? badge;
  final bool isAvailable;
  final int? netWeightGrams;
  final int? priceIdr;
  final String? bagImageUrl;
  final String? bagImagePublicId;
  final int displayOrder;
  final String? recommendedBrewMethod;
  final int? recommendedTempC;
  final String? recommendedRatio;
  final String? recommendedGrindSize;

  const CoffeeLineupItem({
    this.id,
    required this.name,
    required this.origin,
    required this.roastProfile,
    required this.variety,
    required this.process,
    required this.tastingNotes,
    required this.price100g,
    required this.price200g,
    required this.originalPackage,
    this.badge,
    this.isAvailable = true,
    this.netWeightGrams,
    this.priceIdr,
    this.bagImageUrl,
    this.bagImagePublicId,
    this.displayOrder = 0,
    this.recommendedBrewMethod,
    this.recommendedTempC,
    this.recommendedRatio,
    this.recommendedGrindSize,
  });

  static String formatIdr(int amount) {
    final digits = (amount < 0 ? 0 : amount).toString();
    final buf = StringBuffer();
    var count = 0;
    for (var i = digits.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buf.write('.');
      }
      buf.write(digits[i]);
      count++;
    }
    return 'Rp${buf.toString().split('').reversed.join()}';
  }

  static ({String price100g, String price200g, String originalPackage})
      computeUnitLabels(int netWeightGrams, int priceIdr) {
    final safeGrams = netWeightGrams <= 0 ? 250 : netWeightGrams;
    final perGram = priceIdr / safeGrams;
    final p100 = (perGram * 100).round();
    final p200 = (perGram * 200).round();
    return (
      price100g: formatIdr(p100),
      price200g: formatIdr(p200),
      originalPackage: 'Asli: ${formatIdr(priceIdr)} / ${safeGrams}g',
    );
  }

  int get resolvedNetWeightGrams {
    if (netWeightGrams != null && netWeightGrams! > 0) return netWeightGrams!;
    final match = RegExp(r'(\d+)\s*g', caseSensitive: false).firstMatch(originalPackage);
    return int.tryParse(match?.group(1) ?? '') ?? 250;
  }

  int get resolvedPriceIdr {
    if (priceIdr != null && priceIdr! > 0) return priceIdr!;
    final match = RegExp(r'Rp\s*([\d.]+)', caseSensitive: false).firstMatch(originalPackage);
    final rawDigits = (match?.group(1) ?? '').replaceAll('.', '');
    return int.tryParse(rawDigits) ?? 150000;
  }

  factory CoffeeLineupItem.fromJson(Map<String, dynamic> json) {
    final grams = (json['net_weight_grams'] as num?)?.toInt() ?? 250;
    final price = (json['price_idr'] as num?)?.toInt() ?? 150000;
    final computed = computeUnitLabels(grams, price);

    return CoffeeLineupItem(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? 'Roasted Beans',
      origin: json['origin']?.toString() ?? 'Single Origin',
      roastProfile: json['roast_profile']?.toString() ??
          json['roastProfile']?.toString() ??
          'Medium',
      variety: json['variety']?.toString() ?? 'Arabika',
      process: json['process']?.toString() ?? 'Washed',
      tastingNotes: json['tasting_notes']?.toString() ??
          json['tastingNotes']?.toString() ??
          'Balanced Chocolate, Sweet Caramel',
      price100g: json['price_100g_label']?.toString() ??
          json['price100g']?.toString() ??
          computed.price100g,
      price200g: json['price_200g_label']?.toString() ??
          json['price200g']?.toString() ??
          computed.price200g,
      originalPackage: json['original_package_label']?.toString() ??
          json['originalPackage']?.toString() ??
          computed.originalPackage,
      badge: json['badge']?.toString(),
      isAvailable: json['is_available'] as bool? ??
          json['isAvailable'] as bool? ??
          true,
      netWeightGrams: grams,
      priceIdr: price,
      bagImageUrl: json['bag_image_url']?.toString() ?? json['bagImageUrl']?.toString(),
      bagImagePublicId:
          json['bag_image_public_id']?.toString() ?? json['bagImagePublicId']?.toString(),
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      recommendedBrewMethod: json['recommended_brew_method']?.toString() ??
          json['recommendedBrewMethod']?.toString(),
      recommendedTempC: (json['recommended_temp_c'] as num?)?.toInt() ??
          (json['recommendedTempC'] as num?)?.toInt(),
      recommendedRatio: json['recommended_ratio']?.toString() ??
          json['recommendedRatio']?.toString(),
      recommendedGrindSize: json['recommended_grind_size']?.toString() ??
          json['recommendedGrindSize']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'origin': origin,
        'roast_profile': roastProfile,
        'variety': variety,
        'process': process,
        'tasting_notes': tastingNotes,
        'net_weight_grams': resolvedNetWeightGrams,
        'price_idr': resolvedPriceIdr,
        'price_100g_label': price100g,
        'price_200g_label': price200g,
        'original_package_label': originalPackage,
        if (bagImageUrl != null) 'bag_image_url': bagImageUrl,
        if (bagImagePublicId != null) 'bag_image_public_id': bagImagePublicId,
        if (badge != null) 'badge': badge,
        'is_available': isAvailable,
        'display_order': displayOrder,
        if (recommendedBrewMethod != null)
          'recommended_brew_method': recommendedBrewMethod,
        if (recommendedTempC != null) 'recommended_temp_c': recommendedTempC,
        if (recommendedRatio != null) 'recommended_ratio': recommendedRatio,
        if (recommendedGrindSize != null)
          'recommended_grind_size': recommendedGrindSize,
      };

  Map<String, dynamic> toUpsertPayload() => {
        'name': name,
        'origin': origin,
        'roast_profile': roastProfile,
        'variety': variety,
        'process': process,
        'tasting_notes': tastingNotes,
        'net_weight_grams': resolvedNetWeightGrams,
        'price_idr': resolvedPriceIdr,
        if (bagImageUrl != null && bagImageUrl!.trim().isNotEmpty)
          'bag_image_url': bagImageUrl!.trim(),
        if (bagImagePublicId != null && bagImagePublicId!.trim().isNotEmpty)
          'bag_image_public_id': bagImagePublicId!.trim(),
        'badge': (badge ?? '').trim().isEmpty ? null : badge!.trim(),
        'is_available': isAvailable,
        'display_order': displayOrder,
        'recommended_brew_method': (recommendedBrewMethod ?? '').trim().isEmpty
            ? null
            : recommendedBrewMethod!.trim(),
        'recommended_temp_c': recommendedTempC,
        'recommended_ratio': (recommendedRatio ?? '').trim().isEmpty
            ? null
            : recommendedRatio!.trim(),
        'recommended_grind_size': (recommendedGrindSize ?? '').trim().isEmpty
            ? null
            : recommendedGrindSize!.trim(),
      };

  CoffeeLineupItem copyWith({
    String? id,
    String? name,
    String? origin,
    String? roastProfile,
    String? variety,
    String? process,
    String? tastingNotes,
    String? price100g,
    String? price200g,
    String? originalPackage,
    String? badge,
    bool? isAvailable,
    int? netWeightGrams,
    int? priceIdr,
    String? bagImageUrl,
    String? bagImagePublicId,
    int? displayOrder,
    String? recommendedBrewMethod,
    int? recommendedTempC,
    String? recommendedRatio,
    String? recommendedGrindSize,
  }) {
    return CoffeeLineupItem(
      id: id ?? this.id,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      roastProfile: roastProfile ?? this.roastProfile,
      variety: variety ?? this.variety,
      process: process ?? this.process,
      tastingNotes: tastingNotes ?? this.tastingNotes,
      price100g: price100g ?? this.price100g,
      price200g: price200g ?? this.price200g,
      originalPackage: originalPackage ?? this.originalPackage,
      badge: badge ?? this.badge,
      isAvailable: isAvailable ?? this.isAvailable,
      netWeightGrams: netWeightGrams ?? this.netWeightGrams,
      priceIdr: priceIdr ?? this.priceIdr,
      bagImageUrl: bagImageUrl ?? this.bagImageUrl,
      bagImagePublicId: bagImagePublicId ?? this.bagImagePublicId,
      displayOrder: displayOrder ?? this.displayOrder,
      recommendedBrewMethod: recommendedBrewMethod ?? this.recommendedBrewMethod,
      recommendedTempC: recommendedTempC ?? this.recommendedTempC,
      recommendedRatio: recommendedRatio ?? this.recommendedRatio,
      recommendedGrindSize: recommendedGrindSize ?? this.recommendedGrindSize,
    );
  }
}

class Roastery {
  final String id;
  final String? ownerUserId;
  final String? slug;
  final String name;
  final String location;
  final String address;
  final double latitude;
  final double longitude;
  final String description;
  final String specialties;
  final String cluster;
  final String imageUrl;
  final String? logoPublicId;
  final String? bannerUrl;
  final String? bannerPublicId;
  final String? whatsappNumber;
  final String? instagramHandle;
  final String? websiteUrl;
  final double rating;
  final String salesHighlight;
  final bool isVerifiedBusiness;
  final bool isPublished;
  final int? totalLineupsCount;
  final List<CoffeeLineupItem> lineups;

  const Roastery({
    required this.id,
    this.ownerUserId,
    this.slug,
    required this.name,
    required this.location,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.specialties,
    required this.cluster,
    required this.imageUrl,
    this.logoPublicId,
    this.bannerUrl,
    this.bannerPublicId,
    this.whatsappNumber,
    this.instagramHandle,
    this.websiteUrl,
    required this.rating,
    required this.salesHighlight,
    this.isVerifiedBusiness = false,
    this.isPublished = true,
    this.totalLineupsCount,
    required this.lineups,
  });

  int get effectiveLineupCount =>
      lineups.isNotEmpty ? lineups.length : (totalLineupsCount ?? 0);

  factory Roastery.fromJson(Map<String, dynamic> json) {
    final rawLineups = json['lineups'] as List<dynamic>? ?? const [];
    final parsedLineups = rawLineups
        .whereType<Map>()
        .map((e) => CoffeeLineupItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return Roastery(
      id: json['id']?.toString() ?? '',
      ownerUserId:
          json['owner_user_id']?.toString() ?? json['ownerUserId']?.toString(),
      slug: json['slug']?.toString(),
      name: json['name']?.toString() ?? 'Coffee Roastery',
      location: json['city']?.toString() ??
          json['location']?.toString() ??
          'Indonesia',
      address: json['address']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? -6.2088,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 106.8456,
      description: json['description']?.toString() ?? '',
      specialties: json['specialties']?.toString() ?? '',
      cluster: json['cluster']?.toString() ?? 'Roastery Bisnis',
      imageUrl: json['logo_url']?.toString() ??
          json['imageUrl']?.toString() ??
          'assets/images/avatars/generic_fallback.jpg',
      logoPublicId:
          json['logo_public_id']?.toString() ?? json['logoPublicId']?.toString(),
      bannerUrl:
          json['banner_url']?.toString() ?? json['bannerUrl']?.toString(),
      bannerPublicId: json['banner_public_id']?.toString() ??
          json['bannerPublicId']?.toString(),
      whatsappNumber: json['whatsapp_number']?.toString() ??
          json['whatsappNumber']?.toString(),
      instagramHandle: json['instagram_handle']?.toString() ??
          json['instagramHandle']?.toString(),
      websiteUrl:
          json['website_url']?.toString() ?? json['websiteUrl']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      salesHighlight: json['sales_highlight']?.toString() ??
          json['salesHighlight']?.toString() ??
          'Roastery Bisnis Terverifikasi',
      isVerifiedBusiness: json['is_verified_business'] as bool? ??
          json['isVerifiedBusiness'] as bool? ??
          true,
      isPublished: json['is_published'] as bool? ??
          json['isPublished'] as bool? ??
          true,
      totalLineupsCount: (json['total_lineups_count'] as num?)?.toInt() ??
          (json['totalLineupsCount'] as num?)?.toInt(),
      lineups: parsedLineups,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (ownerUserId != null) 'owner_user_id': ownerUserId,
        if (slug != null) 'slug': slug,
        'name': name,
        'city': location,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
        'specialties': specialties,
        'cluster': cluster,
        'logo_url': imageUrl,
        if (logoPublicId != null) 'logo_public_id': logoPublicId,
        if (bannerUrl != null) 'banner_url': bannerUrl,
        if (bannerPublicId != null) 'banner_public_id': bannerPublicId,
        if (whatsappNumber != null) 'whatsapp_number': whatsappNumber,
        if (instagramHandle != null) 'instagram_handle': instagramHandle,
        if (websiteUrl != null) 'website_url': websiteUrl,
        'rating': rating,
        'sales_highlight': salesHighlight,
        'is_verified_business': isVerifiedBusiness,
        'is_published': isPublished,
        'total_lineups_count': effectiveLineupCount,
        'lineups': lineups.map((l) => l.toJson()).toList(),
      };

  Roastery copyWith({
    String? id,
    String? ownerUserId,
    String? slug,
    String? name,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    String? specialties,
    String? cluster,
    String? imageUrl,
    String? logoPublicId,
    String? bannerUrl,
    String? bannerPublicId,
    String? whatsappNumber,
    String? instagramHandle,
    String? websiteUrl,
    double? rating,
    String? salesHighlight,
    bool? isVerifiedBusiness,
    bool? isPublished,
    int? totalLineupsCount,
    List<CoffeeLineupItem>? lineups,
  }) {
    return Roastery(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      location: location ?? this.location,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      specialties: specialties ?? this.specialties,
      cluster: cluster ?? this.cluster,
      imageUrl: imageUrl ?? this.imageUrl,
      logoPublicId: logoPublicId ?? this.logoPublicId,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      bannerPublicId: bannerPublicId ?? this.bannerPublicId,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      rating: rating ?? this.rating,
      salesHighlight: salesHighlight ?? this.salesHighlight,
      isVerifiedBusiness: isVerifiedBusiness ?? this.isVerifiedBusiness,
      isPublished: isPublished ?? this.isPublished,
      totalLineupsCount: totalLineupsCount ?? this.totalLineupsCount,
      lineups: lineups ?? this.lineups,
    );
  }
}
