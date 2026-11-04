import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../screens/brew_journal_screen.dart';
import '../../../../theme/app_theme.dart';

class CuppingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onOpenBeanCatalog;
  final VoidCallback onOpenVarietyModal;
  final VoidCallback onResetForm;
  final VoidCallback onLoadDemo;

  const CuppingAppBar({
    super.key,
    required this.onOpenBeanCatalog,
    required this.onOpenVarietyModal,
    required this.onResetForm,
    required this.onLoadDemo,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Coffee Cupping & Flavor Wheel'),
      centerTitle: true,
      backgroundColor: AppTheme.primaryBrown,
      foregroundColor: Colors.white,
      elevation: 1,
      actions: [
        IconButton(
          tooltip: 'Pilih Biji dari Katalog',
          icon: const Icon(Icons.coffee_rounded, color: Colors.white),
          onPressed: onOpenBeanCatalog,
        ),
        IconButton(
          tooltip: 'Katalog Varietas Lengkap',
          icon: const Icon(Icons.eco_rounded, color: Colors.white),
          onPressed: onOpenVarietyModal,
        ),
        PopupMenuButton<String>(
          tooltip: 'Opsi Lembar Cupping',
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (val) {
            if (val == 'reset') {
              onResetForm();
            } else if (val == 'demo') {
              onLoadDemo();
            } else if (val == 'journal') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrewJournalScreen()),
              );
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'demo',
              child: Row(
                children: [
                  Icon(CupertinoIcons.sparkles, size: 16, color: AppTheme.accentAmber),
                  SizedBox(width: 8),
                  Text('Muat Contoh Demo (90.75)'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'reset',
              child: Row(
                children: [
                  Icon(CupertinoIcons.arrow_counterclockwise, size: 16, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text('Reset / Formulir Baru'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'journal',
              child: Row(
                children: [
                  Icon(CupertinoIcons.book_fill, size: 16, color: AppTheme.primaryBrown),
                  SizedBox(width: 8),
                  Text('Buka Brew Journal'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
