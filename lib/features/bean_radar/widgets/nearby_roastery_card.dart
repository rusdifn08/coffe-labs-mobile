import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/roastery.dart';
import '../../../screens/coffee_roastery_screen.dart';
import '../../../theme/app_theme.dart';

class NearbyRoasteryCard extends StatelessWidget {
  final Roastery roastery;
  final double distanceKm;

  const NearbyRoasteryCard({
    super.key,
    required this.roastery,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final firstLineup = roastery.lineups.isNotEmpty ? roastery.lineups.first : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/roasteries/${roastery.id}.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                    child: const Icon(CupertinoIcons.flame_fill, color: AppTheme.primaryBrown, size: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roastery.name,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roastery.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  distanceKm < 1.0 ? '${(distanceKm * 1000).toInt()} m' : '${distanceKm.toStringAsFixed(1)} km',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryBrown),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Highlight Beans Ready
          if (firstLineup != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.bgCream,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.bag_fill, size: 13, color: AppTheme.primaryBrown),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Biji Unggulan: ${firstLineup.name} • ${firstLineup.price200g}/200g',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),

          // Action buttons: Lihat Lineup & Rute Lokasi
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: AppTheme.primaryBrown),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(CupertinoIcons.map_pin, size: 14, color: AppTheme.primaryBrown),
                  label: const Text('Rute Maps', style: TextStyle(fontSize: 11, color: AppTheme.primaryBrown, fontWeight: FontWeight.w700)),
                  onPressed: () async {
                    final query = Uri.encodeComponent('${roastery.name} ${roastery.address}');
                    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(CupertinoIcons.bag, size: 14, color: Colors.white),
                  label: const Text('Beli Biji Kopi', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CoffeeRoasteryScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
