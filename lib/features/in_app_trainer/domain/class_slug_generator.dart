/// Generator slug kelas ML deterministik (hidden di belakang layar).
class ClassSlugGenerator {
  static const Set<String> _stopWords = {
    'roastery',
    'roasters',
    'roaster',
    'coffee',
    'coffe',
    'beans',
    'bean',
    'kopi',
    'pt',
    'cv',
    'co',
    'ltd',
    'official',
    'store',
    'indonesia',
  };

  /// Menghasilkan slug deterministik format: `brand_beanname_process`
  static String generate({
    required String brand,
    required String beanName,
    required String process,
  }) {
    final cleanBrand = _cleanToken(brand);
    final cleanBean = _cleanToken(beanName);
    final cleanProcess = _cleanToken(process);

    final parts = [cleanBrand, cleanBean, cleanProcess]
        .where((s) => s.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'custom_coffee_bean';
    return parts.join('_');
  }

  static String _cleanToken(String input) {
    var text = input.trim().toLowerCase();

    // Hapus karakter non-alphanumeric selain spasi
    text = text.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');

    // Pisah kata dan eliminasi stop words
    final words = text
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !_stopWords.contains(w))
        .toList();

    if (words.isEmpty) {
      // Fallback bila semua kata terfilter
      final fallbackWords = input
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList();
      return fallbackWords.join('_');
    }

    return words.join('_');
  }
}
