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
    subtitle: 'Solusi Lengkap Home Brewer & Barista Specialist',
    priceLabel: 'Rp 99.000',
    priceAmount: 99000,
    billingPeriod: 'Sekali Bayar • Akses Penuh Selamanya',
    badgeLabel: 'COFFEE LABS PRO',
    isRecommended: true,
    features: [
      'Buka Seluruh 500+ Resep Juara Dunia & Nusantara (WBC / WBrC & 18 Metode Seduh)',
      'Seduh Tanpa Batas (Unlimited Brews) & Alarm Latar Belakang Cold Brew',
      'Toolkit Barista Lengkap 21 Fitur (Smart Brew AI, 100+ Grinder Matrix, 4:6, TDS & Kimia Air)',
      'Learning Brew: Game V60 3D Gyroscope, Akademi LMS & Pustaka E-Book DRM Offline',
      'AI Bean Scanner, Studio AI Vision & Brew Doctor Kompas SCA',
      'Live Brew QR Tracker, Social Coffee Hub & Bebas Iklan 100% Selamanya',
    ],
  );

  static const SubscriptionPlan business = SubscriptionPlan(
    tier: SubscriptionTier.business,
    id: 'plan_coffe_labs_business',
    title: 'Coffee Labs Business',
    subtitle: 'Ekosistem POS, Kiosk AMOLED & Manajemen Kafe',
    priceLabel: 'Rp 249.000',
    priceAmount: 249000,
    billingPeriod: 'Sekali Bayar • Lisensi Komersial Bisnis',
    badgeLabel: 'BUSINESS CAFE & ROASTER',
    features: [
      'Seluruh Fitur Coffee Labs Pro (500+ Resep, Seduh Tanpa Batas & Toolkit Barista)',
      'Dashboard Kafe & POS Kasir Lengkap (Cash, QRIS, Kartu, Diskon & Rekap Tutup Shift)',
      'Business Roastery Studio: 1 Profil Roastery Resmi & Katalog Lineup Kopi Publik (+ AI Scan)',
      'Display Kiosk Pelanggan OLED/AMOLED Always-On + Anti Burn-In & Kunci PIN Kiosk',
      'Stok Opname & Audit Bahan Bar + Estimasi Kapasitas Cup & Peringatan Stok Rendah',
      'Cetak Struk Thermal Bluetooth Tanpa Batas (58mm/80mm) + QR Live Brew Pelanggan',
      'Kustomisasi Profil & Logo Emblem Kafe, Kelola Menu & Multi-Barista Sync (5 Akun)',
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
    if (key == null || key.isEmpty) return trial;
    final normalized = key.toLowerCase().trim();
    if (normalized == 'business' ||
        normalized == 'plan_business' ||
        normalized == 'plan_coffe_labs_business') {
      return business;
    }
    if (normalized == 'pro' ||
        normalized == 'plan_pro' ||
        normalized == 'plan_coffe_labs_pro') {
      return pro;
    }
    return trial;
  }
}
