import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../core/assets/cloud_asset_manager.dart';

/// Latar belakang header resep dengan cascading fallback berlapis:
/// 1) Cover foto barista/resep (`coverImageUrl`, abaikan `generic_fallback.jpg`)
/// 2) Foto portrait barista (`portraitUrl`)
/// 3) Ilustrasi 3D alat seduh (`assets/images/methods/<method>.png`)
/// 4) Latar gradien espresso premium Coffee Labs (tanpa pernah memunculkan error box).
class RecipeCoverBackground extends StatelessWidget {
  final String? coverImageUrl;
  final String? portraitUrl;
  final String? methodName;
  final String? categoryName;

  const RecipeCoverBackground({
    super.key,
    this.coverImageUrl,
    this.portraitUrl,
    this.methodName,
    this.categoryName,
  });

  static String? resolveMethodAsset(String? method, String? category) {
    final text = '${method ?? ''} ${category ?? ''}'.toLowerCase();
    if (text.contains('aeropress')) return 'assets/images/methods/aeropress.png';
    if (text.contains('bee house') || text.contains('beehouse')) {
      return 'assets/images/methods/bee_house.png';
    }
    if (text.contains('bonmac')) return 'assets/images/methods/bonmac.png';
    if (text.contains('chemex')) return 'assets/images/methods/chemex.png';
    if (text.contains('clever')) return 'assets/images/methods/clever_dripper.png';
    if (text.contains('cold brew') || text.contains('toddy')) {
      return 'assets/images/methods/cold_brew.png';
    }
    if (text.contains('cupping')) return 'assets/images/methods/cupping.png';
    if (text.contains('drip coffee') || text.contains('batch')) {
      return 'assets/images/methods/drip_coffee_maker.png';
    }
    if (text.contains('espresso')) return 'assets/images/methods/espresso_machine.png';
    if (text.contains('french press')) return 'assets/images/methods/french_press.png';
    if (text.contains('japanese') || text.contains('iced v60') || text.contains('flash')) {
      return 'assets/images/methods/japanese_drip.png';
    }
    if (text.contains('kalita')) return 'assets/images/methods/kalita_wave.png';
    if (text.contains('moka')) return 'assets/images/methods/moka_pot.png';
    if (text.contains('origami')) return 'assets/images/methods/origami_dripper.png';
    if (text.contains('syphon') || text.contains('siphon')) {
      return 'assets/images/methods/syphon.png';
    }
    if (text.contains('turkish') || text.contains('ibrik')) {
      return 'assets/images/methods/turkish_coffee.png';
    }
    if (text.contains('vietnam') || text.contains('phin')) {
      return 'assets/images/methods/vietnam_drip.png';
    }
    if (text.contains('v60') || text.contains('switch') || text.contains('pour')) {
      return 'assets/images/methods/hario_v60.png';
    }
    return 'assets/images/methods/hario_v60.png';
  }

  static const String _genericFallbackAsset =
      'assets/images/avatars/generic_fallback.jpg';

  static List<String> buildCandidatePaths({
    String? coverImageUrl,
    String? portraitUrl,
    String? methodName,
    String? categoryName,
  }) {
    final List<String> candidates = [];

    void addCandidate(String? raw) {
      final cleaned = raw?.trim() ?? '';
      if (cleaned.isEmpty) return;
      if (cleaned == _genericFallbackAsset) return;
      if (!candidates.contains(cleaned)) {
        candidates.add(cleaned);
      }
    }

    addCandidate(coverImageUrl);
    addCandidate(portraitUrl);
    addCandidate(resolveMethodAsset(methodName, categoryName));
    return candidates;
  }

  @override
  Widget build(BuildContext context) {
    final candidates = buildCandidatePaths(
      coverImageUrl: coverImageUrl,
      portraitUrl: portraitUrl,
      methodName: methodName,
      categoryName: categoryName,
    );

    if (candidates.isEmpty) {
      return _buildGradientBackdrop();
    }

    return _buildCascadingImage(candidates, 0);
  }

  Widget _buildCascadingImage(List<String> candidates, int index) {
    if (index >= candidates.length) {
      return _buildGradientBackdrop();
    }
    final path = candidates[index];
    final isMethodAsset = path.startsWith('assets/images/methods/');
    Widget nextBuilder() => _buildCascadingImage(candidates, index + 1);

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => nextBuilder(),
      );
    }

    if (isMethodAsset) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _buildGradientBackdrop(),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              child: Opacity(
                opacity: 0.9,
                child: CloudAssetImage(
                  path,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return CloudAssetImage(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => nextBuilder(),
    );
  }

  Widget _buildGradientBackdrop() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D1C12),
            Color(0xFF4E311D),
            Color(0xFF1F140E),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.accentAmber.withValues(alpha: 0.14),
            border: Border.all(
              color: AppTheme.accentGold.withValues(alpha: 0.28),
            ),
          ),
          child: const Icon(
            Icons.local_cafe_rounded,
            size: 40,
            color: AppTheme.accentGold,
          ),
        ),
      ),
    );
  }
}
