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
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.only(top: 16, left: 18, right: 18, bottom: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1F1813), // Warm Dark Roast
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manajemen Model & Prototipe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'MobileNetV4 (1280-D) Continual Learning Memory',
                    style: TextStyle(color: Color(0xFFD4A373), fontSize: 11),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFFD4A373)),
                onPressed: _loadPrototypes,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Overview banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF281E17),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF3D2D22)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC86D51).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.memory, color: Color(0xFFC86D51), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_prototypes.length} Class Kemasan Terdaftar',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Zero Catastrophic Forgetting • Running Average Centroid',
                        style: TextStyle(color: Colors.white60, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // List of Prototypes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4A373)))
                : _prototypes.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada model terlatih di SQLite.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _prototypes.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final p = _prototypes[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF261D16),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF3B2D24)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Color(0xFFD4AF37),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.classSlug,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${p.roastery} • ${p.process} • ${p.sampleCount} sampel',
                                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                                      ),
                                      if (p.tastingNotes.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          p.tastingNotes.take(3).join(', '),
                                          style: const TextStyle(
                                            color: Color(0xFFD4A373),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFF10B981), width: 0.8),
                                  ),
                                  child: const Text(
                                    '1280-D Active',
                                    style: TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 12),

          // Bottom Action: Train Version Stepper
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A373),
                foregroundColor: const Color(0xFF12100E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.tune, size: 18),
              label: const Text(
                'Latih Versi NCM Baru (5-Step Stepper)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
