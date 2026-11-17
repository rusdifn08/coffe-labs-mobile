import 'dart:convert';

enum TrialFeature {
  allRecipes,
  unlimitedBrews,
  smartBrewDialIn,
  aiScanner,
  toolkitPro,
  learningAcademy,
  brewDoctor,
  businessSuite,
}

/// Kebijakan akses akun Trial / Non-Pembeli yang dapat dikontrol penuh oleh Admin.
class TrialAccessPolicy {
  static const String modeStrictLimited = 'strict_limited';
  static const String modeFull7dNonBusiness = 'full_trial_7d_non_business';
  static const String modeCustom = 'custom';

  final String policyMode;
  final int trialDurationDays;
  final bool unlockAllRecipes;
  final bool unlockSmartBrewDialIn;
  final bool unlockAiScanner;
  final bool unlockToolkitPro;
  final bool unlockLearningAcademy;
  final bool unlockBrewDoctor;
  final bool unlimitedBrews;
  final int maxFreeRecipes;
  final int maxTrialBrews;
  final bool allowBusinessSuite;
  final bool applyToGuests;
  final bool applyToRegisteredTrial;
  final String policyNote;
  final DateTime? activatedAt;
  final DateTime? updatedAt;

  const TrialAccessPolicy({
    this.policyMode = modeStrictLimited,
    this.trialDurationDays = 7,
    this.unlockAllRecipes = false,
    this.unlockSmartBrewDialIn = false,
    this.unlockAiScanner = false,
    this.unlockToolkitPro = false,
    this.unlockLearningAcademy = false,
    this.unlockBrewDoctor = false,
    this.unlimitedBrews = false,
    this.maxFreeRecipes = 10,
    this.maxTrialBrews = 10,
    this.allowBusinessSuite = false,
    this.applyToGuests = true,
    this.applyToRegisteredTrial = true,
    this.policyNote =
        'Kebijakan standar akun Trial Coffee Labs (10 resep & fitur terbatas).',
    this.activatedAt,
    this.updatedAt,
  });

  static const TrialAccessPolicy strictLimited = TrialAccessPolicy();

  factory TrialAccessPolicy.fullTrial7DaysNonBusiness({
    int durationDays = 7,
    DateTime? activatedAt,
    bool applyToGuests = true,
    bool applyToRegisteredTrial = true,
  }) {
    final now = activatedAt ?? DateTime.now();
    return TrialAccessPolicy(
      policyMode: modeFull7dNonBusiness,
      trialDurationDays: durationDays.clamp(1, 365),
      unlockAllRecipes: true,
      unlockSmartBrewDialIn: true,
      unlockAiScanner: true,
      unlockToolkitPro: true,
      unlockLearningAcademy: true,
      unlockBrewDoctor: true,
      unlimitedBrews: true,
      maxFreeRecipes: 999,
      maxTrialBrews: 999,
      allowBusinessSuite: false, // STRICTLY non-business
      applyToGuests: applyToGuests,
      applyToRegisteredTrial: applyToRegisteredTrial,
      policyNote:
          'Trial Full Access $durationDays Hari (Non-Bisnis): seluruh fitur brewer terbuka, POS & Kiosk tetap terkunci.',
      activatedAt: now,
      updatedAt: now,
    );
  }

  bool get isStrictLimited => policyMode == modeStrictLimited;
  bool get isFull7DayNonBusiness => policyMode == modeFull7dNonBusiness;
  bool get isCustom => policyMode == modeCustom;

  DateTime? resolveExpiry({DateTime? userTrialFullUntil}) {
    if (userTrialFullUntil != null) return userTrialFullUntil;
    if (trialDurationDays <= 0) return null;
    final start = activatedAt ?? updatedAt;
    if (start == null) return null;
    return start.add(Duration(days: trialDurationDays));
  }

  bool isWithinActiveWindow({
    DateTime? userTrialFullUntil,
    DateTime? now,
  }) {
    if (isStrictLimited) return true;
    final expiry = resolveExpiry(userTrialFullUntil: userTrialFullUntil);
    if (expiry == null) return true;
    return (now ?? DateTime.now()).isBefore(expiry);
  }

  Duration? remainingWindow({
    DateTime? userTrialFullUntil,
    DateTime? now,
  }) {
    final expiry = resolveExpiry(userTrialFullUntil: userTrialFullUntil);
    if (expiry == null) return null;
    final diff = expiry.difference(now ?? DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  TrialAccessPolicy copyWith({
    String? policyMode,
    int? trialDurationDays,
    bool? unlockAllRecipes,
    bool? unlockSmartBrewDialIn,
    bool? unlockAiScanner,
    bool? unlockToolkitPro,
    bool? unlockLearningAcademy,
    bool? unlockBrewDoctor,
    bool? unlimitedBrews,
    int? maxFreeRecipes,
    int? maxTrialBrews,
    bool? allowBusinessSuite,
    bool? applyToGuests,
    bool? applyToRegisteredTrial,
    String? policyNote,
    DateTime? activatedAt,
    DateTime? updatedAt,
  }) {
    final nextMode = policyMode ?? this.policyMode;
    final effectiveBusiness =
        nextMode == modeFull7dNonBusiness || nextMode == modeStrictLimited
            ? false
            : (allowBusinessSuite ?? this.allowBusinessSuite);

    return TrialAccessPolicy(
      policyMode: nextMode,
      trialDurationDays: trialDurationDays ?? this.trialDurationDays,
      unlockAllRecipes: unlockAllRecipes ?? this.unlockAllRecipes,
      unlockSmartBrewDialIn:
          unlockSmartBrewDialIn ?? this.unlockSmartBrewDialIn,
      unlockAiScanner: unlockAiScanner ?? this.unlockAiScanner,
      unlockToolkitPro: unlockToolkitPro ?? this.unlockToolkitPro,
      unlockLearningAcademy:
          unlockLearningAcademy ?? this.unlockLearningAcademy,
      unlockBrewDoctor: unlockBrewDoctor ?? this.unlockBrewDoctor,
      unlimitedBrews: unlimitedBrews ?? this.unlimitedBrews,
      maxFreeRecipes: maxFreeRecipes ?? this.maxFreeRecipes,
      maxTrialBrews: maxTrialBrews ?? this.maxTrialBrews,
      allowBusinessSuite: effectiveBusiness,
      applyToGuests: applyToGuests ?? this.applyToGuests,
      applyToRegisteredTrial:
          applyToRegisteredTrial ?? this.applyToRegisteredTrial,
      policyNote: policyNote ?? this.policyNote,
      activatedAt: activatedAt ?? this.activatedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TrialAccessPolicy.fromJson(Map<String, dynamic> json) {
    bool readBool(String snake, String camel, bool def) {
      final v = json[snake] ?? json[camel];
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == 'true';
      return def;
    }

    int readInt(String snake, String camel, int def) {
      final v = json[snake] ?? json[camel];
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? def;
    }

    DateTime? readDate(String snake, String camel) {
      final raw = (json[snake] ?? json[camel])?.toString();
      if (raw == null || raw.isEmpty) return null;
      return DateTime.tryParse(raw);
    }

    final rawMode = (json['policy_mode'] ?? json['policyMode'] ?? modeStrictLimited)
        .toString()
        .trim()
        .toLowerCase();
    final mode = (rawMode == modeFull7dNonBusiness ||
            rawMode == 'trial_7d' ||
            rawMode == 'full_7d')
        ? modeFull7dNonBusiness
        : (rawMode == modeCustom ? modeCustom : modeStrictLimited);

    return TrialAccessPolicy(
      policyMode: mode,
      trialDurationDays: readInt('trial_duration_days', 'trialDurationDays', 7),
      unlockAllRecipes: readBool('unlock_all_recipes', 'unlockAllRecipes', false),
      unlockSmartBrewDialIn:
          readBool('unlock_smart_brew_dial_in', 'unlockSmartBrewDialIn', false),
      unlockAiScanner: readBool('unlock_ai_scanner', 'unlockAiScanner', false),
      unlockToolkitPro: readBool('unlock_toolkit_pro', 'unlockToolkitPro', false),
      unlockLearningAcademy:
          readBool('unlock_learning_academy', 'unlockLearningAcademy', false),
      unlockBrewDoctor: readBool('unlock_brew_doctor', 'unlockBrewDoctor', false),
      unlimitedBrews: readBool('unlimited_brews', 'unlimitedBrews', false),
      maxFreeRecipes: readInt('max_free_recipes', 'maxFreeRecipes', 10),
      maxTrialBrews: readInt('max_trial_brews', 'maxTrialBrews', 10),
      allowBusinessSuite: mode == modeCustom
          ? readBool('allow_business_suite', 'allowBusinessSuite', false)
          : false,
      applyToGuests: readBool('apply_to_guests', 'applyToGuests', true),
      applyToRegisteredTrial:
          readBool('apply_to_registered_trial', 'applyToRegisteredTrial', true),
      policyNote: (json['policy_note'] ??
              json['policyNote'] ??
              'Kebijakan akses akun Trial Coffee Labs')
          .toString(),
      activatedAt: readDate('activated_at', 'activatedAt'),
      updatedAt: readDate('updated_at', 'updatedAt'),
    );
  }

  Map<String, dynamic> toJson({bool resetActivatedAt = false}) => {
        'policy_mode': policyMode,
        'trial_duration_days': trialDurationDays,
        'unlock_all_recipes': unlockAllRecipes,
        'unlock_smart_brew_dial_in': unlockSmartBrewDialIn,
        'unlock_ai_scanner': unlockAiScanner,
        'unlock_toolkit_pro': unlockToolkitPro,
        'unlock_learning_academy': unlockLearningAcademy,
        'unlock_brew_doctor': unlockBrewDoctor,
        'unlimited_brews': unlimitedBrews,
        'max_free_recipes': maxFreeRecipes,
        'max_trial_brews': maxTrialBrews,
        'allow_business_suite':
            policyMode == modeCustom ? allowBusinessSuite : false,
        'apply_to_guests': applyToGuests,
        'apply_to_registered_trial': applyToRegisteredTrial,
        'policy_note': policyNote,
        if (activatedAt != null) 'activated_at': activatedAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        if (resetActivatedAt) 'reset_activated_at': true,
      };

  String encodeJson() => json.encode(toJson());
}
