import 'dart:io';
import 'package:flag/flag.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../features/grinder/services/grinder_conversion_engine.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/barista_catalog.dart';
import '../theme/app_theme.dart';
import '../core/assets/cloud_asset_manager.dart';

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
    if (lowerRaw.contains('samo smrke') || lowerRaw.contains('samo bloom')) return 'samo_smrke';
    if (lowerRaw.contains('lance hedrick')) return 'lance_hedrick';
    if (lowerRaw.contains('edrick')) return 'edrick';
    if (lowerRaw.contains('space roastery')) return 'space_roastery';
    if (lowerRaw.contains('smoking barrels')) return 'smoking_barrels';
    if (lowerRaw.contains('roy panggabean') || lowerRaw.contains('serkop')) return 'roy_panggabean';
    if (lowerRaw.contains('kreator double bloom')) return 'double_bloom_id';
    if (lowerRaw.contains('daily caffeine') || lowerRaw.contains('panna')) return 'panna_roastery';
    if (lowerRaw.contains('relo')) return 'kopi_relo';
    if (lowerRaw.contains('mandie')) return 'mandie_fugol';
    if (lowerRaw.contains('fugol')) return 'fugol_coffee';
    if (lowerRaw.contains('anthony douglas')) return 'anthony_douglas';
    if (lowerRaw.contains('andanu')) return 'andanu_prasetyo';
    if (lowerRaw.contains('agnieszka')) return 'agnieszka_rojewska';
    if (lowerRaw.contains('dick bradsell')) return 'dick_bradsell';
    if (lowerRaw.contains('gianni frasi')) return 'gianni_frasi';
    if (lowerRaw.contains('hiroshi sawada')) return 'hiroshi_sawada';
    if (lowerRaw.contains('athens')) return 'athens_barista_community';
    if (lowerRaw.contains('archivist')) return 'archivist_seoul';
    if (lowerRaw.contains('fore coffee')) return 'fore_coffee';
    if (lowerRaw.contains('common grounds')) return 'common_grounds';
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

  static String imageUrlFromRecipe(dynamic rawRecipe) {
    if (rawRecipe is! Map) return 'assets/images/avatars/generic_fallback.jpg';
    final recipe = rawRecipe;
    final author = (recipe['author'] ?? '').toString();
    final rawUrl = (recipe['authorAvatarUrl'] ?? recipe['authorImageUrl'])?.toString();

    // Jika custom recipe pengguna dengan foto custom, gunakan url custom
    if (recipe['isCustom'] == true && rawUrl != null && rawUrl.isNotEmpty) {
      return rawUrl;
    }

    final slug = slugFromAuthor(author);
    if (slug.isNotEmpty) {
      final known = BaristaCatalog.bySlug[slug];
      if (known?.imageAsset != null && !known!.imageAsset!.contains('generic_fallback')) {
        return known.imageAsset!;
      }
      return 'assets/images/avatars/portraits/$slug.jpg';
    }

    if (rawUrl != null &&
        rawUrl.isNotEmpty &&
        !rawUrl.contains('generic_fallback') &&
        !rawUrl.contains('avatar_')) {
      return rawUrl;
    }

    return 'assets/images/avatars/generic_fallback.jpg';
  }

  static String coverUrlFromRecipe(dynamic rawRecipe) {
    if (rawRecipe is! Map) return 'assets/images/avatars/generic_fallback.jpg';
    final recipe = rawRecipe;
    final author = (recipe['author'] ?? '').toString();
    final rawCover = (recipe['coverImageUrl'] ?? recipe['authorImageUrl'])?.toString();

    if (recipe['isCustom'] == true && rawCover != null && rawCover.isNotEmpty) {
      return rawCover;
    }

    final slug = slugFromAuthor(author);
    final catalogCover = BaristaCatalog.coverForSlug(slug);
    if (catalogCover != null) {
      return catalogCover;
    }

    if (rawCover != null &&
        rawCover.isNotEmpty &&
        !rawCover.contains('generic_fallback')) {
      return rawCover;
    }

    return imageUrlFromRecipe(rawRecipe);
  }

  /// Mengambil label singkat gilingan tanpa informasi klik/mikron dalam kurung
  /// agar muat pada kartu resep (contoh: "Medium (23 Klik...)" -> "Medium").
  static String shortGrindLabel(String? rawGrind) {
    if (rawGrind == null || rawGrind.trim().isEmpty) return 'Medium';
    final cleaned = rawGrind.split('(').first.trim();
    if (cleaned.isEmpty) return 'Medium';
    return cleaned;
  }

  /// Menghasilkan estimasi konversi gilingan akurat berbasis Interpolasi Multi-Jangkar
  /// dari [GrinderConversionEngine] (dilengkapi notasi posisi dial fisik Putaran.Angka.Klik).
  static Map<String, String> grinderConversions(String? rawGrind) {
    final g = (rawGrind ?? 'Medium').toLowerCase();
    // Cek jika ada angka klik Comandante eksplisit di string resep
    final clickMatch = RegExp(r'(\d+)\s*klik', caseSensitive: false).firstMatch(rawGrind ?? '');
    final c40 = GrinderConversionEngine.findById('comandante_c40_mk4')!;

    final double microns;
    if (clickMatch != null) {
      final parsedClicks = (int.tryParse(clickMatch.group(1)!) ?? 24).clamp(4, 40).toDouble();
      microns = GrinderConversionEngine.settingToMicrons(c40, parsedClicks);
    } else if (g.contains('turkish') || g.contains('ibrik')) {
      microns = 150.0;
    } else if (g.contains('extra fine') || g.contains('espresso')) {
      microns = 280.0;
    } else if (g.contains('moka')) {
      microns = 480.0;
    } else if (g.contains('medium-fine') || g.contains('medium fine')) {
      microns = 550.0;
    } else if (g.contains('fine')) {
      microns = 420.0;
    } else if (g.contains('medium-coarse') || g.contains('medium coarse')) {
      microns = 820.0;
    } else if (g.contains('cold brew') || g.contains('extra coarse')) {
      microns = 1175.0;
    } else if (g.contains('coarse')) {
      microns = 975.0;
    } else {
      microns = 650.0; // V60 / Medium Pour Over acuan
    }

    String formatForId(String id) {
      final spec = GrinderConversionEngine.findById(id);
      if (spec == null) return '-';
      final val = GrinderConversionEngine.micronsToSetting(spec, microns);
      if (val == null) return 'Kalibrasi Visual';
      final reading = GrinderConversionEngine.formatDialReading(
        spec,
        val,
        targetMicrons: microns,
      );
      if (reading.warning != null && spec.filterOnly && microns < (spec.minRecommendedMicrons ?? 0)) {
        return 'N/A (Khusus Filter)';
      }
      if (reading.physicalNotation.contains('.') || reading.physicalNotation.contains('+')) {
        return '${reading.primaryDisplay} (${reading.physicalNotation})';
      }
      return reading.primaryDisplay;
    }

    final texture = GrinderConversionEngine.textureForMicrons(microns);
    final zone = GrinderConversionEngine.brewZoneForMicrons(microns);

    return {
      'Kategori & Zona': '${shortGrindLabel(rawGrind)} · $zone',
      'Ukuran Partikel': '~${microns.round()} µm ($texture)',
      'Comandante C40 MK4': formatForId('comandante_c40_mk4'),
      'Comandante C40 (Red Clix)': formatForId('comandante_c40_red_clix'),
      '1Zpresso K-Ultra': formatForId('1zpresso_k_ultra'),
      '1Zpresso J-Ultra': formatForId('1zpresso_j_ultra'),
      '1Zpresso JX-Pro': formatForId('1zpresso_jx_pro'),
      '1Zpresso Q2': formatForId('1zpresso_q2'),
      'KINGrinder K6': formatForId('kingrinder_k6'),
      'KINGrinder K2': formatForId('kingrinder_k2'),
      'Timemore Chestnut C3 / C3S': formatForId('timemore_c3'),
      'Timemore Chestnut C3 ESP': formatForId('timemore_c3_esp'),
      'Timemore Chestnut S3': formatForId('timemore_s3'),
      'MHW-3BOMBER Blade R3': formatForId('mhw3bomber_blade_r3'),
      'Normcore Manual V2': formatForId('normcore_manual_v2'),
      'Kinu M47 Classic': formatForId('kinu_m47_classic'),
      'DF64 Gen 2 (Elektrik)': formatForId('df64_gen2'),
      'Baratza Encore ESP (Elektrik)': formatForId('baratza_encore_esp'),
      'Fellow Ode Gen 2 (Elektrik)': formatForId('fellow_ode_gen2'),
      'Eureka Mignon Specialità': formatForId('eureka_mignon_specialita'),
      'Mahlkönig EK43 (Dial 0–16)': formatForId('mahlkonig_ek43'),
      'Porlex Mini / Tall II': formatForId('porlex_mini_ii'),
    };
  }

  /// Render gambar 100% offline (mendukung assets/, file lokal perangkat, & fallback aman tanpa red-X).
  static Widget buildOfflineImage(
    String? path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    int? cacheWidth,
  }) {
    if (path == null || path.isEmpty) {
      return _buildSafeFallbackWidget(width: width, height: height, fit: fit);
    }
    if (path.startsWith('assets/') || path.startsWith('lib/')) {
      return CloudAssetImage(
        path,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheWidth,
        filterQuality: FilterQuality.low,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) =>
            _buildSafeFallbackWidget(width: width, height: height, fit: fit),
      );
    }
    if (!kIsWeb && !path.startsWith('http')) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          cacheWidth: cacheWidth,
          filterQuality: FilterQuality.low,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) =>
              _buildSafeFallbackWidget(width: width, height: height, fit: fit),
        );
      }
    }
    return _buildSafeFallbackWidget(width: width, height: height, fit: fit);
  }

  static Widget _buildSafeFallbackWidget({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    const fallback = 'assets/images/avatars/generic_fallback.jpg';
    return CloudAssetImage(
      fallback,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.low,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => Container(
        width: width,
        height: height,
        color: AppTheme.bgCream,
        alignment: Alignment.center,
        child: Icon(
          Icons.local_cafe_rounded,
          color: AppTheme.primaryBrown.withValues(alpha: 0.72),
          size: ((width ?? height ?? 44) * 0.48).clamp(16.0, 34.0),
        ),
      ),
    );
  }
}

/// Widget bendera negara aman yang melindungi dari exception jika SVG asset tidak ditemukan.
class BaristaFlagBadge extends StatelessWidget {
  final String countryCode;
  final double width;
  final double height;
  final BoxFit fit;
  final double borderRadius;

  const BaristaFlagBadge({
    super.key,
    required this.countryCode,
    this.width = 18,
    this.height = 13,
    this.fit = BoxFit.contain,
    this.borderRadius = 2,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = countryCode.trim().toLowerCase();
    if (normalized.isEmpty) return const SizedBox.shrink();

    Widget badge;
    if (Flag.flagsCode.contains(normalized)) {
      badge = SvgPicture.asset(
        'packages/flag/res/4x3/$normalized.svg',
        width: width,
        height: height,
        fit: fit,
        semanticsLabel: normalized.toUpperCase(),
        placeholderBuilder: (_) => _buildCodeFallback(normalized),
        errorBuilder: (_, _, _) => _buildCodeFallback(normalized),
      );
    } else {
      badge = _buildCodeFallback(normalized);
    }

    if (borderRadius > 0) {
      badge = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: badge,
      );
    }
    return SizedBox(width: width, height: height, child: badge);
  }

  Widget _buildCodeFallback(String normalized) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.primaryBrown.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        normalized.toUpperCase(),
        style: TextStyle(
          fontSize: (height * 0.58).clamp(6.5, 9.5),
          fontWeight: FontWeight.w800,
          color: AppTheme.primaryBrown,
          height: 1.0,
        ),
      ),
    );
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
    final dpr = MediaQuery.devicePixelRatioOf(context).clamp(1.0, 2.5);
    final cacheW = (size * dpr).round().clamp(64, 512);
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
