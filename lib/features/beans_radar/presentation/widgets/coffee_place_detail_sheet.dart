import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/external_url_launcher.dart';
import '../../../../core/widgets/optimized_coffee_image.dart';
import '../../../../theme/app_theme.dart';
import '../../data/beans_radar_repository.dart';
import '../../models/beans_radar_models.dart';

class CoffeePlaceDetailSheet {
  static Future<void> show({
    required BuildContext context,
    required RadarPlaceCard place,
    required BeansRadarRepository repository,
    required double originLat,
    required double originLng,
    VoidCallback? onOpenLinkedRoastery,
    VoidCallback? onShowInAppRoute,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CoffeePlaceDetailBody(
        place: place,
        repository: repository,
        originLat: originLat,
        originLng: originLng,
        onOpenLinkedRoastery: onOpenLinkedRoastery,
        onShowInAppRoute: onShowInAppRoute,
      ),
    );
  }

  /// Navigasi suara opsional via aplikasi Google Maps (Deep Link gratis dengan travelmode tepat).
  static Future<void> launchDirections(
    RadarPlaceCard place, {
    RadarTravelMode mode = RadarTravelMode.motorcycle,
  }) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}&travelmode=${mode.googleMapsTravelMode}',
    );
    await launchExternalUri(uri);
  }
}

class _CoffeePlaceDetailBody extends StatefulWidget {
  final RadarPlaceCard place;
  final BeansRadarRepository repository;
  final double originLat;
  final double originLng;
  final VoidCallback? onOpenLinkedRoastery;
  final VoidCallback? onShowInAppRoute;

  const _CoffeePlaceDetailBody({
    required this.place,
    required this.repository,
    required this.originLat,
    required this.originLng,
    this.onOpenLinkedRoastery,
    this.onShowInAppRoute,
  });

  @override
  State<_CoffeePlaceDetailBody> createState() => _CoffeePlaceDetailBodyState();
}

class _CoffeePlaceDetailBodyState extends State<_CoffeePlaceDetailBody> {
  RadarPlaceDetail? _detail;
  bool _isFavorite = false;
  bool _expandHours = false;
  bool _isLoadingDetail = true;

  static const _dayLabels = <String, String>{
    'mon': 'Senin',
    'tue': 'Selasa',
    'wed': 'Rabu',
    'thu': 'Kamis',
    'fri': 'Jumat',
    'sat': 'Sabtu',
    'sun': 'Minggu',
  };

  @override
  void initState() {
    super.initState();
    _loadFullDetail();
  }

  Future<void> _loadFullDetail() async {
    final detail = await widget.repository.fetchPlaceDetail(
      widget.place.id,
      originLat: widget.originLat,
      originLng: widget.originLng,
    );
    if (!mounted) return;
    setState(() {
      _detail = detail;
      _isFavorite = detail?.isFavorite ?? false;
      _isLoadingDetail = false;
    });
  }

  Future<void> _toggleFav() async {
    setState(() => _isFavorite = !_isFavorite);
    final saved = await widget.repository.toggleFavorite(widget.place.id);
    if (saved != null && mounted) {
      setState(() => _isFavorite = saved);
    }
  }

  Future<void> _openExternalUrl(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri != null) {
      await launchExternalUri(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = _detail?.card ?? widget.place;
    final openStatus = place.openStatus;
    final statusColor = !openStatus.isOpenNow
        ? const Color(0xFFDC2626)
        : (openStatus.isClosingSoon
            ? const Color(0xFFD97706)
            : const Color(0xFF16A34A));

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.42,
      maxChildSize: 0.94,
      expand: false,
      builder: (ctx, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.bgCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  children: [
                    // Photo Hero Banner
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 175,
                        color: const Color(0xFFE7DFD3),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            OptimizedCoffeeImage(
                              imageUrlOrAsset: place.thumbnailUrl ?? '',
                              width: double.infinity,
                              height: 175,
                              fit: BoxFit.cover,
                              errorWidget: Center(
                                child: Icon(
                                  place.category.iconData,
                                  size: 54,
                                  color: AppTheme.primaryBrown.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Material(
                                color: Colors.white.withValues(alpha: 0.92),
                                shape: const CircleBorder(),
                                child: IconButton(
                                  tooltip: 'Tutup Detail',
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(
                                    CupertinoIcons.xmark,
                                    size: 18,
                                    color: AppTheme.primaryBrown,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Material(
                                color: Colors.white.withValues(alpha: 0.92),
                                shape: const CircleBorder(),
                                child: IconButton(
                                  onPressed: _toggleFav,
                                  icon: Icon(
                                    _isFavorite
                                        ? CupertinoIcons.heart_fill
                                        : CupertinoIcons.heart,
                                    color: _isFavorite
                                        ? Colors.red
                                        : AppTheme.primaryBrown,
                                  ),
                                ),
                              ),
                            ),
                            if (place.isVerifiedPartner)
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBrown,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CupertinoIcons.checkmark_seal_fill,
                                        size: 13,
                                        color: AppTheme.accentGold,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Roastery Partner Coffee Labs',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (place.rating > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                CupertinoIcons.star_fill,
                                size: 15,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${place.rating.toStringAsFixed(1)} ${place.formattedReviewsCount}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        Text(
                          '• ${place.category.fullLabel}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            place.etaDisplayLabel,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Open Status + Expandable 7-Day Hours Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () =>
                                setState(() => _expandHours = !_expandHours),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.clock_fill,
                                  size: 16,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    openStatus.statusLabelId,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _expandHours
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: AppTheme.textMuted,
                                ),
                              ],
                            ),
                          ),
                          if (_expandHours && _detail != null) ...[
                            const Divider(height: 16),
                            ..._dayLabels.entries.map((e) {
                              final slots = _detail!.openingHours[e.key] ?? const [];
                              final slotText = slots.isEmpty
                                  ? 'Tutup'
                                  : slots
                                      .map((p) => p.length >= 2 ? '${p[0]} - ${p[1]}' : '')
                                      .join(', ');
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      e.value,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    Text(
                                      slotText,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Copyable Address Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.map_pin_ellipse,
                            size: 18,
                            color: AppTheme.primaryBrown,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              place.fullAddress.isNotEmpty
                                  ? place.fullAddress
                                  : '${place.cityKabupaten}, ${place.province}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Salin Alamat',
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: place.fullAddress),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Alamat disalin ke clipboard.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded, size: 17),
                          ),
                        ],
                      ),
                    ),

                    if (_detail != null &&
                        (_detail!.whatsappNumber != null ||
                            _detail!.phoneNumber != null ||
                            _detail!.websiteUrl != null ||
                            _detail!.instagramHandle != null)) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_detail!.whatsappNumber != null)
                            _ContactActionChip(
                              icon: Icons.chat_rounded,
                              label: 'WhatsApp',
                              onTap: () => _openExternalUrl(
                                'https://wa.me/${_detail!.whatsappNumber}',
                              ),
                            ),
                          if (_detail!.phoneNumber != null)
                            _ContactActionChip(
                              icon: CupertinoIcons.phone_fill,
                              label: _detail!.phoneNumber!,
                              onTap: () => _openExternalUrl(
                                'tel:${_detail!.phoneNumber}',
                              ),
                            ),
                          if (_detail!.websiteUrl != null)
                            _ContactActionChip(
                              icon: CupertinoIcons.globe,
                              label: 'Website',
                              onTap: () => _openExternalUrl(_detail!.websiteUrl!),
                            ),
                          if (_detail!.instagramHandle != null)
                            _ContactActionChip(
                              icon: Icons.camera_alt_outlined,
                              label: '@${_detail!.instagramHandle}',
                              onTap: () => _openExternalUrl(
                                'https://instagram.com/${_detail!.instagramHandle}',
                              ),
                            ),
                        ],
                      ),
                    ],

                    if (!_isLoadingDetail &&
                        _detail != null &&
                        _detail!.linkedRoasteryLineups.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Lineup Biji Kopi Tersedia',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (widget.onOpenLinkedRoastery != null)
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onOpenLinkedRoastery!();
                              },
                              child: const Text('Buka Roastery >'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ..._detail!.linkedRoasteryLineups.take(3).map(
                            (b) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.bag_fill,
                                    size: 18,
                                    color: AppTheme.primaryBrown,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          b.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                        Text(
                                          '${b.origin} • ${b.roastProfile} • ${b.process}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${b.price200gLabel}/200g',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primaryBrown,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  12 + MediaQuery.paddingOf(context).bottom,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (widget.onOpenLinkedRoastery != null) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onOpenLinkedRoastery!();
                        },
                        icon: const Icon(CupertinoIcons.flame_fill, size: 16),
                        label: const Text('Roastery'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBrown,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (widget.onShowInAppRoute != null) {
                            Navigator.pop(context);
                            widget.onShowInAppRoute!();
                          } else {
                            CoffeePlaceDetailSheet.launchDirections(place);
                          }
                        },
                        icon: const Icon(Icons.alt_route_rounded, size: 17),
                        label: const Text(
                          'Lihat Rute di Peta',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBrown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Navigasi Suara Google Maps',
                      child: OutlinedButton(
                        onPressed: () =>
                            CoffeePlaceDetailSheet.launchDirections(place),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBrown,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Icon(Icons.navigation_rounded, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContactActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 15, color: AppTheme.primaryBrown),
      label: Text(
        label,
        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.white,
      side: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
    );
  }
}
