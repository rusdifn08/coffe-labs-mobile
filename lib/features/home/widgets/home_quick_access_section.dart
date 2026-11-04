import 'package:flutter/material.dart';
import '../../../screens/bean_radar_screen.dart';
import '../../../screens/marketplace_screen.dart';
import '../../../screens/social_coffee_screen.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/toolkit_vector_icons.dart';

/// Compact & simple Quick Access section on HomeScreen for Social, Marketplace, and Beans Radar.
class HomeQuickAccessSection extends StatelessWidget {
  final bool isEn;

  const HomeQuickAccessSection({
    super.key,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEn ? 'Quick Access' : 'Akses Cepat',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF7D7268),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildCard(
              context: context,
              title: isEn ? 'Social' : 'Social',
              iconType: 'social',
              primaryColor: const Color(0xFFE91E63),
              secondaryColor: const Color(0xFFFF80AB),
              bgColor: const Color(0xFFFCE4EC),
              borderColor: const Color(0xFFF8BBD0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SocialCoffeeScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
            _buildCard(
              context: context,
              title: isEn ? 'Marketplace' : 'Marketplace',
              iconType: 'marketplace',
              primaryColor: const Color(0xFF8D4925),
              secondaryColor: const Color(0xFFD7A86E),
              bgColor: const Color(0xFFFBE9E7),
              borderColor: const Color(0xFFFFCCBC),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
            _buildCard(
              context: context,
              title: isEn ? 'Beans Radar' : 'Beans Radar',
              iconType: 'radar',
              primaryColor: const Color(0xFF00796B),
              secondaryColor: const Color(0xFF80CBC4),
              bgColor: const Color(0xFFE0F2F1),
              borderColor: const Color(0xFFB2DFDB),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BeanRadarScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String iconType,
    required Color primaryColor,
    required Color secondaryColor,
    required Color bgColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: borderColor.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: ToolkitVectorIcon(
                    type: iconType,
                    size: 17,
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2420),
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
