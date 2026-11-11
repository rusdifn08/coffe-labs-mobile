import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../in_app_trainer/presentation/in_app_bean_trainer_screen.dart';
import '../../scanner/data/local/prototype_database.dart';
import '../../scanner/domain/services/incremental_vision_engine.dart';
import '../data/local/studio_database.dart';
import 'mobile_dataset_kanban_screen.dart';
import 'widgets/studio_cloud_sync_sheet.dart';
import 'widgets/studio_live_diagnostic_sheet.dart';
import 'widgets/studio_model_manager_sheet.dart';

/// Studio AI Hub Screen: Pusat kendali dan pilihan fitur AI Computer Vision Coffee Labs
/// Didesain dengan tema cerah premium khas Coffee Labs (Warm Cream & Espresso),
/// layout card compact, icon custom tematik, dan tanpa teks deskripsi yang panjang.
class StudioAiHubScreen extends ConsumerStatefulWidget {
  const StudioAiHubScreen({super.key});

  @override
  ConsumerState<StudioAiHubScreen> createState() => _StudioAiHubScreenState();
}

class _StudioAiHubScreenState extends ConsumerState<StudioAiHubScreen> {
  int _prototypeCount = 0;
  int _datasetCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTelemetry();
  }

  Future<void> _loadTelemetry() async {
    setState(() => _isLoading = true);
    try {
      await IncrementalVisionEngine.instance.initialize();
      await StudioDatabase.seedInitialClassesIfEmpty();

      final prototypes = await PrototypeDatabase.loadAllPrototypes();
      final images = await StudioDatabase.getAllImages();

      if (mounted) {
        setState(() {
          _prototypeCount = prototypes.length;
          _datasetCount = images.length;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgCream = Color(0xFFF9F6F0);
    const textDark = Color(0xFF2D1F17);
    const textMuted = Color(0xFF8F857D);

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        backgroundColor: bgCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.auto_awesome, color: Color(0xFFB45309), size: 16),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Studio AI',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Computer Vision & Transfer Learning',
                    style: TextStyle(color: textMuted, fontSize: 10.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Status',
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6B4423), size: 21),
            onPressed: _loadTelemetry,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTelemetry,
        color: const Color(0xFF6B4423),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compact Telemetry Banner
              _buildCompactTelemetryBanner(),
              const SizedBox(height: 16),

              // Section Header
              const Text(
                'PILIHAN FITUR STUDIO AI',
                style: TextStyle(
                  color: Color(0xFF9A7B4F),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),

              // Card 1: Latih Kemasan Kopi Baru (Few-Shot 3 Foto)
              _buildCompactFeatureCard(
                tag: '⚡ CEPAT',
                tagColor: const Color(0xFFD97706),
                icon: Icons.camera_enhance_rounded,
                iconColor: const Color(0xFFD97706),
                iconGradient: const [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
                title: 'Latih Kemasan Baru',
                subtitle: 'Foto 3 sudut kemasan & simpan profil seduh V60',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InAppBeanTrainerScreen(),
                    ),
                  ).then((_) => _loadTelemetry());
                },
              ),
              const SizedBox(height: 10),

              // Card 2: Roboflow Annotation Studio (Batch Auto-Labeler)
              _buildCompactFeatureCard(
                tag: '🤖 AUTO-LABEL',
                tagColor: const Color(0xFF7C3AED),
                icon: Icons.auto_awesome_motion_rounded,
                iconColor: const Color(0xFF7C3AED),
                iconGradient: const [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
                title: 'Roboflow Annotation Studio',
                subtitle: 'Batch anotasi foto, poligon RDP & ekstraksi OCR',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MobileDatasetKanbanScreen(),
                    ),
                  ).then((_) => _loadTelemetry());
                },
              ),
              const SizedBox(height: 10),

              // Card 3: Manajemen Model & NCM Prototipe
              _buildCompactFeatureCard(
                tag: 'NCM 1280-D',
                tagColor: const Color(0xFFB45309),
                icon: Icons.memory_rounded,
                iconColor: const Color(0xFFB45309),
                iconGradient: const [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                title: 'Manajemen Model & Prototipe',
                subtitle: 'Inspeksi prototipe SQLite & versi model continual',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const StudioModelManagerSheet(),
                  ).then((_) => _loadTelemetry());
                },
              ),
              const SizedBox(height: 10),

              // Card 4: Sinkronisasi Katalog Cloud Roastery
              _buildCompactFeatureCard(
                tag: 'NEONDB',
                tagColor: const Color(0xFF059669),
                icon: Icons.cloud_sync_rounded,
                iconColor: const Color(0xFF059669),
                iconGradient: const [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                title: 'Sinkronisasi Cloud Roastery',
                subtitle: 'Unduh & unggah katalog model via REST API',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const StudioCloudSyncSheet(),
                  ).then((_) => _loadTelemetry());
                },
              ),
              const SizedBox(height: 10),

              // Card 5: Uji Diagnostik Akurasi (Live Viewfinder)
              _buildCompactFeatureCard(
                tag: 'LIVE TEST',
                tagColor: const Color(0xFF0284C7),
                icon: Icons.center_focus_strong_rounded,
                iconColor: const Color(0xFF0284C7),
                iconGradient: const [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
                title: 'Uji Akurasi Viewfinder',
                subtitle: 'Live Cosine Similarity & deteksi kemasan kopi',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const StudioLiveDiagnosticSheet(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactTelemetryBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFE8DE), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5C3A21).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA5D6A7), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'MobileNetV4 NCM (1280-D)',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFE082), width: 0.8),
                ),
                child: const Text(
                  'On-Device AI',
                  style: TextStyle(
                    color: Color(0xFFB78103),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 4 Compact Stats in 1 row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8F4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF0EAE2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCompactStat(
                  icon: Icons.inventory_2_outlined,
                  color: const Color(0xFFB45309),
                  value: _isLoading ? '...' : '$_prototypeCount',
                  label: 'Class Model',
                ),
                _buildDivider(),
                _buildCompactStat(
                  icon: Icons.photo_library_outlined,
                  color: const Color(0xFFD97706),
                  value: _isLoading ? '...' : '$_datasetCount',
                  label: 'Foto Dataset',
                ),
                _buildDivider(),
                _buildCompactStat(
                  icon: Icons.bolt_rounded,
                  color: const Color(0xFF059669),
                  value: '< 12 ms',
                  label: 'Latensi NPU',
                ),
                _buildDivider(),
                _buildCompactStat(
                  icon: Icons.verified_user_outlined,
                  color: const Color(0xFF0284C7),
                  value: 'Aktif',
                  label: 'Gatekeeper',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF2D1F17),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8F857D),
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 22,
      color: const Color(0xFFE8DFD8),
    );
  }

  Widget _buildCompactFeatureCard({
    required String tag,
    required Color tagColor,
    required IconData icon,
    required Color iconColor,
    required List<Color> iconGradient,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEFE8DE), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5C3A21).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Custom Unique Squircle Icon Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: iconGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: iconColor.withValues(alpha: 0.22), width: 1),
                ),
                child: Icon(icon, color: iconColor, size: 21),
              ),
              const SizedBox(width: 12),

              // Title + Tag & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF2D1F17),
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: tagColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: tagColor,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF8F857D),
                        fontSize: 11,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Forward Arrow Circle
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F6F0),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEFE8DE)),
                ),
                child: const Icon(
                  CupertinoIcons.chevron_forward,
                  size: 13,
                  color: Color(0xFF8F857D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
