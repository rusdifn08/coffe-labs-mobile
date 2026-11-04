import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../data/roastery_catalog.dart';
import '../features/bean_radar/widgets/nearby_roastery_card.dart';
import '../features/bean_radar/widgets/radar_city_picker_sheet.dart';
import '../features/bean_radar/widgets/radar_radius_filter.dart';
import '../features/bean_radar/widgets/radar_visualizer.dart';
import '../models/roastery.dart';
import '../theme/app_theme.dart';

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
          RadarVisualizer(
            pulseController: _pulseController,
            hasNearbyItems: nearbyList.isNotEmpty,
            currentLocationName: _currentLocationName,
            onSelectCity: () => RadarCityPickerSheet.show(
              context: context,
              cityPresets: _cityPresets,
              currentLocationName: _currentLocationName,
              onSelectCity: (name, lat, lng) {
                setState(() {
                  _currentLocationName = name;
                  _userLat = lat;
                  _userLng = lng;
                });
              },
            ),
          ),

          // Radius filter bar
          RadarRadiusFilter(
            selectedRadiusKm: _selectedRadiusKm,
            onRadiusChanged: (r) => setState(() => _selectedRadiusKm = r),
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
                              return NearbyRoasteryCard(roastery: r, distanceKm: dist);
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
}
