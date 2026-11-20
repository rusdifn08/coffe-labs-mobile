import 'package:flutter/material.dart';

import '../../../core/widgets/optimized_coffee_image.dart';
import '../../../models/marketplace_model.dart';

/// Merender visual kemasan kopi 1:1 secara presisi:
/// - Jika produk memiliki foto terverifikasi Cloudinary / kemasan asli: tampil penuh (`BoxFit.cover`).
/// - Jika belum memiliki foto asli: merender visual kemasan 1:1 beridentitas Roastery (logo + warna sangrai)
///   yang responsif untuk grid 2-kolom, mini-card flash sale, maupun thumbnail keranjang 64px.
class CoffeeBagProductVisual extends StatelessWidget {
  final MarketplaceProduct product;
  final double size;
  final BorderRadius borderRadius;

  const CoffeeBagProductVisual({
    super.key,
    required this.product,
    this.size = 180,
    this.borderRadius = BorderRadius.zero,
  });

  List<Color> _pouchPaletteForRoast(String roast, String process) {
    final r = roast.toLowerCase();
    final p = process.toLowerCase();
    if (p.contains('wine') || p.contains('anaerob') || p.contains('carbonic')) {
      return const [Color(0xFF4F1D2C), Color(0xFF7D2E46)];
    }
    if (r.contains('dark')) {
      return const [Color(0xFF281B14), Color(0xFF473125)];
    }
    if (r.contains('light')) {
      return const [Color(0xFFA66E43), Color(0xFFC59369)];
    }
    return const [Color(0xFF5C3A21), Color(0xFF8B5A36)];
  }

  @override
  Widget build(BuildContext context) {
    final showVerifiedPhoto = product.hasVerifiedBagPhoto &&
        product.imageUrl.trim().isNotEmpty &&
        !product.imageUrl.toLowerCase().contains('avatars/');

    if (showVerifiedPhoto) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: ColoredBox(
          color: const Color(0xFFF6F4F0),
          child: OptimizedCoffeeImage(
            imageUrlOrAsset: product.imageUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorWidget: _buildResponsivePouch(),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: _buildResponsivePouch(),
    );
  }

  Widget _buildResponsivePouch() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite ? constraints.maxWidth : size;
        final isTiny = w < 80;
        final isMini = w < 140;
        final colors =
            _pouchPaletteForRoast(product.roastProfile, product.process);

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF4EFE6), Color(0xFFEBE2D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: FractionallySizedBox(
              widthFactor: isTiny ? 0.78 : 0.68,
              heightFactor: isTiny ? 0.84 : 0.80,
              child: Container(
                padding: EdgeInsets.all(isTiny ? 4 : 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(isTiny ? 8 : 12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D190C).withValues(alpha: 0.22),
                      blurRadius: isTiny ? 4 : 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: isTiny
                    ? Center(
                        child: Icon(
                          Icons.coffee_rounded,
                          size: 20,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      )
                    : Column(
                        children: [
                          Container(
                            height: 2,
                            margin: const EdgeInsets.only(bottom: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(isMini ? 4 : 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDFBF7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!isMini &&
                                      product.roasteryLogoUrl.isNotEmpty) ...[
                                    Container(
                                      width: 22,
                                      height: 22,
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFE4D8C6),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: OptimizedCoffeeImage(
                                          imageUrlOrAsset:
                                              product.roasteryLogoUrl,
                                          width: 18,
                                          height: 18,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                  ],
                                  Flexible(
                                    child: Text(
                                      product.roasteryName.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: isMini ? 6 : 6.8,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                        color: colors.first,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Flexible(
                                    flex: 2,
                                    child: Text(
                                      product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: isMini ? 7.5 : 8.5,
                                        fontWeight: FontWeight.w900,
                                        height: 1.1,
                                        color: const Color(0xFF2B1D13),
                                      ),
                                    ),
                                  ),
                                  if (!isMini) ...[
                                    const SizedBox(height: 3),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color:
                                            colors.first.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        product.process,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 6.5,
                                          fontWeight: FontWeight.w700,
                                          color: colors.first,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (!isMini) ...[
                            const SizedBox(height: 3),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '200g',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 7,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
