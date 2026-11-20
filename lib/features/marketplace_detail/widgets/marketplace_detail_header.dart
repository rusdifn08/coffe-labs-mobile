import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/marketplace_model.dart';
import '../../../screens/cart_screen.dart';
import '../../../services/marketplace_service.dart';
import '../../../theme/app_theme.dart';
import '../../marketplace/widgets/coffee_bag_product_visual.dart';

class MarketplaceDetailHeader extends StatefulWidget {
  final MarketplaceProduct product;

  const MarketplaceDetailHeader({super.key, required this.product});

  @override
  State<MarketplaceDetailHeader> createState() =>
      _MarketplaceDetailHeaderState();
}

class _MarketplaceDetailHeaderState extends State<MarketplaceDetailHeader> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _openZoomGallery() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 3.5,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: CoffeeBagProductVisual(
                    product: widget.product,
                    size: 640,
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(ctx).padding.top + 12,
              right: 16,
              child: CircleAvatar(
                backgroundColor: Colors.white24,
                child: IconButton(
                  icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final slideCount = p.galleryImages.isNotEmpty ? p.galleryImages.length : 1;
    final cartCount = MarketplaceService.instance.cartCount;

    return SliverAppBar(
      expandedHeight: 330,
      pinned: true,
      backgroundColor: AppTheme.primaryBrown,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.35),
          child: IconButton(
            icon: const Icon(CupertinoIcons.back, color: Colors.white, size: 19),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.35),
                child: IconButton(
                  icon: const Icon(CupertinoIcons.cart_fill,
                      color: Colors.white, size: 19),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                ),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 0,
                  top: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEA580C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: GestureDetector(
          onTap: _openZoomGallery,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _pageCtrl,
                itemCount: slideCount,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, _) => CoffeeBagProductVisual(
                  product: p,
                  size: 480,
                ),
              ),
              Positioned(
                bottom: 12,
                right: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${_currentPage + 1}/$slideCount • Ketuk Perbesar',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
