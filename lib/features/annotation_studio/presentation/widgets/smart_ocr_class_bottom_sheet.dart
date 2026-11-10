import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/coffee_annotation_class.dart';
import '../../domain/services/coffee_ocr_parser_service.dart';

class SmartOcrClassBottomSheet extends StatefulWidget {
  final CoffeeOcrResult ocrResult;
  final List<CoffeeAnnotationClass> existingClasses;
  final void Function({
    required String classSlug,
    required String brand,
    required String coffeeName,
    required String process,
    required bool isNewClass,
  }) onConfirm;

  const SmartOcrClassBottomSheet({
    super.key,
    required this.ocrResult,
    required this.existingClasses,
    required this.onConfirm,
  });

  @override
  State<SmartOcrClassBottomSheet> createState() => _SmartOcrClassBottomSheetState();
}

class _SmartOcrClassBottomSheetState extends State<SmartOcrClassBottomSheet> {
  late final TextEditingController _brandCtrl;
  late final TextEditingController _coffeeCtrl;
  late final TextEditingController _processCtrl;
  String _previewSlug = '';

  @override
  void initState() {
    super.initState();
    _brandCtrl = TextEditingController(text: widget.ocrResult.brand);
    _coffeeCtrl = TextEditingController(text: widget.ocrResult.coffeeName);
    _processCtrl = TextEditingController(text: widget.ocrResult.process);
    _updateSlug();

    _brandCtrl.addListener(_updateSlug);
    _coffeeCtrl.addListener(_updateSlug);
    _processCtrl.addListener(_updateSlug);
  }

  @override
  void dispose() {
    _brandCtrl.dispose();
    _coffeeCtrl.dispose();
    _processCtrl.dispose();
    super.dispose();
  }

  void _updateSlug() {
    final b = _cleanToken(_brandCtrl.text);
    final c = _cleanToken(_coffeeCtrl.text);
    final p = _cleanToken(_processCtrl.text);

    final parts = [b, c, p].where((x) => x.isNotEmpty).toList();
    setState(() {
      _previewSlug = parts.isNotEmpty ? parts.join('_') : 'unlabeled_coffee';
    });
  }

  String _cleanToken(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();
  }

  List<MapEntry<CoffeeAnnotationClass, double>> _getTopMatchingClasses() {
    final matches = <MapEntry<CoffeeAnnotationClass, double>>[];
    final currentSlug = _previewSlug;

    for (final cls in widget.existingClasses) {
      final sim = _computeSimilarity(currentSlug, cls.classSlug);
      matches.add(MapEntry(cls, sim));
    }

    matches.sort((a, b) => b.value.compareTo(a.value));
    return matches.take(4).toList();
  }

  double _computeSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    final int dist = _levenshtein(s1, s2);
    final seqSim = 1.0 - (dist / math.max(s1.length, s2.length));
    final t1 = s1.split('_').toSet();
    final t2 = s2.split('_').toSet();
    final union = t1.union(t2).length;
    final jaccard = union == 0 ? 0.0 : t1.intersection(t2).length / union;
    return (0.65 * seqSim) + (0.35 * jaccard);
  }

  int _levenshtein(String a, String b) {
    final List<List<int>> dp = List.generate(
      a.length + 1,
      (_) => List<int>.filled(b.length + 1, 0),
    );
    for (int i = 0; i <= a.length; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= b.length; j++) {
      dp[0][j] = j;
    }
    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce(math.min);
      }
    }
    return dp[a.length][b.length];
  }

  @override
  Widget build(BuildContext context) {
    final topMatches = _getTopMatchingClasses();
    final bool hasExactMatch = topMatches.isNotEmpty && topMatches.first.value >= 0.85;
    final matchedClass = hasExactMatch ? topMatches.first.key : null;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF161B26),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle & Title
            Center(
              child: Container(
                width: 48,
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
                const Text(
                  'Smart OCR Class Parser',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Status Badge
                if (hasExactMatch)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      border: Border.all(color: const Color(0xFF3B82F6)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, size: 12, color: Color(0xFF1D4ED8)),
                        const SizedBox(width: 4),
                        Text(
                          '✓ MATCHED (${(topMatches.first.value * 100).toStringAsFixed(0)}%)',
                          style: const TextStyle(
                            color: Color(0xFF1D4ED8),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      border: Border.all(color: const Color(0xFF10B981)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '✨ NEW OCR CLASS',
                      style: TextStyle(
                        color: Color(0xFF047857),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Format Baku: {brand}_{nama_kopi}_{proses}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
            ),
            const SizedBox(height: 16),

            // 3 Quick TextFields
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Brand / Roastery',
                    hint: 'fugol',
                    controller: _brandCtrl,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    label: 'Nama Kopi',
                    hint: 'halubanana',
                    controller: _coffeeCtrl,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    label: 'Proses Pascapanen',
                    hint: 'wine',
                    controller: _processCtrl,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Live Preview Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0F19),
                border: Border.all(color: const Color(0xFF6D28D9).withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 14, color: Color(0xFFD4A373)),
                      const SizedBox(width: 6),
                      Text(
                        'Generated Semantic Class Slug:',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _previewSlug,
                    style: const TextStyle(
                      color: Color(0xFFD4A373),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick-Select Matching Chips
            if (topMatches.isNotEmpty) ...[
              Text(
                'Class Terdaftar Terdekat (${topMatches.length}):',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: topMatches.map((entry) {
                  final cls = entry.key;
                  final simPercent = (entry.value * 100).toStringAsFixed(0);
                  final isSelected = cls.classSlug == _previewSlug;

                  return ActionChip(
                    backgroundColor: isSelected ? const Color(0xFF6D28D9) : const Color(0xFF1F2937),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFD4A373) : Colors.white12,
                    ),
                    label: Text(
                      '${cls.classSlug} ($simPercent%)',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onPressed: () {
                      _brandCtrl.text = cls.brand;
                      _coffeeCtrl.text = cls.coffeeName;
                      _processCtrl.text = cls.process;
                      setState(() {
                        _previewSlug = cls.classSlug;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Main Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasExactMatch ? const Color(0xFF2563EB) : const Color(0xFF6D28D9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  final b = _cleanToken(_brandCtrl.text);
                  final c = _cleanToken(_coffeeCtrl.text);
                  final p = _cleanToken(_processCtrl.text);

                  widget.onConfirm(
                    classSlug: _previewSlug,
                    brand: b.isNotEmpty ? b : 'unknownbrand',
                    coffeeName: c.isNotEmpty ? c : 'unknowncoffee',
                    process: p.isNotEmpty ? p : 'standard',
                    isNewClass: !hasExactMatch,
                  );
                  Navigator.of(context).pop();
                },
                child: Text(
                  hasExactMatch
                      ? '✓ Gunakan Class Terdaftar: "${matchedClass?.classSlug ?? _previewSlug}"'
                      : '✨ Gunakan & Tambah Class Baru: "$_previewSlug"',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
            filled: true,
            fillColor: const Color(0xFF0B0F19),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6D28D9), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
