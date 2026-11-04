import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/bean_ai_customization_models.dart';
import '../../../theme/app_theme.dart';

/// Interactive AI Brewing Intelligence Card
/// Allows fine-tuning bean roast age (CO2 degassing), water mineral profile (PPM),
/// and championship pouring paradigm (Tetsu 4:6, Lance 1-2-1, Osmotic, Hoffmann).
class BeanAiCustomizerCard extends StatelessWidget {
  final BeanRoastAge selectedRoastAge;
  final WaterProfile selectedWaterProfile;
  final PouringParadigm selectedParadigm;
  final ValueChanged<BeanRoastAge> onRoastAgeChanged;
  final ValueChanged<WaterProfile> onWaterProfileChanged;
  final ValueChanged<PouringParadigm> onParadigmChanged;
  final ValueChanged<AiTweakAction> onApplyTweak;

  const BeanAiCustomizerCard({
    super.key,
    required this.selectedRoastAge,
    required this.selectedWaterProfile,
    required this.selectedParadigm,
    required this.onRoastAgeChanged,
    required this.onWaterProfileChanged,
    required this.onParadigmChanged,
    required this.onApplyTweak,
  });

  void _showTweakDoctorModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AiTweakDoctorModal(onApplyTweak: onApplyTweak),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.cyan.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header AI Neural Matrix
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF007A87), Color(0xFF00B4D8)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(CupertinoIcons.waveform_path_ecg, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '3. Kustomisasi AI & Gaya Seduh',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppTheme.textDark),
                        ),
                        SizedBox(width: 6),
                        _AiBadge(),
                      ],
                    ),
                    Text(
                      'Degassing CO2, profil mineral air & teknik barista juara',
                      style: TextStyle(fontSize: 10.5, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Roast Age / Degassing Period
          _buildRoastAgeSection(),
          const SizedBox(height: 12),

          // 2. Water Mineral Profile
          _buildWaterProfileSection(),
          const SizedBox(height: 12),

          // 3. Pouring Paradigm Selector
          _buildPouringParadigmSection(),
          const SizedBox(height: 14),

          // 4. AI Dial-In Doctor Button
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showTweakDoctorModal(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade50,
                    const Color(0xFFFFF7E6),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: const Row(
                children: [
                  Icon(CupertinoIcons.sparkles, size: 16, color: Color(0xFFB45309)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dokter Seduh AI: Seduhan Belum Pas?',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF78350F)),
                        ),
                        Text(
                          'Koreksi otomatis rasa terlalu asam, pahit sepat, atau encer',
                          style: TextStyle(fontSize: 10, color: Color(0xFF92400E)),
                        ),
                      ],
                    ),
                  ),
                  Icon(CupertinoIcons.chevron_right, size: 14, color: Color(0xFFB45309)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoastAgeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Umur Sangrai (Degassing CO2)',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.textDark),
            ),
            Text(
              selectedRoastAge.badge,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.cyan.shade800),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: BeanRoastAge.values.map((age) {
            final isSel = selectedRoastAge == age;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onRoastAgeChanged(age),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF007A87) : AppTheme.bgCream,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSel ? const Color(0xFF007A87) : Colors.grey.shade300,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      age.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                        color: isSel ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWaterProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profil Air Seduh (PPM & Mineral)',
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.textDark),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: WaterProfile.values.map((w) {
            final isSel = selectedWaterProfile == w;
            return ChoiceChip(
              avatar: Icon(w.icon, size: 13, color: isSel ? Colors.white : AppTheme.primaryBrown),
              label: Text(
                w.label.split('(').first.trim(),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  color: isSel ? Colors.white : AppTheme.textDark,
                ),
              ),
              selected: isSel,
              selectedColor: const Color(0xFF007A87),
              backgroundColor: AppTheme.bgCream,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onSelected: (_) => onWaterProfileChanged(w),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPouringParadigmSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gaya Alur Seduh (Pouring Paradigm)',
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.textDark),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: PouringParadigm.values.map((p) {
            final isSel = selectedParadigm == p;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    p.label,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      color: isSel ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSel ? Colors.white.withValues(alpha: 0.25) : AppTheme.accentGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      p.badge,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: isSel ? Colors.white : AppTheme.primaryBrown,
                      ),
                    ),
                  ),
                ],
              ),
              selected: isSel,
              selectedColor: AppTheme.primaryBrown,
              backgroundColor: AppTheme.bgCream,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onSelected: (_) => onParadigmChanged(p),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AiBadge extends StatelessWidget {
  const _AiBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF007A87), Color(0xFF00B4D8)],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'AI v3.4',
        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

class _AiTweakDoctorModal extends StatelessWidget {
  final ValueChanged<AiTweakAction> onApplyTweak;

  const _AiTweakDoctorModal({required this.onApplyTweak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(CupertinoIcons.lab_flask_solid, color: AppTheme.primaryBrown, size: 20),
                SizedBox(width: 8),
                Text(
                  'Dokter Seduh & Dial-In AI 🧪',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Bagaimana hasil cangkir kopi terakhir Anda? Pilih kendala rasa untuk auto-tuning parameter:',
              style: TextStyle(fontSize: 11.5, color: Colors.grey),
            ),
            const SizedBox(height: 14),
            ...AiTweakAction.values.map((action) => _buildTweakItem(context, action)),
          ],
        ),
      ),
    );
  }

  Widget _buildTweakItem(BuildContext context, AiTweakAction action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.1),
          child: Icon(action.icon, color: AppTheme.primaryBrown, size: 20),
        ),
        title: Text(
          action.label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(action.diagnosis, style: const TextStyle(fontSize: 10.5, color: Colors.black87)),
              const SizedBox(height: 2),
              Text(
                action.suggestion,
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF007A87)),
              ),
            ],
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onApplyTweak(action);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBrown,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: const Text('Terapkan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
