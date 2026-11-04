class RecipeAttributeDeducer {
  static Map<String, String> parseBeanInfo(Map<String, dynamic> recipe) {
    final rawBean = (recipe['beanName'] ?? '').toString().trim();
    String name = rawBean;
    String variety = (recipe['variety'] ?? recipe['beanVariety'] ?? '').toString().trim();
    String process = (recipe['process'] ?? recipe['beanProcess'] ?? '').toString().trim();
    String roast = (recipe['roastLevel'] ?? '').toString().trim();

    String extraInfo = '';
    if (rawBean.contains('(') && rawBean.contains(')')) {
      final startIdx = rawBean.indexOf('(');
      final endIdx = rawBean.lastIndexOf(')');
      name = rawBean.substring(0, startIdx).trim();
      extraInfo = rawBean.substring(startIdx + 1, endIdx).trim();

      // Jika formatnya: Varietas • Proses • Roast
      if (extraInfo.contains('•')) {
        final parts = extraInfo.split('•').map((p) => p.trim()).toList();
        if (parts.isNotEmpty && variety.isEmpty) variety = parts[0];
        if (parts.length > 1 && process.isEmpty) process = parts[1];
        if (parts.length > 2 && roast.isEmpty) roast = parts[2];
      }
    }

    final fullContext = '$rawBean $extraInfo ${recipe['description'] ?? ''} ${recipe['title'] ?? ''}'.toLowerCase();

    // 1. Deteksi Proses Kopi Otomatis
    if (process.isEmpty) {
      if (fullContext.contains('wine process') ||
          fullContext.contains('winey') ||
          fullContext.contains('kopi wine') ||
          fullContext.contains('(wine') ||
          fullContext.contains('wine /') ||
          fullContext.contains('fermentasi wine') ||
          (fullContext.contains('wine') && !fullContext.contains('winemaking'))) {
        process = 'Wine Process';
      } else if (fullContext.contains('thermal shock')) {
        process = 'Thermal Shock';
      } else if (fullContext.contains('carbonic') ||
          fullContext.contains('maceration') ||
          fullContext.contains(' cm ') ||
          fullContext.contains('gesha cm') ||
          fullContext.contains('carbonic natural')) {
        if (fullContext.contains('natural')) {
          process = 'Carbonic Maceration Natural';
        } else if (fullContext.contains('washed')) {
          process = 'Carbonic Maceration Washed';
        } else {
          process = 'Carbonic Maceration';
        }
      } else if (fullContext.contains('koji')) {
        process = 'Koji Fermented';
      } else if (fullContext.contains('yeast') ||
          fullContext.contains('co-ferment') ||
          fullContext.contains('fruit ferment') ||
          fullContext.contains('strawberry natural') ||
          fullContext.contains('mossto')) {
        process = 'Yeast / Co-Fermentation';
      } else if (fullContext.contains('wet-hulled') ||
          fullContext.contains('wet hulled') ||
          fullContext.contains('giling basah')) {
        process = 'Wet Hulled (Giling Basah)';
      } else if (fullContext.contains('double anaerobic')) {
        process = 'Double Anaerobic';
      } else if (fullContext.contains('anaerobic') || fullContext.contains('anaerob')) {
        if (fullContext.contains('natural')) {
          process = 'Anaerobic Natural';
        } else if (fullContext.contains('washed')) {
          process = 'Anaerobic Washed';
        } else if (fullContext.contains('honey')) {
          process = 'Anaerobic Honey';
        } else {
          process = 'Anaerobic Fermentation';
        }
      } else if (fullContext.contains('black honey')) {
        process = 'Black Honey';
      } else if (fullContext.contains('red honey')) {
        process = 'Red Honey';
      } else if (fullContext.contains('yellow honey')) {
        process = 'Yellow Honey';
      } else if (fullContext.contains('honey') || fullContext.contains('pulped')) {
        process = 'Honey Process';
      } else if (fullContext.contains('extended natural')) {
        process = 'Extended Natural';
      } else if (fullContext.contains('lactic natural')) {
        process = 'Lactic Natural';
      } else if (fullContext.contains('natural') || fullContext.contains('dry process') || fullContext.contains('sundried')) {
        process = 'Natural Process';
      } else if (fullContext.contains('double washed')) {
        process = 'Double Washed';
      } else if (fullContext.contains('extended washed')) {
        process = 'Extended Washed';
      } else if (fullContext.contains('washed') || fullContext.contains('wet process')) {
        process = 'Washed';
      } else {
        process = 'Washed Process';
      }
    }

    // 2. Deteksi Varietas Kopi Otomatis yang Akurat
    if (variety.isEmpty || variety.toLowerCase().contains('arabica specialty') || variety.toLowerCase().contains('arabica single origin')) {
      if (fullContext.contains('geisha') || fullContext.contains('gesha')) {
        variety = 'Geisha / Gesha';
      } else if (fullContext.contains('pink bourbon')) {
        variety = 'Pink Bourbon';
      } else if (fullContext.contains('red bourbon')) {
        variety = 'Red Bourbon';
      } else if (fullContext.contains('yellow bourbon')) {
        variety = 'Yellow Bourbon';
      } else if (fullContext.contains('bourbon')) {
        variety = 'Bourbon';
      } else if (fullContext.contains('pacamara')) {
        variety = 'Pacamara';
      } else if (fullContext.contains('sl28') || fullContext.contains('sl34') || fullContext.contains('sl-28') || fullContext.contains('sl-34')) {
        variety = 'SL28 / SL34';
      } else if (fullContext.contains('caturra') && fullContext.contains('catuai')) {
        variety = 'Caturra / Catuai';
      } else if (fullContext.contains('caturra')) {
        variety = 'Caturra';
      } else if (fullContext.contains('catuai')) {
        variety = 'Catuai';
      } else if (fullContext.contains('sudan rume') || fullContext.contains('rume sudan')) {
        variety = 'Sudan Rume';
      } else if (fullContext.contains('eugenioides')) {
        variety = 'Coffea Eugenioides';
      } else if (fullContext.contains('wush wush')) {
        variety = 'Wush Wush';
      } else if (fullContext.contains('sidra')) {
        variety = 'Sidra';
      } else if (fullContext.contains('laurina')) {
        variety = 'Laurina';
      } else if (fullContext.contains('castillo')) {
        variety = 'Castillo';
      } else if (fullContext.contains('typica')) {
        variety = 'Typica';
      } else if (fullContext.contains('sigarar utang') || fullContext.contains('timtim') || fullContext.contains('ateng')) {
        variety = 'Sigarar Utang / TimTim';
      } else if (fullContext.contains('s795') || fullContext.contains('s-795') || fullContext.contains('kartika')) {
        variety = 'S-795 / Kartika';
      } else if (fullContext.contains('kopyol')) {
        variety = 'Kopyol';
      } else if (fullContext.contains('heirloom') || fullContext.contains('kurume')) {
        variety = 'Ethiopian Heirloom';
      }
      // Infer berdasarkan Origin Terkenal di Dunia
      else if (fullContext.contains('ethiopia') || fullContext.contains('yirgacheffe') || fullContext.contains('guji') || fullContext.contains('sidama') || fullContext.contains('nekisse')) {
        variety = 'Ethiopian Heirloom';
      } else if (fullContext.contains('kenya') || fullContext.contains('nyeri') || fullContext.contains('kirinyaga')) {
        variety = 'SL28 / SL34';
      } else if (fullContext.contains('panama') || fullContext.contains('boquete') || fullContext.contains('volcan')) {
        variety = 'Panama Geisha';
      } else if (fullContext.contains('colombia') || fullContext.contains('huila') || fullContext.contains('cauca')) {
        variety = 'Castillo / Caturra';
      } else if (fullContext.contains('costa rica') || fullContext.contains('tarrazu')) {
        variety = 'Caturra / Catuai';
      } else if (fullContext.contains('guatemala') || fullContext.contains('antigua')) {
        variety = 'Bourbon / Caturra';
      } else if (fullContext.contains('gayo') || fullContext.contains('aceh')) {
        variety = 'Ateng Super / TimTim';
      } else if (fullContext.contains('toraja') || fullContext.contains('sapan')) {
        variety = 'S-795 / Typica';
      } else if (fullContext.contains('kintamani') || fullContext.contains('bali')) {
        variety = 'Kopyol / S-795';
      } else if (fullContext.contains('flores') || fullContext.contains('bajawa')) {
        variety = 'Kartika / S-795';
      } else if (fullContext.contains('puntang')) {
        variety = 'Red Bourbon / Typica';
      } else if (fullContext.contains('kerinci')) {
        variety = 'Andung Sari / Sigarar Utang';
      } else if (fullContext.contains('latimojong') || fullContext.contains('enrekang')) {
        variety = 'S-795 / Typica';
      } else if (fullContext.contains('halu') || fullContext.contains('kamojang') || fullContext.contains('manglayang') || fullContext.contains('jawa') || fullContext.contains('java')) {
        variety = 'Typica / Sigarar Utang';
      } else if (fullContext.contains('papua') || fullContext.contains('wamena')) {
        variety = 'Typica / Bourbon';
      } else if (fullContext.contains('brazil') || fullContext.contains('brasil')) {
        variety = 'Mundo Novo / Catuai';
      } else {
        variety = 'Single Origin Heirloom';
      }
    }

    if (name.isEmpty) name = 'Single Origin Specialty';

    String processAndRoast = process;
    if (roast.isNotEmpty) {
      final roastFormatted = roast.toLowerCase().contains('roast') ? roast : '$roast Roast';
      processAndRoast = '$process • $roastFormatted';
    }

    return {
      'name': name,
      'variety': variety,
      'process': processAndRoast,
    };
  }
}
