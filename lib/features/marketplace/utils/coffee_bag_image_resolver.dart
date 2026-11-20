/// Memastikan produk Marketplace TIDAK PERNAH menampilkan foto potret barista
/// (`avatars/covers/*`) atau screenshot UI palsu, dan hanya merender foto
/// kemasan kopi terverifikasi atau kemasan studio bermerek roastery.
class CoffeeBagImageResolver {
  static const Map<String, String> _verifiedRealLocalBagBySlug = {
    'indibro_sutoyo_mknd_bali_kintamani': 'assets/images/beans/mknd_bali_kintamani.jpg',
    'indibro_sutoyo_mknd_kopi_excelsa': 'assets/images/beans/mknd_kopi_excelsa.jpg',
    'indibro_sutoyo_mknd_aceh_gayo': 'assets/images/beans/mknd_aceh_gayo.jpg',
    'indibro_sutoyo_mknd_toraja_sapan': 'assets/images/beans/mknd_toraja_sapan.jpg',
    'fugol_coffee_kamojang_classico': 'assets/images/beans/kamojang_classico.jpg',
    'mahugi_coffee_ijen_carbonic': 'assets/images/beans/mahugi_ijen_carbonic.jpg',
    'mahugi_coffee_rancabali_patuha': 'assets/images/beans/mahugi_rancabali_patuha.jpg',
  };

  /// Mengidentifikasi URL/path yang wajib ditolak (potret manusia, avatar cover, UI screenshot).
  static bool isBlockedPortraitOrScreenshot(String rawUrl) {
    final low = rawUrl.trim().toLowerCase();
    if (low.isEmpty) return true;
    return low.contains('avatars/') ||
        low.contains('/portraits/') ||
        low.contains('/covers/') ||
        low.contains('mikael_jasin') ||
        low.contains('fugol_sample_');
  }

  /// Resolusi aman gambar kemasan kopi + flag verifikasi visual.
  static ({String imageUrl, bool isVerifiedPhoto, String roasteryLogoAsset})
      resolve({
    required String roasteryId,
    required String coffeeName,
    String? explicitBagUrl,
  }) {
    final logoAsset = roasteryId.trim().isNotEmpty
        ? 'assets/images/roasteries/${roasteryId.trim()}.png'
        : 'assets/images/coffee_labs_emblem.png';

    final cleanExplicit = (explicitBagUrl ?? '').trim();
    if (cleanExplicit.startsWith('http://') ||
        cleanExplicit.startsWith('https://')) {
      return (
        imageUrl: cleanExplicit,
        isVerifiedPhoto: true,
        roasteryLogoAsset: logoAsset,
      );
    }

    final slug = coffeeName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final fullKey = '${roasteryId}_$slug';

    for (final entry in _verifiedRealLocalBagBySlug.entries) {
      if (fullKey.contains(entry.key) ||
          (roasteryId == 'indibro_sutoyo_mknd' &&
              slug.contains(entry.key.split('_mknd_').last))) {
        return (
          imageUrl: entry.value,
          isVerifiedPhoto: true,
          roasteryLogoAsset: logoAsset,
        );
      }
    }

    return (
      imageUrl: '',
      isVerifiedPhoto: false,
      roasteryLogoAsset: logoAsset,
    );
  }
}
