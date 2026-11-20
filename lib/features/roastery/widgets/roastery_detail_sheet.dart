import 'package:flutter/material.dart';

import '../../../models/roastery.dart';
import '../screens/roastery_detail_screen.dart';

/// Dipertahankan sebagai helper navigasi penuh ke [RoasteryDetailScreen]
/// agar seluruh jalur tetap membuka halaman storefront roastery lengkap (bukan popup bottom sheet).
class RoasteryDetailSheet {
  static Future<void> show(BuildContext context, Roastery roastery) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoasteryDetailScreen(roastery: roastery),
      ),
    );
  }
}
