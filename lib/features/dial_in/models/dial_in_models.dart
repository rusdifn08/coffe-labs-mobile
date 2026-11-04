import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DiagnosisResult {
  final String title;
  final String rootCause;
  final Color bannerColor;
  final IconData bannerIcon;
  final List<String> actions;

  DiagnosisResult({
    required this.title,
    required this.rootCause,
    required this.bannerColor,
    required this.bannerIcon,
    required this.actions,
  });
}

class DialInDiagnosticsEngine {
  static DiagnosisResult getEspressoDiagnosis({
    required String taste,
    required int timeSeconds,
    required bool isEn,
  }) {
    if (taste == 'balanced' && timeSeconds >= 24 && timeSeconds <= 32) {
      return DiagnosisResult(
        title: isEn ? 'God Shot / Dialed-In!' : 'God Shot! Ekstraksi Sempurna',
        rootCause: isEn
            ? 'Extraction is in harmony. Sweetness, crema viscosity, and acidity balance perfectly.'
            : 'Ekstraksi telah mencapai titik manis optimal. Crema tebal, rasa manis membulat, dan minim kepahitan kasar.',
        bannerColor: Colors.green.shade700,
        bannerIcon: CupertinoIcons.checkmark_seal_fill,
        actions: isEn
            ? [
                'Lock in your current grinder setting and dose.',
                'Record this recipe in your Brew Journal.',
                'Keep boiler temperature stable at 92-94°C.',
              ]
            : [
                'Kunci settingan grinder dan dosis kopi ini saat ini.',
                'Simpan log ini ke dalam Jurnal Brew Anda.',
                'Jaga kestabilan suhu mesin espresso di 92-94°C.',
              ],
      );
    }

    if (taste == 'sour' || timeSeconds < 24) {
      return DiagnosisResult(
        title: isEn ? 'Under-Extracted (Sour & Fast Flow)' : 'Under-Extracted (Asam & Terlalu Cepat)',
        rootCause: isEn
            ? 'Water bypassed through the coffee bed too quickly without dissolving sweet sugars.'
            : 'Air mengalir terlalu kencang melintasi bubuk kopi sehingga senyawa gula manis belum sempat larut, menyisakan asam organik tajam.',
        bannerColor: Colors.amber.shade900,
        bannerIcon: CupertinoIcons.exclamationmark_triangle_fill,
        actions: isEn
            ? [
                'Grind 1-2 steps FINER on your grinder to increase resistance.',
                'Check dose: increase dose by +0.5g if the basket has headspace.',
                'Increase water temperature by +1°C (target 93-94°C).',
                'Extend yield ratio from 1:2 to 1:2.2 (e.g. 18g in -> 40g out).',
              ]
            : [
                'Putar settingan grinder LEBIH HALUS (Grind Finer) sebanyak 1-2 klik.',
                'Tambahkan dosis bubuk +0.5g jika portafilter masih menyisakan ruang longgar.',
                'Naikkan suhu mesin espresso +1°C (target 93-94°C).',
                'Perpanjang rasio yield dari 1:2 ke 1:2.2 (contoh: 18g kopi -> 40g hasil cangkir).',
              ],
      );
    }

    if (taste == 'bitter' || timeSeconds > 32) {
      return DiagnosisResult(
        title: isEn ? 'Over-Extracted (Bitter & Choking)' : 'Over-Extracted (Pahit & Tersumbat)',
        rootCause: isEn
            ? 'Water was in contact too long or ground too fine, extracting bitter tannins and ash.'
            : 'Bubuk kopi terlalu halus atau air tertahan terlalu lama sehingga mengekstrak senyawa pahit kasar (tannin) dan rasa abu.',
        bannerColor: Colors.deepOrange.shade800,
        bannerIcon: CupertinoIcons.xmark_circle_fill,
        actions: isEn
            ? [
                'Grind 1-2 steps COARSER on your grinder.',
                'Reduce dose by -0.5g if puck is touching the shower screen.',
                'Shorten yield ratio to 1:1.75 or 1:1.8 (Ristretto style).',
                'Lower brew temperature to 91-92°C.',
              ]
            : [
                'Putar settingan grinder LEBIH KASAR (Grind Coarser) sebanyak 1-2 klik.',
                'Kurangi dosis bubuk -0.5g jika ampas kopi menempel ke shower screen.',
                'Persingkat rasio yield menjadi 1:1.8 (gaya Ristretto) untuk memotong rasa pahit akhir.',
                'Turunkan suhu mesin menjadi 91-92°C.',
              ],
      );
    }

    if (taste == 'channeling') {
      return DiagnosisResult(
        title: isEn ? 'Channeling / Uneven Puck Prep' : 'Channeling (Jalur Air Rusak / Tak Merata)',
        rootCause: isEn
            ? 'Water formed cracks and fissures in the puck, resulting in both sour and bitter flavors simultaneously.'
            : 'Air bertekanan 9 bar menembus celah retak bubuk kopi. Sebagian bubuk kurang terekstrak (asam) dan sebagian gosong terbakar (pahit).',
        bannerColor: Colors.purple.shade700,
        bannerIcon: CupertinoIcons.waveform_path,
        actions: isEn
            ? [
                'Use a WDT needle distribution tool to declump grounds thoroughly.',
                'Ensure tamping is strictly level and perpendicular.',
                'Avoid knocking the portafilter side after tamping.',
                'Consider using a bottom paper filter or puck screen mesh.',
              ]
            : [
                'Gunakan jarum WDT (Weiss Distribution Technique) untuk mengurai gumpalan bubuk.',
                'Pastikan tamping benar-benar rata dan tegak lurus (Level Tamp).',
                'Jangan pernah mengetuk dinding portafilter setelah bubuk di-tamp.',
                'Gunakan puck screen atau filter kertas dasar portafilter.',
              ],
      );
    }

    return DiagnosisResult(
      title: isEn ? 'Low TDS / Watery' : 'Ekstraksi Encer / Low TDS',
      rootCause: isEn ? 'Not enough coffee grounds dissolved into the liquid.' : 'Konsentrasi zat padat kopi terlarut terlalu rendah.',
      bannerColor: Colors.blueGrey,
      bannerIcon: CupertinoIcons.drop,
      actions: isEn
          ? ['Increase coffee dose by +1.0g.', 'Grind slightly finer.', 'Ensure 9 bar extraction pressure.']
          : ['Tingkatkan dosis kopi bubuk +1.0g.', 'Giling sedikit lebih halus.', 'Pastikan tekanan pompa stabil di 9 bar.'],
    );
  }

  static DiagnosisResult getFilterDiagnosis({
    required String taste,
    required bool isEn,
  }) {
    if (taste == 'sweet') {
      return DiagnosisResult(
        title: isEn ? 'Golden Cup Achieved!' : 'Golden Cup Tercapai!',
        rootCause: isEn
            ? 'Ideal extraction balance between fruit acids, sweetness, and transparent clarity.'
            : 'Keseimbangan rasa asam buah segar, manis gula alami, dan kejernihan body tercapai sempurna.',
        bannerColor: Colors.green.shade700,
        bannerIcon: CupertinoIcons.checkmark_seal_fill,
        actions: isEn
            ? ['Maintain pouring agitation and temperature.', 'Save recipe to Favorites.']
            : ['Pertahankan ritme tuangan dan suhu air saat ini.', 'Simpan resep ini ke koleksi favorit.'],
      );
    }

    if (taste == 'sour') {
      return DiagnosisResult(
        title: isEn ? 'Under-Extracted Filter Coffee' : 'Under-Extracted (Asam Mentah / Kurang Matang)',
        rootCause: isEn
            ? 'The water flowed through too fast or water temperature was too cold to extract sweetness.'
            : 'Air mengalir terlalu cepat atau suhu air terlalu dingin sehingga rasa manis buah kopi belum terekstrak sempurna.',
        bannerColor: Colors.amber.shade900,
        bannerIcon: CupertinoIcons.exclamationmark_triangle_fill,
        actions: isEn
            ? [
                'Grind 1-2 clicks finer on your hand grinder.',
                'Increase water temperature (e.g. from 90°C to 93-94°C).',
                'Extend bloom duration from 30s to 45s.',
                'Increase pouring agitation with a higher, spiral pour.',
              ]
            : [
                'Giling 1-2 klik LEBIH HALUS pada grinder Anda.',
                'Naikkan suhu air seduh (misal dari 90°C ke 93-94°C).',
                'Perpanjang waktu blooming dari 30 detik menjadi 45 detik.',
                'Tingkatkan agitasi tuangan dengan spiral teratur dari tengah ke tepi.',
              ],
      );
    }

    return DiagnosisResult(
      title: isEn ? 'Over-Extracted Filter Coffee' : 'Over-Extracted (Pahit & Sepet Astringent)',
      rootCause: isEn
          ? 'Fines clogged the filter or brew temperature was too hot, creating harsh dry finish.'
          : 'Debu halus (fines) menyumbat kertas filter atau suhu air terlalu tinggi, menimbulkan rasa pahit sepat di langit-langit mulut.',
      bannerColor: Colors.deepOrange.shade800,
      bannerIcon: CupertinoIcons.xmark_circle_fill,
      actions: isEn
          ? [
              'Grind 2-3 clicks coarser on your grinder.',
              'Lower water temperature to 89-91°C.',
              'Reduce pour agitation: pour closer to the bed in center circles.',
              'Use fewer pouring stages (e.g. 2-pour instead of 5-pour).',
            ]
          : [
              'Giling 2-3 klik LEBIH KASAR pada grinder Anda.',
              'Turunkan suhu air ke 89-91°C.',
              'Kurangi agitasi: tuang corong teko lebih rendah dan lembut di area tengah.',
              'Gunakan metode tuangan lebih ringkas (misal 2x pour alih-alih 5x pour).',
            ],
    );
  }
}
