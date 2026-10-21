import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/roastery_catalog.dart';
import '../models/roastery.dart';
import '../theme/app_theme.dart';
import 'coffee_roastery_screen.dart';

class BeanRadarScreen extends StatefulWidget {
  const BeanRadarScreen({super.key});

  @override
  State<BeanRadarScreen> createState() => _BeanRadarScreenState();
}

class _BeanRadarScreenState extends State<BeanRadarScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  // Lokasi default (Jakarta Pusat)
  double _userLat = -6.1944;
  double _userLng = 106.8229;
  String _currentLocationName = 'Jakarta Pusat (Monas / Thamrin)';
  bool _isLocating = false;
  double _selectedRadiusKm = 50.0;

  final Map<String, List<double>> _cityPresets = {
    'Jakarta Pusat': [-6.1944, 106.8229],
    'Jakarta Selatan (Senopati/Gandaria)': [-6.2411, 106.7915],
    'Bandung (Dago / Citarum)': [-6.9015, 107.6228],
    'Tangerang (Gading Serpong)': [-6.2520, 106.6310],
    'Bekasi (Grand Galaxy)': [-6.2625, 106.9741],
    'Yogyakarta (Sleman / Kaliurang)': [-7.7335, 110.3952],
    'Bali (Kintamani / Tabanan)': [-8.2431, 115.3340],
    'Bandar Lampung': [-5.4412, 105.2638],
    'Subang (Ciater)': [-6.7452, 107.6534],
    'Sukabumi': [-6.9182, 106.9295],
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Haversine formula distance in kilometers
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }

  Future<void> _refreshLocation() async {
    setState(() => _isLocating = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _isLocating = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lokasi berhasil dikalibrasi ke $_currentLocationName'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hitung jarak ke seluruh roastery
    final allRoasteries = RoasteryCatalog.list;
    final List<Map<String, dynamic>> nearbyList = [];

    for (final r in allRoasteries) {
      final dist = _calculateDistance(_userLat, _userLng, r.latitude, r.longitude);
      if (dist <= _selectedRadiusKm) {
        nearbyList.add({
          'roastery': r,
          'distance': dist,
        });
      }
    }

    // Urutkan dari yang paling dekat
    nearbyList.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Beans Radar'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Kalibrasi Lokasi',
            icon: _isLocating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBrown),
                  )
                : const Icon(CupertinoIcons.location_fill),
            onPressed: _refreshLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Visual Radar Widget
          Container(
            height: 220,
            width: double.infinity,
            color: AppTheme.bgCream,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulse Circles
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final progress = _pulseController.value;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140 + progress * 70,
                          height: 140 + progress * 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.accentGold.withValues(alpha: (1.0 - progress) * 0.4),
                              width: 1.5,
                            ),
                          ),
                        ),
                        Container(
                          width: 80 + progress * 50,
                          height: 80 + progress * 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.accentGold.withValues(alpha: (1.0 - progress) * 0.08),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Radar Crosshairs
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
                  ),
                ),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
                  ),
                ),

                // Center User Pin
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBrown,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.35),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(CupertinoIcons.location_solid, color: Colors.white, size: 24),
                ),

                // Nearby Ping dots
                if (nearbyList.isNotEmpty) ...[
                  Positioned(
                    top: 45,
                    left: 70,
                    child: _buildRadarBlip('0.8 km'),
                  ),
                  Positioned(
                    bottom: 40,
                    right: 80,
                    child: _buildRadarBlip('1.4 km'),
                  ),
                  Positioned(
                    top: 60,
                    right: 65,
                    child: _buildRadarBlip('2.2 km'),
                  ),
                ],

                // Location Pill at bottom of radar
                Positioned(
                  bottom: 12,
                  child: GestureDetector(
                    onTap: _showCityPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.placemark_fill, size: 14, color: AppTheme.accentGold),
                          const SizedBox(width: 6),
                          Text(
                            _currentLocationName,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryBrown),
                          ),
                          const SizedBox(width: 4),
                          const Icon(CupertinoIcons.chevron_down, size: 12, color: AppTheme.primaryBrown),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Radius filter bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: AppTheme.bgCream,
            child: Row(
              children: [
                const Text(
                  'Radius: ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [10.0, 25.0, 50.0, 150.0, 500.0].map((radius) {
                        final isSel = _selectedRadiusKm == radius;
                        final label = radius >= 500.0 ? 'Semua' : '${radius.toInt()} km';
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(label, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : AppTheme.primaryBrown)),
                            selected: isSel,
                            selectedColor: AppTheme.primaryBrown,
                            backgroundColor: AppTheme.surfaceWhite,
                            onSelected: (val) {
                              if (val) setState(() => _selectedRadiusKm = radius);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Roastery List Container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kopi & Roastery Terdekat (${nearbyList.length})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(CupertinoIcons.checkmark_seal_fill, size: 11, color: Colors.green),
                            SizedBox(width: 3),
                            Text('Ready Beans', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: nearbyList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(CupertinoIcons.location_slash, size: 40, color: Colors.grey),
                                const SizedBox(height: 8),
                                Text(
                                  'Tidak ada roastery dalam radius ${_selectedRadiusKm.toInt()} km.',
                                  style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => setState(() => _selectedRadiusKm = 500.0),
                                  child: const Text('Perluas Radius ke Seluruh Indonesia'),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: nearbyList.length,
                            separatorBuilder: (_, index) => const SizedBox(height: 12),
                            padding: const EdgeInsets.only(bottom: 24),
                            itemBuilder: (context, index) {
                              final item = nearbyList[index];
                              final Roastery r = item['roastery'] as Roastery;
                              final double dist = item['distance'] as double;
                              return _buildNearbyCard(context, r, dist);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarBlip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primaryBrown,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNearbyCard(BuildContext context, Roastery r, double dist) {
    final firstLineup = r.lineups.isNotEmpty ? r.lineups.first : null;

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
                  color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.flame_fill, color: AppTheme.primaryBrown, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      r.address,
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
                  dist < 1.0 ? '${(dist * 1000).toInt()} m' : '${dist.toStringAsFixed(1)} km',
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
                    final query = Uri.encodeComponent('${r.name} ${r.address}');
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

  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Lokasi Pencarian Beans Radar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: _cityPresets.entries.map((e) {
                    final isSel = _currentLocationName == e.key;
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        isSel ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.location,
                        color: isSel ? AppTheme.primaryBrown : Colors.grey,
                      ),
                      title: Text(
                        e.key,
                        style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                      ),
                      onTap: () {
                        setState(() {
                          _currentLocationName = e.key;
                          _userLat = e.value[0];
                          _userLng = e.value[1];
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
