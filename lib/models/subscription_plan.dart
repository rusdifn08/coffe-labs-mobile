enum SubscriptionTier {
  trial,
  pro,
  business,
}

class SubscriptionPlan {
  final SubscriptionTier tier;
  final String id;
  final String title;
  final String subtitle;
  final String priceLabel;
  final int priceAmount;
  final String billingPeriod;
  final String badgeLabel;
  final List<String> features;
  final bool isRecommended;

  const SubscriptionPlan({
    required this.tier,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.priceLabel,
    required this.priceAmount,
    required this.billingPeriod,
    required this.badgeLabel,
    required this.features,
    this.isRecommended = false,
  });

  static const SubscriptionPlan trial = SubscriptionPlan(
    tier: SubscriptionTier.trial,
    id: 'plan_trial',
    title: 'Coffee Labs Trial',
    subtitle: 'Akses Eksplorasi Awal Barista',
    priceLabel: 'Gratis',
    priceAmount: 0,
    billingPeriod: 'Selamanya (Kapasitas Terbatas)',
    badgeLabel: 'TRIAL BARISTA',
    features: [
      'Batas 10 kali seduh aktif',
      'Akses 10 resep dasar pilihan',
      'Timer seduh standar',
      'Termasuk iklan Google AdMob',
    ],
  );

  static const SubscriptionPlan pro = SubscriptionPlan(
    tier: SubscriptionTier.pro,
    id: 'plan_coffe_labs_pro',
    title: 'Coffee Labs Pro',
    subtitle: 'Solusi Lengkap Home Brewer & Specialist',
    priceLabel: 'Rp 99.000',
    priceAmount: 99000,
    billingPeriod: 'Sekali Bayar • Akses Penuh Selamanya',
    badgeLabel: 'COFFEE LABS PRO',
    isRecommended: true,
    features: [
      'Bebas Iklan 100% Selamanya (Zero Ads)',
      'Buka Seluruh 409+ Resep Juara Dunia (WBC / WBrC)',
      'Seduh Tanpa Batas (Unlimited Brews)',
      'Lab Ekstraksi: Dial-In Assistant V60 & Espresso',
      'Grinder Matrix 8 Grinder Dunia (µm Slider)',
      'Kalkulator Formula 4:6 Tetsu Kasuya',
      'Kalkulator Remineralisasi Air & TDS Refractometer',
      'Badge Spesial PRO di Profil Barista',
    ],
  );

  static const SubscriptionPlan business = SubscriptionPlan(
    tier: SubscriptionTier.business,
    id: 'plan_coffe_labs_business',
    title: 'Coffee Labs Business',
    subtitle: 'Ekosistem Profesional untuk Kafe & Micro-Roastery',
    priceLabel: 'Rp 249.000',
    priceAmount: 249000,
    billingPeriod: 'Sekali Bayar • Lisensi Komersial Bisnis',
    badgeLabel: 'BUSINESS CAFE & ROASTER',
    features: [
      'Seluruh Fitur Coffee Labs Pro Termasuk',
      'Multi-Barista Sync (Hingga 5 Akun Barista Toko)',
      'Katalog Digital Roastery & Menu Seduh Kafe',
      'Cetak Struk Seduh Bluetooth Thermal Printer Tanpa Batas',
      'Export Jurnal Evaluasi Sensori PDF & CSV',
      'Beans Radar & Marketplace Priority Listing',
      'Dukungan Teknis & Konsultasi Dial-In Prioritas',
      'Badge Eksklusif BUSINESS & Sertifikasi Kafe',
    ],
  );

  static List<SubscriptionPlan> get paidPlans => [pro, business];

  static SubscriptionPlan fromTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.pro:
        return pro;
      case SubscriptionTier.business:
        return business;
      case SubscriptionTier.trial:
        return trial;
    }
  }

  static SubscriptionPlan fromString(String? key) {
    if (key == 'business' || key == 'plan_coffe_labs_business') {
      return business;
    }
    if (key == 'pro' || key == 'plan_coffe_labs_pro') {
      return pro;
    }
    return trial;
  }
}
