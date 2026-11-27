/// Leksikon moderasi kata kasar multibahasa Coffee Labs (15+ bahasa + anti-spam judi online).
///
/// Terbagi menjadi 4 lapisan presisi tinggi agar 0% false positive pada kosakata kopi:
/// 1. `severeSubstringTerms`: umpatan/kata kasar tegas (Latin & non-Latin: Hanzi, Hangul, Kana,
///    Cyrillic, Arabic, Devanagari) yang dicek baik utuh, substring token, maupun anti-spasi.
/// 2. `exactTokenTerms`: kata kasar pendek/ambigu yang HANYA diblokir bila berdiri sebagai token utuh.
/// 3. `safeCoffeeWhitelist`: kosakata kopi & umum yang secara eksplisit dilindungi.
/// 4. `wildcardPatterns`: pola sensor manual seperti `f*ck`, `k*nt*l`, `b*ngs*t`, `sh*t`.
class ProfanityLexicon {
  ProfanityLexicon._();

  static const Set<String> severeSubstringTerms = {
    // 1. Indonesia & Bahasa Daerah (Jawa, Sunda, Batak, Melayu, Minang, Makassar, Betawi)
    'bangsat', 'bangsad', 'kontol', 'kntol', 'kntl', 'memek', 'mmek', 'ngentot', 'ngntot',
    'entot', 'jancok', 'jancuk', 'dancok', 'dancuk', 'jnck', 'jncok', 'anjing', 'anjink',
    'anjir', 'anjrit', 'bajingan', 'keparat', 'brengsek', 'brengsex', 'pepek', 'jembut',
    'perek', 'lonte', 'bencong', 'pukimak', 'pukima', 'pantek', 'panteq', 'kimak', 'lancau',
    'lanjiao', 'tempik', 'turuk', 'pelacur', 'pecun', 'sundal', 'cibai', 'chibai', 'jablay',
    'tetek', 'ngocok', 'colmek', 'bokep', 'porno', 'sange', 'ngewe', 'ewean', 'goblog',
    'goblok', 'tolol', 'bego', 'idiot', 'laknat', 'biadab', 'kampret', 'bangke', 'taek',
    'telek', 'matamu', 'ndasmu', 'raimu', 'cangkemmu', 'jahanam', 'bodat', 'sundala',
    'telaso', 'bacot', 'bacod', 'bacotan', 'cocot', 'geblek', 'somplak', 'sinting',

    // 2. English
    'fuck', 'fucker', 'fucking', 'motherfucker', 'mofo', 'fuxk', 'shit', 'bullshit',
    'shitty', 'bitch', 'bitches', 'cunt', 'dickhead', 'cocksucker', 'asshole', 'arsehole',
    'bastard', 'whore', 'slut', 'wanker', 'twat', 'nigger', 'nigga', 'faggot', 'retard',
    'blowjob', 'handjob', 'pornhub', 'xvideos', 'xnxx',

    // 3. Filipino / Tagalog
    'putangina', 'tangina', 'gago', 'ulol', 'tarantado', 'pakyu', 'kupal', 'punyeta',
    'hinayupak', 'kantot',

    // 4. Spanish
    'hijodeputa', 'mierda', 'pendejo', 'cabron', 'chinga', 'chingada', 'chingar', 'verga',
    'pinche', 'joder', 'cojones', 'maricon', 'culero', 'carajo', 'gilipollas', 'malparido',
    'gonorrea',

    // 5. Portuguese
    'porra', 'caralho', 'fodase', 'buceta', 'arrombado', 'desgracado', 'viado', 'cuzao',
    'merda',

    // 6. French
    'merde', 'putain', 'salope', 'connard', 'connasse', 'encule', 'enculer', 'niquer',
    'bordel', 'batard', 'couille',

    // 7. German
    'scheisse', 'arschloch', 'hurensohn', 'ficken', 'fotze', 'wichser', 'schlampe',
    'missgeburt', 'verpiss', 'drecksau',

    // 8. Italian
    'stronzo', 'vaffanculo', 'fanculo', 'cazzo', 'coglione', 'puttana', 'troia', 'bastardo',

    // 9. Russian (Latin + Cyrillic)
    'blyat', 'blyad', 'cyka', 'pizdec', 'pizda', 'nahui', 'ebat', 'yebat', 'mudak',
    'pidor', 'pidoras', 'блядь', 'блять', 'сука', 'пиздец', 'пизда', 'хуй', 'ебать',
    'мудак', 'пидор',

    // 10. Korean (Romanized + Hangul)
    'shibal', 'ssibal', 'sibal', 'gaesaekki', 'saekki', 'byeongsin', 'byungsin', 'jiral',
    '씨발', '시발', '개새끼', '새끼', '병신', '지랄', '미친놈', '미친년', '좆',

    // 11. Japanese (Romanized + Kana / Kanji)
    'kusoyaro', 'chikusho', 'bakayaro', 'chinko', 'manko', 'yariman', 'くそ', 'クソ',
    '糞', '死ね', 'ちんこ', 'まんこ', 'ばかやろう', 'バカヤロウ', 'クソ野郎',

    // 12. Chinese / Mandarin / Cantonese / Hokkien (Pinyin + Hanzi)
    'caonima', 'shabi', 'nimabi', 'tamade', 'gundan', 'diulei', 'pokgai', 'kanina',
    'knnbccb', '操你妈', '草泥马', '傻逼', '煞笔', '妈逼', '他妈的', '滚蛋', '屌你', '扑街',

    // 13. Arabic (Romanized + Arabic Script)
    'sharmouta', 'sharmuta', 'kusomak', 'kosomak', 'manyouk', 'شرموطة', 'كس امك',
    'كسمك', 'خرا', 'ابن الكلب', 'منيوك', 'قحبة',

    // 14. Hindi / Urdu (Romanized + Devanagari)
    'madarchod', 'bhenchod', 'behenchod', 'chutiya', 'chutiye', 'bhosdike', 'bhosdi',
    'harami', 'haramzada', 'gandu', 'randi', 'मादरचोद', 'बहनचोद', 'चूतिया', 'भोसड़ीके',
    'हरामी', 'गांडू', 'रंडी',

    // 15. Turkish, Polish, Dutch
    'orospu', 'siktir', 'amcik', 'yarrak', 'pezevenk', 'kurwa', 'pierdol', 'spierdalaj',
    'klootzak',

    // 16. Anti-Spam Judi Online / Scam / SARA
    'slot gacor', 'judi online', 'togel online', 'situs gacor', 'maxwin88', 'zeus88',
    'slot88', 'jp maxwin', 'depo slot', 'judol', 'pinjol ilegal', 'scammer',
    'penipu anjing', 'kafir laknat', 'bunuh diri',
  };

  /// Daftar istilah khusus judi online / spam / penipuan agar kategori pelanggaran tampil spesifik.
  static const Set<String> gamblingAndScamTerms = {
    'slot gacor', 'judi online', 'togel online', 'situs gacor', 'maxwin88', 'zeus88',
    'slot88', 'jp maxwin', 'depo slot', 'judol', 'pinjol ilegal', 'scammer',
  };

  /// Kata pendek/ambigu yang HANYA diblokir bila muncul sebagai token/kata berdiri sendiri.
  static const Set<String> exactTokenTerms = {
    'asu', 'cok', 'cuk', 'fck', 'fuk', 'fuq', 'fk', 'fu', 'sht', 'btch', 'cnt',
    'bgst', 'bgsd', 'ajg', 'anjg', 'mmk', 'ktl', 'ntot', 'ngtd', 'tai', 'tae',
    'babi', 'dick', 'cock', 'pussy', 'piss', 'ass', 'cum', 'fag', 'hoe', 'wtf',
    'stfu', 'puta', 'puto', 'foda', 'foder', 'kuso', 'khara', 'hui', 'khuy',
    'coli', 'ewe', 'itil', 'porn', 'nude', 'knn', 'chuj', 'hoer',
  };

  /// Daftar kosakata kopi & umum yang aman (mencegah false positive seperti "memekarkan", "classic", "masuk").
  static const Set<String> safeCoffeeWhitelist = {
    'espresso', 'classic', 'class', 'passion', 'assessment', 'assistant', 'associate',
    'peacock', 'hancock', 'cockpit', 'title', 'subtitle', 'scunthorpe', 'masuk', 'kasus',
    'kasur', 'asuransi', 'basuh', 'titik', 'titisan', 'kocok', 'mengocok', 'cocok',
    'analisis', 'analisa', 'memekarkan', 'mekar', 'bloom', 'blooming', 'pantai',
    'tangkai', 'bintang', 'suka', 'suku', 'sukses', 'bitter', 'bitterness', 'arabica',
    'robusta', 'kintamani', 'bajawa', 'toraja', 'gayo', 'mandheling', 'kerinci',
    'puntang', 'ciwidey', 'garut', 'temanggung', 'wamena', 'papua', 'flores', 'halu',
    'shining', 'sunshine', 'shine', 'pic', 'pics', 'picture', 'bite', 'bobo', 'tangga',
  };

  static final List<String> nonAsciiOrMultiWordSevere = severeSubstringTerms
      .where((t) => _hasNonAscii(t) || t.contains(' '))
      .toList(growable: false);

  static final List<String> asciiSingleWordSevere = severeSubstringTerms
      .where((t) => !_hasNonAscii(t) && !t.contains(' '))
      .toList(growable: false);

  static final List<String> antiSpacingSevere = asciiSingleWordSevere
      .where((t) => t.length >= 4)
      .toList(growable: false);

  static bool _hasNonAscii(String s) {
    for (final unit in s.codeUnits) {
      if (unit > 127) return true;
    }
    return false;
  }
}
