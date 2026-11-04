/// Utility to normalize coffee recipe instructions, titles, and technical metrics
/// into natural, warm, articulate Indonesian Female Barista speech for TTS.
/// Accurately phoneticizes English coffee terms (like 'Pour', 'Bloom', 'Drawdown', etc.)
/// so the Indonesian female voice engine speaks them with authentic, professional English articulation.
class VoiceTextNormalizer {
  /// Builds a complete, natural Indonesian barista vocal prompt for a brewing step.
  static String buildStepPrompt({
    required String title,
    required String instruction,
    required int stepIndex,
    int? stepWaterGrams,
    int? cumulativeWaterGrams,
    int? waterTempCelsius,
    int? durationSeconds,
    bool isNextStep = false,
  }) {
    final String spokenTitle = normalizeTitle(title, stepIndex, isNextStep: isNextStep);
    String body = instruction.trim();

    if (body.isEmpty) {
      if (stepWaterGrams != null && stepWaterGrams > 0) {
        final tempPart = (waterTempCelsius != null && waterTempCelsius > 0 && stepIndex == 0)
            ? ' bersuhu $waterTempCelsius derajat celcius'
            : '';
        final durPart = (durationSeconds != null && durationSeconds > 0)
            ? ' selama $durationSeconds detik'
            : '';
        body = 'Tuang $stepWaterGrams gram air$tempPart secara perlahan$durPart.';
      } else if (durationSeconds != null && durationSeconds > 0) {
        body = 'Pertahankan tahapan ini selama $durationSeconds detik.';
      }
    } else {
      // Ensure water weight and temperature are explicitly spoken if not already in text
      final hasGramMention = RegExp(r'\d+\s*(?:g|gr|gram|ml|mililiter)\b', caseSensitive: false).hasMatch(body);
      if (!hasGramMention && stepWaterGrams != null && stepWaterGrams > 0) {
        final tempPart = (waterTempCelsius != null && waterTempCelsius > 0 && stepIndex == 0)
            ? ' suhu $waterTempCelsius derajat celcius'
            : '';
        body = 'Tuang $stepWaterGrams gram air$tempPart. $body';
      }
    }

    final String spokenInstruction = normalizeInstruction(body);
    if (spokenInstruction.isEmpty) {
      return '$spokenTitle.';
    }
    return '$spokenTitle. $spokenInstruction';
  }

  /// Converts technical recipe text into natural conversational Indonesian speech
  /// with authentic English pronunciation for coffee terminology.
  static String normalizeInstruction(String rawText) {
    if (rawText.trim().isEmpty) return '';

    String text = rawText;

    // 1. Normalize step numbering at beginning (e.g. "1. " -> "Tahap satu, ")
    text = text.replaceAllMapped(RegExp(r'^(\d+)\.\s*'), (m) {
      final numStr = _numberToWord(int.tryParse(m[1] ?? '1') ?? 1);
      return 'Tahap $numStr, ';
    });

    // 2. English coffee loanwords and technical barista jargon
    text = _phoneticizeCoffeeTerms(text);

    // 3. Remove leading plus sign on weights (+45g -> 45g)
    text = text.replaceAllMapped(RegExp(r'\+(\d+)'), (m) => '${m[1]}');

    // 4. Normalize water temperature range first (90°C–91°C -> 90 sampai 91 derajat celcius)
    text = text.replaceAllMapped(
      RegExp(r'(\d+)\s*(?:°\s*C|°\s*c)?\s*[–-]\s*(\d+)\s*(?:°\s*C|°\s*c|derajat\s*c(?:elcius)?)\b', caseSensitive: false),
      (m) => '${m[1]} sampai ${m[2]} derajat celcius',
    );
    // Single temperature (°C / °c -> derajat celcius)
    text = text.replaceAllMapped(
      RegExp(r'(\d+)\s*(?:°\s*C|°\s*c|derajat\s*c(?:elcius)?)(?=\s|[.,;)]|$)', caseSensitive: false),
      (m) => '${m[1]} derajat celcius',
    );

    // 5. Normalize ratios FIRST (1:15 -> satu banding 15, 4:6 -> empat banding enam)
    text = text.replaceAll(RegExp(r'\b4:6\b'), 'empat banding enam');
    text = text.replaceAllMapped(
      RegExp(r'\b1:(\d+(?:[.,]\d+)?)\b'),
      (m) => 'satu banding ${m[1]}',
    );

    // 6. Normalize time markers (0:45 or menit 1:30)
    text = text.replaceAllMapped(
      RegExp(r'\b0:(\d{2})\b'),
      (m) {
        final secs = int.tryParse(m[1] ?? '0') ?? 0;
        return '$secs detik';
      },
    );
    text = text.replaceAllMapped(
      RegExp(r'(?:menit\s+)(\d+):(\d{2})\b', caseSensitive: false),
      (m) {
        final mins = int.tryParse(m[1] ?? '0') ?? 0;
        final secs = int.tryParse(m[2] ?? '0') ?? 0;
        if (mins == 0) return 'menit ke $secs detik';
        if (secs == 0) return 'menit ke $mins';
        return 'menit $mins lewat $secs detik';
      },
    );

    // 7. Normalize volume (ml / mL -> mililiter)
    text = text.replaceAllMapped(
      RegExp(r'(\d+(?:[.,]\d+)?)\s*(?:ml|mL|mililiter)\b', caseSensitive: false),
      (m) => '${m[1]} mililiter',
    );

    // 8. Normalize weight (g / gr / gram -> gram)
    text = text.replaceAllMapped(
      RegExp(r'(\d+(?:[.,]\d+)?)\s*(?:g|gr|gram)\b', caseSensitive: false),
      (m) => '${m[1]} gram',
    );

    // 9. Normalize centimeters (cm -> sentimeter)
    text = text.replaceAllMapped(
      RegExp(r'(\d+(?:[.,]\d+)?)\s*cm\b', caseSensitive: false),
      (m) => '${m[1]} sentimeter',
    );

    // 10. Normalize CO2 (CO2 / co2 -> karbon dioksida)
    text = text.replaceAll(RegExp(r'\bCO2\b|\bco2\b'), 'karbon dioksida');

    // 11. Normalize time seconds (s / dtk / detik -> detik)
    text = text.replaceAllMapped(
      RegExp(r'(\d+)\s*(?:s|dtk|detik)\b', caseSensitive: false),
      (m) => '${m[1]} detik',
    );

    // 12. Normalize microns (µm / um / micron -> mikron)
    text = text.replaceAllMapped(
      RegExp(r'(\d+)\s*(?:µm|μm|um|mikron)\b', caseSensitive: false),
      (m) => '${m[1]} mikron',
    );

    // 13. Normalize multipliers (2x -> dua kali)
    text = text.replaceAllMapped(
      RegExp(r'\b(\d+)x\b', caseSensitive: false),
      (m) => '${_numberToWord(int.tryParse(m[1] ?? '2') ?? 2)} kali',
    );

    // 14. Normalize percentages (40% -> 40 persen)
    text = text.replaceAllMapped(
      RegExp(r'(\d+(?:[.,]\d+)?)\s*%'),
      (m) => '${m[1]} persen',
    );

    // 15. Clean slashes and brackets for natural prosody pauses
    text = text.replaceAll(' / ', ', ');
    text = text.replaceAll('(', ', ').replaceAll(')', ', ');
    text = text.replaceAll('·', ', ');
    text = text.replaceAll('•', ', ');
    text = text.replaceAll(RegExp(r',\s*,+'), ', ');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }

  /// Phoneticizes English coffee jargon so Indonesian speech synthesis articulates them naturally
  /// (e.g. 'Pour' -> 'Por', 'Bloom' -> 'Blum', 'Drawdown' -> 'Drodaun').
  static String _phoneticizeCoffeeTerms(String input) {
    String text = input;

    // Multi-word compound terms first
    text = text.replaceAll(RegExp(r'\bDouble[- ]Weight Bloom\b', caseSensitive: false), 'Dabel Weit Blum');
    text = text.replaceAll(RegExp(r'\bSteady Circle Main Pour\b', caseSensitive: false), 'Stedi Serkel Mein Por');
    text = text.replaceAll(RegExp(r'\bSteady Circle\b', caseSensitive: false), 'Stedi Serkel');
    text = text.replaceAll(RegExp(r'\bMain Pour\b', caseSensitive: false), 'Mein Por');
    text = text.replaceAll(RegExp(r'\bCenter Pour\b', caseSensitive: false), 'Senter Por');
    text = text.replaceAll(RegExp(r'\bSpiral Pour\b', caseSensitive: false), 'Spiral Por');
    text = text.replaceAll(RegExp(r'\bPulse Pour\b', caseSensitive: false), 'Pals Por');
    text = text.replaceAll(RegExp(r'\bOsmotic Pour\b', caseSensitive: false), 'Osmotik Por');
    text = text.replaceAll(RegExp(r'\bPour[- ]Over\b', caseSensitive: false), 'Por Over');
    text = text.replaceAll(RegExp(r'\bFirst Pour\b', caseSensitive: false), 'Ferst Por');
    text = text.replaceAll(RegExp(r'\bSecond Pour\b', caseSensitive: false), 'Sekend Por');
    text = text.replaceAll(RegExp(r'\bThird Pour\b', caseSensitive: false), 'Terd Por');
    text = text.replaceAll(RegExp(r'\bfinal\s+pour\b'), 'fainel por');
    text = text.replaceAll(RegExp(r'\bFinal\s+Pour\b', caseSensitive: false), 'Fainel Por');
    text = text.replaceAll(RegExp(r'\bFlash Brew\b', caseSensitive: false), 'Flesy Bru');
    text = text.replaceAll(RegExp(r'\bCold Brew\b', caseSensitive: false), 'Kold Bru');
    text = text.replaceAll(RegExp(r'\bCold Drip\b', caseSensitive: false), 'Kold Drip');
    text = text.replaceAll(RegExp(r'\bFrench Press\b', caseSensitive: false), 'Frents Pres');
    text = text.replaceAll(RegExp(r'\bAeroPress\b|\bAeropress\b', caseSensitive: false), 'Eropres');
    text = text.replaceAll(RegExp(r'\bKalita Wave\b', caseSensitive: false), 'Kalita Weiv');
    text = text.replaceAll(RegExp(r'\bFlat Bottom\b', caseSensitive: false), 'Flet Botom');
    text = text.replaceAll(RegExp(r'\bPaper Filter\b', caseSensitive: false), 'Peper Filter');
    text = text.replaceAll(RegExp(r'\bCloth Filter\b', caseSensitive: false), 'Klos Filter');
    text = text.replaceAll(RegExp(r'\bClever Dripper\b', caseSensitive: false), 'Klever Driper');
    text = text.replaceAll(RegExp(r'\bGooseneck Kettle\b', caseSensitive: false), 'Gusnek Ketel');
    text = text.replaceAll(RegExp(r'\bGooseneck\b', caseSensitive: false), 'Gusnek');
    text = text.replaceAll(RegExp(r'\bPuck Prep\b', caseSensitive: false), 'Pak Prep');
    text = text.replaceAll(RegExp(r'\bPre[- ]infusion\b', caseSensitive: false), 'Pri-infyusyen');
    text = text.replaceAll(RegExp(r'\bPre[- ]wetting\b', caseSensitive: false), 'Pri-weting');
    text = text.replaceAll(RegExp(r'\bClean Cup\b', caseSensitive: false), 'Klin Kap');
    text = text.replaceAll(RegExp(r'\bSingle Origin\b', caseSensitive: false), 'Singel Orijin');
    text = text.replaceAll(RegExp(r'\bGrind Size\b', caseSensitive: false), 'Graind Sais');
    text = text.replaceAll(RegExp(r'\bMedium[- ]Coarse\b', caseSensitive: false), 'Medium Kors');
    text = text.replaceAll(RegExp(r'\bMedium[- ]Fine\b', caseSensitive: false), 'Medium Fain');
    text = text.replaceAll(RegExp(r'\bGroup Head\b|\bGrouphead\b', caseSensitive: false), 'Grup Hed');
    text = text.replaceAll(RegExp(r'\bscale reads\b', caseSensitive: false), 'timbangan menunjukkan');

    // Standalone English coffee terms
    text = text.replaceAll(RegExp(r'\bpour\b', caseSensitive: false), 'por');
    text = text.replaceAll(RegExp(r'\bpours\b', caseSensitive: false), 'pors');
    text = text.replaceAll(RegExp(r'\bpouring\b', caseSensitive: false), 'poring');
    text = text.replaceAll(RegExp(r'\bbloom\b', caseSensitive: false), 'blum');
    text = text.replaceAll(RegExp(r'\bblooming\b', caseSensitive: false), 'bluming');
    text = text.replaceAll(RegExp(r'\bdrawdown\b', caseSensitive: false), 'drodaun');
    text = text.replaceAll(RegExp(r'\bchanneling\b', caseSensitive: false), 'tseneling');
    text = text.replaceAll(RegExp(r'\bswirl\b', caseSensitive: false), 'swerl');
    text = text.replaceAll(RegExp(r'\bswirling\b', caseSensitive: false), 'swerling');
    text = text.replaceAll(RegExp(r'\bchemex\b', caseSensitive: false), 'kemeks');
    text = text.replaceAll(RegExp(r'\bsyphon\b|\bsiphon\b', caseSensitive: false), 'saifon');
    text = text.replaceAll(RegExp(r'\bv60\b', caseSensitive: false), 'V-siksti');
    text = text.replaceAll(RegExp(r'\bswitch\b', caseSensitive: false), 'switsy');
    text = text.replaceAll(RegExp(r'\bpuck\b', caseSensitive: false), 'pak');
    text = text.replaceAll(RegExp(r'\btamper\b', caseSensitive: false), 'temper');
    text = text.replaceAll(RegExp(r'\btamping\b', caseSensitive: false), 'temping');
    text = text.replaceAll(RegExp(r'\bkettle\b', caseSensitive: false), 'ketel');
    text = text.replaceAll(RegExp(r'\bdripper\b', caseSensitive: false), 'driper');
    text = text.replaceAll(RegExp(r'\bflow\b', caseSensitive: false), 'flo');
    text = text.replaceAll(RegExp(r'\bpulse\b', caseSensitive: false), 'pals');
    text = text.replaceAll(RegExp(r'\bcoarse\b', caseSensitive: false), 'kors');
    text = text.replaceAll(RegExp(r'\bfines\b', caseSensitive: false), 'fains');
    text = text.replaceAll(RegExp(r'\btimer\b', caseSensitive: false), 'taimer');
    text = text.replaceAll(RegExp(r'\bbody\b', caseSensitive: false), 'bodi');
    text = text.replaceAll(RegExp(r'\bsweetness\b', caseSensitive: false), 'switnes');
    text = text.replaceAll(RegExp(r'\baftertaste\b', caseSensitive: false), 'afterteist');
    text = text.replaceAll(RegExp(r'\buntil\b', caseSensitive: false), 'hingga');

    return text;
  }

  /// Normalizes step title for vocal announcement.
  static String normalizeTitle(String rawTitle, int stepIndex, {bool isNextStep = false}) {
    String clean = rawTitle.replaceAll(RegExp(r'^\d+\.\s*'), '').trim();
    clean = clean.replaceAllMapped(
      RegExp(r'\(Pour\s*(\d+)\)', caseSensitive: false),
      (m) => 'tuangan ke-${_numberToWord(int.tryParse(m[1] ?? '1') ?? 1)}',
    );
    clean = normalizeInstruction(clean);
    final word = _numberToWord(stepIndex + 1);
    if (isNextStep) {
      return 'Bersiap tahap $word, $clean';
    }
    return 'Tahap $word, $clean';
  }

  /// Splits normalized text into natural prosody clauses (<= 150 chars each)
  /// so TTS engines articulate each sentence clearly without truncation.
  static List<String> splitIntoSpeechChunks(String text, {int maxChunkLength = 150}) {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return const [];
    if (cleaned.length <= maxChunkLength) return [cleaned];

    final List<String> result = [];
    final sentences = cleaned.split(RegExp(r'(?<=[.!?])\s+'));

    String buffer = '';
    for (final sentence in sentences) {
      if (sentence.trim().isEmpty) continue;
      if (buffer.isEmpty) {
        if (sentence.length <= maxChunkLength) {
          buffer = sentence;
        } else {
          result.addAll(_splitLongSentenceByClauses(sentence, maxChunkLength));
        }
      } else if (buffer.length + 1 + sentence.length <= maxChunkLength) {
        buffer = '$buffer $sentence';
      } else {
        result.add(buffer.trim());
        if (sentence.length <= maxChunkLength) {
          buffer = sentence;
        } else {
          result.addAll(_splitLongSentenceByClauses(sentence, maxChunkLength));
          buffer = '';
        }
      }
    }
    if (buffer.trim().isNotEmpty) {
      result.add(buffer.trim());
    }
    return result;
  }

  static List<String> _splitLongSentenceByClauses(String sentence, int maxLen) {
    final clauses = sentence.split(RegExp(r'(?<=[,;])\s+'));
    final List<String> chunks = [];
    String current = '';

    for (final clause in clauses) {
      if (clause.length > maxLen) {
        if (current.trim().isNotEmpty) {
          chunks.add(current.trim());
          current = '';
        }
        chunks.addAll(_splitByWords(clause, maxLen));
      } else if (current.isEmpty) {
        current = clause;
      } else if (current.length + 1 + clause.length <= maxLen) {
        current = '$current $clause';
      } else {
        chunks.add(current.trim());
        current = clause;
      }
    }
    if (current.trim().isNotEmpty) {
      chunks.add(current.trim());
    }
    return chunks;
  }

  static List<String> _splitByWords(String text, int maxLen) {
    final words = text.split(RegExp(r'\s+'));
    final List<String> out = [];
    String cur = '';
    for (final w in words) {
      if (w.isEmpty) continue;
      if (cur.isEmpty) {
        cur = w;
      } else if (cur.length + 1 + w.length <= maxLen) {
        cur = '$cur $w';
      } else {
        out.add(cur);
        cur = w;
      }
    }
    if (cur.isNotEmpty) out.add(cur);
    return out;
  }

  /// Converts numbers 1..10 to Indonesian spoken words.
  static String _numberToWord(int n) {
    switch (n) {
      case 1:
        return 'satu';
      case 2:
        return 'dua';
      case 3:
        return 'tiga';
      case 4:
        return 'empat';
      case 5:
        return 'lima';
      case 6:
        return 'enam';
      case 7:
        return 'tujuh';
      case 8:
        return 'delapan';
      case 9:
        return 'sembilan';
      case 10:
        return 'sepuluh';
      default:
        return n.toString();
    }
  }

  /// Spoken countdown words (5, 4, 3, 2, 1).
  static String countdownWord(int sec) {
    switch (sec) {
      case 5:
        return 'Lima';
      case 4:
        return 'Empat';
      case 3:
        return 'Tiga';
      case 2:
        return 'Dua';
      case 1:
        return 'Satu';
      default:
        return sec.toString();
    }
  }

  /// Estimates duration in seconds for articulate Indonesian speech (~12 chars/sec).
  static int estimateSpeechSeconds(String text) {
    if (text.isEmpty) return 0;
    final seconds = (text.length / 12.0).ceil();
    return seconds.clamp(1, 14);
  }
}
