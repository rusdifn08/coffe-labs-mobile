import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShopeeCompactPromoCarousel extends StatefulWidget {
  const ShopeeCompactPromoCarousel({super.key});

  @override
  State<ShopeeCompactPromoCarousel> createState() =>
      _ShopeeCompactPromoCarouselState();
}

class _ShopeeCompactPromoCarouselState
    extends State<ShopeeCompactPromoCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.94);
  int _currentPage = 0;

  static const _banners = [
    (
      tag: 'PROMO QRIS',
      title: 'Diskon 15% Kopi Pertama • Kode: COFFEEFIRST',
      subtitle: 'Bayar instan via QRIS bebas biaya admin',
      colors: [Color(0xFF5C3A21), Color(0xFF9E4720)],
      voucherCode: 'COFFEEFIRST',
    ),
    (
      tag: 'FRESH BATCH',
      title: 'Roasted < 48 Jam dari 127+ Roastery Nusantara',
      subtitle: 'Dijamin segar & dikemas kedap udara valve',
      colors: [Color(0xFF3E2723), Color(0xFF6B4423)],
      voucherCode: 'FREESHIP',
    ),
    (
      tag: 'BARISTA CLUB',
      title: 'Potongan 20% Order Komunitas • BARISTA20',
      subtitle: 'Tukar kode voucher di halaman keranjang',
      colors: [Color(0xFF4A2511), Color(0xFFB45309)],
      voucherCode: 'BARISTA20',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          SizedBox(
            height: 86,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _banners.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, idx) {
                final b = _banners[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: b.voucherCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Kode promo ${b.voucherCode} disalin!',
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: b.colors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4AF37),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    b.tag,
                                    style: const TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF2B1A0E),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  b.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  b.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            CupertinoIcons.qrcode_viewfinder,
                            color: Color(0xFFFFD56B),
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_banners.length, (i) {
              final active = _currentPage == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: active ? 16 : 6,
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFEA580C)
                      : const Color(0xFFD6CBBF),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
