import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/marketplace_model.dart';
import '../../../theme/app_theme.dart';

class MarketplaceDetailSpecs extends StatelessWidget {
  final MarketplaceProduct product;
  final bool isEn;

  const MarketplaceDetailSpecs({
    super.key,
    required this.product,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Specs Ribbon (Rating, Roast, Stock)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSpecChip(
                icon: Icons.star,
                iconColor: Colors.amber,
                title: '${product.rating} ★',
                subtitle: '${product.reviewCount} ${isEn ? "reviews" : "ulasan"}',
              ),
              Container(width: 1, height: 32, color: Colors.grey.withValues(alpha: 0.2)),
              _buildSpecChip(
                icon: CupertinoIcons.flame_fill,
                iconColor: Colors.orange,
                title: product.roastProfile,
                subtitle: isEn ? 'Roast Profile' : 'Profil Sangrai',
              ),
              Container(width: 1, height: 32, color: Colors.grey.withValues(alpha: 0.2)),
              _buildSpecChip(
                icon: CupertinoIcons.checkmark_shield_fill,
                iconColor: Colors.green,
                title: '${product.stock} Left',
                subtitle: isEn ? 'Fresh Stock' : 'Stok Segar',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Tasting Notes & Flavors
        Text(
          isEn ? 'Sensory Tasting Notes' : 'Profil Sensorik & Rasa',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: product.tastingNotes.map((note) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF6EFE7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2D4C3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.sparkles, size: 12, color: AppTheme.primaryBrown),
                  const SizedBox(width: 4),
                  Text(
                    note,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // Origin & Lot Technical Details
        Text(
          isEn ? 'Farm & Processing Specifications' : 'Spesifikasi Kebun & Proses',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildDetailRow(isEn ? 'Processing' : 'Proses Pasca Panen', product.process),
              const Divider(height: 16),
              _buildDetailRow(isEn ? 'Variety' : 'Varietas Kopi', product.variety),
              const Divider(height: 16),
              _buildDetailRow(isEn ? 'Altitude' : 'Ketinggian Kebun', product.altitudeMasl),
              const Divider(height: 16),
              _buildDetailRow(isEn ? 'Producer' : 'Produser / Koperasi', product.producer),
              const Divider(height: 16),
              _buildDetailRow(isEn ? 'Freshness' : 'Waktu Sangrai', product.roastDate),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Recommended Brew Method
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(CupertinoIcons.lightbulb_fill, color: AppTheme.primaryBrown, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Roaster Recommended Recipe' : 'Saran Seduh dari Roaster',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.recommendedMethod,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Story / Description
        Text(
          isEn ? 'About this Lot' : 'Tentang Kopi Ini',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 6),
        Text(
          product.description,
          style: const TextStyle(fontSize: 12.5, height: 1.5, color: AppTheme.textDark),
        ),
      ],
    );
  }

  Widget _buildSpecChip({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
      ],
    );
  }
}
