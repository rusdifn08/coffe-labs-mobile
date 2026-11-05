import '../data/barista_catalog.dart';
import '../utils/barista_utils.dart';

class RecipeSanitizer {
  static int toInt(dynamic value, int fallback) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim()) ?? fallback;
  }

  static num toNum(dynamic value, num fallback) {
    if (value == null) return fallback;
    if (value is num) return value;
    return num.tryParse(value.toString().trim()) ?? fallback;
  }

  static String nonEmptyString(dynamic value, String fallback) {
    final s = value?.toString().trim() ?? '';
    return s.isEmpty ? fallback : s;
  }

  static String offlineAssetOrPath(dynamic value) {
    final s = value?.toString().trim() ?? '';
    if (s.isEmpty || s.startsWith('http')) {
      return 'assets/images/avatars/generic_fallback.jpg';
    }
    return s;
  }

  /// Mendeteksi apakah resep merupakan keluarga espresso atau minuman olahan berbasis espresso.
  static bool isEspressoBased({String? method, String? category, String? title}) {
    final combined = '${method ?? ''} ${category ?? ''} ${title ?? ''}'.toLowerCase();
    return combined.contains('espresso') ||
        combined.contains('latte') ||
        combined.contains('cappuccino') ||
        combined.contains('flat white') ||
        combined.contains('cortado') ||
        combined.contains('macchiato') ||
        combined.contains('americano') ||
        combined.contains('long black') ||
        combined.contains('affogato') ||
        combined.contains('mocha') ||
        combined.contains('mocaccino') ||
        combined.contains('piccolo') ||
        combined.contains('con panna') ||
        combined.contains('dirty coffee') ||
        combined.contains('breve') ||
        combined.contains('romano') ||
        combined.contains('corretto') ||
        combined.contains('shaken espresso') ||
        combined.contains('dalgona') ||
        combined.contains('marocchino') ||
        combined.contains('freddo') ||
        combined.contains('gibraltar') ||
        combined.contains('flair') ||
        combined.contains('picopresso') ||
        combined.contains('rok') ||
        combined.contains('lever');
  }

  /// Memeriksa apakah teks instruksi mengandung anomali atau halusinasi pour-over drip.
  static bool hasHallucinatedPourOverText(String text) {
    final lower = text.toLowerCase();
    return lower.contains('blooming') ||
        lower.contains('degassing') ||
        lower.contains('secara spiral') ||
        lower.contains('drawdown') ||
        lower.contains('fase imersi') ||
        lower.contains('pada timbangan');
  }

  /// Menghasilkan instruksi barista espresso autentik yang realistis berdasarkan judul langkah.
  static String synthesizeEspressoInstruction({
    required String stepTitle,
    required num coffeeWeightGrams,
    required int waterAdded,
    required int duration,
    required int stepIndex,
    required String recipeTitle,
  }) {
    final t = stepTitle.toLowerCase();
    final targetYield = waterAdded > 0 ? waterAdded : (coffeeWeightGrams * 2).round();

    if (t.contains('dose') ||
        t.contains('giling') ||
        t.contains('grind') ||
        t.contains('wdt') ||
        t.contains('distribus') ||
        t.contains('puck') ||
        t.contains('tamp') ||
        t.contains('basket') ||
        t.contains('level')) {
      return 'Giling ${coffeeWeightGrams}g biji kopi halus ke double basket. Lakukan WDT (Weiss Distribution Technique) dengan jarum melingkar untuk memecah gumpalan dan ratakan densitas bubuk, lalu tamp rata presisi horizontal dengan tekanan 15–20 kg.';
    }

    if (t.contains('pre-infusion') || t.contains('infusi') || t.contains('preinfusion')) {
      return 'Beri pre-infusion pada tekanan rendah 2–3 bar selama ${duration > 0 ? duration : 5} detik agar air membasahi seluruh coffee puck secara merata untuk mencegah channeling sebelum tekanan pompa 9-bar penuh aktif.';
    }

    if (t.contains('ekstraksi') ||
        t.contains('shot') ||
        t.contains('tarik') ||
        t.contains('pull') ||
        t.contains('yield') ||
        t.contains('normale') ||
        t.contains('ristretto') ||
        t.contains('lungo') ||
        t.contains('doppio') ||
        t.contains('9 bar') ||
        t.contains('corong')) {
      return 'Ekstraksi pompa 9-bar penuh. Amati cairan mengalir halus menyerupai ekor tikus dengan lapisan crema hazelnut tebal berkilau. Kunci yield pada ~${targetYield}g dalam waktu ${duration > 0 ? duration : 26} detik.';
    }

    if (t.contains('steam') || t.contains('susu') || t.contains('milk') || t.contains('busa') || t.contains('foam')) {
      final milkVol = waterAdded > 0 ? waterAdded : 120;
      return 'Tuang ${milkVol}ml fresh milk dingin (4°C) ke dalam milk jug. Posisikan steam wand di bawah permukaan untuk stretching udara mikro halus hingga suhu 37°C, lalu pusarkan vortex hingga mencapai 60–65°C bertekstur microfoam mengkilap (glossy).';
    }

    if (t.contains('ganache') ||
        t.contains('cokelat') ||
        t.contains('chocolate') ||
        t.contains('sirup') ||
        t.contains('syrup') ||
        t.contains('kental manis') ||
        t.contains('condensed') ||
        t.contains('caramel') ||
        t.contains('karamel') ||
        t.contains('vanila') ||
        t.contains('hazelnut') ||
        t.contains('gula') ||
        t.contains('sugar') ||
        t.contains('puree') ||
        t.contains('saus') ||
        t.contains('pasta') ||
        t.contains('matcha') ||
        t.contains('hojicha') ||
        t.contains('yuzu')) {
      return 'Siapkan ${waterAdded > 0 ? '${waterAdded}ml/g ' : ''}bahan dasar perisa ke dasar cangkir/gelas saji. Aduk perlahan agar larut dan berpadu sempurna saat bertemu espresso panas.';
    }

    if (t.contains('es') || t.contains('ice') || t.contains('batu') || t.contains('dingin') || t.contains('chilled')) {
      return 'Masukkan es batu kristal higienis secukupnya ke dalam gelas saji untuk menjaga kesegaran dan kestabilan suhu dingin minuman.';
    }

    if (t.contains('gelato') || t.contains('es krim') || t.contains('ice cream') || t.contains('scoop')) {
      return 'Tempatkan 1 scoop besar gelato vanila beku berkualitas ke tengah gelas saji sebelum disiram perlahan dengan espresso panas segar.';
    }

    if (t.contains('shake') || t.contains('shaker') || t.contains('kocok')) {
      return 'Campurkan espresso panas, es batu, dan pemanis ke dalam cocktail shaker. Kocok kuat (hard shake) selama 10–12 detik hingga tercipta tekstur busa dingin mengembang pekat.';
    }

    if (t.contains('pour') ||
        t.contains('tuang') ||
        t.contains('art') ||
        t.contains('latte art') ||
        t.contains('dome') ||
        t.contains('finish') ||
        t.contains('layer') ||
        t.contains('siram') ||
        t.contains('sendokkan')) {
      return 'Tuang susu microfoam perlahan dari ketinggian sedang menembus crema untuk menyatukan dasar rasa, lalu dekatkan moncong jug ke permukaan untuk melukis pola latte art atau membentuk lapisan kubah busa (dome) tebal yang lembut.';
    }

    if (t.contains('lemon') || t.contains('citrus') || t.contains('romano') || t.contains('kulit')) {
      return 'Gosokkan kulit lemon segar pada bibir cangkir untuk melepaskan minyak aromatik sitrus, lalu sajikan bersama shot espresso panas.';
    }

    // Default barista instruction
    return 'Lakukan tahapan peracikan barista dengan teliti untuk menjaga konsistensi temperatur, kestabilan tekanan, dan profil rasa seimbang minuman specialty espresso.';
  }

  /// Menghasilkan daftar komposisi & bahan baku autentik terstruktur untuk resep seduh / espresso.
  static List<Map<String, dynamic>> synthesizeIngredients(
    Map<dynamic, dynamic> raw, {
    required bool isEspresso,
    required num coffeeWeightGrams,
    required int totalWaterWeightGrams,
    required int iceWeightGrams,
    required int waterTempCelsius,
    required String beanName,
    required String title,
    required String category,
  }) {
    final rawIngredients = raw['ingredients'];
    if (rawIngredients is List && rawIngredients.isNotEmpty) {
      final List<Map<String, dynamic>> parsed = [];
      for (final item in rawIngredients) {
        if (item is Map) {
          parsed.add({
            'name': nonEmptyString(item['name'], 'Bahan Kopi'),
            'amount': nonEmptyString(item['amount'] ?? item['qty'], 'Secukupnya'),
            'role': nonEmptyString(item['role'], 'Komposisi'),
            'icon': nonEmptyString(item['icon'], 'coffee_beans'),
          });
        } else if (item is String && item.trim().isNotEmpty) {
          parsed.add({
            'name': item.trim(),
            'amount': 'Secukupnya',
            'role': 'Bahan',
            'icon': 'coffee_beans',
          });
        }
      }
      if (parsed.isNotEmpty) return parsed;
    }

    final lowerTitle = title.toLowerCase();
    final lowerCat = category.toLowerCase();
    final combined = '$lowerTitle $lowerCat';
    final List<Map<String, dynamic>> list = [];

    if (isEspresso) {
      // 1. Base Coffee Dose
      final cleanBean = beanName.trim();
      final beanDisplay = cleanBean.isNotEmpty
          ? (cleanBean.startsWith('(') && cleanBean.endsWith(')')
              ? 'Biji Kopi Sangrai $cleanBean'
              : 'Biji Kopi Sangrai ($cleanBean)')
          : 'Biji Kopi Espresso Blend';
      list.add({
        'name': beanDisplay,
        'amount': '${coffeeWeightGrams}g (Grind Fine)',
        'role': 'Espresso Base',
        'icon': 'coffee_beans',
      });

      // 2. Extractions / Dairy / Syrups based on drink type
      if (combined.contains('cappuccino')) {
        list.add({
          'name': 'Hasil Ekstraksi Espresso 9-Bar',
          'amount': '30–36 ml (Double Shot)',
          'role': 'Espresso Liquid Core',
          'icon': 'water',
        });
        list.add({
          'name': 'Fresh Milk Pasteurisasi Dingin (4°C)',
          'amount': '100–120 ml (Steamed Busa Tebal 65°C)',
          'role': 'Dairy / Microfoam Dome',
          'icon': 'milk',
        });
        list.add({
          'name': 'Bubuk Kakao Premium (Dark Chocolate)',
          'amount': 'Secukupnya (Dusting Halus)',
          'role': 'Topping & Garnish',
          'icon': 'topping',
        });
      } else if (combined.contains('mocha') || combined.contains('mocaccino')) {
        list.add({
          'name': 'Hasil Ekstraksi Espresso 9-Bar',
          'amount': '36–40 ml (Double Shot)',
          'role': 'Espresso Liquid Core',
          'icon': 'water',
        });
        list.add({
          'name': 'Dark Chocolate Ganache / Saus Kakao 70%',
          'amount': '25–30 g (Pelelehan Hangat)',
          'role': 'Saus Cokelat Murni',
          'icon': 'chocolate',
        });
        list.add({
          'name': 'Fresh Milk Pasteurisasi',
          'amount': '150–180 ml (Steamed 65°C)',
          'role': 'Dairy / Steamed Milk',
          'icon': 'milk',
        });
        list.add({
          'name': 'Whipped Cream Dingin & Parutan Kakao',
          'amount': 'Secukupnya (Opsional)',
          'role': 'Topping & Garnish',
          'icon': 'topping',
        });
      } else if (combined.contains('caramel macchiato')) {
        list.add({
          'name': 'Hasil Ekstraksi Espresso 9-Bar',
          'amount': '36 ml (Double Shot Floated)',
          'role': 'Espresso Mark Layer',
          'icon': 'water',
        });
        list.add({
          'name': 'Sirup Vanila Alami (Pure Bourbon Vanilla)',
          'amount': '15–20 ml',
          'role': 'Pemanis Alami (Dasar)',
          'icon': 'syrup',
        });
        list.add({
          'name': 'Fresh Milk Dingin / Steamed',
          'amount': '150–180 ml',
          'role': 'Dairy Base',
          'icon': 'milk',
        });
        list.add({
          'name': 'Saus Karamel Mentega (Butter Caramel Drizzle)',
          'amount': '15 ml (Crosshatch Grid)',
          'role': 'Topping Drizzle',
          'icon': 'syrup',
        });
      } else if (combined.contains('spanish latte') || combined.contains('bombon')) {
        list.add({
          'name': 'Hasil Ekstraksi Espresso 9-Bar',
          'amount': '36–40 ml (Double Shot)',
          'role': 'Espresso Liquid Core',
          'icon': 'water',
        });
        list.add({
          'name': 'Susu Kental Manis (Sweetened Condensed Milk)',
          'amount': '25–30 ml (Dasar Gelas)',
          'role': 'Pemanis Lembut & Kental',
          'icon': 'syrup',
        });
        list.add({
          'name': 'Fresh Milk Pasteurisasi',
          'amount': '120–140 ml (Steamed 62°C)',
          'role': 'Dairy / Steamed Milk',
          'icon': 'milk',
        });
      } else if (combined.contains('vanilla')) {
        list.add({
          'name': 'Hasil Ekstraksi Espresso 9-Bar',
          'amount': '36 ml (Double Shot)',
          'role': 'Espresso Liquid Core',
          'icon': 'water',
        });
        list.add({
          'name': 'Sirup Vanila Alami',
          'amount': '15–20 ml',
          'role': 'Flavoring Syrup',
          'icon': 'syrup',
        });
        list.add({
          'name': 'Fresh Milk Pasteurisasi',
          'amount': '160–180 ml (Steamed Silky 62°C)',
          'role': 'Dairy / Steamed Milk',
          'icon': 'milk',
        });
      } else if (combined.contains('hazelnut')) {
        list.add({
          'name': 'Hasil Ekstraksi Espresso 9-Bar',
          'amount': '36 ml (Double Shot)',
          'role': 'Espresso Liquid Core',
          'icon': 'water',
        });
        list.add({
          'name': 'Sirup Hazelnut Panggang',
          'amount': '15–20 ml',
          'role': 'Flavoring Syrup',
          'icon': 'syrup',
        });
        list.add({
          'name': 'Fresh Milk Pasteurisasi',
          'amount': '160–180 ml (Steamed Silky 62°C)',
          'role': 'Dairy / Steamed Milk',
          'icon': 'milk',
        });
      } else if (combined.contains('flat white')) {
        list.add({
          'name': 'Hasil Ekstraksi Double Ristretto',
          'amount': '30–34 ml (Sweet & Dense Core)',
          'role': 'Ristretto Base',
          'icon': 'water',
        });
        list.add({
          'name': 'Fresh Milk Steamed Velvet',
          'amount': '120–140 ml (Mikrobusa Tipis Rata 60°C)',
          'role': 'Velvet Microfoam',
          'icon': 'milk',
        });
      } else if (combined.contains('cortado') || combined.contains('gibraltar')) {
        list.add({
          'name': 'Hasil Ekstraksi Espresso 9-Bar',
          'amount': '36–40 ml (Double Shot)',
          'role': 'Espresso Base',
          'icon': 'water',
        });
        list.add({
          'name': 'Warm Steamed Milk (Rasio 1:1)',
          'amount': '40–50 ml (Suhu 55°C, Tekstur Halus)',
          'role': 'Warm Dairy (1:1 Ratio)',
          'icon': 'milk',
        });
      } else if (combined.contains('piccolo')) {
        list.add({
          'name': 'Hasil Ekstraksi Single Ristretto',
          'amount': '18–20 ml',
          'role': 'Ristretto Base',
          'icon': 'water',
        });
        list.add({
          'name': 'Fresh Milk Steamed',
          'amount': '60–75 ml (Suhu 60°C)',
          'role': 'Silky Dairy',
          'icon': 'milk',
        });
      } else if (combined.contains('latte') && !combined.contains('matcha')) {
        list.add({
          'name': 'Hasil Ekstraksi Espresso 9-Bar',
          'amount': '36 ml (Double Shot)',
          'role': 'Espresso Liquid Core',
          'icon': 'water',
        });
        list.add({
          'name': 'Fresh Milk Pasteurisasi (Dingin 4°C)',
          'amount': '180–200 ml (Steamed Silky 62°C)',
          'role': 'Dairy / Microfoam Sutra',
          'icon': 'milk',
        });
      } else if (combined.contains('avocatto') || combined.contains('alpukat') || combined.contains('avocado')) {
        list.add({
          'name': 'Jus Alpukat Mentega Kental Segar',
          'amount': '100–120 ml (Creamy Alpukat Base)',
          'role': 'Alpukat Mentega Puree',
          'icon': 'citrus',
        });
        list.add({
          'name': 'Es Krim Cokelat / Vanila Madagaskar',
          'amount': '1 Scoop (~60g Beku)',
          'role': 'Ice Cream Topping',
          'icon': 'icecream',
        });
        list.add({
          'name': 'Hasil Ekstraksi Double Espresso Panas',
          'amount': '36–40 ml (Tuang Sesaat Disajikan)',
          'role': 'Hot Espresso Pour',
          'icon': 'water',
        });
        list.add({
          'name': 'Saus Cokelat / Ganache Leleh',
          'amount': '15 ml (Garnish Drizzle)',
          'role': 'Chocolate Drizzle',
          'icon': 'chocolate',
        });
      } else if (combined.contains('roegal') || combined.contains('regal')) {
        list.add({
          'name': 'Sirup Rum Halal / Gula Aren',
          'amount': '20 ml (Aroma Rum Legit)',
          'role': 'Flavoring Syrup',
          'icon': 'syrup',
        });
        list.add({
          'name': 'Fresh Milk Dingin Pasteurisasi',
          'amount': '120–140 ml (4°C)',
          'role': 'Chilled Fresh Milk',
          'icon': 'milk',
        });
        list.add({
          'name': 'Hasil Ekstraksi Espresso 9-Bar',
          'amount': '30–36 ml',
          'role': 'Espresso Core',
          'icon': 'water',
        });
        list.add({
          'name': 'Biskuit Marie Regal Renyah',
          'amount': '3 Keping (Topping Atas)',
          'role': 'Biscuit Topping',
          'icon': 'topping',
        });
      } else if (combined.contains('butterscotch') || combined.contains('sea salt')) {
        list.add({
          'name': 'Sirup Butterscotch Gurih Legit',
          'amount': '20 ml',
          'role': 'Butterscotch Base',
          'icon': 'syrup',
        });
        list.add({
          'name': 'Fresh Milk Dingin Pasteurisasi',
          'amount': '120–140 ml (4°C)',
          'role': 'Chilled Fresh Milk',
          'icon': 'milk',
        });
        list.add({
          'name': 'Hasil Ekstraksi Double Ristretto',
          'amount': '30–35 ml (Aroma Harum Pekat)',
          'role': 'Dense Ristretto Core',
          'icon': 'water',
        });
        list.add({
          'name': 'Sea Salt Cream Foam Dingin',
          'amount': '30–40 ml (Lapisan Busa Gurih)',
          'role': 'Salty Foam Topping',
          'icon': 'topping',
        });
      } else if (combined.contains('pandan') || combined.contains('klepon')) {
        list.add({
          'name': 'Sirup Pandan Asli / Gula Jawa Kental',
          'amount': '20–25 ml',
          'role': 'Pandan & Palm Sugar',
          'icon': 'syrup',
        });
        list.add({
          'name': 'Fresh Milk Dingin / Steamed 62°C',
          'amount': '130–150 ml',
          'role': 'Dairy Base',
          'icon': 'milk',
        });
        list.add({
          'name': 'Hasil Ekstraksi Double Espresso',
          'amount': '36–40 ml',
          'role': 'Espresso Core',
          'icon': 'water',
        });
      } else if (combined.contains('oat')) {
        list.add({
          'name': 'Oat Milk Barista Edition (Plant-Based)',
          'amount': '140–160 ml (Tekstur Tebal Gurih)',
          'role': 'Plant-Based Milk',
          'icon': 'milk',
        });
        list.add({
          'name': 'Hasil Ekstraksi Double Espresso',
          'amount': '36–40 ml (Ekstraksi 9-Bar)',
          'role': 'Espresso Core',
          'icon': 'water',
        });
      } else if (combined.contains('gula aren') ||
          combined.contains('aren') ||
          combined.contains('kopi susu') ||
          combined.contains('janji jiwa') ||
          combined.contains('kenangan')) {
        list.add({
          'name': 'Gula Aren Organik Cair Asli',
          'amount': '20–25 ml (Kekentalan Sedang)',
          'role': 'Pemanis Alami Aren',
          'icon': 'syrup',
        });
        list.add({
          'name': 'Susu Kental Manis / Evaporasi',
          'amount': '10–15 ml (Enhancer Gurih)',
          'role': 'Creaminess Enhancer',
          'icon': 'syrup',
        });
        list.add({
          'name': 'Fresh Milk Dingin (4°C)',
          'amount': '100–120 ml',
          'role': 'Fresh Milk Base',
          'icon': 'milk',
        });
        list.add({
          'name': 'Hasil Ekstraksi Double Espresso Mantap',
          'amount': '36–40 ml (Karakter Bold Pekat)',
          'role': 'Espresso Liquid Core',
          'icon': 'water',
        });
      } else if (combined.contains('affogato')) {
        list.add({
          'name': 'Gelato / Es Krim Vanila Madagaskar',
          'amount': '1 Scoop Besar (~60–80g Beku)',
          'role': 'Artisanal Gelato Core',
          'icon': 'icecream',
        });
        list.add({
          'name': 'Double Shot Espresso Segar Panas',
          'amount': '36–40 ml (Tuang di Depan Meja)',
          'role': 'Hot Espresso Pour',
          'icon': 'water',
        });
      } else if (combined.contains('dirty')) {
        list.add({
          'name': 'Cold Whole Milk & Heavy Cream (4°C)',
          'amount': '100–120 ml (Sangat Dingin)',
          'role': 'Chilled Heavy Dairy Base',
          'icon': 'milk',
        });
        list.add({
          'name': 'Double Shot Espresso Ekstraksi Lambat',
          'amount': '36 ml (Panas Mengapung di Permukaan)',
          'role': 'Floating Hot Espresso',
          'icon': 'water',
        });
      } else if (combined.contains('americano') || combined.contains('long black')) {
        list.add({
          'name': 'Air Panas Suhu Seduh Filtered Water',
          'amount': '120–160 ml ($waterTempCelsius°C)',
          'role': 'Hot Water Base',
          'icon': 'water',
        });
        list.add({
          'name': 'Double Shot Espresso 9-Bar',
          'amount': '36–40 ml (Crema Mengapung)',
          'role': 'Espresso Liquid Core',
          'icon': 'coffee_beans',
        });
      } else if (combined.contains('con panna')) {
        list.add({
          'name': 'Hasil Ekstraksi Double Espresso',
          'amount': '36–40 ml',
          'role': 'Espresso Core',
          'icon': 'water',
        });
        list.add({
          'name': 'Fresh Whipped Cream Dingin',
          'amount': '25–30 g (Dollop Tebal Lembut)',
          'role': 'Cold Cream Topping',
          'icon': 'topping',
        });
      } else if (combined.contains('romano')) {
        list.add({
          'name': 'Hasil Ekstraksi Espresso 9-Bar',
          'amount': '30 ml (Single / Double Shot)',
          'role': 'Espresso Core',
          'icon': 'water',
        });
        list.add({
          'name': 'Irisan Kulit Lemon Segar (Lemon Peel Twist)',
          'amount': '1 Buah (Minyak Atsiri Citrus)',
          'role': 'Aroma & Citrus Accent',
          'icon': 'citrus',
        });
      } else {
        // Pure Espresso / Ristretto / Lungo / Doppio
        list.add({
          'name': 'Hasil Ekstraksi Espresso 9-Bar',
          'amount': '~${totalWaterWeightGrams > 0 ? totalWaterWeightGrams : (coffeeWeightGrams * 2).round()} ml',
          'role': 'Liquid Crema Yield',
          'icon': 'water',
        });
      }

      // Add Ice if iced espresso drink
      if ((iceWeightGrams > 0 || combined.contains('iced') || combined.contains('freddo')) &&
          !combined.contains('affogato')) {
        list.add({
          'name': 'Es Batu Kristal Higienis',
          'amount': '${iceWeightGrams > 0 ? iceWeightGrams : 90}g',
          'role': 'Pendingin / Thermal Ice',
          'icon': 'ice',
        });
      }
    } else {
      // Manual Pour Over / Filter Coffee
      list.add({
        'name': 'Biji Kopi Sangrai ($beanName)',
        'amount': '$coffeeWeightGrams g',
        'role': 'Bubuk Kopi Specialty',
        'icon': 'coffee_beans',
      });
      list.add({
        'name': 'Air Mineral Seduh Presisi',
        'amount': '$totalWaterWeightGrams ml ($waterTempCelsius°C)',
        'role': 'Pelarut Ekstraksi Presisi',
        'icon': 'water',
      });
      if (iceWeightGrams > 0) {
        list.add({
          'name': 'Es Batu Kristal Higienis',
          'amount': '${iceWeightGrams}g (Di Dalam Server)',
          'role': 'Pendingin Flash Chill',
          'icon': 'ice',
        });
      }
    }

    return list;
  }

  /// Menjamin tidak ada satupun field resep atau step yang bernilai null atau mengalami anomali.
  static Map<String, dynamic> sanitizeRecipe(Map<dynamic, dynamic> raw, {int fallbackId = 1}) {
    final id = toInt(raw['id'], fallbackId);
    final title = nonEmptyString(raw['title'], 'Custom Brew Recipe');
    final author = nonEmptyString(raw['author'], 'Barista');
    var category = nonEmptyString(raw['category'], 'V60');
    if (category == 'V60 Pour Over') category = 'V60';
    if (category == 'Japanese Iced') category = 'Japanese';

    final method = nonEmptyString(raw['method'], category);
    final beanName = nonEmptyString(raw['beanName'], 'Specialty Single Origin');
    final isEspresso = isEspressoBased(method: method, category: category, title: title);
    final grindSize = nonEmptyString(
      raw['grindSize'],
      isEspresso ? 'Fine (Espresso Range)' : 'Medium (22 Klik Comandante)',
    );
    final waterTempCelsius = toInt(raw['waterTempCelsius'], isEspresso ? 93 : 92);
    final coffeeWeightGrams = toNum(raw['coffeeWeightGrams'], isEspresso ? 18 : 15);
    final iceWeightGrams = toInt(
      raw['iceWeightGrams'],
      category.toLowerCase().contains('iced') || title.toLowerCase().contains('iced') ? 90 : 0,
    );

    final rawSteps = raw['steps'];
    final List<Map<String, dynamic>> sanitizedSteps = [];
    int sumDuration = 0;
    int sumWater = 0;

    if (rawSteps is List && rawSteps.isNotEmpty) {
      for (int i = 0; i < rawSteps.length; i++) {
        final s = rawSteps[i];
        if (s is Map) {
          final stepTitle = nonEmptyString(s['title'], 'Step ${i + 1}');
          final duration = toInt(s['durationSeconds'] ?? s['timeSeconds'], 30);
          final waterAdded = toInt(s['waterAddedGrams'] ?? s['waterGrams'], 0);
          sumDuration += duration;
          sumWater += waterAdded;

          String stepInstruction;
          final existingInstruction = s['instruction']?.toString().trim() ?? '';

          if (isEspresso) {
            // Jika resep espresso tetapi teks instruksi kosong atau terdeteksi halusinasi pour-over
            if (existingInstruction.isEmpty || hasHallucinatedPourOverText(existingInstruction)) {
              stepInstruction = synthesizeEspressoInstruction(
                stepTitle: stepTitle,
                coffeeWeightGrams: coffeeWeightGrams,
                waterAdded: waterAdded,
                duration: duration,
                stepIndex: i,
                recipeTitle: title,
              );
            } else {
              stepInstruction = existingInstruction;
            }
          } else {
            // Mode Pour Over / Drip Manual
            if (existingInstruction.isNotEmpty) {
              stepInstruction = existingInstruction;
            } else if (waterAdded > 0 && i == 0) {
              stepInstruction =
                  'Tuang ${waterAdded}g air ($waterTempCelsius°C) secara merata untuk fase blooming & degassing selama ${duration}s.';
            } else if (waterAdded > 0) {
              stepInstruction =
                  'Tuang ${waterAdded}g air secara spiral stabil hingga mencapai total ${sumWater}g pada timbangan dalam ${duration}s.';
            } else {
              stepInstruction =
                  'Tahan fase imersi / biarkan air terekstraksi dan mengalir turun (drawdown) selama ${duration}s.';
            }
          }

          sanitizedSteps.add({
            'stepOrder': i + 1,
            'title': stepTitle,
            'durationSeconds': duration,
            'waterAddedGrams': waterAdded,
            'timeSeconds': duration,
            'waterGrams': waterAdded,
            'cumulativeWaterGrams': sumWater,
            'instruction': stepInstruction,
          });
        }
      }
    }

    if (sanitizedSteps.isEmpty) {
      if (isEspresso) {
        final doubleYield = (coffeeWeightGrams * 2).round();
        sanitizedSteps.addAll([
          {
            'stepOrder': 1,
            'title': '1. Puck Preparation & WDT',
            'durationSeconds': 15,
            'waterAddedGrams': 0,
            'timeSeconds': 15,
            'waterGrams': 0,
            'cumulativeWaterGrams': 0,
            'instruction':
                'Giling ${coffeeWeightGrams}g kopi halus, ratakan dengan jarum WDT bebas gumpalan, lalu tamp rata presisi 15–20 kg.',
          },
          {
            'stepOrder': 2,
            'title': '2. Ekstraksi 9-Bar Espresso',
            'durationSeconds': 26,
            'waterAddedGrams': doubleYield,
            'timeSeconds': 26,
            'waterGrams': doubleYield,
            'cumulativeWaterGrams': doubleYield,
            'instruction':
                'Mulai ekstraksi pompa 9-bar penuh. Hentikan pada yield ~${doubleYield}g dalam kurun 25–28 detik dengan crema hazelnut tebal.',
          },
        ]);
        sumDuration = 41;
        sumWater = doubleYield;
      } else {
        final fallbackWater = toInt(raw['totalWaterWeightGrams'], 225);
        final bloomWater = (fallbackWater * 0.2).round().clamp(30, 60);
        final mainWater = (fallbackWater - bloomWater).clamp(50, 500);
        sanitizedSteps.addAll([
          {
            'stepOrder': 1,
            'title': '1. Blooming',
            'durationSeconds': 35,
            'waterAddedGrams': bloomWater,
            'timeSeconds': 35,
            'waterGrams': bloomWater,
            'cumulativeWaterGrams': bloomWater,
            'instruction': 'Tuang ${bloomWater}g air secara merata dan goyangkan dripper lembut.',
          },
          {
            'stepOrder': 2,
            'title': '2. Main Pour',
            'durationSeconds': 95,
            'waterAddedGrams': mainWater,
            'timeSeconds': 95,
            'waterGrams': mainWater,
            'cumulativeWaterGrams': bloomWater + mainWater,
            'instruction': 'Tuang ${mainWater}g air secara spiral stabil hingga mencapai ${bloomWater + mainWater}g.',
          },
        ]);
        sumDuration = 130;
        sumWater = bloomWater + mainWater;
      }
    }

    final rawTotalWater = toInt(raw['totalWaterWeightGrams'], 0);
    final totalWaterWeightGrams = rawTotalWater > 0
        ? rawTotalWater
        : (sumWater > 0 ? sumWater : (isEspresso ? (coffeeWeightGrams * 2).round() : 225));

    final rawTotalTime = toInt(raw['totalTimeSeconds'], 0);
    final totalTimeSeconds = rawTotalTime > 0
        ? rawTotalTime
        : (sumDuration > 0 ? sumDuration : (isEspresso ? 45 : 130));

    final authorProfile = BaristaCatalog.resolve(author, imageUrl: raw['authorAvatarUrl']?.toString());
    final catalogAvatar = authorProfile.imageAsset;

    String avatarUrl;
    if (raw['isCustom'] == true) {
      avatarUrl = offlineAssetOrPath(raw['authorAvatarUrl'] ?? raw['authorImageUrl']);
    } else if (catalogAvatar != null && !catalogAvatar.contains('generic_fallback')) {
      avatarUrl = catalogAvatar;
    } else {
      final candidate = (raw['authorAvatarUrl'] ?? raw['authorImageUrl'])?.toString();
      if (candidate != null &&
          !candidate.contains('avatar_') &&
          !candidate.contains('generic_fallback')) {
        avatarUrl = offlineAssetOrPath(candidate);
      } else {
        avatarUrl = 'assets/images/avatars/generic_fallback.jpg';
      }
    }

    final slug = BaristaUtils.slugFromAuthor(author);
    final catalogCover = BaristaCatalog.coverForSlug(slug);
    String coverUrl;
    if (raw['isCustom'] == true) {
      coverUrl = offlineAssetOrPath(raw['coverImageUrl'] ?? raw['authorImageUrl'] ?? avatarUrl);
    } else if (catalogCover != null) {
      coverUrl = catalogCover;
    } else {
      coverUrl = offlineAssetOrPath(raw['coverImageUrl'] ?? raw['authorImageUrl'] ?? avatarUrl);
    }

    // Synthesize & sanitize complete ingredients
    final sanitizedIngredients = synthesizeIngredients(
      raw,
      isEspresso: isEspresso,
      coffeeWeightGrams: coffeeWeightGrams,
      totalWaterWeightGrams: totalWaterWeightGrams,
      iceWeightGrams: iceWeightGrams,
      waterTempCelsius: waterTempCelsius,
      beanName: beanName,
      title: title,
      category: category,
    );

    return {
      'id': id,
      'title': title,
      'author': author,
      'coverImageUrl': coverUrl,
      'authorAvatarUrl': avatarUrl,
      'authorImageUrl': coverUrl,
      'beanName': beanName,
      'variety': nonEmptyString(raw['variety'] ?? raw['beanVariety'], 'Specialty Arabica'),
      'process': nonEmptyString(raw['process'] ?? raw['beanProcess'], ''),
      'roastLevel': nonEmptyString(raw['roastLevel'], isEspresso ? 'Medium-Dark' : 'Light-Medium'),
      'method': method,
      'category': category,
      'waterTempCelsius': waterTempCelsius,
      'grindSize': grindSize,
      'coffeeWeightGrams': coffeeWeightGrams,
      'totalWaterWeightGrams': totalWaterWeightGrams,
      'iceWeightGrams': iceWeightGrams,
      'waterPpm': nonEmptyString(raw['waterPpm'], isEspresso ? '100-130 ppm' : '70-85 ppm'),
      'tastingNotes': nonEmptyString(
        raw['tastingNotes'],
        isEspresso
            ? 'Velvety Body, Rich Cocoa, Toasted Nut, Lingering Sweet Crema'
            : 'Balanced Sweetness, Clean Acidity, Aromatic Finish',
      ),
      'totalTimeSeconds': totalTimeSeconds,
      'description': nonEmptyString(
        raw['description'],
        isEspresso
            ? 'Resep espresso profesional dengan parameter ekstraksi 9-bar dan rasio presisi untuk citarasa optimal.'
            : 'Resep seduh profesional menggunakan $method pada suhu $waterTempCelsius°C dengan gilingan $grindSize.',
      ),
      'isCustom': raw['isCustom'] == true,
      'createdAt': nonEmptyString(raw['createdAt'], DateTime.now().toIso8601String()),
      'steps': sanitizedSteps,
      'ingredients': sanitizedIngredients,
    };
  }
}
