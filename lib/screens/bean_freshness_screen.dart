import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/bean_freshness/models/freshness_models.dart';
import '../features/bean_freshness/widgets/freshness_dial_card.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';

/// Bean Degassing Curve, Storage Aging & Peak Flavor Window Calculator.
class BeanFreshnessScreen extends StatefulWidget {
  const BeanFreshnessScreen({super.key});

  @override
  State<BeanFreshnessScreen> createState() => _BeanFreshnessScreenState();
}

class _BeanFreshnessScreenState extends State<BeanFreshnessScreen> {
  DateTime _roastDate = DateTime.now().subtract(const Duration(days: 10));
  String _roastLevel = 'Light';
  String _brewType = 'filter';
  String _process = 'Washed';
  StorageMethod _storageMethod = StorageMethod.valveBag;

  int get _actualDaysOffRoast {
    final diff = DateTime.now().difference(_roastDate).inDays;
    return diff < 0 ? 0 : diff;
  }

  int get _effectiveDaysOffRoast {
    return (_actualDaysOffRoast * _storageMethod.agingMultiplier).round();
  }

  FreshnessStage get _stage {
    final extraDays = (_process == 'Anaerobic') ? 4 : (_process == 'Natural' ? 2 : 0);
    final days = _effectiveDaysOffRoast;
    final isEspresso = _brewType == 'espresso';

    if (_roastLevel == 'Light') {
      if (isEspresso) {
        if (days < 10 + extraDays) return FreshnessStage.resting;
        if (days <= 35 + extraDays) return FreshnessStage.peak;
        if (days <= 55 + extraDays) return FreshnessStage.mature;
        return FreshnessStage.pastPeak;
      } else {
        if (days < 6 + extraDays) return FreshnessStage.resting;
        if (days <= 28 + extraDays) return FreshnessStage.peak;
        if (days <= 50 + extraDays) return FreshnessStage.mature;
        return FreshnessStage.pastPeak;
      }
    } else if (_roastLevel == 'Medium-Light' || _roastLevel == 'Medium') {
      if (isEspresso) {
        if (days < 7 + extraDays) return FreshnessStage.resting;
        if (days <= 25 + extraDays) return FreshnessStage.peak;
        if (days <= 45 + extraDays) return FreshnessStage.mature;
        return FreshnessStage.pastPeak;
      } else {
        if (days < 4 + extraDays) return FreshnessStage.resting;
        if (days <= 21 + extraDays) return FreshnessStage.peak;
        if (days <= 40 + extraDays) return FreshnessStage.mature;
        return FreshnessStage.pastPeak;
      }
    } else {
      if (days < 3 + extraDays) return FreshnessStage.resting;
      if (days <= 16 + extraDays) return FreshnessStage.peak;
      if (days <= 30 + extraDays) return FreshnessStage.mature;
      return FreshnessStage.pastPeak;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _roastDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryBrown),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _roastDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final stage = _stage;
    final isEspresso = _brewType == 'espresso';
    final adjustment = BrewAdjustment.calculate(
      stage: stage,
      roastLevel: _roastLevel,
      isEspresso: isEspresso,
    );

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(isEn ? 'Bean Freshness & Aging' : 'Pelacak Kesegaran & Degassing Biji'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Main Freshness Status Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [stage.color, stage.color.withValues(alpha: 0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: stage.color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hari ke-$_actualDaysOffRoast kalender',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        if (_storageMethod != StorageMethod.valveBag)
                          Text(
                            'Usia Efektif Rasa: Hari ke-$_effectiveDaysOffRoast',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                          ),
                      ],
                    ),
                    Icon(stage.icon, color: Colors.white, size: 28),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    stage.label,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                Text(stage.desc, style: const TextStyle(color: Colors.white, fontSize: 12.5, height: 1.35)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Date Picker Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Roast Date' : 'Tanggal Roasting',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    ),
                    Text(
                      '${_roastDate.day}/${_roastDate.month}/${_roastDate.year}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.1),
                    foregroundColor: AppTheme.primaryBrown,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _pickDate,
                  icon: const Icon(CupertinoIcons.calendar, size: 16),
                  label: Text(isEn ? 'Change Date' : 'Ubah Tanggal'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Storage Method Selector (WBrC Freezing vs Valve Bag vs Hopper)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(CupertinoIcons.archivebox_fill, size: 16, color: AppTheme.primaryBrown),
                    SizedBox(width: 6),
                    Text(
                      'Kondisi Penyimpanan (Preservasi Gas):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...StorageMethod.values.map((method) {
                  final active = _storageMethod == method;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _storageMethod = method),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: active ? AppTheme.primaryBrown.withValues(alpha: 0.08) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: active ? AppTheme.primaryBrown : Colors.grey.shade200,
                            width: active ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(method.icon, size: 18, color: active ? AppTheme.primaryBrown : Colors.grey.shade600),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method.label,
                                    style: TextStyle(
                                      fontWeight: active ? FontWeight.bold : FontWeight.w600,
                                      fontSize: 12,
                                      color: active ? AppTheme.primaryBrown : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    method.description,
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Dynamic Extraction Calibration Dial Card
          FreshnessDialCard(
            adjustment: adjustment,
            isEspresso: isEspresso,
          ),
          const SizedBox(height: 12),

          // Method & Process Selection Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tujuan Metode Seduh:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildRadioChip('filter', '☕ Manual Filter (V60)'),
                    const SizedBox(width: 8),
                    _buildRadioChip('espresso', '⚡ Espresso Mesin (9 Bar)'),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Profil Sangrai:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Light', 'Medium-Light', 'Medium', 'Dark'].map((r) {
                      final sel = _roastLevel == r;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _roastLevel = r),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: sel ? AppTheme.primaryBrown : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              r,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                                color: sel ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Metode Pasca-Panen (Degas Rate):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Washed', 'Natural', 'Honey', 'Anaerobic'].map((p) {
                      final sel = _process == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _process = p),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: sel ? AppTheme.primaryBrown : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              p,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                                color: sel ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRadioChip(String key, String label) {
    final sel = _brewType == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _brewType = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: sel ? AppTheme.primaryBrown : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: sel ? AppTheme.primaryBrown : Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: sel ? FontWeight.bold : FontWeight.w500,
              color: sel ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
