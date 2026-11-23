import '../../services/language_service.dart';
import 'profanity_lexicon.dart';

/// Hasil inspeksi sistem moderasi konten multibahasa Coffee Labs.
class ModerationVerdict {
  final bool isAllowed;
  final String? reasonCode;
  final String? category;
  final String? userMessage;

  const ModerationVerdict._({
    required this.isAllowed,
    this.reasonCode,
    this.category,
    this.userMessage,
  });

  const ModerationVerdict.allowed() : this._(isAllowed: true);

  const ModerationVerdict.blocked({
    required String reasonCode,
    required String category,
    required String userMessage,
  }) : this._(
          isAllowed: false,
          reasonCode: reasonCode,
          category: category,
          userMessage: userMessage,
        );
}

/// Exception resmi saat layer service menolak konten karena melanggar moderasi kata kasar.
class ContentModerationException implements Exception {
  final ModerationVerdict verdict;
  const ContentModerationException(this.verdict);

  @override
  String toString() =>
      verdict.userMessage ??
      'Konten mengandung kata kasar atau tidak pantas dan diblokir oleh sistem moderasi Coffee Labs.';
}

/// Mesin arsitektur moderasi konten multibahasa client-side (zero-latency, offline-capable).
///
/// Fitur anti-bypass:
/// - Penghapusan karakter tak terlihat (zero-width, soft-hyphen, bidirectional markers)
/// - Normalisasi diakritik lintas bahasa & leetspeak (`f*ck`, `k0nt0l`, `b4ngs4t`, `5h1t`, `@nj1ng`)
/// - Dual-form matching: decoded-only (`scheisse`, `vaffanculo`, `asshole`) + repeat-collapsed (`fuuuuuck -> fuck`)
/// - Deteksi bypass spasi/tanda baca (`f u c k`, `k.o.n.t.o.l`, `b-a-n-g-s-a-t`)
/// - Deteksi multi-skrip (Latin, Hangul, Hanzi, Kana/Kanji, Cyrillic, Arabic, Devanagari)
/// - Whitelist kosakata kopi & umum agar 0% false positive.
class ContentModerationGuard {
  ContentModerationGuard._();

  static final RegExp _zeroWidthRegex = RegExp(
    r'[\u200B-\u200F\u202A-\u202E\u2060\uFEFF\u00AD]',
  );
  static final RegExp _tokenSplitRegex = RegExp(
    r'[\s,;:\?"\x27()\[\]{}/\\<>]+',
  );
  static final RegExp _nonLatinAlphaRegex = RegExp(r'[^a-z]');

  static const Map<String, String> _diacriticAndLeetMap = {
    'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a', '@': 'a', '4': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', '3': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', 'ı': 'i', '1': 'i', '!': 'i', '|': 'i',
    'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o', 'ø': 'o', '0': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ñ': 'n',
    'ç': 'c', 'ć': 'c',
    'ş': 's', 'š': 's', '\$': 's', '5': 's',
    'ğ': 'g',
    'ł': 'l',
    '7': 't',
    '8': 'b',
  };

  static final List<String> _collapsedAsciiSevere = ProfanityLexicon
      .asciiSingleWordSevere
      .map(collapseRepeats)
      .toList(growable: false);

  static final Set<String> _collapsedExactTokens = ProfanityLexicon
      .exactTokenTerms
      .map(collapseRepeats)
      .toSet();

  static final List<String> _collapsedAntiSpacing = ProfanityLexicon
      .antiSpacingSevere
      .map(collapseRepeats)
      .toList(growable: false);

  /// Menghapus karakter zero-width, mengganti `ß -> ss`, dan menurunkan huruf menjadi lowercase.
  static String normalizeZeroWidthAndLower(String input) {
    return input
        .replaceAll(_zeroWidthRegex, '')
        .replaceAll('ß', 'ss')
        .replaceAll('ẞ', 'ss')
        .toLowerCase();
  }

  /// Decode diakritik & leetspeak tanpa menghilangkan huruf ganda (`scheisse -> scheisse`, `k0nt0l -> kontol`).
  static String decodeLeetOnly(String token) {
    final buf = StringBuffer();
    for (int i = 0; i < token.length; i++) {
      final ch = token[i];
      final mapped = _diacriticAndLeetMap[ch] ?? ch;
      if (_nonLatinAlphaRegex.hasMatch(mapped)) continue;
      buf.write(mapped);
    }
    return buf.toString();
  }

  /// Gabungkan huruf berulang (`fuuuuuck -> fuck`, `scheiiiisse -> scheise`).
  static String collapseRepeats(String input) {
    final buf = StringBuffer();
    String? prev;
    for (int i = 0; i < input.length; i++) {
      final ch = input[i];
      if (prev != ch) {
        buf.write(ch);
        prev = ch;
      }
    }
    return buf.toString();
  }

  /// Decode leetspeak + collapse huruf berulang (`fuuuuck -> fuck`, `k0nt00l -> kontol`).
  static String decodeLeetAndCollapse(String token) {
    return collapseRepeats(decodeLeetOnly(token));
  }

  /// Cek cepat apakah teks mengandung kata kasar multibahasa.
  static bool containsProfanity(String rawText) {
    return !inspect(rawText).isAllowed;
  }

  /// Menginspeksi satu field teks dan mengembalikan [ModerationVerdict].
  static ModerationVerdict inspect(
    String rawText, {
    String fieldLabel = 'Konten',
  }) {
    final clean = normalizeZeroWidthAndLower(rawText).trim();
    if (clean.isEmpty) return const ModerationVerdict.allowed();

    // Lapisan 1: Skrip non-Latin (Hangul, Hanzi, Kana, Cyrillic, Arabic, Devanagari) & frasa multi-kata
    for (final term in ProfanityLexicon.nonAsciiOrMultiWordSevere) {
      if (clean.contains(term)) {
        return _buildBlockedVerdict(fieldLabel);
      }
    }

    // Lapisan 2: Tokenisasi Latin + wildcard (`f*ck`, `k*nt*l`) + dual-form leetspeak/repeat check
    final tokens = clean
        .split(_tokenSplitRegex)
        .where((t) => t.isNotEmpty)
        .toList(growable: false);

    for (final tok in tokens) {
      if (_matchesMaskedWildcard(tok)) {
        return _buildBlockedVerdict(fieldLabel);
      }
      final alphaOnly = tok.replaceAll(_nonLatinAlphaRegex, '');
      if (ProfanityLexicon.safeCoffeeWhitelist.contains(alphaOnly)) {
        continue;
      }
      final decoded = decodeLeetOnly(tok);
      final collapsed = collapseRepeats(decoded);
      if (decoded.isEmpty ||
          ProfanityLexicon.safeCoffeeWhitelist.contains(decoded) ||
          ProfanityLexicon.safeCoffeeWhitelist.contains(collapsed)) {
        continue;
      }
      if (ProfanityLexicon.exactTokenTerms.contains(decoded) ||
          _collapsedExactTokens.contains(collapsed)) {
        return _buildBlockedVerdict(fieldLabel);
      }
      for (int i = 0; i < ProfanityLexicon.asciiSingleWordSevere.length; i++) {
        if (decoded.contains(ProfanityLexicon.asciiSingleWordSevere[i]) ||
            collapsed.contains(_collapsedAsciiSevere[i])) {
          return _buildBlockedVerdict(fieldLabel);
        }
      }
    }

    // Lapisan 3: Anti-spacing bypass (`f u c k`, `k.o.n.t.o.l`, `b-a-n-g-s-a-t`)
    final shortBuf = StringBuffer();
    int shortCount = 0;
    for (final tok in tokens) {
      final dec = decodeLeetOnly(tok);
      if (dec.isNotEmpty && dec.length <= 2) {
        shortBuf.write(dec);
        shortCount++;
        if (shortCount >= 3 && shortBuf.length >= 4) {
          final joined = shortBuf.toString();
          final joinedCollapsed = collapseRepeats(joined);
          for (int i = 0; i < ProfanityLexicon.antiSpacingSevere.length; i++) {
            if (joined.contains(ProfanityLexicon.antiSpacingSevere[i]) ||
                joinedCollapsed.contains(_collapsedAntiSpacing[i])) {
              return _buildBlockedVerdict(fieldLabel);
            }
          }
        }
      } else {
        shortBuf.clear();
        shortCount = 0;
      }
    }

    return const ModerationVerdict.allowed();
  }

  /// Menginspeksi beberapa field sekaligus (misal isi post + tagar, atau nama + bio).
  static ModerationVerdict inspectMultiple(Map<String, String?> fields) {
    for (final entry in fields.entries) {
      final val = entry.value;
      if (val == null || val.trim().isEmpty) continue;
      final verdict = inspect(val, fieldLabel: entry.key);
      if (!verdict.isAllowed) return verdict;
    }
    return const ModerationVerdict.allowed();
  }

  /// Lapisan defensif tampilan: bila ada teks lama dari cache/legacy yang lolos, sensor otomatis.
  static String sanitizeForDisplay(String rawText) {
    if (rawText.trim().isEmpty || !containsProfanity(rawText)) {
      return rawText;
    }
    final words = rawText.split(' ');
    final sanitized = words.map((w) {
      if (containsProfanity(w)) {
        return '•' * w.length.clamp(3, 6);
      }
      return w;
    }).join(' ');
    if (containsProfanity(sanitized)) {
      return '[Konten disembunyikan oleh filter moderasi komunitas]';
    }
    return sanitized;
  }

  static bool _matchesMaskedWildcard(String rawToken) {
    if (!rawToken.contains('*') && !rawToken.contains('#') && !rawToken.contains('_')) {
      return false;
    }
    final buf = StringBuffer();
    int alphaCount = 0;
    for (int i = 0; i < rawToken.length; i++) {
      final ch = rawToken[i];
      if (ch == '*' || ch == '#' || ch == '_' || ch == '.' || ch == '-') {
        buf.write('*');
      } else {
        final mapped = _diacriticAndLeetMap[ch] ?? ch;
        if (!_nonLatinAlphaRegex.hasMatch(mapped)) {
          buf.write(mapped);
          alphaCount++;
        }
      }
    }
    final cleaned = buf.toString();
    if (cleaned.length < 4 || alphaCount < 2 || !cleaned.contains('*')) {
      return false;
    }
    final regexPattern = '^${cleaned.replaceAll(RegExp(r'\*+'), '[a-z]+')}\$';
    final wildcardRe = RegExp(regexPattern);
    for (final term in ProfanityLexicon.asciiSingleWordSevere) {
      if (term.length >= 4 &&
          term.length <= cleaned.length + 3 &&
          wildcardRe.hasMatch(term)) {
        return true;
      }
    }
    return false;
  }

  static ModerationVerdict _buildBlockedVerdict(String fieldLabel) {
    final isEn = LanguageService.isEnglish;
    return ModerationVerdict.blocked(
      reasonCode: 'PROFANITY_DETECTED',
      category: isEn ? 'Profanity & Abusive Language' : 'Kata Kasar & Bahasa Tidak Pantas',
      userMessage: isEn
          ? '$fieldLabel contains profane or abusive language and cannot be published. Please keep Coffee Labs respectful and friendly.'
          : '$fieldLabel mengandung kata kasar atau tidak pantas sehingga diblokir otomatis. Mari jaga komunitas Coffee Labs tetap sopan dan nyaman.',
    );
  }
}
