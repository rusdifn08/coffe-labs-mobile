import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DripperVisualItem {
  final String name;
  final String shortName;
  final String subtitle;
  final String defaultCategory;
  final String shapeType; // v60, iced_v60, switch, origami, flat, aeropress, frenchpress, clever, chemex, pulsar, phin
  final Color color;

  const DripperVisualItem({
    required this.name,
    required this.shortName,
    required this.subtitle,
    required this.defaultCategory,
    required this.shapeType,
    required this.color,
  });
}

class BeanVisualItem {
  final String name;
  final String region;
  final String defaultVariety;
  final String process;
  final String roast;
  final List<String> defaultNotes;
  final Color color;
  final String emoji;

  const BeanVisualItem({
    required this.name,
    required this.region,
    this.defaultVariety = 'Arabica',
    required this.process,
    required this.roast,
    required this.defaultNotes,
    required this.color,
    required this.emoji,
  });
}

class FlavorNoteVisualItem {
  final String label;
  final String group;
  final String emoji;
  final Color color;

  const FlavorNoteVisualItem({
    required this.label,
    required this.group,
    required this.emoji,
    required this.color,
  });
}

class GrinderModel {
  final String id;
  final String name;
  final String brand;
  final String typeDescription;
  final String imagePath;
  final bool isElectric;
  final int minClicks;
  final int maxClicks;
  final int defaultClicks;
  final double micronsPerClick;
  final int fineClick;
  final int medFineClick;
  final int mediumClick;
  final int medCoarseClick;
  final int coarseClick;

  const GrinderModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.typeDescription,
    required this.imagePath,
    this.isElectric = false,
    required this.minClicks,
    required this.maxClicks,
    required this.defaultClicks,
    required this.micronsPerClick,
    required this.fineClick,
    required this.medFineClick,
    required this.mediumClick,
    required this.medCoarseClick,
    required this.coarseClick,
  });

  int getClicksForPreset(String preset) {
    switch (preset.toLowerCase()) {
      case 'fine':
        return fineClick;
      case 'medium-fine':
      case 'med-fine':
        return medFineClick;
      case 'medium':
        return mediumClick;
      case 'medium-coarse':
      case 'med-coarse':
        return medCoarseClick;
      case 'coarse':
        return coarseClick;
      default:
        return mediumClick;
    }
  }

  String estimateMicrons(int clicks) {
    final um = (clicks * micronsPerClick).round();
    return '$um µm';
  }
}

class BrewVisualCatalog {
  static const List<DripperVisualItem> drippers = [
    DripperVisualItem(
      name: 'Hario V60 02',
      shortName: 'Hario V60',
      subtitle: 'Cone 60° Spiral Ribs',
      defaultCategory: 'V60',
      shapeType: 'v60',
      color: Color(0xFF7B4B2A),
    ),
    DripperVisualItem(
      name: 'Hario V60 02 + Es di Server',
      shortName: 'Japanese Iced V60',
      subtitle: 'Flash Brew di atas Es',
      defaultCategory: 'Japanese',
      shapeType: 'iced_v60',
      color: Color(0xFF1E88E5),
    ),
    DripperVisualItem(
      name: 'Hario Switch 02',
      shortName: 'Hario Switch',
      subtitle: 'Hybrid Immersion Valve',
      defaultCategory: 'Hybrid',
      shapeType: 'switch',
      color: Color(0xFF00897B),
    ),
    DripperVisualItem(
      name: 'Origami Dripper Air S',
      shortName: 'Origami Dripper',
      subtitle: '20-Channel Fluted Cone',
      defaultCategory: 'Origami',
      shapeType: 'origami',
      color: Color(0xFFD81B60),
    ),
    DripperVisualItem(
      name: 'Kalita Wave 185',
      shortName: 'Kalita Wave',
      subtitle: '3-Hole Flat Bottom',
      defaultCategory: 'Flat Bottom',
      shapeType: 'flat',
      color: Color(0xFF43A047),
    ),
    DripperVisualItem(
      name: 'Orea V4 / April Brewer',
      shortName: 'Orea / April',
      subtitle: 'Fast-Flow Flat Bottom',
      defaultCategory: 'Flat Bottom',
      shapeType: 'flat',
      color: Color(0xFFFB8C00),
    ),
    DripperVisualItem(
      name: 'AeroPress Standard / Inverted',
      shortName: 'AeroPress',
      subtitle: 'Pressure & Immersion',
      defaultCategory: 'AeroPress',
      shapeType: 'aeropress',
      color: Color(0xFF5E35B1),
    ),
    DripperVisualItem(
      name: 'French Press Carafe',
      shortName: 'French Press',
      subtitle: 'Full Steep Metal Mesh',
      defaultCategory: 'French Press',
      shapeType: 'frenchpress',
      color: Color(0xFF6D4C41),
    ),
    DripperVisualItem(
      name: 'Clever Dripper',
      shortName: 'Clever Dripper',
      subtitle: 'Steep & Release Filter',
      defaultCategory: 'Immersion',
      shapeType: 'clever',
      color: Color(0xFF3949AB),
    ),
    DripperVisualItem(
      name: 'Chemex / Kono Dripper',
      shortName: 'Chemex / Kono',
      subtitle: 'Classic Cone Percolation',
      defaultCategory: 'Cone',
      shapeType: 'chemex',
      color: Color(0xFF8D6E63),
    ),
    DripperVisualItem(
      name: 'NextLevel Pulsar / Gina',
      shortName: 'Pulsar / Gina',
      subtitle: 'Zero-Bypass Valve Brewer',
      defaultCategory: 'Hybrid',
      shapeType: 'pulsar',
      color: Color(0xFF00ACC1),
    ),
    DripperVisualItem(
      name: 'Vietnam Drip (Phin)',
      shortName: 'Vietnam Phin',
      subtitle: 'Traditional Gravity Drip',
      defaultCategory: 'Vietnam Drip',
      shapeType: 'phin',
      color: Color(0xFF546E7A),
    ),
  ];

  static const List<String> varieties = [
    'Geisha / Gesha',
    'Bourbon',
    'Typica',
    'Ateng Super / TimTim',
    'Sigarar Utang',
    'Andungsari',
    'Kartika',
    'Lini S',
    'Caturra',
    'Catuai',
    'SL28',
    'SL34',
    'Pacamara',
    'Pink Bourbon',
    'Yellow Bourbon',
    'Wush Wush',
    'Sudan Rume',
    'Castillo',
    'Catimor',
    'Maragogype',
    'Heirloom / Landrace',
    'Batian',
    'Ruiru 11',
  ];

  static const List<String> roastLevels = [
    'Light',
    'Light-Medium',
    'Medium',
    'Medium-Dark',
    'Dark',
  ];

  static const List<String> processes = [
    'Washed',
    'Natural',
    'Wine Process',
    'Honey / Pulped Natural',
    'Black Honey',
    'Red Honey',
    'Yellow Honey',
    'Anaerobic Natural',
    'Anaerobic Washed',
    'Carbonic Maceration',
    'Thermal Shock',
    'Double Anaerobic',
    'Wet Hulled (Giling Basah)',
    'Koji Fermented',
    'Yeast Inoculated / Co-Fermentation',
    'Lactic Fermentation',
    'Extended Natural',
  ];

  static const List<BeanVisualItem> beans = [
    // SUMATRA & ACEH
    BeanVisualItem(
      name: 'Aceh Gayo Wine',
      region: 'Takengon, Aceh 🇮🇩',
      defaultVariety: 'Ateng Super / TimTim Gayo',
      process: 'Wine Process',
      roast: 'Light-Medium',
      defaultNotes: ['Sangria & Red Wine', 'Ripe Fig', 'Dark Berries & Concord Grape'],
      color: Color(0xFF880E4F),
      emoji: '🍷',
    ),
    BeanVisualItem(
      name: 'Aceh Gayo',
      region: 'Aceh, Sumatra 🇮🇩',
      defaultVariety: 'Sigarar Utang / TimTim',
      process: 'Natural',
      roast: 'Light-Medium',
      defaultNotes: ['Red Grape & Winey', 'Strawberry', 'Dark Chocolate'],
      color: Color(0xFF8E24AA),
      emoji: '🍒',
    ),
    BeanVisualItem(
      name: 'Aceh Bener Meriah',
      region: 'Bener Meriah, Aceh 🇮🇩',
      defaultVariety: 'Ateng Super / Bourbon',
      process: 'Washed',
      roast: 'Light-Medium',
      defaultNotes: ['Sweet Orange', 'Wild Honey', 'Black Tea & Earl Grey'],
      color: Color(0xFFFB8C00),
      emoji: '🍊',
    ),
    BeanVisualItem(
      name: 'Sumatra Kerinci Kayu Aro',
      region: 'Jambi, Sumatra 🇮🇩',
      defaultVariety: 'Andungsari / Typica',
      process: 'Anaerobic Natural',
      roast: 'Light',
      defaultNotes: ['Tropical Mango', 'Passion Fruit', 'Red Grape & Winey'],
      color: Color(0xFFD81B60),
      emoji: '🥭',
    ),
    BeanVisualItem(
      name: 'Sumatra Mandheling',
      region: 'Mandailing Natal, Sumatra 🇮🇩',
      defaultVariety: 'Ateng Super',
      process: 'Wet Hulled (Giling Basah)',
      roast: 'Medium-Dark',
      defaultNotes: ['Dark Chocolate', 'Herbal & Lemongrass', 'Roasted Hazelnut'],
      color: Color(0xFF4E342E),
      emoji: '🪵',
    ),
    BeanVisualItem(
      name: 'Sumatra Lintong Nihuta',
      region: 'Humbang Hasundutan, Sumatra 🇮🇩',
      defaultVariety: 'Lasuna / Garunggang',
      process: 'Wet Hulled (Giling Basah)',
      roast: 'Medium',
      defaultNotes: ['Dark Chocolate', 'Herbal & Lemongrass', 'Sweet Orange'],
      color: Color(0xFF2E7D32),
      emoji: '🌿',
    ),
    BeanVisualItem(
      name: 'Sumatra Sidikalang',
      region: 'Dairi, Sumatra Utara 🇮🇩',
      defaultVariety: 'Typica S795',
      process: 'Washed',
      roast: 'Medium',
      defaultNotes: ['Caramel & Brown Sugar', 'Dark Chocolate', 'Roasted Almond'],
      color: Color(0xFF5D4037),
      emoji: '🌰',
    ),
    BeanVisualItem(
      name: 'Sumatra Solok Radjo',
      region: 'Solok, Sumatra Barat 🇮🇩',
      defaultVariety: 'Typica / Kartika',
      process: 'Honey / Pulped Natural',
      roast: 'Light-Medium',
      defaultNotes: ['Lemon & Bergamot', 'Wild Honey', 'Crisp Apple'],
      color: Color(0xFF43A047),
      emoji: '🍏',
    ),
    BeanVisualItem(
      name: 'Sumatra Lahat Pagaralam',
      region: 'Sumatra Selatan 🇮🇩',
      defaultVariety: 'Besemah Arabika',
      process: 'Natural',
      roast: 'Medium',
      defaultNotes: ['Dark Chocolate', 'Roasted Almond', 'Toffee & Butterscotch'],
      color: Color(0xFF6D4C41),
      emoji: '🍫',
    ),
    BeanVisualItem(
      name: 'Bengkulu Kepahiang Kaba',
      region: 'Kepahiang, Bengkulu 🇮🇩',
      defaultVariety: 'Red Bourbon / Kartika',
      process: 'Natural',
      roast: 'Light-Medium',
      defaultNotes: ['Red Cherry', 'Sweet Orange', 'Caramel & Brown Sugar'],
      color: Color(0xFFC2185B),
      emoji: '🍒',
    ),
    BeanVisualItem(
      name: 'Lampung Ulubelu Tanggamus',
      region: 'Tanggamus, Lampung 🇮🇩',
      defaultVariety: 'Fine Robusta / Arabika',
      process: 'Natural',
      roast: 'Medium',
      defaultNotes: ['Milk Chocolate', 'Roasted Hazelnut', 'Caramel & Brown Sugar'],
      color: Color(0xFF795548),
      emoji: '🥜',
    ),

    // JAWA
    BeanVisualItem(
      name: 'Jawa Kamojang Garut',
      region: 'Garut, Jawa Barat 🇮🇩',
      defaultVariety: 'Typica Yellow Bourbon',
      process: 'Washed',
      roast: 'Light',
      defaultNotes: ['Jasmine', 'White Peach', 'Lemon & Bergamot'],
      color: Color(0xFFEC407A),
      emoji: '🌸',
    ),
    BeanVisualItem(
      name: 'Jawa Gunung Puntang',
      region: 'Bandung, Jawa Barat 🇮🇩',
      defaultVariety: 'Red Bourbon / Typica Classic',
      process: 'Natural',
      roast: 'Light-Medium',
      defaultNotes: ['Tropical Mango', 'Wild Honey', 'Clean & Juicy Finish'],
      color: Color(0xFFFFA000),
      emoji: '👑',
    ),
    BeanVisualItem(
      name: 'Jawa Gunung Halu',
      region: 'Bandung Barat, Jawa Barat 🇮🇩',
      defaultVariety: 'Sigarar Utang',
      process: 'Honey / Pulped Natural',
      roast: 'Light-Medium',
      defaultNotes: ['Wild Honey', 'White Peach', 'Sweet Orange'],
      color: Color(0xFFFBC02D),
      emoji: '🍯',
    ),
    BeanVisualItem(
      name: 'Jawa Gunung Manglayang',
      region: 'Bandung Timur, Jawa Barat 🇮🇩',
      defaultVariety: 'Bourbon / Lini S',
      process: 'Washed',
      roast: 'Light-Medium',
      defaultNotes: ['Sweet Orange', 'Caramel & Brown Sugar', 'Crisp Apple'],
      color: Color(0xFF43A047),
      emoji: '🍊',
    ),
    BeanVisualItem(
      name: 'Jawa Preanger Malabar',
      region: 'Pangalengan, Jawa Barat 🇮🇩',
      defaultVariety: 'Typica / Ateng',
      process: 'Honey / Pulped Natural',
      roast: 'Light-Medium',
      defaultNotes: ['Wild Honey', 'White Peach', 'Jasmine'],
      color: Color(0xFFFB8C00),
      emoji: '🍑',
    ),
    BeanVisualItem(
      name: 'Jawa Ciwidey Patuha',
      region: 'Ciwidey, Jawa Barat 🇮🇩',
      defaultVariety: 'Catimor / Typica',
      process: 'Anaerobic Washed',
      roast: 'Light',
      defaultNotes: ['Strawberry', 'Rose & Hibiscus', 'Clean & Juicy Finish'],
      color: Color(0xFFE53935),
      emoji: '🍓',
    ),
    BeanVisualItem(
      name: 'Jawa Papandayan Garut',
      region: 'Garut, Jawa Barat 🇮🇩',
      defaultVariety: 'Typica / Yellow Caturra',
      process: 'Washed',
      roast: 'Light-Medium',
      defaultNotes: ['Lemon & Bergamot', 'Black Tea & Earl Grey', 'Wild Honey'],
      color: Color(0xFF00897B),
      emoji: '🍵',
    ),
    BeanVisualItem(
      name: 'Jawa Ijen Raung',
      region: 'Bondowoso, Jawa Timur 🇮🇩',
      defaultVariety: 'USDA 762 / Typica',
      process: 'Washed',
      roast: 'Medium',
      defaultNotes: ['Crisp Apple', 'Caramel & Brown Sugar', 'Milk Chocolate'],
      color: Color(0xFF689F38),
      emoji: '🍏',
    ),
    BeanVisualItem(
      name: 'Jawa Sindoro Wonosobo',
      region: 'Wonosobo, Jawa Tengah 🇮🇩',
      defaultVariety: 'Kartika / Typica',
      process: 'Natural',
      roast: 'Light-Medium',
      defaultNotes: ['Red Cherry', 'Sweet Orange', 'Wild Honey'],
      color: Color(0xFFD84315),
      emoji: '🍒',
    ),
    BeanVisualItem(
      name: 'Jawa Temanggung',
      region: 'Temanggung, Jawa Tengah 🇮🇩',
      defaultVariety: 'Kartika Arabika',
      process: 'Full Washed',
      roast: 'Medium',
      defaultNotes: ['Tobacco & Spices', 'Dark Chocolate', 'Caramel & Brown Sugar'],
      color: Color(0xFF8D6E63),
      emoji: '☕',
    ),

    // BALI & NUSA TENGGARA
    BeanVisualItem(
      name: 'Bali Kintamani Ulian',
      region: 'Bangli, Bali 🇮🇩',
      defaultVariety: 'Typica / Bourbon',
      process: 'Washed',
      roast: 'Light-Medium',
      defaultNotes: ['Sweet Orange', 'Caramel & Brown Sugar', 'Black Tea & Earl Grey'],
      color: Color(0xFFFB8C00),
      emoji: '🍊',
    ),
    BeanVisualItem(
      name: 'Bali Belantih Kintamani',
      region: 'Kintamani, Bali 🇮🇩',
      defaultVariety: 'Kopyol / Typica',
      process: 'Natural',
      roast: 'Light',
      defaultNotes: ['Tropical Mango', 'Passion Fruit', 'Sweet Orange'],
      color: Color(0xFFFFA000),
      emoji: '🥭',
    ),
    BeanVisualItem(
      name: 'Lombok Sembalun Rinjani',
      region: 'Lombok Timur, NTB 🇮🇩',
      defaultVariety: 'Typica / Juria',
      process: 'Washed',
      roast: 'Light-Medium',
      defaultNotes: ['Crisp Apple', 'Wild Honey', 'Lemon & Bergamot'],
      color: Color(0xFF43A047),
      emoji: '🏔️',
    ),
    BeanVisualItem(
      name: 'Sumbawa Tambora',
      region: 'Tambora, NTB 🇮🇩',
      defaultVariety: 'Arabika Tambora',
      process: 'Honey / Pulped Natural',
      roast: 'Medium',
      defaultNotes: ['Brown Sugar', 'Dark Chocolate', 'Roasted Almond'],
      color: Color(0xFF6D4C41),
      emoji: '🌋',
    ),
    BeanVisualItem(
      name: 'Flores Bajawa Ngada',
      region: 'Ngada, NTT 🇮🇩',
      defaultVariety: 'Yellow Caturra',
      process: 'Natural',
      roast: 'Medium',
      defaultNotes: ['Dark Chocolate', 'Roasted Almond', 'Caramel & Brown Sugar'],
      color: Color(0xFF6D4C41),
      emoji: '🍫',
    ),
    BeanVisualItem(
      name: 'Flores Manggarai Colol',
      region: 'Manggarai Timur, NTT 🇮🇩',
      defaultVariety: 'Juria / Yellow Caturra',
      process: 'Washed',
      roast: 'Light-Medium',
      defaultNotes: ['Lemon & Bergamot', 'Black Tea & Earl Grey', 'Wild Honey'],
      color: Color(0xFF00897B),
      emoji: '☕',
    ),

    // SULAWESI
    BeanVisualItem(
      name: 'Toraja Sapan',
      region: 'Tana Toraja, Sulawesi 🇮🇩',
      defaultVariety: 'Typica S795',
      process: 'Washed',
      roast: 'Medium',
      defaultNotes: ['Herbal & Lemongrass', 'Sweet Orange', 'Dark Chocolate'],
      color: Color(0xFF2E7D32),
      emoji: '🌿',
    ),
    BeanVisualItem(
      name: 'Toraja Pulu Pulu',
      region: 'Toraja Utara, Sulawesi 🇮🇩',
      defaultVariety: 'Typica Heirloom (2000 mdpl)',
      process: 'Washed',
      roast: 'Light',
      defaultNotes: ['Jasmine', 'White Peach', 'Clean & Juicy Finish'],
      color: Color(0xFF00ACC1),
      emoji: '✨',
    ),
    BeanVisualItem(
      name: 'Enrekang Kalosi Benteng Alla',
      region: 'Enrekang, Sulawesi 🇮🇩',
      defaultVariety: 'Lini S / Typica',
      process: 'Honey / Pulped Natural',
      roast: 'Light-Medium',
      defaultNotes: ['Wild Honey', 'Sweet Orange', 'Black Tea & Earl Grey'],
      color: Color(0xFFFB8C00),
      emoji: '🍊',
    ),
    BeanVisualItem(
      name: 'Mamasa Gandangbatu',
      region: 'Sulawesi Barat 🇮🇩',
      defaultVariety: 'Typica S795',
      process: 'Natural',
      roast: 'Light-Medium',
      defaultNotes: ['Red Grape & Winey', 'Strawberry', 'Caramel & Brown Sugar'],
      color: Color(0xFF8E24AA),
      emoji: '🍇',
    ),

    // PAPUA
    BeanVisualItem(
      name: 'Papua Wamena Lembah Baliem',
      region: 'Jayawijaya, Papua 🇮🇩',
      defaultVariety: 'Typica Blue Mountain',
      process: 'Washed',
      roast: 'Light-Medium',
      defaultNotes: ['Wild Honey', 'Crisp Apple', 'Clean & Juicy Finish'],
      color: Color(0xFF43A047),
      emoji: '🏔️',
    ),
    BeanVisualItem(
      name: 'Papua Moanemani Dogiyai',
      region: 'Dogiyai, Papua 🇮🇩',
      defaultVariety: 'Typica Heirloom',
      process: 'Washed',
      roast: 'Light-Medium',
      defaultNotes: ['Black Tea & Earl Grey', 'Sweet Orange', 'Wild Honey'],
      color: Color(0xFF00897B),
      emoji: '☕',
    ),
    BeanVisualItem(
      name: 'Papua Tiom Lanny Jaya',
      region: 'Pegunungan Papua 🇮🇩',
      defaultVariety: 'Bourbon / Typica',
      process: 'Natural',
      roast: 'Light',
      defaultNotes: ['Tropical Mango', 'Red Cherry', 'Clean & Juicy Finish'],
      color: Color(0xFFD81B60),
      emoji: '🥭',
    ),

    // DUNIA & INTERNASIONAL
    BeanVisualItem(
      name: 'Ethiopia Yirgacheffe',
      region: 'Yirgacheffe, Ethiopia 🇪🇹',
      defaultVariety: 'Heirloom / Landrace',
      process: 'Washed',
      roast: 'Light',
      defaultNotes: ['Jasmine', 'Lemon & Bergamot', 'Black Tea & Earl Grey'],
      color: Color(0xFFEC407A),
      emoji: '🌸',
    ),
    BeanVisualItem(
      name: 'Ethiopia Guji',
      region: 'Guji, Ethiopia 🇪🇹',
      defaultVariety: 'Heirloom / Landrace',
      process: 'Natural',
      roast: 'Light',
      defaultNotes: ['Blueberry & Currant', 'Strawberry', 'Jasmine'],
      color: Color(0xFF5E35B1),
      emoji: '🫐',
    ),
    BeanVisualItem(
      name: 'Ethiopia Sidama Bombe',
      region: 'Sidama, Ethiopia 🇪🇹',
      defaultVariety: '74110 / 74112',
      process: 'Anaerobic Washed',
      roast: 'Light',
      defaultNotes: ['White Peach', 'Wild Honey', 'Lemon & Bergamot'],
      color: Color(0xFFF06292),
      emoji: '🍑',
    ),
    BeanVisualItem(
      name: 'Kenya AA Nyeri',
      region: 'Nyeri, Kenya 🇰🇪',
      defaultVariety: 'SL28 / SL34',
      process: 'Washed',
      roast: 'Light',
      defaultNotes: ['Blueberry & Currant', 'Lemon & Bergamot', 'Clean & Juicy Finish'],
      color: Color(0xFF3949AB),
      emoji: '🍇',
    ),
    BeanVisualItem(
      name: 'Rwanda Nyamasheke Red Bourbon',
      region: 'Lake Kivu, Rwanda 🇷🇼',
      defaultVariety: 'Red Bourbon',
      process: 'Washed',
      roast: 'Light-Medium',
      defaultNotes: ['Black Tea & Earl Grey', 'Sweet Orange', 'Crisp Apple'],
      color: Color(0xFF00897B),
      emoji: '🍵',
    ),
    BeanVisualItem(
      name: 'Burundi Kayanza',
      region: 'Kayanza, Burundi 🇧🇮',
      defaultVariety: 'Red Bourbon',
      process: 'Natural',
      roast: 'Light',
      defaultNotes: ['Red Cherry', 'Caramel & Brown Sugar', 'Silky Body'],
      color: Color(0xFFC2185B),
      emoji: '🍒',
    ),
    BeanVisualItem(
      name: 'Panama Boquete Gesha',
      region: 'Boquete, Panama 🇵🇦',
      defaultVariety: 'Geisha / Gesha',
      process: 'Washed',
      roast: 'Light',
      defaultNotes: ['Jasmine', 'White Peach', 'Wild Honey', 'Lemon & Bergamot'],
      color: Color(0xFFD81B60),
      emoji: '👑',
    ),
    BeanVisualItem(
      name: 'Colombia Pink Bourbon Huila',
      region: 'Huila, Colombia 🇨🇴',
      defaultVariety: 'Pink Bourbon',
      process: 'Anaerobic Natural',
      roast: 'Light',
      defaultNotes: ['Tropical Mango', 'Strawberry', 'Clean & Juicy Finish'],
      color: Color(0xFFE53935),
      emoji: '🥭',
    ),
    BeanVisualItem(
      name: 'Colombia Thermal Shock Gesha',
      region: 'Valle del Cauca, Colombia 🇨🇴',
      defaultVariety: 'Geisha / Gesha',
      process: 'Thermal Shock',
      roast: 'Light',
      defaultNotes: ['Passion Fruit', 'Rose & Hibiscus', 'Lychee & Guava'],
      color: Color(0xFF9C27B0),
      emoji: '🧪',
    ),
    BeanVisualItem(
      name: 'Costa Rica Tarrazu',
      region: 'Tarrazu, Costa Rica 🇨🇷',
      defaultVariety: 'Caturra / Catuai',
      process: 'Honey / Pulped Natural',
      roast: 'Light-Medium',
      defaultNotes: ['Wild Honey', 'Crisp Apple', 'Caramel & Brown Sugar'],
      color: Color(0xFFFFA000),
      emoji: '🍯',
    ),
    BeanVisualItem(
      name: 'Guatemala Antigua Pastoral',
      region: 'Antigua, Guatemala 🇬🇹',
      defaultVariety: 'Bourbon / Typica',
      process: 'Washed',
      roast: 'Medium',
      defaultNotes: ['Milk Chocolate', 'Sweet Orange', 'Roasted Almond'],
      color: Color(0xFF6D4C41),
      emoji: '🍫',
    ),
    BeanVisualItem(
      name: 'Brazil Cerrado Mineiro',
      region: 'Minas Gerais, Brazil 🇧🇷',
      defaultVariety: 'Yellow Catuai / Mundo Novo',
      process: 'Natural',
      roast: 'Medium',
      defaultNotes: ['Dark Chocolate', 'Roasted Hazelnut', 'Vanilla & Creamy'],
      color: Color(0xFF5D4037),
      emoji: '🥜',
    ),
    BeanVisualItem(
      name: 'El Salvador Pacamara',
      region: 'Santa Ana, El Salvador 🇸🇻',
      defaultVariety: 'Pacamara',
      process: 'Honey / Pulped Natural',
      roast: 'Light-Medium',
      defaultNotes: ['White Peach', 'Red Grape & Winey', 'Maple Syrup'],
      color: Color(0xFFE65100),
      emoji: '🍑',
    ),
    BeanVisualItem(
      name: 'Yemen Mokha Matari',
      region: 'Bani Matar, Yemen 🇾🇪',
      defaultVariety: 'Yemenia / Heirloom',
      process: 'Natural',
      roast: 'Medium',
      defaultNotes: ['Dark Chocolate', 'Cinnamon & Spices', 'Red Grape & Winey'],
      color: Color(0xFF880E4F),
      emoji: '🏺',
    ),
  ];

  static const List<FlavorNoteVisualItem> flavorNotes = [
    // 🌸 FLORAL
    FlavorNoteVisualItem(label: 'Jasmine', group: 'Floral', emoji: '🌸', color: Color(0xFFEC407A)),
    FlavorNoteVisualItem(label: 'Orange Blossom', group: 'Floral', emoji: '🌼', color: Color(0xFFFFB300)),
    FlavorNoteVisualItem(label: 'Rose', group: 'Floral', emoji: '🌹', color: Color(0xFFE91E63)),
    FlavorNoteVisualItem(label: 'Hibiscus', group: 'Floral', emoji: '🌺', color: Color(0xFFD81B60)),
    FlavorNoteVisualItem(label: 'Lavender', group: 'Floral', emoji: '🪻', color: Color(0xFF7E57C2)),
    FlavorNoteVisualItem(label: 'Chamomile', group: 'Floral', emoji: '🌼', color: Color(0xFFFDD835)),
    FlavorNoteVisualItem(label: 'Elderflower', group: 'Floral', emoji: '💮', color: Color(0xFFFFF9C4)),
    FlavorNoteVisualItem(label: 'Magnolia', group: 'Floral', emoji: '🌸', color: Color(0xFFF48FB1)),
    FlavorNoteVisualItem(label: 'Coffee Blossom', group: 'Floral', emoji: '🤍', color: Color(0xFFE0E0E0)),

    // 🍑 STONE FRUIT (FRUITY)
    FlavorNoteVisualItem(label: 'White Peach', group: 'Stone Fruit', emoji: '🍑', color: Color(0xFFFF7043)),
    FlavorNoteVisualItem(label: 'Yellow Peach', group: 'Stone Fruit', emoji: '🍑', color: Color(0xFFFF8A65)),
    FlavorNoteVisualItem(label: 'Apricot', group: 'Stone Fruit', emoji: '🍑', color: Color(0xFFF4511E)),
    FlavorNoteVisualItem(label: 'Dark Plum', group: 'Stone Fruit', emoji: '🫐', color: Color(0xFF6A1B9A)),
    FlavorNoteVisualItem(label: 'Red Cherry', group: 'Stone Fruit', emoji: '🍒', color: Color(0xFFD32F2F)),
    FlavorNoteVisualItem(label: 'Sweet Cherry', group: 'Stone Fruit', emoji: '🍒', color: Color(0xFFC2185B)),
    FlavorNoteVisualItem(label: 'Nectarine', group: 'Stone Fruit', emoji: '🍑', color: Color(0xFFFF5722)),

    // 🥭 TROPICAL FRUIT (FRUITY)
    FlavorNoteVisualItem(label: 'Tropical Mango', group: 'Tropical', emoji: '🥭', color: Color(0xFFFFA000)),
    FlavorNoteVisualItem(label: 'Ripe Mango', group: 'Tropical', emoji: '🥭', color: Color(0xFFFFB300)),
    FlavorNoteVisualItem(label: 'Passion Fruit', group: 'Tropical', emoji: '🍈', color: Color(0xFFFF8F00)),
    FlavorNoteVisualItem(label: 'Pineapple', group: 'Tropical', emoji: '🍍', color: Color(0xFFFFD600)),
    FlavorNoteVisualItem(label: 'Lychee', group: 'Tropical', emoji: '🍈', color: Color(0xFFF06292)),
    FlavorNoteVisualItem(label: 'Pink Guava', group: 'Tropical', emoji: '🍈', color: Color(0xFFE91E63)),
    FlavorNoteVisualItem(label: 'Papaya', group: 'Tropical', emoji: '🍈', color: Color(0xFFFF7043)),
    FlavorNoteVisualItem(label: 'Sweet Melon / Honeydew', group: 'Tropical', emoji: '🍈', color: Color(0xFF81C784)),
    FlavorNoteVisualItem(label: 'Jackfruit (Nangka)', group: 'Tropical', emoji: '🍈', color: Color(0xFFFFB74D)),
    FlavorNoteVisualItem(label: 'Dragonfruit', group: 'Tropical', emoji: '🌺', color: Color(0xFFAD1457)),
    FlavorNoteVisualItem(label: 'Starfruit (Belimbing)', group: 'Tropical', emoji: '⭐', color: Color(0xFFDCE775)),
    FlavorNoteVisualItem(label: 'Banana', group: 'Tropical', emoji: '🍌', color: Color(0xFFFFEE58)),

    // 🍎 ORCHARD FRUIT (FRUITY)
    FlavorNoteVisualItem(label: 'Crisp Green Apple', group: 'Orchard Fruit', emoji: '🍏', color: Color(0xFF43A047)),
    FlavorNoteVisualItem(label: 'Red Fuji Apple', group: 'Orchard Fruit', emoji: '🍎', color: Color(0xFFE53935)),
    FlavorNoteVisualItem(label: 'Juicy Pear', group: 'Orchard Fruit', emoji: '🍐', color: Color(0xFFAED581)),
    FlavorNoteVisualItem(label: 'White Grape', group: 'Orchard Fruit', emoji: '🍇', color: Color(0xFF81C784)),
    FlavorNoteVisualItem(label: 'Red Grape', group: 'Orchard Fruit', emoji: '🍇', color: Color(0xFF8E24AA)),
    FlavorNoteVisualItem(label: 'Pomegranate (Delima)', group: 'Orchard Fruit', emoji: '🍒', color: Color(0xFFB71C1C)),
    FlavorNoteVisualItem(label: 'Fig (Buah Tin)', group: 'Orchard Fruit', emoji: '🫐', color: Color(0xFF4A148C)),

    // 🍋 CITRUS
    FlavorNoteVisualItem(label: 'Lemon', group: 'Citrus', emoji: '🍋', color: Color(0xFFFBC02D)),
    FlavorNoteVisualItem(label: 'Bergamot', group: 'Citrus', emoji: '🍋', color: Color(0xFFC0CA33)),
    FlavorNoteVisualItem(label: 'Sweet Orange', group: 'Citrus', emoji: '🍊', color: Color(0xFFFB8C00)),
    FlavorNoteVisualItem(label: 'Blood Orange', group: 'Citrus', emoji: '🍊', color: Color(0xFFD84315)),
    FlavorNoteVisualItem(label: 'Lime', group: 'Citrus', emoji: '🍈', color: Color(0xFF7CB342)),
    FlavorNoteVisualItem(label: 'Grapefruit', group: 'Citrus', emoji: '🍈', color: Color(0xFFFF7043)),
    FlavorNoteVisualItem(label: 'Tangerine / Mandarin', group: 'Citrus', emoji: '🍊', color: Color(0xFFFF9800)),
    FlavorNoteVisualItem(label: 'Yuzu', group: 'Citrus', emoji: '🍋', color: Color(0xFFFFEA00)),
    FlavorNoteVisualItem(label: 'Kumquat', group: 'Citrus', emoji: '🍊', color: Color(0xFFFFA726)),

    // 🍓 BERRY
    FlavorNoteVisualItem(label: 'Strawberry', group: 'Berry', emoji: '🍓', color: Color(0xFFE53935)),
    FlavorNoteVisualItem(label: 'Wild Blueberry', group: 'Berry', emoji: '🫐', color: Color(0xFF5E35B1)),
    FlavorNoteVisualItem(label: 'Raspberry', group: 'Berry', emoji: '🍓', color: Color(0xFFC2185B)),
    FlavorNoteVisualItem(label: 'Blackcurrant', group: 'Berry', emoji: '🫐', color: Color(0xFF311B92)),
    FlavorNoteVisualItem(label: 'Blackberry', group: 'Berry', emoji: '🫐', color: Color(0xFF4A148C)),
    FlavorNoteVisualItem(label: 'Cranberry', group: 'Berry', emoji: '🍒', color: Color(0xFF880E4F)),
    FlavorNoteVisualItem(label: 'Mulberry', group: 'Berry', emoji: '🫐', color: Color(0xFF3949AB)),

    // 🍯 SWEET & CONFECTION
    FlavorNoteVisualItem(label: 'Wild Honey', group: 'Sweet', emoji: '🍯', color: Color(0xFFF9A825)),
    FlavorNoteVisualItem(label: 'Caramel', group: 'Sweet', emoji: '🍮', color: Color(0xFFD84315)),
    FlavorNoteVisualItem(label: 'Brown Sugar', group: 'Sweet', emoji: '🍮', color: Color(0xFFA1887F)),
    FlavorNoteVisualItem(label: 'Gula Aren / Palm Sugar', group: 'Sweet', emoji: '🥥', color: Color(0xFF795548)),
    FlavorNoteVisualItem(label: 'Toffee & Butterscotch', group: 'Sweet', emoji: '🍬', color: Color(0xFFE65100)),
    FlavorNoteVisualItem(label: 'Maple Syrup', group: 'Sweet', emoji: '🍁', color: Color(0xFF8D6E63)),
    FlavorNoteVisualItem(label: 'Vanilla', group: 'Sweet', emoji: '🍦', color: Color(0xFFAB47BC)),
    FlavorNoteVisualItem(label: 'Molasses', group: 'Sweet', emoji: '🍯', color: Color(0xFF4E342E)),
    FlavorNoteVisualItem(label: 'Marshmallow', group: 'Sweet', emoji: '🍥', color: Color(0xFFE1BEE7)),

    // 🍫 CHOCOLATE & COCOA
    FlavorNoteVisualItem(label: 'Dark Chocolate', group: 'Cocoa', emoji: '🍫', color: Color(0xFF4E342E)),
    FlavorNoteVisualItem(label: 'Milk Chocolate', group: 'Cocoa', emoji: '🍫', color: Color(0xFF795548)),
    FlavorNoteVisualItem(label: 'Cocoa Nibs', group: 'Cocoa', emoji: '🍫', color: Color(0xFF3E2723)),
    FlavorNoteVisualItem(label: 'White Chocolate', group: 'Cocoa', emoji: '🍫', color: Color(0xFFD7CCC8)),

    // 🥜 NUTTY
    FlavorNoteVisualItem(label: 'Roasted Almond', group: 'Nutty', emoji: '🥜', color: Color(0xFF8D6E63)),
    FlavorNoteVisualItem(label: 'Roasted Hazelnut', group: 'Nutty', emoji: '🌰', color: Color(0xFFA1887F)),
    FlavorNoteVisualItem(label: 'Walnut & Pecan', group: 'Nutty', emoji: '🌰', color: Color(0xFF6D4C41)),
    FlavorNoteVisualItem(label: 'Pistachio', group: 'Nutty', emoji: '🥜', color: Color(0xFF81C784)),
    FlavorNoteVisualItem(label: 'Cashew (Kacang Mede)', group: 'Nutty', emoji: '🥜', color: Color(0xFFBCAAA4)),

    // 🪵 SPICES & HERBAL
    FlavorNoteVisualItem(label: 'Cinnamon (Kayu Manis)', group: 'Herbal', emoji: '🪵', color: Color(0xFFBF360C)),
    FlavorNoteVisualItem(label: 'Clove (Cengkeh)', group: 'Herbal', emoji: '🪵', color: Color(0xFF5D4037)),
    FlavorNoteVisualItem(label: 'Cardamom (Kapulaga)', group: 'Herbal', emoji: '🌿', color: Color(0xFF689F38)),
    FlavorNoteVisualItem(label: 'Fresh Ginger (Jahe)', group: 'Herbal', emoji: '🫚', color: Color(0xFFFFB300)),
    FlavorNoteVisualItem(label: 'Lemongrass (Serai)', group: 'Herbal', emoji: '🌿', color: Color(0xFF388E3C)),
    FlavorNoteVisualItem(label: 'Mint Leaf', group: 'Herbal', emoji: '🌱', color: Color(0xFF00BFA5)),
    FlavorNoteVisualItem(label: 'Star Anise (Pekak)', group: 'Herbal', emoji: '⭐', color: Color(0xFF4E342E)),

    // 🍷 WINEY & FERMENT
    FlavorNoteVisualItem(label: 'Red Wine', group: 'Winey', emoji: '🍷', color: Color(0xFF8E24AA)),
    FlavorNoteVisualItem(label: 'White Wine', group: 'Winey', emoji: '🥂', color: Color(0xFFC0CA33)),
    FlavorNoteVisualItem(label: 'Rum Raisin', group: 'Winey', emoji: '🥃', color: Color(0xFF6A1B9A)),
    FlavorNoteVisualItem(label: 'Bourbon Whiskey', group: 'Winey', emoji: '🥃', color: Color(0xFFD84315)),
    FlavorNoteVisualItem(label: 'Apple Cider', group: 'Winey', emoji: '🍾', color: Color(0xFFFF8F00)),
    FlavorNoteVisualItem(label: 'Fermented Kombucha', group: 'Winey', emoji: '🍷', color: Color(0xFF7B1FA2)),

    // 🍵 TEA-LIKE
    FlavorNoteVisualItem(label: 'Black Tea', group: 'Tea-like', emoji: '🍵', color: Color(0xFF00897B)),
    FlavorNoteVisualItem(label: 'Earl Grey', group: 'Tea-like', emoji: '🍵', color: Color(0xFF00695C)),
    FlavorNoteVisualItem(label: 'Jasmine Green Tea', group: 'Tea-like', emoji: '🍵', color: Color(0xFF2E7D32)),
    FlavorNoteVisualItem(label: 'Oolong Tea', group: 'Tea-like', emoji: '🍵', color: Color(0xFF558B2F)),
    FlavorNoteVisualItem(label: 'Cascara Tea', group: 'Tea-like', emoji: '🍒', color: Color(0xFFC2185B)),

    // ✨ MOUTHFEEL & FINISH
    FlavorNoteVisualItem(label: 'Clean & Juicy Finish', group: 'Mouthfeel', emoji: '✨', color: Color(0xFF1E88E5)),
    FlavorNoteVisualItem(label: 'Silky Body', group: 'Mouthfeel', emoji: '🥛', color: Color(0xFF00ACC1)),
    FlavorNoteVisualItem(label: 'Creamy & Round', group: 'Mouthfeel', emoji: '🧈', color: Color(0xFFFFB300)),
    FlavorNoteVisualItem(label: 'Velvety & Dense', group: 'Mouthfeel', emoji: '☕', color: Color(0xFF5D4037)),
  ];

  static const List<GrinderModel> grinderModels = [
    GrinderModel(
      id: 'comandante_c40',
      name: 'Comandante C40 MK3/MK4',
      brand: 'Comandante',
      typeDescription: 'Nitro Blade Hand Grinder 39mm',
      imagePath: 'assets/images/grinders/comandante_c40.png',
      isElectric: false,
      minClicks: 10,
      maxClicks: 40,
      defaultClicks: 23,
      micronsPerClick: 30.0,
      fineClick: 15,
      medFineClick: 19,
      mediumClick: 23,
      medCoarseClick: 27,
      coarseClick: 32,
    ),
    GrinderModel(
      id: 'timemore_c2_c3',
      name: 'Timemore C2 / C3 Chestnut',
      brand: 'Timemore',
      typeDescription: 'Conical S2C 38mm Hand Grinder',
      imagePath: 'assets/images/grinders/timemore_c2_c3.png',
      isElectric: false,
      minClicks: 8,
      maxClicks: 32,
      defaultClicks: 18,
      micronsPerClick: 36.0,
      fineClick: 12,
      medFineClick: 15,
      mediumClick: 18,
      medCoarseClick: 22,
      coarseClick: 26,
    ),
    GrinderModel(
      id: 'timemore_c3_esp',
      name: 'Timemore C3 ESP Pro',
      brand: 'Timemore',
      typeDescription: '0.023mm Micro Step 30 Clicks/Rev',
      imagePath: 'assets/images/grinders/timemore_c3_esp.png',
      isElectric: false,
      minClicks: 20,
      maxClicks: 90,
      defaultClicks: 55,
      micronsPerClick: 23.0,
      fineClick: 35,
      medFineClick: 45,
      mediumClick: 55,
      medCoarseClick: 68,
      coarseClick: 80,
    ),
    GrinderModel(
      id: 'timemore_x_lite',
      name: 'Timemore Chestnut X Lite',
      brand: 'Timemore',
      typeDescription: 'S2C880 Flagship Conical Burr',
      imagePath: 'assets/images/grinders/timemore_x_lite.png',
      isElectric: false,
      minClicks: 8,
      maxClicks: 30,
      defaultClicks: 16,
      micronsPerClick: 42.0,
      fineClick: 10,
      medFineClick: 13,
      mediumClick: 16,
      medCoarseClick: 20,
      coarseClick: 24,
    ),
    GrinderModel(
      id: 'timemore_slim',
      name: 'Timemore Slim Plus / Nano',
      brand: 'Timemore',
      typeDescription: 'Slim Diamond Cut Aluminium 38mm',
      imagePath: 'assets/images/grinders/timemore_slim.png',
      isElectric: false,
      minClicks: 8,
      maxClicks: 30,
      defaultClicks: 17,
      micronsPerClick: 38.0,
      fineClick: 11,
      medFineClick: 14,
      mediumClick: 17,
      medCoarseClick: 21,
      coarseClick: 25,
    ),
    GrinderModel(
      id: 'vesper_pro',
      name: 'Vesper Pro Grinder',
      brand: 'Vesper',
      typeDescription: '48mm Titanium Burr (Laris Indonesia)',
      imagePath: 'assets/images/grinders/vesper_pro.png',
      isElectric: false,
      minClicks: 20,
      maxClicks: 120,
      defaultClicks: 75,
      micronsPerClick: 18.0,
      fineClick: 45,
      medFineClick: 60,
      mediumClick: 75,
      medCoarseClick: 90,
      coarseClick: 105,
    ),
    GrinderModel(
      id: 'o_two_cups',
      name: 'O-Two Cups Pro Stainless',
      brand: 'O Two Cups',
      typeDescription: 'CNC Stainless Steel Best Seller Shopee',
      imagePath: 'assets/images/grinders/o_two_cups.png',
      isElectric: false,
      minClicks: 8,
      maxClicks: 36,
      defaultClicks: 18,
      micronsPerClick: 35.0,
      fineClick: 12,
      medFineClick: 15,
      mediumClick: 18,
      medCoarseClick: 22,
      coarseClick: 28,
    ),
    GrinderModel(
      id: 'mhw_3bomber_race',
      name: 'MHW-3BOMBER Race M1',
      brand: 'MHW-3BOMBER',
      typeDescription: '38mm CNC High Precision Burr',
      imagePath: 'assets/images/grinders/mhw_3bomber_race.png',
      isElectric: false,
      minClicks: 15,
      maxClicks: 70,
      defaultClicks: 40,
      micronsPerClick: 24.0,
      fineClick: 25,
      medFineClick: 32,
      mediumClick: 40,
      medCoarseClick: 50,
      coarseClick: 60,
    ),
    GrinderModel(
      id: 'mhw_3bomber_sonic',
      name: 'MHW-3BOMBER Sonic S1',
      brand: 'MHW-3BOMBER',
      typeDescription: '48mm Heptagonal External Adjust',
      imagePath: 'assets/images/grinders/mhw_3bomber_sonic.png',
      isElectric: false,
      minClicks: 20,
      maxClicks: 100,
      defaultClicks: 65,
      micronsPerClick: 18.0,
      fineClick: 40,
      medFineClick: 52,
      mediumClick: 65,
      medCoarseClick: 78,
      coarseClick: 90,
    ),
    GrinderModel(
      id: 'kinu_m47',
      name: 'Kinu M47 Phoenix',
      brand: 'Kinu',
      typeDescription: 'Black Fusion 47mm Stepless 50 Div',
      imagePath: 'assets/images/grinders/kinu_m47.png',
      isElectric: false,
      minClicks: 10,
      maxClicks: 50,
      defaultClicks: 32,
      micronsPerClick: 20.0,
      fineClick: 18,
      medFineClick: 25,
      mediumClick: 32,
      medCoarseClick: 38,
      coarseClick: 45,
    ),
    GrinderModel(
      id: 'hero_s01',
      name: 'Hero S01 Hand Grinder',
      brand: 'Hero',
      typeDescription: 'CNC Conical Steel Burr Indonesia',
      imagePath: 'assets/images/grinders/hero_s01.png',
      isElectric: false,
      minClicks: 8,
      maxClicks: 36,
      defaultClicks: 18,
      micronsPerClick: 36.0,
      fineClick: 12,
      medFineClick: 15,
      mediumClick: 18,
      medCoarseClick: 22,
      coarseClick: 28,
    ),
    GrinderModel(
      id: 'one_two_cups_vintage',
      name: 'One Two Cups Classic',
      brand: 'One Two Cups',
      typeDescription: 'Manual Grinder Murah Sejuta Umat',
      imagePath: 'assets/images/grinders/one_two_cups_vintage.png',
      isElectric: false,
      minClicks: 6,
      maxClicks: 30,
      defaultClicks: 15,
      micronsPerClick: 45.0,
      fineClick: 10,
      medFineClick: 12,
      mediumClick: 15,
      medCoarseClick: 19,
      coarseClick: 24,
    ),
    GrinderModel(
      id: 'pietro_manual',
      name: 'Pietro Manual Flat Burr 58mm',
      brand: 'Pietro / Fiorenzato',
      typeDescription: 'Vertical Flat Burr 58mm Multipurpose',
      imagePath: 'assets/images/grinders/pietro_manual.png',
      isElectric: false,
      minClicks: 1,
      maxClicks: 10,
      defaultClicks: 6,
      micronsPerClick: 80.0,
      fineClick: 3,
      medFineClick: 4,
      mediumClick: 6,
      medCoarseClick: 7,
      coarseClick: 9,
    ),
    GrinderModel(
      id: 'kingrinder_k6',
      name: 'Kingrinder K6',
      brand: 'Kingrinder',
      typeDescription: 'Heptagonal 48mm External Dial',
      imagePath: 'assets/images/grinders/kingrinder_k6.png',
      isElectric: false,
      minClicks: 30,
      maxClicks: 140,
      defaultClicks: 90,
      micronsPerClick: 16.0,
      fineClick: 60,
      medFineClick: 75,
      mediumClick: 90,
      medCoarseClick: 105,
      coarseClick: 120,
    ),
    GrinderModel(
      id: 'kingrinder_k2',
      name: 'Kingrinder K2 / K4',
      brand: 'Kingrinder',
      typeDescription: 'Budget Hero Marketplace 48mm',
      imagePath: 'assets/images/grinders/kingrinder_k2.png',
      isElectric: false,
      minClicks: 25,
      maxClicks: 120,
      defaultClicks: 70,
      micronsPerClick: 18.0,
      fineClick: 45,
      medFineClick: 58,
      mediumClick: 70,
      medCoarseClick: 85,
      coarseClick: 100,
    ),
    GrinderModel(
      id: '1zpresso_k_ultra',
      name: '1Zpresso K-Ultra / K-Max',
      brand: '1Zpresso',
      typeDescription: 'Foldable Handle K-Burr 48mm',
      imagePath: 'assets/images/grinders/1zpresso_k_ultra.png',
      isElectric: false,
      minClicks: 35,
      maxClicks: 105,
      defaultClicks: 70,
      micronsPerClick: 20.0,
      fineClick: 50,
      medFineClick: 62,
      mediumClick: 70,
      medCoarseClick: 80,
      coarseClick: 92,
    ),
    GrinderModel(
      id: '1zpresso_jx_pro',
      name: '1Zpresso JX-Pro / J-Max',
      brand: '1Zpresso',
      typeDescription: 'Top Adjustment 48mm Titanium',
      imagePath: 'assets/images/grinders/1zpresso_jx_pro.png',
      isElectric: false,
      minClicks: 80,
      maxClicks: 260,
      defaultClicks: 170,
      micronsPerClick: 12.5,
      fineClick: 120,
      medFineClick: 150,
      mediumClick: 175,
      medCoarseClick: 200,
      coarseClick: 230,
    ),
    GrinderModel(
      id: '1zpresso_q2',
      name: '1Zpresso Q2 Air / Heptagonal',
      brand: '1Zpresso',
      typeDescription: 'Compact Travel Fits Inside AeroPress',
      imagePath: 'assets/images/grinders/1zpresso_q2.png',
      isElectric: false,
      minClicks: 15,
      maxClicks: 65,
      defaultClicks: 38,
      micronsPerClick: 30.0,
      fineClick: 24,
      medFineClick: 32,
      mediumClick: 38,
      medCoarseClick: 46,
      coarseClick: 54,
    ),
    GrinderModel(
      id: 'hario_skerton',
      name: 'Hario Skerton Pro / Plus',
      brand: 'Hario',
      typeDescription: 'Ceramic Conical Glass Canister',
      imagePath: 'assets/images/grinders/hario_skerton.png',
      isElectric: false,
      minClicks: 4,
      maxClicks: 18,
      defaultClicks: 10,
      micronsPerClick: 60.0,
      fineClick: 6,
      medFineClick: 8,
      mediumClick: 10,
      medCoarseClick: 13,
      coarseClick: 16,
    ),
    GrinderModel(
      id: 'universal_manual',
      name: 'Manual Grinder Universal',
      brand: 'Universal',
      typeDescription: 'Standard Hand Conical Grinder',
      imagePath: 'assets/images/grinders/universal_manual.png',
      isElectric: false,
      minClicks: 5,
      maxClicks: 35,
      defaultClicks: 20,
      micronsPerClick: 32.0,
      fineClick: 12,
      medFineClick: 16,
      mediumClick: 20,
      medCoarseClick: 24,
      coarseClick: 28,
    ),
    GrinderModel(
      id: 'baratza_encore',
      name: 'Baratza Encore / ESP',
      brand: 'Baratza',
      typeDescription: 'Electric M2 40mm Conical Burr',
      imagePath: 'assets/images/grinders/baratza_encore.png',
      isElectric: true,
      minClicks: 4,
      maxClicks: 40,
      defaultClicks: 16,
      micronsPerClick: 42.0,
      fineClick: 9,
      medFineClick: 13,
      mediumClick: 16,
      medCoarseClick: 21,
      coarseClick: 28,
    ),
    GrinderModel(
      id: 'fellow_ode_gen2',
      name: 'Fellow Ode Gen 1 / Gen 2',
      brand: 'Fellow',
      typeDescription: '64mm Flat Burr Single Dose',
      imagePath: 'assets/images/grinders/fellow_ode_gen2.png',
      isElectric: true,
      minClicks: 1,
      maxClicks: 11,
      defaultClicks: 5,
      micronsPerClick: 75.0,
      fineClick: 2,
      medFineClick: 4,
      mediumClick: 5,
      medCoarseClick: 7,
      coarseClick: 9,
    ),
    GrinderModel(
      id: 'latina_royal',
      name: 'Latina Royal 600N / Sumba',
      brand: 'Latina',
      typeDescription: 'Electric Flat Burr 60mm (Warkop Hero)',
      imagePath: 'assets/images/grinders/latina_royal.png',
      isElectric: true,
      minClicks: 1,
      maxClicks: 8,
      defaultClicks: 4,
      micronsPerClick: 90.0,
      fineClick: 2,
      medFineClick: 3,
      mediumClick: 4,
      medCoarseClick: 5,
      coarseClick: 7,
    ),
    GrinderModel(
      id: 'feima_600n',
      name: 'Feima 600N Taiwan',
      brand: 'Feima',
      typeDescription: 'Classic Flat Burr Kafe & Roastery',
      imagePath: 'assets/images/grinders/feima_600n.png',
      isElectric: true,
      minClicks: 1,
      maxClicks: 8,
      defaultClicks: 4,
      micronsPerClick: 90.0,
      fineClick: 2,
      medFineClick: 3,
      mediumClick: 4,
      medCoarseClick: 5,
      coarseClick: 7,
    ),
    GrinderModel(
      id: 'df64_gen2',
      name: 'DF64 Gen 2 Single Dose',
      brand: 'DF64 / Turin',
      typeDescription: '64mm DLC/SS Flat Burr Booming',
      imagePath: 'assets/images/grinders/df64_gen2.png',
      isElectric: true,
      minClicks: 10,
      maxClicks: 90,
      defaultClicks: 55,
      micronsPerClick: 12.0,
      fineClick: 30,
      medFineClick: 45,
      mediumClick: 55,
      medCoarseClick: 68,
      coarseClick: 80,
    ),
    GrinderModel(
      id: 'timemore_sculptor',
      name: 'Timemore Sculptor 064/078',
      brand: 'Timemore',
      typeDescription: 'Electric Rotary Fines Separator',
      imagePath: 'assets/images/grinders/timemore_sculptor.png',
      isElectric: true,
      minClicks: 1,
      maxClicks: 18,
      defaultClicks: 11,
      micronsPerClick: 48.0,
      fineClick: 6,
      medFineClick: 9,
      mediumClick: 11,
      medCoarseClick: 14,
      coarseClick: 16,
    ),
    GrinderModel(
      id: 'mahlkonig_ek43',
      name: 'Mahlkönig EK43 / EK43S',
      brand: 'Mahlkönig',
      typeDescription: 'Specialty Standard 98mm Cast Steel',
      imagePath: 'assets/images/grinders/mahlkonig_ek43.png',
      isElectric: true,
      minClicks: 1,
      maxClicks: 16,
      defaultClicks: 9,
      micronsPerClick: 55.0,
      fineClick: 5,
      medFineClick: 7,
      mediumClick: 9,
      medCoarseClick: 11,
      coarseClick: 14,
    ),
    GrinderModel(
      id: 'eureka_mignon',
      name: 'Eureka Mignon Filtro / Crono',
      brand: 'Eureka',
      typeDescription: 'Italian 50mm Hardened Flat Burr',
      imagePath: 'assets/images/grinders/eureka_mignon.png',
      isElectric: true,
      minClicks: 1,
      maxClicks: 6,
      defaultClicks: 4,
      micronsPerClick: 120.0,
      fineClick: 2,
      medFineClick: 3,
      mediumClick: 4,
      medCoarseClick: 5,
      coarseClick: 6,
    ),
  ];

  /// Mencocokkan string note bebas dengan item visual terdekat.
  static FlavorNoteVisualItem matchNote(String rawNote) {
    final lower = rawNote.toLowerCase();
    for (final item in flavorNotes) {
      if (lower.contains(item.label.toLowerCase())) return item;
    }
    // Pencarian kata parsial / kata kunci utama
    for (final item in flavorNotes) {
      final cleanLabel = item.label.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase();
      final words = cleanLabel.split(' ');
      for (final w in words) {
        if (w.length >= 4 && lower.contains(w)) return item;
      }
    }
    // Fallback berdasarkan grup rasa utama
    if (lower.contains('floral') || lower.contains('flower') || lower.contains('bunga')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Floral', orElse: () => flavorNotes.first);
    }
    if (lower.contains('citrus') || lower.contains('jeruk') || lower.contains('lemon')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Citrus', orElse: () => flavorNotes.first);
    }
    if (lower.contains('berry') || lower.contains('beri')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Berry', orElse: () => flavorNotes.first);
    }
    if (lower.contains('tropical') || lower.contains('tropis') || lower.contains('mango') || lower.contains('nanas')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Tropical', orElse: () => flavorNotes.first);
    }
    if (lower.contains('stone') || lower.contains('peach') || lower.contains('apricot') || lower.contains('cherry')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Stone Fruit', orElse: () => flavorNotes.first);
    }
    if (lower.contains('apple') || lower.contains('pear') || lower.contains('grape')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Orchard Fruit', orElse: () => flavorNotes.first);
    }
    if (lower.contains('choco') || lower.contains('cocoa') || lower.contains('cokelat')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Cocoa', orElse: () => flavorNotes.first);
    }
    if (lower.contains('sweet') || lower.contains('honey') || lower.contains('caramel') || lower.contains('madu')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Sweet', orElse: () => flavorNotes.first);
    }
    if (lower.contains('nut') || lower.contains('almond') || lower.contains('kacang')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Nutty', orElse: () => flavorNotes.first);
    }
    if (lower.contains('wine') || lower.contains('rum') || lower.contains('whiskey') || lower.contains('ferment')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Winey', orElse: () => flavorNotes.first);
    }
    if (lower.contains('tea') || lower.contains('teh') || lower.contains('earl grey')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Tea-like', orElse: () => flavorNotes.first);
    }
    if (lower.contains('spice') || lower.contains('herb') || lower.contains('rempah') || lower.contains('kayu manis')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Herbal', orElse: () => flavorNotes.first);
    }

    return flavorNotes.firstWhere(
      (fn) => fn.label == 'Clean & Juicy Finish',
      orElse: () => flavorNotes.first,
    );
  }

  /// Mencocokkan nama metode/dripper dengan visual dripper item.
  static DripperVisualItem matchDripper(String? rawMethod, {String? category}) {
    final m = '${rawMethod ?? ''} ${category ?? ''}'.toLowerCase();
    if (m.contains('switch')) return drippers[2];
    if (m.contains('origami')) return drippers[3];
    if (m.contains('kalita')) return drippers[4];
    if (m.contains('orea') || m.contains('april') || m.contains('flat')) return drippers[5];
    if (m.contains('aeropress')) return drippers[6];
    if (m.contains('french press')) return drippers[7];
    if (m.contains('clever')) return drippers[8];
    if (m.contains('chemex') || m.contains('kono')) return drippers[9];
    if (m.contains('pulsar') || m.contains('gina')) return drippers[10];
    if (m.contains('vietnam') || m.contains('phin')) return drippers[11];
    if (m.contains('es') || m.contains('ice')) return drippers[1];
    return drippers[0];
  }

  /// Menghitung jumlah tahapan tuangan air (pour count) dari sebuah resep.
  static int countPours(Map<String, dynamic> recipe) {
    final steps = recipe['steps'] as List<dynamic>? ?? [];
    int count = 0;
    for (final s in steps) {
      if (s is Map) {
        final w = (s['waterAddedGrams'] ?? s['waterGrams'] ?? 0) as num;
        if (w > 0) count++;
      }
    }
    return count > 0 ? count : 1;
  }
}

/// Widget gambar ilustrasi vektor untuk Dripper
class DripperGraphicBadge extends StatelessWidget {
  final DripperVisualItem item;
  final double size;

  const DripperGraphicBadge({
    super.key,
    required this.item,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item.color.withValues(alpha: 0.18),
            item.color.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: item.color.withValues(alpha: 0.3)),
      ),
      child: CustomPaint(
        painter: _DripperShapePainter(shapeType: item.shapeType, color: item.color),
      ),
    );
  }
}

class _DripperShapePainter extends CustomPainter {
  final String shapeType;
  final Color color;

  _DripperShapePainter({required this.shapeType, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    if (shapeType == 'aeropress') {
      final rect = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.32, h * 0.28, w * 0.36, h * 0.50), const Radius.circular(3));
      canvas.drawRRect(rect, fill);
      canvas.drawRRect(rect, stroke);
      canvas.drawLine(Offset(w * 0.38, h * 0.16), Offset(w * 0.62, h * 0.16), stroke);
      canvas.drawLine(Offset(w * 0.50, h * 0.16), Offset(w * 0.50, h * 0.45), stroke);
      canvas.drawLine(Offset(w * 0.25, h * 0.78), Offset(w * 0.75, h * 0.78), stroke);
      return;
    }

    if (shapeType == 'frenchpress') {
      final rect = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.26, h * 0.26, w * 0.42, h * 0.54), const Radius.circular(4));
      canvas.drawRRect(rect, fill);
      canvas.drawRRect(rect, stroke);
      canvas.drawCircle(Offset(w * 0.47, h * 0.17), 3.0, stroke);
      canvas.drawLine(Offset(w * 0.47, h * 0.20), Offset(w * 0.47, h * 0.58), stroke);
      canvas.drawLine(Offset(w * 0.30, h * 0.58), Offset(w * 0.64, h * 0.58), stroke);
      final handle = Path()
        ..moveTo(w * 0.68, h * 0.34)
        ..lineTo(w * 0.78, h * 0.34)
        ..lineTo(w * 0.78, h * 0.68)
        ..lineTo(w * 0.68, h * 0.68);
      canvas.drawPath(handle, stroke);
      return;
    }

    if (shapeType == 'flat') {
      final path = Path()
        ..moveTo(w * 0.20, h * 0.26)
        ..lineTo(w * 0.80, h * 0.26)
        ..lineTo(w * 0.66, h * 0.72)
        ..lineTo(w * 0.34, h * 0.72)
        ..close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
      canvas.drawLine(Offset(w * 0.40, h * 0.26), Offset(w * 0.43, h * 0.72), stroke);
      canvas.drawLine(Offset(w * 0.60, h * 0.26), Offset(w * 0.57, h * 0.72), stroke);
      canvas.drawLine(Offset(w * 0.24, h * 0.76), Offset(w * 0.76, h * 0.76), stroke);
      return;
    }

    if (shapeType == 'origami') {
      final path = Path()
        ..moveTo(w * 0.18, h * 0.24)
        ..lineTo(w * 0.82, h * 0.24)
        ..lineTo(w * 0.56, h * 0.74)
        ..lineTo(w * 0.44, h * 0.74)
        ..close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
      canvas.drawLine(Offset(w * 0.34, h * 0.24), Offset(w * 0.47, h * 0.74), stroke);
      canvas.drawLine(Offset(w * 0.50, h * 0.24), Offset(w * 0.50, h * 0.74), stroke);
      canvas.drawLine(Offset(w * 0.66, h * 0.24), Offset(w * 0.53, h * 0.74), stroke);
      return;
    }

    // Default V60 / Switch / Iced V60 Cone
    final cone = Path()
      ..moveTo(w * 0.20, h * 0.24)
      ..lineTo(w * 0.80, h * 0.24)
      ..lineTo(w * 0.56, h * 0.68)
      ..lineTo(w * 0.44, h * 0.68)
      ..close();
    canvas.drawPath(cone, fill);
    canvas.drawPath(cone, stroke);
    canvas.drawArc(Rect.fromLTWH(w * 0.32, h * 0.30, w * 0.36, h * 0.28), 0.3, 1.8, false, stroke);
    canvas.drawLine(Offset(w * 0.26, h * 0.72), Offset(w * 0.74, h * 0.72), stroke);

    if (shapeType == 'switch' || shapeType == 'clever') {
      final baseRect = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.36, h * 0.68, w * 0.28, h * 0.12), const Radius.circular(3));
      canvas.drawRRect(baseRect, fill);
      canvas.drawRRect(baseRect, stroke);
      canvas.drawLine(Offset(w * 0.64, h * 0.74), Offset(w * 0.78, h * 0.78), stroke);
    } else if (shapeType == 'iced_v60') {
      final iceRect = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.41, h * 0.75, w * 0.18, h * 0.14), const Radius.circular(3));
      canvas.drawRRect(iceRect, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Badge visual untuk Tasting Notes lengkap dengan gambar/ikon warna sesuai rasanya.
class FlavorNoteVisualBadge extends StatelessWidget {
  final String noteText;
  final bool selected;
  final VoidCallback? onTap;

  const FlavorNoteVisualBadge({
    super.key,
    required this.noteText,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final item = BrewVisualCatalog.matchNote(noteText);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? item.color : item.color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? item.color : item.color.withValues(alpha: 0.30),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? Colors.white.withValues(alpha: 0.25) : Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(item.emoji, style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                noteText,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : item.color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 4),
              const Icon(CupertinoIcons.check_mark, size: 12, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
