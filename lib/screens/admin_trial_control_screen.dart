import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/trial_access_policy.dart';
import '../services/trial_service.dart';
import '../theme/app_theme.dart';

/// Pusat Kontrol Admin untuk mengelola kebijakan akses akun Trial / Non-Pembeli
/// termasuk tombol switch cepat "Trial 7 Hari Full Access (Non-Bisnis)" dan
/// saklar granular per fitur, durasi, kuota, serta target akun.
class AdminTrialControlScreen extends StatefulWidget {
  const AdminTrialControlScreen({super.key});

  @override
  State<AdminTrialControlScreen> createState() =>
      _AdminTrialControlScreenState();
}

class _AdminTrialControlScreenState extends State<AdminTrialControlScreen> {
  TrialAccessPolicy _policy = TrialAccessPolicy.strictLimited;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _resetStartNow = false;

  @override
  void initState() {
    super.initState();
    _loadPolicy();
  }

  Future<void> _loadPolicy() async {
    setState(() => _isLoading = true);
    final loaded = await TrialService.getPolicy(refreshFromBackend: true);
    if (!mounted) return;
    setState(() {
      _policy = loaded;
      _isLoading = false;
    });
  }

  void _applyPreset(String mode) {
    setState(() {
      if (mode == TrialAccessPolicy.modeFull7dNonBusiness) {
        _policy = TrialAccessPolicy.fullTrial7DaysNonBusiness(
          durationDays: _policy.trialDurationDays <= 0
              ? 7
              : _policy.trialDurationDays,
          activatedAt: DateTime.now(),
          applyToGuests: _policy.applyToGuests,
          applyToRegisteredTrial: _policy.applyToRegisteredTrial,
        );
        _resetStartNow = true;
      } else if (mode == TrialAccessPolicy.modeStrictLimited) {
        _policy = TrialAccessPolicy.strictLimited.copyWith(
          applyToGuests: _policy.applyToGuests,
          applyToRegisteredTrial: _policy.applyToRegisteredTrial,
          activatedAt: DateTime.now(),
        );
        _resetStartNow = false;
      } else {
        _policy = _policy.copyWith(
          policyMode: TrialAccessPolicy.modeCustom,
          policyNote: 'Kebijakan Kustom Admin: akses disesuaikan secara manual.',
        );
      }
    });
  }

  Future<void> _savePolicy() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final updatedToSave = _resetStartNow
        ? _policy.copyWith(activatedAt: DateTime.now(), updatedAt: DateTime.now())
        : _policy.copyWith(updatedAt: DateTime.now());

    final syncedToBackend = await TrialService.adminSavePolicy(
      updatedToSave,
      resetActivatedAt: _resetStartNow,
    );
    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _resetStartNow = false;
      _policy = TrialService.currentPolicySync;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          syncedToBackend
              ? 'Kebijakan Trial disimpan ke server & langsung aktif di aplikasi!'
              : 'Kebijakan diterapkan di perangkat lokal (server sedang tidak terjangkau).',
        ),
        backgroundColor:
            syncedToBackend ? const Color(0xFF2E7D32) : Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatRemainingWindow() {
    if (_policy.isStrictLimited) return 'Mode Terbatas Aktif';
    final rem = _policy.remainingWindow();
    if (rem == null) return 'Aktif Tanpa Batas Hari';
    if (rem == Duration.zero) return 'Masa Berlaku Habis (Auto-Lock Aktif)';
    final days = rem.inDays;
    final hours = rem.inHours % 24;
    return 'Aktif • Sisa $days hari $hours jam';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Kontrol Akses Trial & Non-Pembeli'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Muat Ulang dari Server',
            onPressed: _isLoading ? null : _loadPolicy,
            icon: const Icon(CupertinoIcons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBrown),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
              children: [
                _buildHeroStatusBanner(),
                const SizedBox(height: 14),
                _buildModePresetSection(),
                const SizedBox(height: 14),
                _buildDurationAndQuotaSection(),
                const SizedBox(height: 14),
                _buildGranularFeaturesSection(),
                const SizedBox(height: 14),
                _buildTargetAudienceSection(),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            border: Border(top: BorderSide(color: AppTheme.borderWarm)),
          ),
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _savePolicy,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(CupertinoIcons.checkmark_shield_fill, size: 19),
              label: Text(
                _isSaving
                    ? 'Menyimpan Kebijakan...'
                    : 'Simpan & Terapkan Live ke Akun Trial',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStatusBanner() {
    final isFull7d = _policy.isFull7DayNonBusiness;
    final isStrict = _policy.isStrictLimited;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFull7d
              ? const [Color(0xFF14532D), Color(0xFF166534)]
              : (isStrict
                  ? const [Color(0xFF3E2723), Color(0xFF5D4037)]
                  : const [Color(0xFF1E3A8A), Color(0xFF1D4ED8)]),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isFull7d
                      ? CupertinoIcons.sparkles
                      : CupertinoIcons.lock_shield_fill,
                  color: const Color(0xFFFDE68A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFull7d
                          ? 'TRIAL 7 HARI FULL (NON-BISNIS)'
                          : (isStrict
                              ? 'MODE TERBATAS (STRICT)'
                              : 'MODE KUSTOM GRANULAR'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatRemainingWindow(),
                      style: const TextStyle(
                        color: Color(0xFFFDE68A),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _policy.policyNote,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  _policy.allowBusinessSuite
                      ? CupertinoIcons.exclamationmark_triangle_fill
                      : CupertinoIcons.lock_fill,
                  color: _policy.allowBusinessSuite
                      ? Colors.amber
                      : const Color(0xFF86EFAC),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _policy.allowBusinessSuite
                        ? 'Perhatian: Business Suite POS/Kiosk diizinkan pada mode kustom.'
                        : 'Proteksi Bisnis Aktif: Kasir POS & OLED Kiosk tetap terkunci untuk non-Business.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModePresetSection() {
    return _sectionCard(
      title: '1. Switch Sistem Akses Akun Trial / Non-Pembeli',
      subtitle:
          'Pilih preset utama untuk langsung mengubah perilaku akun non-berbayar',
      child: Column(
        children: [
          _presetTile(
            selected: _policy.isFull7DayNonBusiness,
            title: 'Trial 7 Hari Full Access (Non-Bisnis)',
            subtitle:
                'Buka seluruh 400+ Resep, Smart Brew AI, Scanner, Toolkit Lab Pro, LMS/Game & Brew Doctor. Bisnis POS tetap terkunci.',
            badge: 'REKOMENDASI PROMO',
            accentColor: const Color(0xFF15803D),
            icon: CupertinoIcons.sparkles,
            onTap: () =>
                _applyPreset(TrialAccessPolicy.modeFull7dNonBusiness),
          ),
          const SizedBox(height: 8),
          _presetTile(
            selected: _policy.isStrictLimited,
            title: 'Mode Trial Ketat / Terbatas (Default)',
            subtitle:
                'Hanya 10 resep pembuka kanonik (aman dari filter/search) & Toolkit Lab Pro terkunci.',
            badge: 'DEFAULT KETAT',
            accentColor: AppTheme.primaryBrown,
            icon: CupertinoIcons.shield_lefthalf_fill,
            onTap: () => _applyPreset(TrialAccessPolicy.modeStrictLimited),
          ),
          const SizedBox(height: 8),
          _presetTile(
            selected: _policy.isCustom,
            title: 'Mode Kustom Granular',
            subtitle:
                'Atur setiap izin fitur, durasi hari & batas kuota satu per satu.',
            badge: 'FLEKSIBEL',
            accentColor: const Color(0xFF1D4ED8),
            icon: CupertinoIcons.slider_horizontal_3,
            onTap: () => _applyPreset(TrialAccessPolicy.modeCustom),
          ),
        ],
      ),
    );
  }

  Widget _presetTile({
    required bool selected,
    required String title,
    required String subtitle,
    required String badge,
    required Color accentColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? accentColor.withValues(alpha: 0.08) : AppTheme.bgCream,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? accentColor : AppTheme.borderWarm,
              width: selected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationAndQuotaSection() {
    final dayOptions = [3, 7, 14, 30, 0];
    final maxRecipeOptions = [5, 10, 15, 25, 50];

    return _sectionCard(
      title: '2. Durasi Masa Trial & Batas Resep Bebas',
      subtitle: 'Tentukan lama periode Full Access & batas resep saat terkunci',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Durasi Trial Full Access:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: dayOptions.map((d) {
              final selected = _policy.trialDurationDays == d;
              return ChoiceChip(
                label: Text(d == 0 ? 'Tanpa Batas' : '$d Hari'),
                selected: selected,
                selectedColor: AppTheme.primaryBrown,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppTheme.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                backgroundColor: AppTheme.bgCream,
                onSelected: (_) {
                  setState(() {
                    _policy = _policy.copyWith(trialDurationDays: d);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeTrackColor: AppTheme.primaryBrown,
            title: const Text(
              'Mulai Ulang Timer Countdown Mulai Sekarang',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'Aktifkan untuk memberi masa penuh baru mulai detik penyimpanan ini',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
            value: _resetStartNow,
            onChanged: (v) => setState(() => _resetStartNow = v),
          ),
          if (!_policy.unlockAllRecipes) ...[
            const Divider(height: 20),
            const Text(
              'Jumlah Resep Gratis Saat Terbatas (Kanonik Anti-Bypass):',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: maxRecipeOptions.map((count) {
                final selected = _policy.maxFreeRecipes == count;
                return ChoiceChip(
                  label: Text('$count Resep'),
                  selected: selected,
                  selectedColor: AppTheme.primaryBrown,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppTheme.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  backgroundColor: AppTheme.bgCream,
                  onSelected: (_) {
                    setState(() {
                      _policy = _policy.copyWith(
                        policyMode: _policy.isFull7DayNonBusiness
                            ? TrialAccessPolicy.modeCustom
                            : _policy.policyMode,
                        maxFreeRecipes: count,
                      );
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGranularFeaturesSection() {
    return _sectionCard(
      title: '3. Pengaturan Izin Fitur Granular',
      subtitle:
          'Saklar independen per modul (mengubah saklar otomatis masuk mode Kustom)',
      child: Column(
        children: [
          _featureSwitch(
            title: 'Buka Semua 400+ Resep Juara',
            subtitle: 'Membuka seluruh resep WBrC, WBC & Nusantara di World Recipes',
            value: _policy.unlockAllRecipes,
            onChanged: (v) => _updateCustom((p) => p.copyWith(
                  policyMode: TrialAccessPolicy.modeCustom,
                  unlockAllRecipes: v,
                )),
          ),
          _featureSwitch(
            title: 'Seduh Tanpa Batas Kuota',
            subtitle: 'Nonaktifkan pembatasan kuota seduh trial',
            value: _policy.unlimitedBrews,
            onChanged: (v) => _updateCustom((p) => p.copyWith(
                  policyMode: TrialAccessPolicy.modeCustom,
                  unlimitedBrews: v,
                )),
          ),
          _featureSwitch(
            title: 'Smart Brew AI & Dial-In Assistant',
            subtitle: 'Kalkulator profil rasa, rekomendasi biji & asisten ekstraksi',
            value: _policy.unlockSmartBrewDialIn,
            onChanged: (v) => _updateCustom((p) => p.copyWith(
                  policyMode: TrialAccessPolicy.modeCustom,
                  unlockSmartBrewDialIn: v,
                )),
          ),
          _featureSwitch(
            title: 'Smart Coffee Bag Scanner & OCR',
            subtitle: 'Pemindai kemasan roastery + pembacaan AI & kamera',
            value: _policy.unlockAiScanner,
            onChanged: (v) => _updateCustom((p) => p.copyWith(
                  policyMode: TrialAccessPolicy.modeCustom,
                  unlockAiScanner: v,
                )),
          ),
          _featureSwitch(
            title: 'Barista Toolkit Pro (Grinder, 4:6, TDS, Air, Scale)',
            subtitle: 'Seluruh instrumen Lab Ekstraksi & Coffee Science',
            value: _policy.unlockToolkitPro,
            onChanged: (v) => _updateCustom((p) => p.copyWith(
                  policyMode: TrialAccessPolicy.modeCustom,
                  unlockToolkitPro: v,
                )),
          ),
          _featureSwitch(
            title: 'Game Brew 3D, Akademi LMS & Pustaka E-Book DRM',
            subtitle: 'Seluruh modul pembelajaran interaktif & buku kopi',
            value: _policy.unlockLearningAcademy,
            onChanged: (v) => _updateCustom((p) => p.copyWith(
                  policyMode: TrialAccessPolicy.modeCustom,
                  unlockLearningAcademy: v,
                )),
          ),
          _featureSwitch(
            title: 'Brew Doctor & Kompas Sensori SCA',
            subtitle: 'Diagnosa keseimbangan asam-pahit & plot ekstraksi',
            value: _policy.unlockBrewDoctor,
            onChanged: (v) => _updateCustom((p) => p.copyWith(
                  policyMode: TrialAccessPolicy.modeCustom,
                  unlockBrewDoctor: v,
                )),
          ),
          const Divider(height: 16),
          _featureSwitch(
            title: 'Business Suite (Kasir POS & OLED Kiosk)',
            subtitle: _policy.isFull7DayNonBusiness
                ? 'Terkunci otomatis pada mode "Trial 7 Hari Non-Bisnis"'
                : 'Khusus mode kustom: izinkan fitur komersial toko/kafe',
            value: _policy.allowBusinessSuite,
            enabled: !_policy.isFull7DayNonBusiness && !_policy.isStrictLimited,
            activeColor: Colors.redAccent,
            onChanged: (v) => _updateCustom((p) => p.copyWith(
                  policyMode: TrialAccessPolicy.modeCustom,
                  allowBusinessSuite: v,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetAudienceSection() {
    return _sectionCard(
      title: '4. Target Pemberlakuan Akun',
      subtitle: 'Pilih siapa saja yang menerima kebijakan di atas',
      child: Column(
        children: [
          _featureSwitch(
            title: 'Akun Terdaftar Non-Pembeli (Tier Trial)',
            subtitle: 'User yang sudah login dengan akun resmi tanpa pembelian Pro/Business',
            value: _policy.applyToRegisteredTrial,
            onChanged: (v) => setState(
              () => _policy = _policy.copyWith(applyToRegisteredTrial: v),
            ),
          ),
          _featureSwitch(
            title: 'Mode Pengunjung / Tamu Anonim',
            subtitle: 'Pengunjung aplikasi tanpa login akun',
            value: _policy.applyToGuests,
            onChanged: (v) =>
                setState(() => _policy = _policy.copyWith(applyToGuests: v)),
          ),
        ],
      ),
    );
  }

  void _updateCustom(
    TrialAccessPolicy Function(TrialAccessPolicy current) transform,
  ) {
    setState(() {
      _policy = transform(_policy);
    });
  }

  Widget _featureSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
    Color? activeColor,
  }) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeTrackColor: activeColor ?? const Color(0xFF15803D),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: enabled ? AppTheme.textDark : AppTheme.textMuted,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
      ),
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
