import '../../../../models/roastery.dart';

class RoasteryBrewRecipeBuilder {
  /// Membangun resep seduh siap-Timer (`BrewTimerScreen`) dari profil kopi Roastery.
  static Map<String, dynamic> buildRecipeForLineup({
    required Roastery roastery,
    required CoffeeLineupItem item,
  }) {
    final methodRaw = (item.recommendedBrewMethod ?? '').trim();
    final isEspresso = methodRaw.toLowerCase().contains('espresso') ||
        (methodRaw.isEmpty && item.roastProfile.toLowerCase().contains('dark'));

    final method = methodRaw.isNotEmpty
        ? methodRaw
        : (isEspresso ? 'Espresso' : 'V60');

    final roastLow = item.roastProfile.toLowerCase();
    final defaultTemp = roastLow.contains('light')
        ? 93
        : (roastLow.contains('dark') ? 88 : 91);
    final tempC = item.recommendedTempC ?? defaultTemp;

    final grind = (item.recommendedGrindSize ?? '').trim().isNotEmpty
        ? item.recommendedGrindSize!.trim()
        : (isEspresso ? 'Fine (Espresso)' : 'Medium-Fine (22-26 Klik)');

    final ratioLabel = (item.recommendedRatio ?? '').trim().isNotEmpty
        ? item.recommendedRatio!.trim()
        : (isEspresso ? '1:2' : '1:15');

    if (isEspresso) {
      return {
        'id': 9000 + item.name.hashCode.abs() % 900,
        'title': '${item.name} — ${roastery.name}',
        'method': method,
        'category': 'Roastery Lineup',
        'author': roastery.name,
        'beanOrigin': item.origin,
        'roastLevel': item.roastProfile,
        'coffeeWeightGrams': 18,
        'totalWaterWeightGrams': 36,
        'waterTempCelsius': tempC,
        'grindSize': grind,
        'ratio': ratioLabel,
        'tastingNotes': item.tastingNotes,
        'totalTimeSeconds': 43,
        'steps': [
          {
            'stepOrder': 1,
            'title': '1. Dosing & Distribusi WDT',
            'durationSeconds': 15,
            'waterAddedGrams': 0,
            'timeSeconds': 15,
            'waterGrams': 0,
            'cumulativeWaterGrams': 0,
            'instruction':
                'Giling 18g ${item.name} (${item.variety}), ratakan puck dengan WDT & tamp stabil sebelum memasang portafilter.',
          },
          {
            'stepOrder': 2,
            'title': '2. Ekstraksi Espresso $ratioLabel',
            'durationSeconds': 28,
            'waterAddedGrams': 36,
            'timeSeconds': 28,
            'waterGrams': 36,
            'cumulativeWaterGrams': 36,
            'instruction':
                'Ekstrak di suhu $tempC°C hingga 36g yield dalam 26–30 detik untuk menonjolkan karakter ${item.tastingNotes}.',
          },
        ],
      };
    }

    const dose = 15;
    const totalWater = 225;
    const bloom = 45;
    const pour2 = 90;
    const pour3 = 90;

    return {
      'id': 9000 + item.name.hashCode.abs() % 900,
      'title': '${item.name} — ${roastery.name}',
      'method': method,
      'category': 'Roastery Lineup',
      'author': roastery.name,
      'beanOrigin': item.origin,
      'roastLevel': item.roastProfile,
      'coffeeWeightGrams': dose,
      'totalWaterWeightGrams': totalWater,
      'waterTempCelsius': tempC,
      'grindSize': grind,
      'ratio': ratioLabel,
      'tastingNotes': item.tastingNotes,
      'totalTimeSeconds': 155,
      'steps': [
        {
          'stepOrder': 1,
          'title': '1. Blooming & Degassing',
          'durationSeconds': 40,
          'waterAddedGrams': bloom,
          'timeSeconds': 40,
          'waterGrams': bloom,
          'cumulativeWaterGrams': bloom,
          'instruction':
              'Basahi ${dose}g bubuk ${item.name} (${item.process}) dengan ${bloom}g air ($tempC°C), swirl lembut agar CO2 keluar sempurna.',
        },
        {
          'stepOrder': 2,
          'title': '2. Ekstraksi Rasa Utama',
          'durationSeconds': 55,
          'waterAddedGrams': pour2,
          'timeSeconds': 55,
          'waterGrams': pour2,
          'cumulativeWaterGrams': bloom + pour2,
          'instruction':
              'Tuang spiral konstan hingga ${bloom + pour2}g untuk membuka catatan rasa ${item.tastingNotes}.',
        },
        {
          'stepOrder': 3,
          'title': '3. Clean Sweetness Finish',
          'durationSeconds': 60,
          'waterAddedGrams': pour3,
          'timeSeconds': 60,
          'waterGrams': pour3,
          'cumulativeWaterGrams': totalWater,
          'instruction':
              'Tuang halus di tengah hingga ${totalWater}g dan biarkan drawdown selesai bersih.',
        },
      ],
    };
  }
}
