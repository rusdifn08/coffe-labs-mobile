import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Klasifikasi keluarga alat seduh untuk adaptasi tampilan timer dan instruksi.
enum BrewMethodFamily {
  pourOver('Manual Pour Over', CupertinoIcons.drop_fill, Colors.blueAccent),
  mokaPot('Stovetop Moka Pot', CupertinoIcons.flame_fill, Colors.deepOrange),
  espresso('Espresso Machine', CupertinoIcons.bolt_fill, Colors.amber),
  syphon('Syphon / Vacuum Pot', CupertinoIcons.tornado, Colors.purple),
  coldBrew('Cold Brew & Cold Drip', CupertinoIcons.snow, Colors.cyan),
  turkish('Turkish / Cezve Ibrik', CupertinoIcons.flame, Colors.brown),
  vietnamesePhin('Vietnamese Phin', CupertinoIcons.hourglass, Colors.teal),
  immersionPress('French Press / Cupping', CupertinoIcons.layers_alt_fill, Colors.indigo),
  aeropress('AeroPress / Flow Control', CupertinoIcons.circle_grid_hex_fill, Colors.orange),
  hybrid('Clever Dripper / Switch', CupertinoIcons.slider_horizontal_3, Colors.green);

  final String label;
  final IconData icon;
  final Color primaryColor;

  const BrewMethodFamily(this.label, this.icon, this.primaryColor);
}

class BrewMethodHelper {
  /// Mendeteksi keluarga metode seduh dari string metode atau kategori.
  static BrewMethodFamily detectFamily({String? method, String? category}) {
    final m = (method ?? '').toLowerCase();
    final c = (category ?? '').toLowerCase();
    final combined = '$m $c';

    if (combined.contains('moka') || combined.contains('bialetti') || combined.contains('stovetop')) {
      return BrewMethodFamily.mokaPot;
    }
    if (combined.contains('syphon') || combined.contains('siphon') || combined.contains('vacuum')) {
      return BrewMethodFamily.syphon;
    }
    if (combined.contains('cold brew') || combined.contains('cold drip') || combined.contains('kyoto') || combined.contains('dutch')) {
      return BrewMethodFamily.coldBrew;
    }
    if (combined.contains('turkish') || combined.contains('cezve') || combined.contains('ibrik')) {
      return BrewMethodFamily.turkish;
    }
    if (combined.contains('phin') || combined.contains('vietnam') || combined.contains('vietnamese')) {
      return BrewMethodFamily.vietnamesePhin;
    }
    if (combined.contains('aeropress')) {
      return BrewMethodFamily.aeropress;
    }
    if (combined.contains('espresso') || combined.contains('flair') || combined.contains('picopresso') || combined.contains('rok')) {
      return BrewMethodFamily.espresso;
    }
    if (combined.contains('french press') || combined.contains('cupping') || combined.contains('plunger')) {
      return BrewMethodFamily.immersionPress;
    }
    if (combined.contains('clever') || combined.contains('switch') || combined.contains('gina')) {
      return BrewMethodFamily.hybrid;
    }

    return BrewMethodFamily.pourOver;
  }

  /// Menghasilkan label aksi fase yang akurat untuk step tile (bukan sekadar "+Xg Air" atau "Imersi").
  static String getStepActionLabel({
    required BrewMethodFamily family,
    required String stepTitle,
    required int stepWater,
    required int cumulativeTarget,
    required bool isEnglish,
  }) {
    final t = stepTitle.toLowerCase();

    switch (family) {
      case BrewMethodFamily.mokaPot:
        if (t.contains('isi') || t.contains('boiler') || t.contains('air')) {
          return isEnglish ? 'Preheat Boiler: ${stepWater > 0 ? stepWater : cumulativeTarget}g Hot Water' : 'Boiler Bawah: ${stepWater > 0 ? stepWater : cumulativeTarget}g Air Mendidih';
        }
        if (t.contains('panas') || t.contains('kompor') || t.contains('heat') || t.contains('api')) {
          return isEnglish ? 'Stovetop Heating · Low-Med Flame 🔥' : 'Pemanasan Kompor · Api Sedang-Kecil 🔥';
        }
        if (t.contains('alir') || t.contains('ekstraksi') || t.contains('flow') || t.contains('crema')) {
          return isEnglish ? 'Honey Coffee Flow Rising ☕' : 'Aliran Kopi Madu Naik ke Atas ☕';
        }
        if (t.contains('dingin') || t.contains('hentikan') || t.contains('cut') || t.contains('handuk')) {
          return isEnglish ? 'Cold Water Cut-off · Stop Burn ❄️' : 'Pendinginan Boiler · Cut-Off Anti Pahit ❄️';
        }
        return isEnglish ? 'Moka Chamber Preparation' : 'Persiapan Corong & Rapatkan Teko';

      case BrewMethodFamily.espresso:
        if (t.contains('dose') || t.contains('dosing') || t.contains('wdt') || t.contains('distribus')) {
          return isEnglish ? 'Puck Prep: WDT Needle Distribution 🪄' : 'Puck Prep: Distribusi Jarum WDT 🪄';
        }
        if (t.contains('tamp') || t.contains('level')) {
          return isEnglish ? 'Precision Level Tamp (15–20 kg) 🔨' : 'Tamping Rata Presisi (15–20 kg) 🔨';
        }
        if (t.contains('pre-infusion') || t.contains('infusi')) {
          return isEnglish ? 'Low Pressure Pre-Infusion (2–3 Bar) 💧' : 'Pre-Infusion Tekanan Rendah (2–3 Bar) 💧';
        }
        if (t.contains('ekstraksi') || t.contains('tarik') || t.contains('shot') || t.contains('pull') || t.contains('yield')) {
          final yieldG = stepWater > 0 ? stepWater : cumulativeTarget;
          return isEnglish ? 'Full 9-Bar Pump Extraction · Yield: ~${yieldG}g ⚡' : 'Ekstraksi 9-Bar Penuh · Target Yield: ~${yieldG}g ⚡';
        }
        if (t.contains('steam') || t.contains('susu') || t.contains('milk')) {
          return isEnglish ? 'Microfoam Milk Steaming (60–65°C) 🥛' : 'Steaming Susu Microfoam Mengkilap (60–65°C) 🥛';
        }
        if (t.contains('tuang') || t.contains('art') || t.contains('pour') || t.contains('shaker') || t.contains('sirup')) {
          return isEnglish ? 'Latte Art & Final Beverage Presentation 🎨' : 'Pouring Latte Art & Penyajian Menu 🎨';
        }
        return isEnglish ? 'Espresso Step' : 'Tahapan Espresso';

      case BrewMethodFamily.syphon:
        if (t.contains('isi') || t.contains('bawah') || t.contains('boiler')) {
          return isEnglish ? 'Boil Water in Lower Globe: ${stepWater > 0 ? stepWater : cumulativeTarget}g 🌡️' : 'Didihkan Air Bejana Bawah: ${stepWater > 0 ? stepWater : cumulativeTarget}g 🌡️';
        }
        if (t.contains('naik') || t.contains('pasang') || t.contains('atas')) {
          return isEnglish ? 'Vapor Pressure: Water Rising to Upper Bowl 🌪️' : 'Tekanan Uap: Air Naik ke Bejana Atas 🌪️';
        }
        if (t.contains('stir') || t.contains('aduk') || t.contains('masuk')) {
          return isEnglish ? 'Gentle Paddle Cross Stir (10s) 🥄' : 'Aduk Halus Melintang dengan Paddle (10 detik) 🥄';
        }
        if (t.contains('turun') || t.contains('vakum') || t.contains('drawdown') || t.contains('dome')) {
          return isEnglish ? 'Vacuum Drawdown & Golden Coffee Dome 🌪️' : 'Tarikan Vakum Turun & Kubah Kopi Emas 🌪️';
        }
        return isEnglish ? 'Syphon Immersion Steeping ⏳' : 'Kontak Seduh Rendam Syphon ⏳';

      case BrewMethodFamily.coldBrew:
        if (t.contains('timbang') || t.contains('giling') || t.contains('persiapan')) {
          return isEnglish ? 'Coarse Grind Prep & Decanter Setup' : 'Persiapan Biji Kasar & Wadah Bersih';
        }
        if (t.contains('tuang') || t.contains('hidrasi') || t.contains('aduk')) {
          return isEnglish ? 'Cold Water Saturation: +${stepWater > 0 ? stepWater : cumulativeTarget}g 💧' : 'Hidrasi Air Dingin: +${stepWater > 0 ? stepWater : cumulativeTarget}g 💧';
        }
        if (t.contains('saring') || t.contains('filter') || t.contains('decant')) {
          return isEnglish ? 'Dual Micro-Filtration & Bottling 🏷️' : 'Penyaringan Ganda & Pembotolan Kaca 🏷️';
        }
        return isEnglish ? 'Cold Maceration Extraction (4°C Refrigerator) ❄️' : 'Ekstraksi Rendam Dingin Kulkas (4°C) ❄️';

      case BrewMethodFamily.turkish:
        if (t.contains('bubuk') || t.contains('air') || t.contains('campur')) {
          return isEnglish ? 'Super-Fine Powder & Cold Water Mix 💧' : 'Campur Bubuk Ekstra Halus & Air Suhu Ruang 💧';
        }
        if (t.contains('aduk') || t.contains('stir')) {
          return isEnglish ? 'Gentle Paddle Stir (One Time Only) 🥄' : 'Aduk Lembut Satu Kali (Sendok Kayu) 🥄';
        }
        if (t.contains('panas') || t.contains('pasir') || t.contains('kompor') || t.contains('sand')) {
          return isEnglish ? 'Slow Flame / Hot Sand Bed Heating 🔥' : 'Pemanasan Perlahan di Kompor / Pasir Panas 🔥';
        }
        if (t.contains('crema') || t.contains('busa') || t.contains('angkat') || t.contains('naik')) {
          return isEnglish ? 'Golden Crema Rising · Remove Before Boil! ✨' : 'Kenaikan Crema Emas · Angkat Sebelum Mendidih! ✨';
        }
        return isEnglish ? 'Sediment Resting in Finjan Cup ⏳' : 'Pengendapan Ampas di Cangkir Finjan ⏳';

      case BrewMethodFamily.vietnamesePhin:
        if (t.contains('susu') || t.contains('kental') || t.contains('dasar')) {
          return isEnglish ? 'Sweet Condensed Milk Base 🥛' : 'Lapisan Susu Kental Manis di Dasar Gelas 🥛';
        }
        if (t.contains('bloom') || t.contains('mekar')) {
          return isEnglish ? 'Blooming Damper: +${stepWater > 0 ? stepWater : 20}g Hot Water 💧' : 'Blooming Saringan: +${stepWater > 0 ? stepWater : 20}g Air Panas 💧';
        }
        if (t.contains('penuh') || t.contains('tutup') || t.contains('tuang')) {
          return isEnglish ? 'Full Water Fill: +${stepWater > 0 ? stepWater : 70}g 💧' : 'Tuang Penuh Air Panas: +${stepWater > 0 ? stepWater : 70}g 💧';
        }
        if (t.contains('tetes') || t.contains('drip') || t.contains('gravity')) {
          return isEnglish ? 'Slow Gravity Drip (1 drop/sec) ⏳' : 'Tetesan Gravitasi Lambat (1 tetes/detik) ⏳';
        }
        return isEnglish ? 'Stir with Crushed Ice 🧊' : 'Aduk Bersama Es Batu Serut Melimpah 🧊';

      case BrewMethodFamily.immersionPress:
        if (t.contains('pecah') || t.contains('break') || t.contains('kerak') || t.contains('crust')) {
          return isEnglish ? 'Break Crust & Gentle Stir 🥄' : 'Pecahkan Kerak Kopi & Aduk Lembut 🥄';
        }
        if (t.contains('skim') || t.contains('busa') || t.contains('bersih')) {
          return isEnglish ? 'Skim Floating Foam & Fines 🥄' : 'Sendok & Buang Busa Minyak Mengapung 🥄';
        }
        if (t.contains('tekan') || t.contains('plunge') || t.contains('saring')) {
          return isEnglish ? 'Slow Steady Plunge Down ⬇️' : 'Tekan Plunger Perlahan & Stabil ⬇️';
        }
        return stepWater > 0
            ? (isEnglish ? 'Pour Water: +${stepWater}g (Target: ${cumulativeTarget}g)' : 'Tuang Air: +${stepWater}g (Target: ${cumulativeTarget}g)')
            : (isEnglish ? 'Full Immersion Steeping ⏳' : 'Seduh Rendam Penuh (Steeping) ⏳');

      case BrewMethodFamily.aeropress:
        if (t.contains('inverted') || t.contains('terbalik')) {
          return isEnglish ? 'Inverted Setup & Chamber Heat' : 'Posisi Inverted (Tabung Terbalik)';
        }
        if (t.contains('stir') || t.contains('aduk') || t.contains('putar')) {
          return isEnglish ? 'Turbulence Paddle Stir (3–5x) 🥄' : 'Aduk Agitasi Memutar (3–5 kali) 🥄';
        }
        if (t.contains('balik') || t.contains('flip') || t.contains('pasang')) {
          return isEnglish ? 'Flip Onto Server & Seal Cap 🔄' : 'Balikkan Teko ke Atas Server Bersih 🔄';
        }
        if (t.contains('tekan') || t.contains('press') || t.contains('plunge')) {
          return isEnglish ? 'Gentle Steady Plunge (Stop at Hiss!) ⬇️' : 'Tekan Plunger Mantap (Berhenti Saat Berdesis!) ⬇️';
        }
        return stepWater > 0
            ? (isEnglish ? 'Add Water: +${stepWater}g' : 'Tuang Air: +${stepWater}g')
            : (isEnglish ? 'Immersion Contact Time' : 'Waktu Kontak Ekstraksi');

      case BrewMethodFamily.hybrid:
        if (t.contains('tutup') || t.contains('valve') || t.contains('close')) {
          return isEnglish ? 'Valve Closed · Full Immersion Phase 🔒' : 'Katup Tertutup · Fase Rendam Penuh 🔒';
        }
        if (t.contains('buka') || t.contains('open') || t.contains('switch')) {
          return isEnglish ? 'Switch Open · Rapid Drawdown 🔓' : 'Tekan Buka Katup · Aliran Drawdown Cepat 🔓';
        }
        return stepWater > 0
            ? (isEnglish ? '+${stepWater}g Water (Target: ${cumulativeTarget}g)' : '+${stepWater}g Air (Target: ${cumulativeTarget}g)')
            : (isEnglish ? 'Hybrid Immersion Phase' : 'Fase Imersi Campuran');

      case BrewMethodFamily.pourOver:
        return stepWater > 0
            ? (isEnglish ? '+${stepWater}g Water (Target: ${cumulativeTarget}g)' : '+${stepWater}g Air (Target: ${cumulativeTarget}g)')
            : (isEnglish ? 'Drawdown & Drainage (Target: ${cumulativeTarget}g)' : 'Drawdown & Aliran Surut (Target: ${cumulativeTarget}g)');
    }
  }

  /// Menghasilkan instruksi cerdas jika resep lama tidak memiliki teks instruksi.
  static String getFallbackInstruction({
    required BrewMethodFamily family,
    required String stepTitle,
    required bool isEnglish,
  }) {
    final t = stepTitle.toLowerCase();

    switch (family) {
      case BrewMethodFamily.mokaPot:
        if (t.contains('boiler') || t.contains('air')) {
          return isEnglish
              ? 'Fill preheated boiling water into bottom boiler just below the brass safety valve.'
              : 'Tuang air mendidih terpisah ke boiler bawah hingga tepat di bawah katup pengaman kuningan (safety valve).';
        }
        if (t.contains('corong') || t.contains('tamp') || t.contains('filter')) {
          return isEnglish
              ? 'Fill funnel basket with medium-fine coffee level to the rim. DO NOT tamp or press down.'
              : 'Masukkan bubuk kopi medium-fine ke corong hingga rata sejajar bibir corong. JANGAN ditekan atau di-tamp!';
        }
        if (t.contains('panas') || t.contains('kompor') || t.contains('api')) {
          return isEnglish
              ? 'Place moka pot onto stovetop over medium-low heat with the lid open. Wait for vapor pressure to rise.'
              : 'Letakkan teko di atas kompor api sedang-kecil dengan tutup terbuka. Biarkan uap air perlahan naik.';
        }
        if (t.contains('alir') || t.contains('kuning') || t.contains('madu') || t.contains('ekstraksi')) {
          return isEnglish
              ? 'Rich honey-like coffee will slowly emerge from the column. Observe color gradient.'
              : 'Kopi kental berwarna cokelat madu pekat akan mengalir keluar dari cerobong tengah secara perlahan.';
        }
        if (t.contains('dingin') || t.contains('hentikan') || t.contains('handuk')) {
          return isEnglish
              ? 'As stream turns blonde and begins sputtering, immediately remove and wrap/cool base with wet towel.'
              : 'Begitu aliran berubah warna pirang pucat dan mulai berdesis, segera angkat dan dinginkan dasar teko dengan air dingin untuk memotong rasa pahit gosong.';
        }
        return isEnglish
            ? 'Assemble top chamber tightly using a dry cloth (bottom is very hot).'
            : 'Rapatkan chamber atas menggunakan kain lap pelindung karena boiler bawah sangat panas.';

      case BrewMethodFamily.espresso:
        if (t.contains('wdt') || t.contains('dose') || t.contains('distribus')) {
          return isEnglish
              ? 'Dose ground coffee and use WDT needle tool to break clumps for zero channeling.'
              : 'Gunakan jarum WDT untuk memecah gumpalan bubuk halus secara merata agar tidak terjadi channeling.';
        }
        if (t.contains('tamp') || t.contains('level')) {
          return isEnglish
              ? 'Apply firm, level downward pressure (~15-20 kg) until coffee puck is completely flat.'
              : 'Tekan tamper rata horizontal dengan tekanan ~15-20 kg hingga permukaan coffee puck padat merata.';
        }
        if (t.contains('pre-infusion') || t.contains('infusi')) {
          return isEnglish
              ? 'Saturate the puck at gentle 2-3 bar low pressure to prevent cracks.'
              : 'Alirkan air tekanan rendah 2-3 bar untuk membasahi puck secara merata sebelum pompa penuh.';
        }
        if (t.contains('ekstraksi') || t.contains('shot') || t.contains('tarik')) {
          return isEnglish
              ? 'Full 9 bar extraction. Stream should flow like warm honey with thick hazelnut crema.'
              : 'Ekstraksi pompa 9 bar penuh. Cairan mengalir halus seperti ekor tikus dengan crema hazelnut tebal.';
        }
        if (t.contains('steam') || t.contains('susu')) {
          return isEnglish
              ? 'Submerge steam wand tip, stretch milk with gentle hiss to 37°C, then whirlpool to 60-65°C.'
              : 'Masukkan ujung steam wand, buat desisan halus hingga 37°C lalu pusar melingkar hingga 60-65°C glossy.';
        }
        return isEnglish
            ? 'Pour textured microfoam gently into espresso to integrate sweet layers.'
            : 'Tuang susu steamed lembut menembus crema espresso untuk menyatukan lapisan rasa manis.';

      case BrewMethodFamily.syphon:
        return isEnglish
            ? 'Maintain constant burner flame. Gentle paddle stir ensures full dispersion without clogging filter.'
            : 'Pertahankan api burner stabil. Aduk melintang lembut dengan paddle kayu agar ekstraksi rata tanpa menyumbat filter.';

      case BrewMethodFamily.coldBrew:
        return isEnglish
            ? 'Store sealed container in cold refrigerator at 4°C for 12 to 24 hours. Filter twice before serving.'
            : 'Tutup rapat wadah kedap udara di kulkas 4°C selama 12–24 jam. Saring ampas ganda sebelum disajikan.';

      case BrewMethodFamily.turkish:
        return isEnglish
            ? 'Heat very slowly over low flame. When golden foam rises to rim, lift immediately before boiling over.'
            : 'Panaskan sangat perlahan di api kecil. Saat busa crema emas naik mendekati bibir cezve, segera angkat sebelum mendidih!';

      case BrewMethodFamily.vietnamesePhin:
        return isEnglish
            ? 'Allow coffee to drip slowly at ~1 drop per second. Stir thoroughly with condensed milk and ice.'
            : 'Biarkan kopi menetes lambat gravitasi ~1 tetes per detik. Aduk merata bersama susu kental manis dan es.';

      case BrewMethodFamily.immersionPress:
        return isEnglish
            ? 'After steeping, break crust with spoon and skim floating foam for the cleanest French press cup.'
            : 'Setelah masa rendam, pecahkan kerak dengan sendok dan buang busa mengapung untuk cangkir bersih bebas ampas.';

      case BrewMethodFamily.aeropress:
        return isEnglish
            ? 'Plunge with steady forearm weight for 25-30 seconds. Stop immediately when you hear the hiss sound.'
            : 'Tekan plunger dengan berat lengan stabil selama 25-30 detik. Berhenti segera saat terdengar desisan angin.';

      case BrewMethodFamily.hybrid:
        return isEnglish
            ? 'Full immersion extracts dense sweetness, while releasing the valve provides a clean paper filter finish.'
            : 'Perendaman penuh mengunci rasa manis buah, pelepasan katup memberikan kejernihan khas filter kertas.';

      case BrewMethodFamily.pourOver:
        return isEnglish
            ? 'Pour in smooth concentric circles from center outward, maintaining steady water level.'
            : 'Penuangan memutar konsentris teratur dari tengah ke arah luar dengan ketinggian air stabil.';
    }
  }
}
