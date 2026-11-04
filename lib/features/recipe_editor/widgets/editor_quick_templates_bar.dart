import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class EditorQuickTemplatesBar extends StatelessWidget {
  final ValueChanged<String> onSelectTemplate;

  const EditorQuickTemplatesBar({
    super.key,
    required this.onSelectTemplate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            '1. Gunakan Template Cepat (Opsional)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _templateChip('V60 3-Pour', CupertinoIcons.drop_fill, () => onSelectTemplate('v60_3pour')),
              const SizedBox(width: 8),
              _templateChip('Japanese Iced (Es)', CupertinoIcons.snow, () => onSelectTemplate('japanese_iced')),
              const SizedBox(width: 8),
              _templateChip('Full Immersion', CupertinoIcons.timer_fill, () => onSelectTemplate('immersion')),
              const SizedBox(width: 8),
              _templateChip('Hybrid Switch', CupertinoIcons.lab_flask_solid, () => onSelectTemplate('hybrid_switch')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _templateChip(String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 15, color: AppTheme.primaryBrown),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      backgroundColor: AppTheme.surfaceWhite,
      side: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
      onPressed: onTap,
    );
  }
}
