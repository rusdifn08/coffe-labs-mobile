import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Utilitas nama/negara/slug barista dari field author resep.
class BaristaUtils {
  static const List<String> _emojis = [
    '🇳🇴', '🇬🇷', '🇨🇭', '🇯🇵', '🇬🇧', '🇷🇺', '🇹🇼', '🇮🇪', '🇨🇳', '🇰🇷',
    '🇺🇸', '🇨🇦', '🇦🇺', '🇸🇪', '🇨🇱', '🇫🇷', '🇵🇭', '🇩🇪', '🇷🇴', '🇭🇰',
    '🇲🇾', '🇸🇬', '🇦🇹', '🇦🇪', '🇨🇿', '🇮🇩', '🇧🇷', '🇮🇹', '🇫🇮', '🇨🇴',
  ];

  static const Map<String, String> emojiToCode = {
    '🇳🇴': 'no', '🇬🇷': 'gr', '🇨🇭': 'ch', '🇯🇵': 'jp', '🇬🇧': 'gb',
    '🇷🇺': 'ru', '🇹🇼': 'tw', '🇮🇪': 'ie', '🇨🇳': 'cn', '🇰🇷': 'kr',
    '🇺🇸': 'us', '🇨🇦': 'ca', '🇦🇺': 'au', '🇸🇪': 'se', '🇨🇱': 'cl',
    '🇫🇷': 'fr', '🇵🇭': 'ph', '🇩🇪': 'de', '🇷🇴': 'ro', '🇭🇰': 'hk',
    '🇲🇾': 'my', '🇸🇬': 'sg', '🇦🇹': 'at', '🇦🇪': 'ae', '🇨🇿': 'cz',
    '🇮🇩': 'id', '🇧🇷': 'br', '🇮🇹': 'it', '🇫🇮': 'fi', '🇨🇴': 'co',
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
      'it': 'Italia', 'br': 'Brasil', 'co': 'Kolombia',
    };
    return labels[code] ?? 'Internasional';
  }

  static String slugFromAuthor(String author) {
    final name = cleanName(author)
        .toLowerCase()
        .replaceAll('ø', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ä', 'a')
        .replaceAll('ü', 'u')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return name;
  }

  static String? imageUrlFromRecipe(Map<String, dynamic> recipe) {
    final url = (recipe['authorAvatarUrl'] ?? recipe['authorImageUrl'])?.toString();
    if (url == null || url.isEmpty) return null;
    return url;
  }
}

/// Avatar barista dengan fallback aman + cacheWidth untuk performa.
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
    final url = imageUrl;
    final Widget image;
    if (url != null && url.startsWith('assets/')) {
      image = Image.asset(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round().clamp(64, 512),
        errorBuilder: (_, error, stack) => Image.asset(
          'assets/images/avatars/generic_fallback.jpg',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else if (url != null && url.isNotEmpty) {
      image = Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stack) => Image.asset(
          'assets/images/avatars/generic_fallback.jpg',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else {
      image = Image.asset(
        'assets/images/avatars/generic_fallback.jpg',
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

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
