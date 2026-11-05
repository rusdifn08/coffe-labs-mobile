import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/business_theme.dart';

/// Koleksi ikon SVG buatan sendiri (handcrafted) beresolusi tinggi khusus Mode Business.
/// Setiap ikon dirancang unik merepresentasikan fungsi kartu secara visual:
/// Omset, Transaksi, Cup Penjualan, Rata-rata Order, Kasir POS, Display Kiosk,
/// Stock Opname, Rekap Shift, dan Logo Emblem Kafe yang dapat dikustomisasi.
class BusinessSvgIcon {
  // 1. OMSET HARI INI (Growth Chart + Golden Coffee Bean)
  static Widget omset({double size = 28, Color? color}) {
    final c = _toHex(color ?? BusinessTheme.goldAccent);
    final svg = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="4" y="4" width="40" height="40" rx="12" fill="$c" fill-opacity="0.14"/>
  <rect x="4" y="4" width="40" height="40" rx="12" stroke="$c" stroke-width="1.8" stroke-opacity="0.4"/>
  <!-- Bar chart bars -->
  <rect x="11" y="27" width="5" height="11" rx="2" fill="$c" fill-opacity="0.5"/>
  <rect x="19" y="21" width="5" height="17" rx="2" fill="$c" fill-opacity="0.7"/>
  <rect x="27" y="15" width="5" height="23" rx="2" fill="$c"/>
  <!-- Trend Arrow -->
  <path d="M12 23L20 16L27 20L36 10" stroke="$c" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M30 10H36V16" stroke="$c" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
  <!-- Golden Bean Coin -->
  <circle cx="36" cy="30" r="6" fill="$c"/>
  <path d="M36 26.5C34.5 28 34.5 32 36 33.5C37.5 32 37.5 28 36 26.5Z" fill="#1E1B18"/>
  <path d="M36 27C35.2 28.5 36.8 31.5 36 33" stroke="#1E1B18" stroke-width="1.2" stroke-linecap="round"/>
</svg>
''';
    return SvgPicture.string(svg, width: size, height: size);
  }

  // 2. TRANSAKSI (Digital POS Receipt Docket + Checkmark Seal)
  static Widget transactions({double size = 28, Color? color}) {
    final c = _toHex(color ?? const Color(0xFF60A5FA));
    final svg = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="4" y="4" width="40" height="40" rx="12" fill="$c" fill-opacity="0.14"/>
  <rect x="4" y="4" width="40" height="40" rx="12" stroke="$c" stroke-width="1.8" stroke-opacity="0.4"/>
  <!-- Receipt Paper -->
  <path d="M14 10H34V38L30 35.5L26 38L22 35.5L18 38L14 35.5V10Z" fill="$c" fill-opacity="0.2" stroke="$c" stroke-width="1.8" stroke-linejoin="round"/>
  <!-- Receipt Lines -->
  <line x1="18" y1="16" x2="30" y2="16" stroke="$c" stroke-width="2" stroke-linecap="round"/>
  <line x1="18" y1="21" x2="26" y2="21" stroke="$c" stroke-width="1.8" stroke-linecap="round"/>
  <line x1="18" y1="26" x2="28" y2="26" stroke="$c" stroke-width="1.8" stroke-linecap="round"/>
  <!-- Checkmark Badge -->
  <circle cx="32" cy="30" r="6.5" fill="$c"/>
  <path d="M29.5 30L31.5 32L35 28" stroke="#1E1B18" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';
    return SvgPicture.string(svg, width: size, height: size);
  }

  // 3. CUP PENJUALAN (Specialty Tulip Cup + Latte Art Heart)
  static Widget cupsSold({double size = 28, Color? color}) {
    final c = _toHex(color ?? BusinessTheme.goldAccent);
    final svg = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="4" y="4" width="40" height="40" rx="12" fill="$c" fill-opacity="0.14"/>
  <rect x="4" y="4" width="40" height="40" rx="12" stroke="$c" stroke-width="1.8" stroke-opacity="0.4"/>
  <!-- Aroma Steam -->
  <path d="M19 11C18 13.5 20.5 14.5 19.5 17" stroke="$c" stroke-width="1.8" stroke-linecap="round"/>
  <path d="M24 9C23 12 25.5 13.5 24.5 17" stroke="$c" stroke-width="1.8" stroke-linecap="round"/>
  <path d="M29 11C28 13.5 30.5 14.5 29.5 17" stroke="$c" stroke-width="1.8" stroke-linecap="round"/>
  <!-- Cup Body -->
  <path d="M13 19H33C33 28 29.5 32 23 32C16.5 32 13 28 13 19Z" fill="$c" fill-opacity="0.25" stroke="$c" stroke-width="2"/>
  <!-- Cup Handle -->
  <path d="M33 21C36.5 21 38 23 38 25C38 27.5 35.5 29 32.5 29" stroke="$c" stroke-width="2" stroke-linecap="round"/>
  <!-- Saucer Base -->
  <path d="M11 35H35" stroke="$c" stroke-width="2.5" stroke-linecap="round"/>
  <!-- Latte Art Heart on top -->
  <path d="M23 23C21.5 20.5 18 22 20.5 25L23 27.5L25.5 25C28 22 24.5 20.5 23 23Z" fill="$c"/>
</svg>
''';
    return SvgPicture.string(svg, width: size, height: size);
  }

  // 4. RATA-RATA ORDER (Precision Barista Scale & Basket)
  static Widget averageOrder({double size = 28, Color? color}) {
    final c = _toHex(color ?? const Color(0xFF34D399));
    final svg = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="4" y="4" width="40" height="40" rx="12" fill="$c" fill-opacity="0.14"/>
  <rect x="4" y="4" width="40" height="40" rx="12" stroke="$c" stroke-width="1.8" stroke-opacity="0.4"/>
  <!-- Scale Platform -->
  <rect x="11" y="16" width="26" height="18" rx="4" fill="$c" fill-opacity="0.2" stroke="$c" stroke-width="2"/>
  <!-- LCD Display -->
  <rect x="15" y="24" width="18" height="6" rx="2" fill="#1E1B18"/>
  <circle cx="18" cy="27" r="1" fill="$c"/>
  <circle cx="21" cy="27" r="1" fill="$c"/>
  <circle cx="24" cy="27" r="1" fill="$c"/>
  <text x="27" y="28.5" fill="$c" font-size="5" font-family="monospace" font-weight="bold">g</text>
  <!-- Tamper icon on platform -->
  <path d="M21 12H27V14C27 15 25.5 16 24 16C22.5 16 21 15 21 14V12Z" fill="$c"/>
  <path d="M22 10H26V12H22V10Z" fill="$c"/>
  <!-- Currency sign floating -->
  <circle cx="34" cy="14" r="5" fill="$c"/>
  <text x="32" y="16.5" fill="#1E1B18" font-size="7" font-weight="bold">R</text>
</svg>
''';
    return SvgPicture.string(svg, width: size, height: size);
  }

  // 5. AKSI CEPAT: KASIR POS (Touch Screen Register & Dripper)
  static Widget posCashier({double size = 32, Color? color}) {
    final c = _toHex(color ?? BusinessTheme.goldAccent);
    final svg = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- POS Monitor -->
  <rect x="8" y="10" width="32" height="22" rx="4" fill="$c" fill-opacity="0.2" stroke="$c" stroke-width="2"/>
  <!-- Stand & Base -->
  <path d="M24 32V38M17 38H31" stroke="$c" stroke-width="2.5" stroke-linecap="round"/>
  <!-- Screen grid menu items -->
  <rect x="12" y="14" width="6" height="6" rx="1.5" fill="$c"/>
  <rect x="21" y="14" width="6" height="6" rx="1.5" fill="$c" fill-opacity="0.6"/>
  <rect x="30" y="14" width="6" height="6" rx="1.5" fill="$c" fill-opacity="0.6"/>
  <rect x="12" y="23" width="15" height="5" rx="1.5" fill="$c" fill-opacity="0.4"/>
  <!-- Quick checkout button on screen -->
  <rect x="29" y="23" width="7" height="5" rx="1.5" fill="$c"/>
  <!-- Small Card swipe slot -->
  <path d="M38 18H42V26H38" stroke="$c" stroke-width="1.8" stroke-linecap="round"/>
</svg>
''';
    return SvgPicture.string(svg, width: size, height: size);
  }

  // 6. AKSI CEPAT: DISPLAY KIOSK (AMOLED Dual Bezel Showcase)
  static Widget displayKiosk({double size = 32, Color? color}) {
    final c = _toHex(color ?? const Color(0xFF60A5FA));
    final svg = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Kiosk Totem Body -->
  <rect x="12" y="6" width="24" height="34" rx="4" fill="#141311" stroke="$c" stroke-width="2"/>
  <!-- Outer Bezel accent -->
  <rect x="15" y="9" width="18" height="26" rx="2" fill="$c" fill-opacity="0.15"/>
  <!-- Showcase Coffee Cup on Kiosk screen -->
  <path d="M19 20H27C27 24 25.5 26 23 26C20.5 26 19 24 19 20Z" fill="$c"/>
  <path d="M27 21C28.5 21 29.5 22 29.5 23C29.5 24 28.5 25 27 25" stroke="$c" stroke-width="1.2"/>
  <path d="M18 28H28" stroke="$c" stroke-width="1.4" stroke-linecap="round"/>
  <!-- Price Pill on screen -->
  <rect x="18" y="13" width="12" height="4" rx="2" fill="$c"/>
  <!-- Pedestal Base -->
  <path d="M9 40H39" stroke="$c" stroke-width="3" stroke-linecap="round"/>
  <circle cx="24" cy="37" r="1.5" fill="$c"/>
</svg>
''';
    return SvgPicture.string(svg, width: size, height: size);
  }

  // 7. AKSI CEPAT: STOCK OPNAME (Coffee Bean Jar & Storage Box)
  static Widget stockOpname({double size = 32, Color? color}) {
    final c = _toHex(color ?? const Color(0xFF34D399));
    final svg = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Storage Container / Bin -->
  <path d="M10 16L24 10L38 16L24 22L10 16Z" fill="$c" fill-opacity="0.3" stroke="$c" stroke-width="2" stroke-linejoin="round"/>
  <path d="M10 16V32L24 38V22" fill="$c" fill-opacity="0.2" stroke="$c" stroke-width="2" stroke-linejoin="round"/>
  <path d="M38 16V32L24 38V22" fill="$c" fill-opacity="0.15" stroke="$c" stroke-width="2" stroke-linejoin="round"/>
  <!-- Center Inventory check badge -->
  <circle cx="24" cy="27" r="5" fill="$c"/>
  <path d="M22 27L23.5 28.5L26 25.5" stroke="#1E1B18" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';
    return SvgPicture.string(svg, width: size, height: size);
  }

  // 8. AKSI CEPAT: REKAP SHIFT (Shift Clock & Cashier Ribbon)
  static Widget shiftReport({double size = 32, Color? color}) {
    final c = _toHex(color ?? const Color(0xFFF472B6));
    final svg = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Circular Shift Clock Face -->
  <circle cx="24" cy="22" r="14" fill="$c" fill-opacity="0.15" stroke="$c" stroke-width="2"/>
  <!-- Clock Hands pointing to shift hour -->
  <line x1="24" y1="22" x2="24" y2="14" stroke="$c" stroke-width="2.5" stroke-linecap="round"/>
  <line x1="24" y1="22" x2="31" y2="22" stroke="$c" stroke-width="2" stroke-linecap="round"/>
  <circle cx="24" cy="22" r="2.5" fill="$c"/>
  <!-- Financial Ribbon / Audit Stamp -->
  <path d="M16 33L13 41L19 39L24 42L29 39L35 41L32 33" fill="$c" stroke="$c" stroke-width="1.5" stroke-linejoin="round"/>
  <line x1="18" y1="36" x2="30" y2="36" stroke="#1E1B18" stroke-width="1.8"/>
</svg>
''';
    return SvgPicture.string(svg, width: size, height: size);
  }

  // 9. ESTIMASI KAPASITAS SEDUH (Hourglass Portafilter)
  static Widget brewCapacity({double size = 26, Color? color}) {
    final c = _toHex(color ?? BusinessTheme.goldAccent);
    final svg = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Hourglass Portafilter hybrid -->
  <path d="M14 10H34" stroke="$c" stroke-width="2.5" stroke-linecap="round"/>
  <path d="M14 38H34" stroke="$c" stroke-width="2.5" stroke-linecap="round"/>
  <path d="M16 10C16 20 22 24 22 24C22 24 16 28 16 38" stroke="$c" stroke-width="2"/>
  <path d="M32 10C32 20 26 24 26 24C26 24 32 28 32 38" stroke="$c" stroke-width="2"/>
  <!-- Dripping Crema Droplet -->
  <circle cx="24" cy="28" r="2.2" fill="$c"/>
  <circle cx="24" cy="34" r="1.8" fill="$c"/>
  <!-- Handle extending right -->
  <rect x="33" y="22" width="7" height="4" rx="1.5" fill="$c"/>
</svg>
''';
    return SvgPicture.string(svg, width: size, height: size);
  }

  // 10. CAFE LOGO EMBLEM (Dapat diubah dengan 6 preset unik buatan sendiri)
  static Widget cafeEmblem({
    required String logoType,
    double size = 44,
    Color? color,
  }) {
    final c = _toHex(color ?? BusinessTheme.goldAccent);
    String innerContent;

    switch (logoType) {
      case 'royal_portafilter':
        innerContent = '''
  <!-- Portafilter with Crown -->
  <path d="M18 15L21 11L24 14L27 11L30 15H18Z" fill="$c"/>
  <circle cx="24" cy="23" r="8" fill="$c" fill-opacity="0.3" stroke="$c" stroke-width="2"/>
  <path d="M22 31V37M26 31V37" stroke="$c" stroke-width="2.2" stroke-linecap="round"/>
  <rect x="32" y="21" width="8" height="4" rx="2" fill="$c"/>
''';
        break;

      case 'v60_dripper':
        innerContent = '''
  <!-- V60 Origami Cone -->
  <path d="M14 16L24 33L34 16H14Z" fill="$c" fill-opacity="0.3" stroke="$c" stroke-width="2" stroke-linejoin="round"/>
  <path d="M19 16L24 31L29 16" stroke="$c" stroke-width="1.4"/>
  <line x1="12" y1="14" x2="36" y2="14" stroke="$c" stroke-width="2.5" stroke-linecap="round"/>
  <path d="M18 36H30" stroke="$c" stroke-width="2" stroke-linecap="round"/>
''';
        break;

      case 'botanical_leaf':
        innerContent = '''
  <!-- Specialty Arabica Branch -->
  <path d="M14 34C20 30 28 22 34 14" stroke="$c" stroke-width="2.2" stroke-linecap="round"/>
  <path d="M22 26C18 24 17 19 21 18C25 17 26 22 22 26Z" fill="$c" fill-opacity="0.4" stroke="$c" stroke-width="1.5"/>
  <path d="M26 22C30 24 35 23 34 19C33 15 28 18 26 22Z" fill="$c" fill-opacity="0.4" stroke="$c" stroke-width="1.5"/>
  <circle cx="22" cy="30" r="3" fill="$c"/>
  <circle cx="27" cy="25" r="2.5" fill="$c"/>
''';
        break;

      case 'geometric_cup':
        innerContent = '''
  <!-- Modern Geometric Hexagon Cup -->
  <path d="M24 10L35 16V28L24 34L13 28V16L24 10Z" fill="$c" fill-opacity="0.2" stroke="$c" stroke-width="2"/>
  <path d="M24 18L30 22V28L24 31L18 28V22L24 18Z" fill="$c"/>
  <path d="M24 10V18" stroke="$c" stroke-width="1.5"/>
''';
        break;

      case 'steaming_pitcher':
        innerContent = '''
  <!-- Barista Milk Pitcher -->
  <path d="M16 16L20 34H32L34 16H16Z" fill="$c" fill-opacity="0.2" stroke="$c" stroke-width="2"/>
  <path d="M14 16H20" stroke="$c" stroke-width="2" stroke-linecap="round"/>
  <path d="M34 20C37 21 38 23 38 25C38 28 35 30 32 30" stroke="$c" stroke-width="2"/>
  <!-- Steam latte foam plume -->
  <path d="M22 13C20 10 24 8 26 6C28 8 26 11 28 13" stroke="$c" stroke-width="1.8" stroke-linecap="round"/>
''';
        break;

      case 'flame_bean':
      default:
        innerContent = '''
  <!-- Roasting Flame & Split Bean -->
  <path d="M24 8C27 12 33 16 31 24C30 29 27 32 24 34C21 32 18 29 17 24C15 16 21 12 24 8Z" fill="$c" fill-opacity="0.3" stroke="$c" stroke-width="2"/>
  <!-- Inner split bean shape -->
  <path d="M24 17C21 19 20 25 24 28C28 25 27 19 24 17Z" fill="$c"/>
  <path d="M24 18C22.8 20.5 25.2 24.5 24 27" stroke="#1E1B18" stroke-width="1.2" stroke-linecap="round"/>
''';
        break;
    }

    final svg = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="24" cy="24" r="22" fill="#282420" stroke="$c" stroke-width="2"/>
  $innerContent
</svg>
''';
    return SvgPicture.string(svg, width: size, height: size);
  }

  static String _toHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }
}
