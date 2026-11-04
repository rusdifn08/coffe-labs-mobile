/// Model and catalog of coffee brewing methods.
class BrewMethodItem {
  final String id;
  final String title;
  final String titleId;
  final String imageAsset;
  final String filterKey;
  final String category;
  final String subtitle;
  final int userBrewCount;

  const BrewMethodItem({
    required this.id,
    required this.title,
    required this.titleId,
    required this.imageAsset,
    required this.filterKey,
    required this.category,
    required this.subtitle,
    this.userBrewCount = 0,
  });

  BrewMethodItem copyWith({
    String? id,
    String? title,
    String? titleId,
    String? imageAsset,
    String? filterKey,
    String? category,
    String? subtitle,
    int? userBrewCount,
  }) {
    return BrewMethodItem(
      id: id ?? this.id,
      title: title ?? this.title,
      titleId: titleId ?? this.titleId,
      imageAsset: imageAsset ?? this.imageAsset,
      filterKey: filterKey ?? this.filterKey,
      category: category ?? this.category,
      subtitle: subtitle ?? this.subtitle,
      userBrewCount: userBrewCount ?? this.userBrewCount,
    );
  }

  static const List<BrewMethodItem> allMethods = [
    BrewMethodItem(
      id: 'aeropress',
      title: 'Aeropress',
      titleId: 'Aeropress',
      imageAsset: 'assets/images/methods/aeropress.png',
      filterKey: 'AeroPress',
      category: 'AeroPress',
      subtitle: 'Pressure & Immersion',
    ),
    BrewMethodItem(
      id: 'bee_house',
      title: 'Bee House Dripper',
      titleId: 'Bee House Dripper',
      imageAsset: 'assets/images/methods/bee_house.png',
      filterKey: 'Bee House',
      category: 'Cone',
      subtitle: 'Dual-Hole Wedge Cone',
    ),
    BrewMethodItem(
      id: 'bonmac',
      title: 'Bonmac Dripper',
      titleId: 'Bonmac Dripper',
      imageAsset: 'assets/images/methods/bonmac.png',
      filterKey: 'Bonmac',
      category: 'Cone',
      subtitle: 'Single-Hole Wedge',
    ),
    BrewMethodItem(
      id: 'chemex',
      title: 'Chemex',
      titleId: 'Chemex',
      imageAsset: 'assets/images/methods/chemex.png',
      filterKey: 'Chemex',
      category: 'Cone',
      subtitle: 'Bonded Paper Clarity',
    ),
    BrewMethodItem(
      id: 'clever',
      title: 'Clever Dripper',
      titleId: 'Clever Dripper',
      imageAsset: 'assets/images/methods/clever_dripper.png',
      filterKey: 'Clever',
      category: 'Immersion',
      subtitle: 'Steep & Release Valve',
    ),
    BrewMethodItem(
      id: 'cupping',
      title: 'Cupping',
      titleId: 'Cupping Kopi',
      imageAsset: 'assets/images/methods/cupping.png',
      filterKey: 'Cupping',
      category: 'Cupping',
      subtitle: 'SCA Sensory Tasting',
    ),
    BrewMethodItem(
      id: 'drip_maker',
      title: 'Drip Coffee Maker',
      titleId: 'Mesin Drip Kopi',
      imageAsset: 'assets/images/methods/drip_coffee_maker.png',
      filterKey: 'Drip Coffee Maker',
      category: 'Drip Maker',
      subtitle: 'Auto Shower Batch',
    ),
    BrewMethodItem(
      id: 'espresso',
      title: 'Espresso Machine',
      titleId: 'Mesin Espresso',
      imageAsset: 'assets/images/methods/espresso_machine.png',
      filterKey: 'Espresso',
      category: 'Espresso',
      subtitle: 'High Pressure 9 Bar',
    ),
    BrewMethodItem(
      id: 'french_press',
      title: 'French Press',
      titleId: 'French Press',
      imageAsset: 'assets/images/methods/french_press.png',
      filterKey: 'French Press',
      category: 'French Press',
      subtitle: 'Full Body Immersion',
    ),
    BrewMethodItem(
      id: 'hario_v60',
      title: 'Hario V60',
      titleId: 'Hario V60',
      imageAsset: 'assets/images/methods/hario_v60.png',
      filterKey: 'V60',
      category: 'V60 Pour Over',
      subtitle: '60° Spiral Ribs Cone',
    ),
    BrewMethodItem(
      id: 'kalita_wave',
      title: 'Kalita Wave',
      titleId: 'Kalita Wave',
      imageAsset: 'assets/images/methods/kalita_wave.png',
      filterKey: 'Kalita Wave',
      category: 'Flat Bottom',
      subtitle: '3-Hole Flat Bottom',
    ),
    BrewMethodItem(
      id: 'moka_pot',
      title: 'Moka Pot',
      titleId: 'Moka Pot',
      imageAsset: 'assets/images/methods/moka_pot.png',
      filterKey: 'Moka Pot',
      category: 'Moka Pot',
      subtitle: 'Stovetop Steam Pressure',
    ),
    BrewMethodItem(
      id: 'syphon',
      title: 'Syphon',
      titleId: 'Syphon (Vakum)',
      imageAsset: 'assets/images/methods/chemex.png',
      filterKey: 'Syphon',
      category: 'Syphon',
      subtitle: 'Vacuum Pot Kissaten',
    ),
    BrewMethodItem(
      id: 'cold_brew',
      title: 'Cold Brew',
      titleId: 'Cold Brew & Drip',
      imageAsset: 'assets/images/methods/hario_v60.png',
      filterKey: 'Cold Brew',
      category: 'Cold Brew',
      subtitle: 'Slow Cold Steep',
    ),
    BrewMethodItem(
      id: 'japanese_drip',
      title: 'Japanese Drip',
      titleId: 'Japanese Drip (Es)',
      imageAsset: 'assets/images/methods/japanese_drip.png',
      filterKey: 'Japanese Drip',
      category: 'Iced Pour Over',
      subtitle: 'Flash Chill on Ice',
    ),
    BrewMethodItem(
      id: 'vietnam_drip',
      title: 'Vietnam Drip',
      titleId: 'Vietnam Drip (Phin)',
      imageAsset: 'assets/images/methods/vietnam_drip.png',
      filterKey: 'Vietnam Drip',
      category: 'Immersion & Drip',
      subtitle: 'Traditional Metal Phin',
    ),
    BrewMethodItem(
      id: 'origami_dripper',
      title: 'Origami Dripper',
      titleId: 'Origami Dripper',
      imageAsset: 'assets/images/methods/origami_dripper.png',
      filterKey: 'Origami',
      category: 'Pour Over',
      subtitle: '20-Fold Ceramic Ribs',
    ),
    BrewMethodItem(
      id: 'turkish_coffee',
      title: 'Turkish Coffee',
      titleId: 'Kopi Turki (Cezve)',
      imageAsset: 'assets/images/methods/turkish_coffee.png',
      filterKey: 'Turkish Coffee',
      category: 'Decoction',
      subtitle: 'Ibrik Micro-Foam',
    ),
  ];
}
