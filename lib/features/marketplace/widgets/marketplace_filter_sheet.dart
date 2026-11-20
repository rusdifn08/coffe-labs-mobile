import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class MarketplaceFilterSheet extends StatefulWidget {
  final String initialRoast;
  final String initialProcess;

  const MarketplaceFilterSheet({
    super.key,
    required this.initialRoast,
    required this.initialProcess,
  });

  static Future<({String roast, String process})?> show(
    BuildContext context, {
    required String initialRoast,
    required String initialProcess,
  }) {
    return showModalBottomSheet<({String roast, String process})>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => MarketplaceFilterSheet(
        initialRoast: initialRoast,
        initialProcess: initialProcess,
      ),
    );
  }

  @override
  State<MarketplaceFilterSheet> createState() => _MarketplaceFilterSheetState();
}

class _MarketplaceFilterSheetState extends State<MarketplaceFilterSheet> {
  late String _roast;
  late String _process;

  static const _roastList = [
    'All',
    'Light',
    'Medium',
    'Medium-Dark',
    'Dark',
  ];

  static const _processList = [
    'All',
    'Washed',
    'Natural',
    'Honey',
    'Anaerobic',
    'Carbonic',
  ];

  @override
  void initState() {
    super.initState();
    _roast = widget.initialRoast;
    _process = widget.initialProcess;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD6CBBF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(CupertinoIcons.slider_horizontal_3,
                  size: 18, color: AppTheme.primaryBrown),
              const SizedBox(width: 8),
              const Text(
                'Filter Produk Kopi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _roast = 'All';
                    _process = 'All';
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Tingkat Sangrai (Roast Level)',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _roastList.map((r) {
              final active = _roast == r;
              return ChoiceChip(
                label: Text(r == 'All' ? 'Semua' : r),
                selected: active,
                onSelected: (_) => setState(() => _roast = r),
                selectedColor: const Color(0xFFEA580C),
                backgroundColor: const Color(0xFFF6F4F0),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : AppTheme.textDark,
                ),
                side: BorderSide.none,
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          const Text(
            'Proses Pasca Panen',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _processList.map((p) {
              final active = _process == p;
              return ChoiceChip(
                label: Text(p == 'All' ? 'Semua' : p),
                selected: active,
                onSelected: (_) => setState(() => _process = p),
                selectedColor: AppTheme.primaryBrown,
                backgroundColor: const Color(0xFFF6F4F0),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : AppTheme.textDark,
                ),
                side: BorderSide.none,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, (roast: _roast, process: _process)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA580C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Terapkan Filter',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
