import 'package:flutter/material.dart';
import 'package:coffee_hub_mobile/features/scanner/data/local/prototype_database.dart';
import '../mobile_versions_and_train_stepper_screen.dart';

class StudioModelManagerSheet extends StatefulWidget {
  const StudioModelManagerSheet({super.key});

  @override
  State<StudioModelManagerSheet> createState() => _StudioModelManagerSheetState();
}

class _StudioModelManagerSheetState extends State<StudioModelManagerSheet> {
  List<CoffeePrototypeRecord> _prototypes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrototypes();
  }

  Future<void> _loadPrototypes() async {
    setState(() => _isLoading = true);
    try {
      await PrototypeDatabase.seedInitialClassesIfEmpty();
      final list = await PrototypeDatabase.loadAllPrototypes();
      setState(() {
        _prototypes = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgCream = Color(0xFFF9F6F0);
    const textDark = Color(0xFF2D1F17);
    const textMuted = Color(0xFF8F857D);

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      padding: const EdgeInsets.only(top: 14, left: 16, right: 16, bottom: 20),
      decoration: const BoxDecoration(
        color: bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD8CFBE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manajemen Model & NCM',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'MobileNetV4 1280-D • Memori Prototipe SQLite',
                    style: TextStyle(color: textMuted, fontSize: 11),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6B4423)),
                onPressed: _loadPrototypes,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Overview banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEFE8DE), width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.memory_rounded, color: Color(0xFFB45309), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_prototypes.length} Class Kemasan Terdaftar',
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Zero Catastrophic Forgetting • Centroid NCM Running Average',
                        style: TextStyle(color: textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // List of Prototypes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B4423)))
                : _prototypes.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada model terlatih di SQLite.',
                          style: TextStyle(color: textMuted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _prototypes.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final p = _prototypes[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFEFE8DE), width: 1.1),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF5C3A21).withValues(alpha: 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF7ED),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFFFD8A8), width: 1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Color(0xFFD97706),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.classSlug,
                                        style: const TextStyle(
                                          color: textDark,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        '${p.roastery} • ${p.process} • ${p.sampleCount} sampel',
                                        style: const TextStyle(color: textMuted, fontSize: 10.5),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (p.tastingNotes.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          p.tastingNotes.take(3).join(', '),
                                          style: const TextStyle(
                                            color: Color(0xFFB45309),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFA5D6A7), width: 0.8),
                                  ),
                                  child: const Text(
                                    '1280-D Active',
                                    style: TextStyle(color: Color(0xFF2E7D32), fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 10),

          // Bottom Action: Train Version Stepper
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B4423),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.tune_rounded, size: 16),
              label: const Text(
                'Latih Versi NCM Baru (5-Step Stepper)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MobileVersionsAndTrainStepperScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
