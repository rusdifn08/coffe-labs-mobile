import 'language_service.dart';

/// Service penerjemah terminologi kopi, filosofi seduh, dan instruksi langkah demi langkah
/// Mendukung mode Bahasa Inggris (Default) dan Bahasa Indonesia.
class CoffeeTranslator {
  /// Menerjemahkan judul resep
  static String translateTitle(String title) {
    if (!LanguageService.isEnglish) return title;

    String t = title;
    t = t.replaceAll('Metode 4:6 (2016 Juara 1)', '4:6 Method (2016 1st Place)');
    t = t.replaceAll('(2016 Juara 1)', '(2016 1st Place)');
    t = t.replaceAll('(2016 Juara 2)', '(2016 2nd Place)');
    t = t.replaceAll('(2016 Juara 3)', '(2016 3rd Place)');
    t = t.replaceAll('(2017 Juara 1)', '(2017 1st Place)');
    t = t.replaceAll('(2017 Juara 2)', '(2017 2nd Place)');
    t = t.replaceAll('(2017 Juara 3)', '(2017 3rd Place)');
    t = t.replaceAll('(2018 Juara 1)', '(2018 1st Place)');
    t = t.replaceAll('(2018 Juara 2)', '(2018 2nd Place)');
    t = t.replaceAll('(2019 Juara 1)', '(2019 1st Place)');
    t = t.replaceAll('(2021 Juara 1)', '(2021 1st Place)');
    t = t.replaceAll('(2022 Juara 1)', '(2022 1st Place)');
    t = t.replaceAll('(2023 Juara 1)', '(2023 1st Place)');
    t = t.replaceAll('(2024 Juara 1)', '(2024 1st Place)');
    t = t.replaceAll('Juara 1', '1st Place');
    t = t.replaceAll('Juara 2', '2nd Place');
    t = t.replaceAll('Juara 3', '3rd Place');
    t = t.replaceAll('Juara Dunia', 'World Champion');
    t = t.replaceAll('Rutinitas Kedai Kopi', 'Cafe Routine');
    t = t.replaceAll('Ekstraksi Konstan Berbasis Aroma', 'Aroma-Based Constant Extraction');
    t = t.replaceAll('Transisi Rasa Presisi Suhu', 'Temperature Precision Flavor Transition');
    t = t.replaceAll('Metode Seduh', 'Brewing Method');
    t = t.replaceAll('Resep Favorit', 'Favorite Recipe');
    t = t.replaceAll('Resep Harian', 'Daily Recipe');
    t = t.replaceAll('Resep Seduh', 'Brew Recipe');
    t = t.replaceAll('di Atas Es', 'Over Ice');
    t = t.replaceAll('Pakai Es', 'Iced');

    return t;
  }

  /// Menerjemahkan negara brewer
  static String translateCountry(String country) {
    if (!LanguageService.isEnglish) return country;
    switch (country.trim().toLowerCase()) {
      case 'jepang':
        return 'Japan';
      case 'yunani':
        return 'Greece';
      case 'swiss':
        return 'Switzerland';
      case 'norwegia':
        return 'Norway';
      case 'finlandia':
        return 'Finland';
      case 'belanda':
        return 'Netherlands';
      case 'inggris':
        return 'United Kingdom';
      case 'amerika serikat':
      case 'as':
        return 'United States';
      case 'australia':
        return 'Australia';
      case 'taiwan':
        return 'Taiwan';
      case 'malaysia':
        return 'Malaysia';
      case 'denmark':
        return 'Denmark';
      case 'jerman':
        return 'Germany';
      case 'indonesia':
        return 'Indonesia';
      default:
        return country;
    }
  }

  /// Menerjemahkan spesialisasi barista
  static String translateSpecialty(String specialty) {
    if (!LanguageService.isEnglish) return specialty;
    String s = specialty;
    s = s.replaceAll('Metode 4:6 & Hybrid Switch', '4:6 Method & Hybrid Switch');
    s = s.replaceAll('Metode Fokus', 'Focus Method');
    s = s.replaceAll('Fokus', 'Focus');
    s = s.replaceAll('Resep Seduh Kustom', 'Custom Brew Recipes');
    s = s.replaceAll('Seduhan Manual', 'Manual Brew');
    return s;
  }

  /// Menerjemahkan bio ringkas barista
  static String translateBio(String bio) {
    if (!LanguageService.isEnglish) return bio;

    // Direct mapping atau perbaikan kata kunci untuk bio barista
    String b = bio;
    b = b.replaceAll('Juara World Brewers Cup 2016 dan pendiri Philocoffea. Pencipta metode 4:6, Neo Brew, serta Devil Recipe pada Hario Switch yang menggabungkan perkolasi suhu tinggi dan imersi suhu rendah.',
        'World Brewers Cup 2016 Champion and founder of Philocoffea. Creator of the 4:6 Method, Neo Brew, and the Hario Switch Devil Recipe combining high-temperature percolation with low-temperature immersion.');
    b = b.replaceAll('Juara WBrC 2015 asal Norwegia. Memopulerkan ekstraksi kopi natural process yang bersih dan bebas fermentasi berat dengan air mineral PPM rendah.',
        '2015 WBrC Champion from Norway. Popularized ultra-clean natural process coffee extraction free of heavy funk using low-PPM water.');
    b = b.replaceAll('Inovator teknik kriogenik dan penggilingan biji beku (frozen grinding) untuk distribusi partikel lebih seragam dan minim fines.',
        'Innovator of cryogenic techniques and frozen bean grinding for uniform particle distribution and minimal fines.');
    b = b.replaceAll('Spesialis kurva termal slurry dan body sehalus sutra lewat saringan mikron dan penuangan tunggal kontinu.',
        'Specialist in slurry thermal curves and silky-smooth body via micron sifting and single continuous pours.');
    b = b.replaceAll('Membawa efisiensi alur kerja kedai kopi Nordik ke panggung dunia menggunakan Kalita Wave 155 dan tuangan spiral kontinu.',
        'Brought Nordic cafe workflow efficiency to the world stage using the Kalita Wave 155 and continuous spiral pouring.');
    b = b.replaceAll('Juara WBrC 2017 asal Taiwan yang terkenal dengan teknik center continuous pour dan resep Japanese Iced V60 beraroma floral tajam.',
        '2017 WBrC Champion from Taiwan renowned for center continuous pouring and vibrant floral Japanese Iced V60 recipes.');
    b = b.replaceAll('Pelopor penggunaan biji Carbonic Maceration di panggung dunia dengan 5-pulse pouring yang sangat presisi bersama Ona Coffee.',
        'Pioneer of Carbonic Maceration coffees on the world stage with highly precise 5-pulse pouring alongside Ona Coffee.');
    b = b.replaceAll('Finalis multi-tahun WBrC asal Yunani dengan fokus kejernihan rasa dan kontrol turbulensi rendah.',
        'Multi-year WBrC Finalist from Greece focusing on flavor clarity and low-turbulence pouring control.');
    b = b.replaceAll('Juara World Brewers Cup 2018 asal Swiss. Menguasai teknik multi-dripper dan pencampuran varietas kopi eksotik.',
        '2018 World Brewers Cup Champion from Switzerland. Master of multi-dripper techniques and exotic coffee varietal blending.');
    b = b.replaceAll('Juara World Barista Championship 2024 asal Indonesia dan pendiri Catur Coffee Company. Dikenal dengan pendekatan mindfulness, presisi ekstraksi, dan eksplorasi varietas lokal Indonesia.',
        '2024 World Barista Champion from Indonesia and founder of Catur Coffee Company. Known for mindfulness, precision extraction, and highlighting exceptional Indonesian terroirs.');
    b = b.replaceAll('Juara Indonesia Brewers Cup & Juara 3 World Brewers Cup 2024. Membawa kopi Nusantara (termasuk Excelsa Sumedang) ke podium dunia.',
        'Indonesia Brewers Cup Champion & 3rd Place World Brewers Cup 2024. Brought Indonesian terroirs (including Excelsa Sumedang) to the world podium.');
    b = b.replaceAll('Juara World Barista Championship 2007, pendiri Square Mile Coffee, dan penulis The World Atlas of Coffee. Pencipta metode Ultimate V60, French Press tanpa ampas, dan Iced Filter Coffee paling populer di dunia.',
        '2007 World Barista Champion, founder of Square Mile Coffee, and author of The World Atlas of Coffee. Creator of the iconic Ultimate V60, sediment-free French Press, and modern filter coffee standards.');
    b = b.replaceAll('Astrofisikawan Kanada dan penulis buku The Physics of Filter Coffee. Pencipta resep legendaris 10-Minute AeroPress Immersion yang menghasilkan kejernihan luar biasa tanpa channeling.',
        'Canadian astrophysicist and author of The Physics of Filter Coffee. Creator of the legendary 10-Minute AeroPress Immersion recipe achieving extreme clarity without channeling.');
    b = b.replaceAll('Insinyur Stanford dan penemu alat seduh AeroPress (2005). Resep orisinalnya menggunakan suhu rendah (80°C), imersi singkat, dan pengenceran (bypass) yang menghasilkan cangkir sangat halus bebas pahit.',
        'Stanford engineer and inventor of the AeroPress (2005). His original recipe uses low temperature (80°C), brief immersion, and dilution (bypass) yielding an ultra-smooth, bitterness-free cup.');
    b = b.replaceAll('Juara Dunia World AeroPress Championship 2019 asal Belanda. Mengandalkan dosis tinggi, imersi 60 detik singkat, dan air bypass untuk menonjolkan keasaman buah yang berkilau.',
        '2019 World AeroPress Champion from the Netherlands. Relies on high dosing, a quick 60s immersion, and bypass water to accentuate sparkling fruit acidity.');
    b = b.replaceAll('Juara Dunia World AeroPress Championship 2021 asal Helsinki. Menggunakan metode inverted dengan dua tahap penuangan lembut untuk keseimbangan rasa manis dan floral.',
        '2021 World AeroPress Champion from Helsinki. Utilizes inverted method with two gentle pours for balanced sweetness and floral notes.');
    b = b.replaceAll('Kreator resep di Coffee Labs. Jelajahi teknik seduh dan catat hasil brew Anda.',
        'Recipe creator at Coffee Labs. Explore brew profiles and dial in your craft.');

    // Kata kunci pengganti umum
    b = b.replaceAll('Juara Dunia', 'World Champion');
    b = b.replaceAll('Juara', 'Champion');
    b = b.replaceAll('asal', 'from');
    b = b.replaceAll('dengan fokus', 'focusing on');
    b = b.replaceAll('berfokus pada', 'focusing on');
    b = b.replaceAll('penemu alat seduh', 'inventor of');
    b = b.replaceAll('pendiri', 'founder of');

    return b;
  }

  /// Menerjemahkan filosofi teknik dan ekstraksi
  static String translatePhilosophy(String desc) {
    if (!LanguageService.isEnglish) return desc;

    String d = desc;

    // 1. Template otomatis berulang pada ~30 resep kompetisi
    if (d.contains('Resep ini menggunakan rasio presisi') && d.contains('manipulasi turbulensi')) {
      final ratioMatch = RegExp(r'rasio presisi ([\d\.:]+)').firstMatch(d);
      final tempMatch = RegExp(r'bersuhu (\d+°C)').firstMatch(d);
      final grindMatch = RegExp(r'gilingan berukuran ([^,]+),').firstMatch(d);

      final ratioStr = ratioMatch?.group(1) ?? '1:15.0';
      final tempStr = tempMatch?.group(1) ?? '93°C';
      final grindStr = grindMatch?.group(1) ?? 'Medium to Coarse';

      return 'Focuses on mechanical precision and round, pristine fruit clarity. This recipe features a precision $ratioStr ratio engineered to balance extraction dynamics. Utilizing $tempStr water and a $grindStr grind, the pour profile actively regulates in-dripper turbulence (agitation). This ensures complete carbon dioxide degassing throughout the bloom phase while preventing unlevel channeling. The result is a cup of multifaceted complexity, highlighting natural sweetness and vivid flavor definition.';
    }

    // 2. Specific Champion Philosophies
    if (d.contains('Metode 4:6') || d.contains('Tahun 2016 menjadi titik balik historis')) {
      return '2016 marked a historic milestone with the introduction of the 4:6 Method. The theory divides total brew water into two distinct fractions: the first fraction (40% of water) dictates the acid-to-sugar balance, where Kasuya pours 50g followed by 70g to calibrate sweetness versus acidity. The second fraction (60% of water) is split into three equal pulses to tune cup strength and concentration. The methodology relies on a very coarse grind to facilitate rapid flow and capture extreme flavor clarity without over-extraction.';
    }

    if (d.contains('Mikaela membawa semangat realisme kedai kopi')) {
      return 'Mikaela Wallgren brought the realism of Nordic cafe workflow to the world stage. Utilizing the flat-bottomed metal Kalita Wave 155, the bed structure fosters uniform extraction with minimal manual intervention. After sifting fines, Mikaela applies a steady, continuous spiral pour reaching the 250g target at 1:45. The customized low-mineral RO water formulation maximizes sweetness extraction.';
    }

    if (d.contains('Chad Wang memenangkan kompetisi dengan presisi tinggi')) {
      return 'Chad Wang claimed the World Championship through impeccable pouring discipline. Eschewing circular agitation, he directs a single, static continuous stream directly into the center of the dripper. This concentrates thermal mass in the slurry core, ensuring exceptionally consistent extraction and showcasing a dramatic sensory progression from warm peach to cool orange blossom and sweet banana liqueur.';
    }

    if (d.contains('Sam Corra mencatatkan sejarah dengan kopi proses Carbonic Maceration')) {
      return 'Sam Corra made history by championing Carbonic Maceration (CM) coffee, a technique adopted from avant-garde winemaking. Corra utilizes a coarse grind paired with five aggressive, high-velocity pulses across 300ml. His routine distinctly separated terroir characteristics from process-driven esters, yielding an unforgettable, sparkling cup profile.';
    }

    if (d.contains('James Hoffmann') && d.contains('1-cangkir terpopuler')) {
      return "James Hoffmann's benchmark 1-cup V60 technique divides 250g of water into five equal 50g pulses with short 10-second pauses. This keeps slurry temperature elevated throughout brewing, yielding ultra-consistent extraction, vibrant sweetness, and clean cup structure.";
    }

    if (d.contains('Scott Rao') && d.contains('Rao Spin')) {
      return "Scott Rao's industry-standard protocol (1:17 ratio) features bloom excavation, two measured main pours from optimal height, and the iconic 'Rao Spin' swirl. This leaves a table-flat spent coffee bed and prevents dry channeling pockets.";
    }

    if (d.contains('Matt Perger') && d.contains('ekstraksi tinggi di atas 22%')) {
      return "Matt Perger's legendary WBrC recipe redefined modern V60 brewing by pairing a fine grind with a 12g dose and vigorous bloom stirring to achieve high extraction yields exceeding 22% with zero dry astringency.";
    }

    if (d.contains('Wendelien van Bunnik') && d.contains('World AeroPress')) {
      return "Wendelien van Bunnik's 2019 World AeroPress Championship winner extracts for just 60 seconds using an intense 30g coarse dose, then bypasses with 120g pure water to release an explosion of clean, sweet tropical fruit notes.";
    }

    if (d.contains('Mikael Jasin') && d.contains('WBC 2024')) {
      return "2024 World Barista Champion Mikael Jasin's sensory precision routine. Features a 1:16 ratio with an initial bloom and gentle swirl, followed by measured concentric pours with a Melodrip tool to safeguard sparkling clarity and floral honey without astringent tannin extraction.";
    }

    if (d.contains('Ryan Wibawa') && d.contains('Gunung Halu')) {
      return "Ryan Wibawa's signature Japanese Flash Brew for anaerobic West Java Gunung Halu. The thermal shock of 100g ice cubes in the server instantly captures volatile tropical banana and sweet mango esters for a vibrant, crisp finish.";
    }

    if (d.contains('Double Immersion') && d.contains('Ryan Wibawa')) {
      return "Proves that Ryan Wibawa's 86°C/92°C Double Immersion architecture can be replicated with single-origin beans to achieve a world-stage competition cup profile.";
    }

    // Penerjemahan umum kata kunci bahasa Indonesia ke Bahasa Inggris
    d = d.replaceAll('Resep ulang tahun ke-10 (2026) Tetsu Kasuya.',
        "Tetsu Kasuya's 10th anniversary (2026) recipe.");
    d = d.replaceAll('Menggunakan gilingan super kasar dan 10 kali tuangan beruntun',
        'Features a super-coarse grind and 10 rapid sequential pours');
    d = d.replaceAll('untuk menghasilkan tekstur sangat kental (syrupy), rasa manis maksimal, dan minim pahit.',
        'to achieve a thick syrupy mouthfeel, maximum sweetness, and negligible bitterness.');
    d = d.replaceAll('Pada tahun 2015, Odd-Steinar mendobrak dogma',
        'In 2015, Odd-Steinar broke conventional dogma');
    d = d.replaceAll('Tiga tuangan agresif, diseduh ke alat pendingin cepat',
        'Three vigorous pours brewed over rapid chilling');
    d = d.replaceAll('Zero bypass dengan air kalibrasi konsentrat mineral murni',
        'Zero bypass with pure mineral calibration water');
    d = d.replaceAll('Kopi Aceh Gayo proses natural memiliki kelarutan tinggi',
        'Natural processed Aceh Gayo beans feature high solubility and sweetness');
    d = d.replaceAll('sehingga rentan over-extracted jika diseduh terlalu panas.',
        'making them vulnerable to harshness if brewed too hot.');
    d = d.replaceAll('Resep harian berfokus rasa manis gula merah',
        'A daily brew profile emphasizing brown sugar sweetness');
    d = d.replaceAll('Varietas Onan Ganjang dan Sigararutang',
        'Rare Onan Ganjang and Sigararutang varieties');
    d = d.replaceAll('Pemanasan awal (preheating) yang menyeluruh',
        'Thorough preheating of ceramic drippers');

    return d;
  }

  /// Menerjemahkan instruksi tahapan seduh (Pour Step Instructions)
  static String translateInstruction(String text) {
    if (!LanguageService.isEnglish) return text;
    if (text.isEmpty) return text;

    String t = text;

    // 1. Template: "Tuang {X}g air panas {temp}°C memutar merata, basahi seluruh bubuk dan biarkan blooming selama {Y} detik."
    final bloomMatch = RegExp(r'Tuang (\d+)g air panas (\d+°C) memutar merata.*blooming selama (\d+) detik', caseSensitive: false).firstMatch(t);
    if (bloomMatch != null) {
      final water = bloomMatch.group(1);
      final temp = bloomMatch.group(2);
      final dur = bloomMatch.group(3);
      return 'Pour ${water}g hot water ($temp) evenly in circles, saturating all grounds and allow blooming for $dur seconds.';
    }

    // 2. Template: "Tuang {X}g air dengan fokus gerakan spiral kecil di tengah hingga timbangan {Y}g."
    final spiralCenterMatch = RegExp(r'Tuang (\d+)g air dengan fokus gerakan spiral kecil di tengah hingga timbangan (\d+)g', caseSensitive: false).firstMatch(t);
    if (spiralCenterMatch != null) {
      final water = spiralCenterMatch.group(1);
      final scale = spiralCenterMatch.group(2);
      return 'Pour ${water}g water focusing on small center spirals until scale reads ${scale}g.';
    }

    // 3. Template: "Tuang {X}g air memutar perlahan hingga {Y}g..."
    final slowSpiralMatch = RegExp(r'Tuang (\d+)g air memutar perlahan hingga (\d+)g', caseSensitive: false).firstMatch(t);
    if (slowSpiralMatch != null) {
      final water = slowSpiralMatch.group(1);
      final scale = slowSpiralMatch.group(2);
      return 'Pour ${water}g water slowly in circles until ${scale}g to maintain stable slurry temperature.';
    }

    // 4. Template: "Tuang {X}g air terakhir tepat di tengah hingga {Y}g dan tunggu drawdown tuntas pada menit {M}."
    final centerDrawdownMatch = RegExp(r'Tuang (\d+)g air terakhir tepat di tengah hingga (\d+)g dan tunggu drawdown tuntas', caseSensitive: false).firstMatch(t);
    if (centerDrawdownMatch != null) {
      final water = centerDrawdownMatch.group(1);
      final scale = centerDrawdownMatch.group(2);
      return 'Pour final ${water}g water strictly in the center until ${scale}g and wait for drawdown to complete.';
    }

    // 5. Template Japanese Iced: "Siapkan {X}g es batu di server. Tuang {Y}g air panas {temp}°C..."
    final icePrepMatch = RegExp(r'Siapkan (\d+)g es batu di server\. Tuang (\d+)g air panas (\d+°C)', caseSensitive: false).firstMatch(t);
    if (icePrepMatch != null) {
      final ice = icePrepMatch.group(1);
      final water = icePrepMatch.group(2);
      final temp = icePrepMatch.group(3);
      return 'Prepare ${ice}g ice in server. Pour ${water}g hot water ($temp) evenly to saturate coffee bed.';
    }

    // 6. Template Japanese Iced: "Tuang {X}g air dengan spiral kencang hingga {Y}g..."
    final fastSpiralMatch = RegExp(r'Tuang (\d+)g air dengan spiral kencang hingga (\d+)g', caseSensitive: false).firstMatch(t);
    if (fastSpiralMatch != null) {
      final water = fastSpiralMatch.group(1);
      final scale = fastSpiralMatch.group(2);
      return 'Pour ${water}g water with vigorous spirals until ${scale}g to drive rich extraction over ice.';
    }

    // 7. Template Japanese Iced Finish: "Tuang {X}g air terakhir di tengah hingga {Y}g, lalu swirling server..."
    final iceFinishMatch = RegExp(r'Tuang (\d+)g air terakhir di tengah hingga (\d+)g.*swirling server', caseSensitive: false).firstMatch(t);
    if (iceFinishMatch != null) {
      final water = iceFinishMatch.group(1);
      final scale = iceFinishMatch.group(2);
      return 'Pour final ${water}g water in center until ${scale}g, then swirl server gently to melt ice completely.';
    }

    // 8. General phrase replacements
    t = t.replaceAll('Bilas paper filter dengan air panas dan buang air bilasan.',
        'Rinse paper filter with hot water and discard rinse water.');
    t = t.replaceAll('Tuang air panas secara memutar perlahan', 'Pour hot water slowly in outward spirals');
    t = t.replaceAll('Tuang air secara merata', 'Pour water evenly over grounds');
    t = t.replaceAll('Tuang tepat di tengah', 'Pour strictly in the center');
    t = t.replaceAll('Tunggu hingga air turun habis', 'Wait for water to completely draw down');
    t = t.replaceAll('Tunggu drawdown tuntas', 'Wait for drawdown to complete');
    t = t.replaceAll('Biarkan blooming', 'Allow blooming');
    t = t.replaceAll('Imersi / Tunggu', 'Immersion / Drawdown');
    t = t.replaceAll('Aduk perlahan', 'Stir gently');
    t = t.replaceAll('Putar server perlahan', 'Swirl server gently');
    t = t.replaceAll('hingga timbangan', 'until scale reads');
    t = t.replaceAll('hingga', 'until');

    return t;
  }

  /// Menerjemahkan judul langkah (Step title)
  static String translateStepTitle(String title) {
    if (!LanguageService.isEnglish) return title;
    String s = title;
    s = s.replaceAll('1. Blooming Melingkar', '1. Circular Blooming');
    s = s.replaceAll('1. Blooming di Atas Es', '1. Blooming Over Ice');
    s = s.replaceAll('2. Spiral Agitation Cepat', '2. Fast Spiral Agitation');
    s = s.replaceAll('3. Center Finish Pour', '3. Center Finish Pour');
    s = s.replaceAll('4. Center Drawdown', '4. Center Drawdown');
    s = s.replaceAll('Tuangan Utama', 'Main Pour');
    s = s.replaceAll('Tuangan Terakhir', 'Final Pour');
    s = s.replaceAll('Tuangan Spiral', 'Spiral Pour');
    s = s.replaceAll('Tuangan Tengah', 'Center Pour');
    s = s.replaceAll('Satu Kali Tuang', 'Single Pour');
    s = s.replaceAll('Tunggu Tetesan', 'Wait for Drawdown');
    s = s.replaceAll('Pengadukan Bloom', 'Bloom Stir');
    s = s.replaceAll('Tahap', 'Step');
    return s;
  }
}
