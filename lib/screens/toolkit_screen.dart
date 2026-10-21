import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/toolkit_vector_icons.dart';
import 'bean_radar_screen.dart';
import 'brew_journal_screen.dart';
import 'coffee_roastery_screen.dart';
import 'favorites_screen.dart';
import 'flavor_wheel_screen.dart';
import 'social_coffee_screen.dart';

class ToolkitScreen extends StatelessWidget {
  const ToolkitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_ToolkitItem> items = [
      _ToolkitItem(
        title: 'Favorite',
        subtitle: 'Koleksi resep seduh favorit Anda',
        iconType: 'favorite',
        primaryColor: const Color(0xFFD32F2F),
        secondaryColor: const Color(0xFFFF8A80),
        gradientColors: [const Color(0xFFFFEBEE), const Color(0xFFFFCDD2)],
        destination: const FavoritesScreen(),
      ),
      _ToolkitItem(
        title: 'Cupping Flavour',
        subtitle: 'SCA wheel & profil sensorik rasa',
        iconType: 'cupping',
        primaryColor: const Color(0xFFE65100),
        secondaryColor: const Color(0xFFFFB74D),
        gradientColors: [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
        destination: const FlavorWheelScreen(),
      ),
      _ToolkitItem(
        title: 'Coffee Roastery',
        subtitle: 'Katalog 50 roastery & lineup kopi',
        iconType: 'roastery',
        primaryColor: const Color(0xFF5D4037),
        secondaryColor: const Color(0xFFBCAAA4),
        gradientColors: [const Color(0xFFEFEBE9), const Color(0xFFD7CCC8)],
        destination: const CoffeeRoasteryScreen(),
      ),
      _ToolkitItem(
        title: 'Beans Radar',
        subtitle: 'Cari biji kopi terdekat via lokasi',
        iconType: 'radar',
        primaryColor: const Color(0xFF00796B),
        secondaryColor: const Color(0xFF80CBC4),
        gradientColors: [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)],
        destination: const BeanRadarScreen(),
      ),
      _ToolkitItem(
        title: 'Jurnal Brew',
        subtitle: 'Catatan ekstraksi & log seduh harian',
        iconType: 'journal',
        primaryColor: const Color(0xFF303F9F),
        secondaryColor: const Color(0xFF9FA8DA),
        gradientColors: [const Color(0xFFE8EAF6), const Color(0xFFC5CAE9)],
        destination: const BrewJournalScreen(),
      ),
      _ToolkitItem(
        title: 'Social Coffee',
        subtitle: 'Komunitas barista, diskusi & bagikan resep',
        iconType: 'social',
        primaryColor: const Color(0xFFE91E63),
        secondaryColor: const Color(0xFFFF80AB),
        gradientColors: [const Color(0xFFFCE4EC), const Color(0xFFF8BBD0)],
        destination: const SocialCoffeeScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Barista Toolkit'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Header Card (Professional Suite Banner)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBrown,
                  AppTheme.primaryBrown.withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.16),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PROFESSIONAL SUITE',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                            color: AppTheme.accentGold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Peralatan Presisi Barista',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Akses cepat fitur favorit, cupping, radar lokasi, dan katalog roastery nasional.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.sparkles, color: AppTheme.accentGold, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2-Column Grid of 6 Professional & Simple Cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final tool = items[index];
              return _buildSimpleCard(context, tool);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleCard(BuildContext context, _ToolkitItem tool) {
    return Material(
      color: AppTheme.surfaceWhite,
      borderRadius: BorderRadius.circular(16),
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => tool.destination),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon SVG kecil unik
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: tool.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: ToolkitVectorIcon(
                  type: tool.iconType,
                  size: 20,
                  primaryColor: tool.primaryColor,
                  secondaryColor: tool.secondaryColor,
                ),
              ),
              const SizedBox(height: 10),

              // Nama Card
              Text(
                tool.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),

              // Deskripsi Card
              Text(
                tool.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppTheme.textMuted,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolkitItem {
  final String title;
  final String subtitle;
  final String iconType;
  final Color primaryColor;
  final Color secondaryColor;
  final List<Color> gradientColors;
  final Widget destination;

  const _ToolkitItem({
    required this.title,
    required this.subtitle,
    required this.iconType,
    required this.primaryColor,
    required this.secondaryColor,
    required this.gradientColors,
    required this.destination,
  });
}
