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
    if (widget.existingClasses.isEmpty) return [];

    final matches = <MapEntry<CoffeeAnnotationClass, double>>[];
    for (final cls in widget.existingClasses) {
      final sim = _computeSimilarity(_previewSlug, cls.classSlug);
      matches.add(MapEntry(cls, sim));
    }

    matches.sort((a, b) => b.value.compareTo(a.value));
    return matches.take(4).toList();
  }

  double _computeSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    int matches = 0;
    final maxLen = math.max(s1.length, s2.length);
    final minLen = math.min(s1.length, s2.length);

    for (int i = 0; i < minLen; i++) {
      if (s1[i] == s2[i]) matches++;
    }

    if (s1.contains(s2) || s2.contains(s1)) {
      return (matches / maxLen * 0.5) + 0.5;
    }

    return matches / maxLen;
  }

  @override
  Widget build(BuildContext context) {
    const bgCream = Color(0xFFF9F6F0);
    const textDark = Color(0xFF2D1F17);
    const textMuted = Color(0xFF8F857D);

    final topMatches = _getTopMatchingClasses();
    final bool hasExactMatch = topMatches.isNotEmpty && topMatches.first.value >= 0.85;
    final matchedClass = hasExactMatch ? topMatches.first.key : null;

    return Container(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
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
                const Text(
                  'Smart OCR Class Parser',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Status Badge
                if (hasExactMatch)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      border: Border.all(color: const Color(0xFF3B82F6)),
                      borderRadius: BorderRadius.circular(10),
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
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      border: Border.all(color: const Color(0xFF10B981)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '✨ NEW OCR CLASS',
                      style: TextStyle(
                        color: Color(0xFF047857),
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'Format Baku: {brand}_{nama_kopi}_{proses}',
              style: TextStyle(color: textMuted, fontSize: 11),
            ),
            const SizedBox(height: 14),

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
            const SizedBox(height: 12),

            // Live Preview Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFEFE8DE), width: 1.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 13, color: Color(0xFFB45309)),
                      SizedBox(width: 5),
                      Text(
                        'Generated Semantic Class Slug:',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _previewSlug,
                    style: const TextStyle(
                      color: Color(0xFFB45309),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Quick-Select Matching Chips
            if (topMatches.isNotEmpty) ...[
              const Text(
                'Class Terdaftar Terdekat:',
                style: TextStyle(
                  color: textDark,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: topMatches.map((entry) {
                  final cls = entry.key;
                  final simPercent = (entry.value * 100).toStringAsFixed(0);
                  final isSelected = cls.classSlug == _previewSlug;

                  return ActionChip(
                    backgroundColor: isSelected ? const Color(0xFF6B4423) : Colors.white,
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF6B4423) : const Color(0xFFEFE8DE),
                    ),
                    label: Text(
                      '${cls.classSlug} ($simPercent%)',
                      style: TextStyle(
                        color: isSelected ? Colors.white : textDark,
                        fontSize: 10.5,
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
              const SizedBox(height: 16),
            ],

            // Main Action Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasExactMatch ? const Color(0xFF2563EB) : const Color(0xFF6B4423),
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
                      ? '✓ Gunakan Class: "${matchedClass?.classSlug ?? _previewSlug}"'
                      : '✨ Simpan Class Baru: "$_previewSlug"',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
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
    const textDark = Color(0xFF2D1F17);
    const textMuted = Color(0xFF8F857D);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(color: textDark, fontSize: 12),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26, fontSize: 12),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEFE8DE)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEFE8DE)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6B4423), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
