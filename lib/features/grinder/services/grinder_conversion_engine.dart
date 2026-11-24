import '../data/grinder_database_electric.dart';
import '../data/grinder_database_manual_a.dart';
import '../data/grinder_database_manual_b.dart';
import '../models/grinder_spec.dart';

/// Mesin Konversi Grinder Presisi (102 Grinder: 70 Manual + 32 Elektrik).
///
/// Menggunakan metode **Interpolasi Multi-Jangkar Non-Linear** (BrewMark + Honest Coffee Guide +
/// Manual Resmi Pabrikan) dan menerjemahkan jumlah klik secara eksak ke posisi angka dial fisik
/// (`Putaran.Angka.Klik`) sesuai arsitektur mekanis tiap grinder.
class GrinderConversionEngine {
  GrinderConversionEngine._();

  static final List<GrinderSpec> allGrinders = List.unmodifiable([
    ...manualGrindersPartA,
    ...manualGrindersPartB,
    ...electricGrinders,
  ]);

  static final Map<String, GrinderSpec> _byId = {
    for (final g in allGrinders) g.id: g,
  };

  /// Urutan prioritas merek populer di Indonesia agar user cepat menemukannya.
  static const List<String> _featuredBrandOrder = [
    '1Zpresso',
    'Timemore',
    'KINGrinder',
    'Comandante',
    'MHW-3BOMBER',
    'Latina',
    'Baratza',
    'DF / Turin',
    'Fellow',
    'Kinu',
    'Eureka',
    'Mahlkönig',
    'Niche',
    'Fiorenzato',
    'Normcore',
    'Mavo',
    'Wacaco',
    'Flair',
    'Hario',
    'Porlex',
    'Otten',
    'N500 / LD-021',
    'Femobook',
    'Breville / Sage',
    'Varia',
    'Option-O',
    "De'Longhi",
    'ROK',
    'Helor',
    'Knock',
    'Mazzer',
    'Rhinowares',
    'HeyCafe',
    'Fuji Royal',
  ];

  static GrinderSpec? findById(String id) => _byId[id];

  static List<GrinderSpec> grindersByCategory(GrinderCategory? category) {
    if (category == null) return allGrinders;
    return allGrinders.where((g) => g.category == category).toList(growable: false);
  }

  /// Daftar merek unik (terurut berdasarkan popularitas pasar Indonesia lalu alfabetis).
  static List<String> getBrands({GrinderCategory? category}) {
    final source = grindersByCategory(category);
    final brandSet = source.map((g) => g.brand).toSet();
    final ordered = <String>[];
    for (final b in _featuredBrandOrder) {
      if (brandSet.remove(b)) ordered.add(b);
    }
    final remaining = brandSet.toList()..sort();
    ordered.addAll(remaining);
    return ordered;
  }

  /// Daftar model grinder milik merek tertentu (opsional filter manual/elektrik).
  static List<GrinderSpec> getModelsForBrand(
    String brand, {
    GrinderCategory? category,
  }) {
    return grindersByCategory(category)
        .where((g) => g.brand == brand)
        .toList(growable: false);
  }

  /// Jumlah model per merek.
  static int modelCountForBrand(String brand, {GrinderCategory? category}) {
    return getModelsForBrand(brand, category: category).length;
  }

  /// Pencarian cepat berdasarkan merek, model, atau tipe burr.
  static List<GrinderSpec> searchGrinders(
    String query, {
    GrinderCategory? category,
    String? brand,
  }) {
    final q = query.trim().toLowerCase();
    return grindersByCategory(category).where((g) {
      if (brand != null && brand.isNotEmpty && g.brand != brand) return false;
      if (q.isEmpty) return true;
      return g.fullName.toLowerCase().contains(q) ||
          g.brand.toLowerCase().contains(q) ||
          g.model.toLowerCase().contains(q) ||
          g.burrSpec.toLowerCase().contains(q);
    }).toList(growable: false);
  }

  /// Klasifikasi zona seduh standar Honest Coffee Guide berdasarkan mikron (µm).
  static String brewZoneForMicrons(double microns) {
    if (microns < 220) return 'Turkish / Ibrik';
    if (microns < 380) return 'Espresso (9 Bar)';
    if (microns < 515) return 'Moka Pot';
    if (microns < 605) return 'AeroPress';
    if (microns < 700) return 'V60 / Cone Pour Over';
    if (microns < 850) return 'Pour Over (Kalita / Chemex / Cupping)';
    if (microns < 1090) return 'French Press';
    return 'Cold Brew / Cold Drip';
  }

  /// Deskripsi tekstur visual bubuk kopi untuk validasi manual/independen.
  static String textureForMicrons(double microns) {
    if (microns < 220) return 'Selembut Tepung Bedak';
    if (microns < 380) return 'Garam Meja Sangat Halus';
    if (microns < 520) return 'Pasir Halus / Gula Kastor';
    if (microns < 700) return 'Gula Pasir Halus–Sedang';
    if (microns < 900) return 'Gula Pasir Kristal (Medium)';
    if (microns < 1100) return 'Garam Kosher Kasar';
    return 'Garam Laut Sangat Kasar (Sea Salt)';
  }

  /// Mengonversi setelan dial grinder asal menjadi estimasi ukuran partikel (µm)
  /// menggunakan Interpolasi Multi-Jangkar Non-Linear.
  static double settingToMicrons(GrinderSpec grinder, double rawSetting) {
    if (!grinder.isCalibrated) return BrewMicronAnchors.v60;

    final clamped = rawSetting.clamp(grinder.minSetting, grinder.maxSetting).toDouble();
    final anchors = _deduplicatedBySetting(grinder.anchors);
    if (anchors.length < 2) return BrewMicronAnchors.v60;

    // Ekstrapolasi halus di bawah jangkar pertama
    if (clamped <= anchors.first.setting) {
      final a0 = anchors[0];
      final a1 = anchors[1];
      final ds = a1.setting - a0.setting;
      if (ds <= 0) return a0.microns;
      final slope = (a1.microns - a0.microns) / ds;
      return (a0.microns + (clamped - a0.setting) * slope).clamp(100.0, 1450.0);
    }

    // Ekstrapolasi kasar di atas jangkar terakhir
    if (clamped >= anchors.last.setting) {
      final a0 = anchors[anchors.length - 2];
      final a1 = anchors[anchors.length - 1];
      final ds = a1.setting - a0.setting;
      if (ds <= 0) return a1.microns;
      final slope = (a1.microns - a0.microns) / ds;
      return (a1.microns + (clamped - a1.setting) * slope).clamp(100.0, 1450.0);
    }

    // Interpolasi segmen tepat di antara 2 jangkar terdekat
    for (int i = 0; i < anchors.length - 1; i++) {
      final low = anchors[i];
      final high = anchors[i + 1];
      if (clamped >= low.setting && clamped <= high.setting) {
        final span = high.setting - low.setting;
        if (span <= 0) return low.microns;
        final t = (clamped - low.setting) / span;
        return (low.microns + t * (high.microns - low.microns)).clamp(100.0, 1450.0);
      }
    }

    return BrewMicronAnchors.v60;
  }

  /// Mengonversi ukuran partikel target (µm) menjadi setelan dial grinder tujuan
  /// menggunakan Interpolasi Multi-Jangkar Non-Linear.
  static double? micronsToSetting(GrinderSpec grinder, double targetMicrons) {
    if (!grinder.isCalibrated) return null;

    final m = targetMicrons.clamp(100.0, 1450.0).toDouble();
    final anchors = grinder.anchors;

    double computed;
    if (m <= anchors.first.microns) {
      final a0 = anchors[0];
      final a1 = anchors[1];
      final dm = a1.microns - a0.microns;
      if (dm <= 0) {
        computed = a0.setting;
      } else {
        final slope = (a1.setting - a0.setting) / dm;
        computed = a0.setting + (m - a0.microns) * slope;
      }
    } else if (m >= anchors.last.microns) {
      final a0 = anchors[anchors.length - 2];
      final a1 = anchors[anchors.length - 1];
      final dm = a1.microns - a0.microns;
      if (dm <= 0) {
        computed = a1.setting;
      } else {
        final slope = (a1.setting - a0.setting) / dm;
        computed = a1.setting + (m - a1.microns) * slope;
      }
    } else {
      computed = anchors.first.setting;
      for (int i = 0; i < anchors.length - 1; i++) {
        final low = anchors[i];
        final high = anchors[i + 1];
        if (m >= low.microns && m <= high.microns) {
          final span = high.microns - low.microns;
          final t = span <= 0 ? 0.0 : (m - low.microns) / span;
          computed = low.setting + t * (high.setting - low.setting);
          break;
        }
      }
    }

    final clamped = computed.clamp(grinder.minSetting, grinder.maxSetting).toDouble();
    return snapSetting(grinder, clamped);
  }

  /// Membulatkan nilai sesuai resolusi fisik dial (klik bulat, 0.1 stepless, atau sub-klik Fellow).
  static double snapSetting(GrinderSpec grinder, double rawValue) {
    final clamped = rawValue.clamp(grinder.minSetting, grinder.maxSetting).toDouble();
    if (grinder.dialType == DialSystemType.fellowSubStep && grinder.clicksPerNumber > 0) {
      final steps = (clamped * grinder.clicksPerNumber).round();
      return (steps / grinder.clicksPerNumber)
          .clamp(grinder.minSetting, grinder.maxSetting)
          .toDouble();
    }
    if (grinder.valueDecimals == 0) {
      return clamped.roundToDouble();
    }
    if (grinder.valueDecimals == 1) {
      return (clamped * 10).round() / 10.0;
    }
    return (clamped * 100).round() / 100.0;
  }

  /// Menerjemahkan nilai numerik grinder ke pembacaan dial fisik eksak (`Putaran.Angka.Klik`)
  /// beserta instruksi praktis bahasa Indonesia.
  static DialReading formatDialReading(
    GrinderSpec grinder,
    double rawValue, {
    double? targetMicrons,
  }) {
    if (!grinder.isCalibrated || grinder.dialType == DialSystemType.uncalibrated) {
      return DialReading(
        rawValue: 0,
        primaryDisplay: 'Kalibrasi Visual',
        physicalNotation: 'Data Mikron N/A',
        humanInstruction: grinder.calibrationNote,
        warning: 'Belum tersedia tabel granulometri independen untuk model ini — ikuti acuan tekstur bubuk & rasa.',
      );
    }

    final val = snapSetting(grinder, rawValue);
    final intVal = val.round();
    String? warning;

    if (grinder.filterOnly &&
        targetMicrons != null &&
        grinder.minRecommendedMicrons != null &&
        targetMicrons < grinder.minRecommendedMicrons!) {
      warning = 'Grinder ini dirancang khusus Filter / Pour Over (tidak ideal untuk Espresso di bawah ${grinder.minRecommendedMicrons!.round()} µm).';
    } else if (grinder.id == '1zpresso_zp6_special' && intVal <= 20) {
      warning = 'Batas bawah ZP6 Special: klik 0–20 (0.0–2.0) adalah zona gesekan burr (burr rub).';
    } else if ((grinder.id.startsWith('timemore_c2') || grinder.id.startsWith('timemore_c3')) &&
        !grinder.id.contains('esp') &&
        intVal <= 6) {
      warning = 'Peringatan Timemore: hindari menggiling di bawah 6 klik agar gigi burr tidak tumpul.';
    } else if (targetMicrons != null && targetMicrons <= 380 && grinder.id == 'baratza_encore') {
      warning = 'Baratza Encore standar memiliki langkah besar untuk espresso; gunakan Encore ESP untuk dial-in espresso presisi.';
    }

    switch (grinder.dialType) {
      case DialSystemType.rotNumSubClick:
        final rot = grinder.clicksPerRotation > 0 ? intVal ~/ grinder.clicksPerRotation : 0;
        final rem = grinder.clicksPerRotation > 0 ? intVal % grinder.clicksPerRotation : intVal;
        final numPos = grinder.clicksPerNumber > 0 ? rem ~/ grinder.clicksPerNumber : rem;
        final sub = grinder.clicksPerNumber > 0 ? rem % grinder.clicksPerNumber : 0;
        final notation = '$rot.$numPos.$sub';
        final rotText = rot == 0 ? '0 putaran (putaran pertama)' : '$rot putaran penuh';
        final subText = sub == 0 ? 'tepat menghadap Angka $numPos' : 'Angka $numPos + $sub klik';
        return DialReading(
          rawValue: intVal.toDouble(),
          primaryDisplay: '$intVal klik',
          physicalNotation: notation,
          humanInstruction: 'Dari titik nol, putar $rotText lalu hentikan jarum $subText.',
          warning: warning,
        );

      case DialSystemType.singleRotNumSubClick:
        final numPos = grinder.clicksPerNumber > 0 ? intVal ~/ grinder.clicksPerNumber : intVal;
        final sub = grinder.clicksPerNumber > 0 ? intVal % grinder.clicksPerNumber : 0;
        final notation = '$numPos.$sub';
        final subText = sub == 0 ? 'tepat di Angka $numPos' : 'Angka $numPos + $sub klik';
        return DialReading(
          rawValue: intVal.toDouble(),
          primaryDisplay: '$intVal klik',
          physicalNotation: notation,
          humanInstruction: 'Dial 1 putaran: putar dari nol hingga jarum $subText.',
          warning: warning,
        );

      case DialSystemType.rotDirectNumber:
        final rot = grinder.clicksPerRotation > 0 ? intVal ~/ grinder.clicksPerRotation : 0;
        final rem = grinder.clicksPerRotation > 0 ? intVal % grinder.clicksPerRotation : intVal;
        final remStr = rem.toString().padLeft(2, '0');
        final notation = '$rot.$remStr';
        final unitLabel = grinder.id == 'mhw3bomber_race_m1' ? 'Grid $rem' : 'Angka $rem';
        final rotText = rot == 0 ? 'putaran pertama' : '$rot putaran penuh';
        return DialReading(
          rawValue: intVal.toDouble(),
          primaryDisplay: '$intVal klik',
          physicalNotation: notation,
          humanInstruction: 'Dari nol, putar $rotText lalu hentikan jarum tepat di $unitLabel.',
          warning: warning,
        );

      case DialSystemType.kinuRotNum:
        final rot = intVal ~/ 50;
        final rem = intVal % 50;
        final numPos = rem ~/ 5;
        final sub = rem % 5;
        final notation = '$rot.$numPos.$sub';
        final putaranDesimal = (intVal / 50.0).toStringAsFixed(1);
        final subText = sub == 0 ? 'tepat di Angka $numPos' : 'Angka $numPos + $sub divisi';
        return DialReading(
          rawValue: intVal.toDouble(),
          primaryDisplay: '$intVal div',
          physicalNotation: '$notation ($putaranDesimal put)',
          humanInstruction: 'Putar $rot putaran penuh dari nol, lalu hentikan di $subText (1 put = 50 div).',
          warning: warning,
        );

      case DialSystemType.flairCrown:
        final rot = intVal ~/ 24;
        final rem = intVal % 24;
        final numPos = rem ~/ 2;
        final sub = rem % 2;
        final crownNo = intVal / 2.0;
        final crownStr = crownNo == crownNo.roundToDouble()
            ? 'No. ${crownNo.round()}'
            : 'No. ${crownNo.toStringAsFixed(1)}';
        return DialReading(
          rawValue: intVal.toDouble(),
          primaryDisplay: '$intVal klik',
          physicalNotation: '$crownStr ($rot.$numPos.$sub)',
          humanInstruction: 'Setel top crown ke $crownStr ($rot putaran, Angka $numPos${sub > 0 ? ' + 1 klik' : ' tepat'}).',
          warning: warning,
        );

      case DialSystemType.dualMajorMinor:
        final major = intVal ~/ 5;
        final minor = intVal % 5;
        return DialReading(
          rawValue: intVal.toDouble(),
          primaryDisplay: 'Major $major · Minor $minor',
          physicalNotation: 'M$major.$minor',
          humanInstruction: 'Putar dial Major ke klik $major (80 µm/klik), lalu fine-tune dial Minor ke posisi $minor (15 µm/klik).',
          warning: warning,
        );

      case DialSystemType.countFromZero:
        String notation;
        String instruction;
        if (grinder.clicksPerRotation > 0) {
          final rot = intVal ~/ grinder.clicksPerRotation;
          final rem = intVal % grinder.clicksPerRotation;
          notation = rot > 0 ? '$rot put + $rem klik' : '$intVal klik dari nol';
          instruction = rot > 0
              ? 'Tutup burr ke titik nol, lalu buka $intVal klik ($rot putaran penuh + $rem klik).'
              : 'Tutup burr ke titik nol, lalu buka $intVal klik.';
        } else {
          notation = '$intVal klik dari nol';
          instruction = 'Tutup burr ke titik nol, lalu hitung tepat $intVal klik ke arah kasar.';
        }
        return DialReading(
          rawValue: intVal.toDouble(),
          primaryDisplay: '$intVal klik',
          physicalNotation: notation,
          humanInstruction: instruction,
          warning: warning,
        );

      case DialSystemType.fellowSubStep:
        if (grinder.clicksPerNumber == 3) {
          // Fellow Ode Gen 2: 1..11 dengan .0, .1, .2
          final totalSteps = ((val - 1.0) * 3).round().clamp(0, 30);
          final whole = 1 + (totalSteps ~/ 3);
          final sub = totalSteps % 3;
          final label = sub == 0 ? '$whole' : '$whole.$sub';
          final desc = sub == 0
              ? 'Putar dial tepat di Angka $whole.'
              : 'Putar dial ke Angka $whole lewat $sub titik ($label).';
          return DialReading(
            rawValue: val,
            primaryDisplay: 'Dial $label',
            physicalNotation: 'Angka $label',
            humanInstruction: desc,
            warning: warning,
          );
        } else {
          // Fellow Opus: 4 sub-klik (.0, .25, .5, .75)
          final formatted = val == val.roundToDouble()
              ? val.round().toString()
              : val.toStringAsFixed(2).replaceAll(RegExp(r'0$'), '');
          return DialReading(
            rawValue: val,
            primaryDisplay: 'Setting $formatted',
            physicalNotation: 'Angka $formatted',
            humanInstruction: 'Putar cincin luar Fellow Opus ke posisi $formatted (4 sub-klik per angka).',
            warning: warning,
          );
        }

      case DialSystemType.eurekaMultiTurn:
        final turns = (val / 6.0).floor().clamp(0, 24);
        final dialNum = (val - turns * 6.0).clamp(0.0, 5.9);
        final dialStr = dialNum.toStringAsFixed(1);
        final notation = '$turns+$dialStr';
        final turnText = turns == 0 ? '0 putaran penuh' : '$turns putaran penuh';
        return DialReading(
          rawValue: val,
          primaryDisplay: notation,
          physicalNotation: '$turns put + $dialStr',
          humanInstruction: 'Dari chirp/zero point, putar $turnText lalu hentikan kenop mikrometrik di Angka $dialStr.',
          warning: warning,
        );

      case DialSystemType.electricStepped:
        final displayNum = grinder.valueDecimals == 0
            ? intVal.toString()
            : (val == val.roundToDouble() ? val.round().toString() : val.toStringAsFixed(1));
        String extraZone = '';
        if (grinder.id == 'baratza_encore_esp') {
          extraZone = val <= 20
              ? ' · Zona Mikro Espresso (20 µm/klik)'
              : ' · Zona Filter (90 µm/klik)';
        } else if (grinder.id == 'latina_feima_600n' && val <= 0.75) {
          return DialReading(
            rawValue: val,
            primaryDisplay: 'Fine – 1',
            physicalNotation: 'Posisi Fine',
            humanInstruction: 'Putar dial Feima 600N ke posisi Fine di sebelah angka 1 (sesuaikan zero point unit).',
            warning: warning,
          );
        }
        final unit = grinder.id == 'fiorenzato_allground' ? 'titik' : 'Setting';
        return DialReading(
          rawValue: val,
          primaryDisplay: grinder.id == 'fiorenzato_allground' ? '$displayNum titik' : '$unit $displayNum',
          physicalNotation: 'Skala $displayNum$extraZone',
          humanInstruction: 'Putar pengatur bertahap ke posisi $displayNum$extraZone.',
          warning: warning,
        );

      case DialSystemType.electricStepless:
        final formatted = val.toStringAsFixed(grinder.valueDecimals);
        return DialReading(
          rawValue: val,
          primaryDisplay: 'Dial $formatted',
          physicalNotation: 'Skala $formatted',
          humanInstruction: 'Putar dial stepless ke angka $formatted dari titik nol (burr chirp).',
          warning: warning,
        );

      case DialSystemType.uncalibrated:
        return DialReading(
          rawValue: 0,
          primaryDisplay: 'Kalibrasi Visual',
          physicalNotation: 'Data Mikron N/A',
          humanInstruction: grinder.calibrationNote,
          warning: 'Belum ada tabel granulometri independen untuk model ini.',
        );
    }
  }

  /// Konversi penuh Grinder Asal -> Grinder Tujuan lewat bahasa tengah mikron (µm).
  static GrinderConversionResult convert({
    required GrinderSpec source,
    required double sourceSetting,
    required GrinderSpec target,
  }) {
    final snappedSource = source.isCalibrated ? snapSetting(source, sourceSetting) : 0.0;
    final microns = settingToMicrons(source, snappedSource);
    final zone = brewZoneForMicrons(microns);
    final sourceReading = formatDialReading(source, snappedSource, targetMicrons: microns);

    if (!source.isCalibrated) {
      return GrinderConversionResult(
        source: source,
        sourceSetting: 0,
        sourceReading: sourceReading,
        estimatedMicrons: microns,
        brewZoneLabel: zone,
        target: target,
        targetReading: null,
        notice:
            '${source.fullName} belum memiliki tabel kalibrasi mikron independen. Pilih grinder asal yang terkalibrasi atau gunakan mode Jelajah Mikron.',
      );
    }

    if (!target.isCalibrated) {
      return GrinderConversionResult(
        source: source,
        sourceSetting: snappedSource,
        sourceReading: sourceReading,
        estimatedMicrons: microns,
        brewZoneLabel: zone,
        target: target,
        targetReading: formatDialReading(target, 0, targetMicrons: microns),
        notice:
            '${target.fullName} belum memiliki tabel granulometri independen — targetkan tekstur "${textureForMicrons(microns)}" (~${microns.round()} µm).',
      );
    }

    final targetVal = micronsToSetting(target, microns)!;
    final targetReading = formatDialReading(target, targetVal, targetMicrons: microns);

    String? notice;
    if (source.calibrationTier == CalibrationTier.partialAnchor ||
        target.calibrationTier == CalibrationTier.partialAnchor) {
      notice =
          'Salah satu model memakai Kalibrasi Parsial (jangkar V60 terverifikasi + langkah mekanis pabrikan). Lakukan dial-in ±2 klik berdasarkan rasa di cangkir.';
    }

    return GrinderConversionResult(
      source: source,
      sourceSetting: snappedSource,
      sourceReading: sourceReading,
      estimatedMicrons: microns,
      brewZoneLabel: zone,
      target: target,
      targetReading: targetReading,
      notice: notice,
    );
  }

  static List<BrewAnchor> _deduplicatedBySetting(List<BrewAnchor> anchors) {
    final result = <BrewAnchor>[];
    for (final a in anchors) {
      if (result.isNotEmpty && (result.last.setting - a.setting).abs() < 1e-6) {
        // Gabungkan 2 metode yang berada di titik klik identik memakai rata-rata mikron
        final prev = result.removeLast();
        result.add(BrewAnchor(
          microns: (prev.microns + a.microns) / 2.0,
          setting: a.setting,
          methodLabel: '${prev.methodLabel} / ${a.methodLabel}',
        ));
      } else {
        result.add(a);
      }
    }
    return result;
  }
}
