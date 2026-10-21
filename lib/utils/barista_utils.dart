import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Utilitas nama/negara/slug barista dari field author resep (100% Offline).
class BaristaUtils {
  static const List<String> _emojis = [
    '🇳🇴', '🇬🇷', '🇨🇭', '🇯🇵', '🇬🇧', '🇷🇺', '🇹🇼', '🇮🇪', '🇨🇳', '🇰🇷',
    '🇺🇸', '🇨🇦', '🇦🇺', '🇸🇪', '🇨🇱', '🇫🇷', '🇵🇭', '🇩🇪', '🇷🇴', '🇭🇰',
    '🇲🇾', '🇸🇬', '🇦🇹', '🇦🇪', '🇨🇿', '🇮🇩', '🇧🇷', '🇮🇹', '🇫🇮', '🇨🇴',
    '🇳🇱', '🇹🇭', '🇸🇦', '🇩🇰', '🇪🇸',
  ];

  static const Map<String, String> emojiToCode = {
    '🇳🇴': 'no', '🇬🇷': 'gr', '🇨🇭': 'ch', '🇯🇵': 'jp', '🇬🇧': 'gb',
    '🇷🇺': 'ru', '🇹🇼': 'tw', '🇮🇪': 'ie', '🇨🇳': 'cn', '🇰🇷': 'kr',
    '🇺🇸': 'us', '🇨🇦': 'ca', '🇦🇺': 'au', '🇸🇪': 'se', '🇨🇱': 'cl',
    '🇫🇷': 'fr', '🇵🇭': 'ph', '🇩🇪': 'de', '🇷🇴': 'ro', '🇭🇰': 'hk',
    '🇲🇾': 'my', '🇸🇬': 'sg', '🇦🇹': 'at', '🇦🇪': 'ae', '🇨🇿': 'cz',
    '🇮🇩': 'id', '🇧🇷': 'br', '🇮🇹': 'it', '🇫🇮': 'fi', '🇨🇴': 'co',
    '🇳🇱': 'nl', '🇹🇭': 'th', '🇸🇦': 'sa', '🇩🇰': 'dk', '🇪🇸': 'es',
  };

  static const Map<String, String> nameToCode = {
    'Norwegia': 'no', 'Yunani': 'gr', 'Swiss': 'ch', 'Jepang': 'jp',
    'Inggris': 'gb', 'Rusia': 'ru', 'Taiwan': 'tw', 'Irlandia': 'ie',
    'China': 'cn', 'Korea Selatan': 'kr', 'Amerika Serikat': 'us',
    'Kanada': 'ca', 'Australia': 'au', 'Swedia': 'se', 'Chile': 'cl',
    'Chili': 'cl', 'Prancis': 'fr', 'Filipina': 'ph', 'Jerman': 'de',
    'Rumania': 'ro', 'Hong Kong': 'hk', 'Malaysia': 'my', 'Singapura': 'sg',
    'Austria': 'at', 'UEA': 'ae', 'Republik Ceko': 'cz', 'Indonesia': 'id',
    'Finlandia': 'fi', 'Italia': 'it', 'Brasil': 'br', 'Kolombia': 'co',
    'Belanda': 'nl', 'Thailand': 'th', 'Arab Saudi': 'sa', 'Denmark': 'dk',
  };

  static String cleanName(String author) {
    var name = author.replaceAll(RegExp(r'\s*\([^)]*\)'), '');
    for (final e in _emojis) {
      name = name.replaceAll(e, '');
    }
    return name.trim();
  }

  static String countryCode(String author) {
    for (final e in emojiToCode.entries) {
      if (author.contains(e.key)) return e.value;
    }
    for (final e in nameToCode.entries) {
      if (author.contains('(${e.key})')) return e.value;
    }
    return '';
  }

  static String countryLabel(String author) {
    final code = countryCode(author);
    const labels = {
      'no': 'Norwegia', 'gr': 'Yunani', 'ch': 'Swiss', 'jp': 'Jepang',
      'gb': 'Inggris', 'ru': 'Rusia', 'tw': 'Taiwan', 'ie': 'Irlandia',
      'cn': 'China', 'kr': 'Korea Selatan', 'us': 'Amerika Serikat',
      'ca': 'Kanada', 'au': 'Australia', 'se': 'Swedia', 'cl': 'Chile',
      'fr': 'Prancis', 'ph': 'Filipina', 'de': 'Jerman', 'ro': 'Rumania',
      'hk': 'Hong Kong', 'my': 'Malaysia', 'sg': 'Singapura', 'at': 'Austria',
      'ae': 'UEA', 'cz': 'Republik Ceko', 'id': 'Indonesia', 'fi': 'Finlandia',
      'it': 'Italia', 'br': 'Brasil', 'co': 'Kolombia', 'nl': 'Belanda',
      'th': 'Thailand', 'sa': 'Arab Saudi', 'dk': 'Denmark', 'es': 'Spanyol',
    };
    return labels[code] ?? 'Internasional';
  }

  static String slugFromAuthor(String author) {
    final lowerRaw = author.toLowerCase();
    if (lowerRaw.contains('pepeng')) return 'pepeng_klinik_kopi';
    if (lowerRaw.contains('melvin')) return 'melvin_fugol';
    if (lowerRaw.contains('dody') || lowerRaw.contains('doddy')) return 'dody_samsura';
    if (lowerRaw.contains('madan')) return 'madan';
    if (lowerRaw.contains('fakhri')) return 'muhammad_fakhri';
    if (lowerRaw.contains('jaya pranata')) return 'jaya_pranata';
    if (lowerRaw.contains('hendri')) return 'hendri_kurniawan';
    if (lowerRaw.contains('dustin')) return 'dustin_wijaya';
    if (lowerRaw.contains('ray janson')) return 'ray_janson';
    if (lowerRaw.contains('prawiraanga')) return 'prawiraanga';
    if (lowerRaw.contains('edrick')) return 'edrick';
    if (lowerRaw.contains('space roastery')) return 'space_roastery';
    if (lowerRaw.contains('smoking barrels')) return 'smoking_barrels';
    if (lowerRaw.contains('roy panggabean') || lowerRaw.contains('serkop')) return 'roy_panggabean';
    if (lowerRaw.contains('kreator double bloom')) return 'double_bloom_id';
    if (lowerRaw.contains('daily caffeine') || lowerRaw.contains('panna')) return 'panna_roastery';
    if (lowerRaw.contains('relo')) return 'kopi_relo';
    if (lowerRaw.contains('mandie')) return 'melvin_fugol';
    if (lowerRaw.contains('fugol')) return 'melvin_fugol';
    if (lowerRaw.contains('instinct')) return 'instinct_roastery';
    if (lowerRaw.contains('hungry bird')) return 'hungry_bird_coffee';
    if (lowerRaw.contains('seniman')) return 'seniman_coffee';
    if (lowerRaw.contains('giyanti')) return 'giyanti_coffee';
    if (lowerRaw.contains('simetri')) return 'simetri_coffee';
    if (lowerRaw.contains('anomali')) return 'anomali_coffee';
    if (lowerRaw.contains('john richard') || lowerRaw.contains('john christopher')) return 'john_christopher';
    if (lowerRaw.contains('jsmine') || lowerRaw.contains('jscafejournal')) return 'jsmine_cafe';
    if (lowerRaw.contains('chandra (home brewer)') || lowerRaw.contains('chandra (kreator')) return 'chandra_brewer';
    if (lowerRaw.contains('tooearlyforcaffeine') || lowerRaw.contains('tefc')) return 'tefc_caffeine';
    if (lowerRaw.contains('opak kopi')) return 'opak_kopi';
    if (lowerRaw.contains('jpw indonesia')) return 'jpw_indonesia';
    if (lowerRaw.contains('filosofi kopi')) return 'filosofi_kopi';
    if (lowerRaw.contains('two hands full')) return 'two_hands_full';
    if (lowerRaw.contains('wheel coffee')) return 'wheel_coffee';
    if (lowerRaw.contains('djournal')) return 'djournal_coffee';
    if (lowerRaw.contains('1/15') || lowerRaw.contains('one fifteenth')) return 'one_fifteenth_coffee';
    if (lowerRaw.contains('smith coffee') || lowerRaw.contains('harapan djaya')) return 'smith_coffee';
    if (lowerRaw.contains('blue doors')) return 'blue_doors';
    if (lowerRaw.contains('surabaya specialty') || lowerRaw.contains('surabaya slow bar')) return 'surabaya_slow_bar';
    if (lowerRaw.contains('medan specialty') || lowerRaw.contains('medan slow bar')) return 'medan_slow_bar';
    if (lowerRaw.contains('ombe kofie')) return 'ombe_kofie';
    if (lowerRaw.contains('tetangga roastery')) return 'tetangga_roastery';
    if (lowerRaw.contains('otten coffee academy')) return 'otten_coffee_academy';
    if (lowerRaw.contains('samo smrke') || lowerRaw.contains('samo bloom')) return 'samo_smrke';
    if (lowerRaw.contains('asser christensen') || lowerRaw.contains('coffee chronicler')) return 'asser_christensen';
    if (lowerRaw.contains('yuma kawano') || lowerRaw.contains('light up coffee')) return 'yuma_kawano';
    if (lowerRaw.contains('taizo iwasaki')) return 'taizo_iwasaki';
    final name = cleanName(author)
        .toLowerCase()
        .replaceAll('ø', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ä', 'a')
        .replaceAll('ü', 'u')
        .replaceAll('é', 'e')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return name;
  }

  static String? imageUrlFromRecipe(Map<String, dynamic> recipe) {
    final url = (recipe['authorAvatarUrl'] ?? recipe['authorImageUrl'])?.toString();
    if (url != null && url.isNotEmpty) return url;
    final author = (recipe['author'] ?? '').toString();
    final slug = slugFromAuthor(author);
    if (slug.isNotEmpty && !(recipe['isCustom'] == true)) {
      return 'assets/images/avatars/portraits/$slug.jpg';
    }
    return null;
  }

  /// Mengambil label singkat gilingan tanpa informasi klik/mikron dalam kurung
  /// agar muat pada kartu resep (contoh: "Medium (23 Klik...)" -> "Medium").
  static String shortGrindLabel(String? rawGrind) {
    if (rawGrind == null || rawGrind.trim().isEmpty) return 'Medium';
    final cleaned = rawGrind.split('(').first.trim();
    if (cleaned.isEmpty) return 'Medium';
    return cleaned;
  }

  /// Menghasilkan estimasi konversi gilingan untuk berbagai grinder populer.
  static Map<String, String> grinderConversions(String? rawGrind) {
    final g = (rawGrind ?? 'Medium').toLowerCase();
    // Cek jika ada angka klik Comandante eksplisit di string
    final clickMatch = RegExp(r'(\d+)\s*klik', caseSensitive: false).firstMatch(rawGrind ?? '');
    final int c40Clicks = clickMatch != null
        ? (int.tryParse(clickMatch.group(1)!) ?? 23)
        : (g.contains('extra fine')
            ? 12
            : g.contains('medium-fine') || g.contains('medium fine')
                ? 19
                : g.contains('fine')
                    ? 15
                    : g.contains('medium-coarse') || g.contains('medium coarse')
                        ? 27
                        : g.contains('coarse')
                            ? 31
                            : 23);

    final int microns = (c40Clicks * 30).clamp(300, 1100);
    final int timemoreC2 = (c40Clicks * 0.72).round().clamp(10, 26);
    final int kingrinderK6 = (c40Clicks * 3.7).round().clamp(45, 130);
    final String oneZpressoK = (c40Clicks * 0.32).toStringAsFixed(1);
    final int baratzaEncore = (c40Clicks * 0.68).round().clamp(8, 30);
    final String fellowOde = (c40Clicks * 0.22).clamp(1.0, 10.0).toStringAsFixed(1);

    String texture = 'Gula Pasir Halus (Table Salt)';
    if (c40Clicks <= 16) {
      texture = 'Garam Meja Halus (Fine Salt)';
    } else if (c40Clicks <= 20) {
      texture = 'Pasir Pantai Halus (Caster Sugar)';
    } else if (c40Clicks <= 25) {
      texture = 'Gula Pasir Kristal (Granulated Sugar)';
    } else if (c40Clicks <= 28) {
      texture = 'Garam Kosher / Gula Kasar';
    } else {
      texture = 'Garam Laut Kasar (Sea Salt)';
    }

    return {
      'Kategori': shortGrindLabel(rawGrind),
      'Ukuran Partikel': '~$microns µm ($texture)',
      'Comandante C40': '$c40Clicks Klik',
      'Timemore C2 / C3': '$timemoreC2 Klik',
      'Kingrinder K6': '$kingrinderK6 Klik',
      '1Zpresso K-Ultra / ZP6': 'Angka $oneZpressoK',
      'Baratza Encore': 'Setting $baratzaEncore',
      'Fellow Ode Gen 2': 'Setting $fellowOde',
    };
  }

  /// Render gambar 100% offline (mendukung assets/ dan file lokal perangkat).
  static Widget buildOfflineImage(
    String? path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    int? cacheWidth,
  }) {
    const fallback = 'assets/images/avatars/generic_fallback.jpg';
    if (path == null || path.isEmpty) {
      return Image.asset(fallback, width: width, height: height, fit: fit);
    }
    if (path.startsWith('assets/') || path.startsWith('lib/')) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheWidth,
        errorBuilder: (_, _, _) => Image.asset(
          fallback,
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }
    if (!path.startsWith('http')) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, _, _) => Image.asset(
            fallback,
            width: width,
            height: height,
            fit: fit,
          ),
        );
      }
    }
    return Image.asset(fallback, width: width, height: height, fit: fit);
  }
}

/// Avatar barista 100% offline dengan fallback aman + cacheWidth untuk performa.
class BaristaAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? heroTag;

  const BaristaAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 24,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final cacheW = (size * MediaQuery.devicePixelRatioOf(context)).round().clamp(64, 512);
    final image = BaristaUtils.buildOfflineImage(
      imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      cacheWidth: cacheW,
    );

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.bgCream,
      child: ClipOval(child: image),
    );

    if (heroTag != null) {
      avatar = Hero(tag: heroTag!, child: avatar);
    }
    return avatar;
  }
}
