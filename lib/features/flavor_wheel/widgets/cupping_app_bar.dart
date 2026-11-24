import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../screens/brew_journal_screen.dart';
import '../../../../theme/app_theme.dart';

/// Clean Coffee Labs light-theme AppBar for SCA Cupping with crisp contrast
/// and zero overflow on narrow mobile screens.
class CuppingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onOpenBeanCatalog;
  final VoidCallback onOpenVarietyModal;
  final VoidCallback onResetForm;
  final VoidCallback onLoadDemo;
  final PreferredSizeWidget? bottom;

  const CuppingAppBar({
    super.key,
    required this.onOpenBeanCatalog,
    required this.onOpenVarietyModal,
    required this.onResetForm,
    required this.onLoadDemo,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.bgCream,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppTheme.textDark,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      title: const Row(
        children: [
          Icon(Icons.coffee_rounded, color: AppTheme.primaryBrown, size: 19),
          SizedBox(width: 7),
          Flexible(
            child: Text(
              'SCA Cupping Lab',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Pilih Biji dari Katalog',
          icon: const Icon(
            Icons.coffee_rounded,
            color: AppTheme.primaryBrown,
            size: 20,
          ),
          onPressed: onOpenBeanCatalog,
        ),
        IconButton(
          tooltip: 'Pilih Varietas (Multi-Select)',
          icon: const Icon(
            Icons.eco_rounded,
            color: Color(0xFF2E7D32),
            size: 20,
          ),
          onPressed: onOpenVarietyModal,
        ),
        PopupMenuButton<String>(
          tooltip: 'Opsi Lembar Cupping',
          icon: const Icon(Icons.more_vert, color: AppTheme.textDark, size: 20),
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
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'demo',
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.sparkles,
                    size: 16,
                    color: AppTheme.accentAmber,
                  ),
                  SizedBox(width: 8),
                  Text('Muat Contoh Demo (91.25)'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'reset',
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.arrow_counterclockwise,
                    size: 16,
                    color: Colors.redAccent,
                  ),
                  SizedBox(width: 8),
                  Text('Reset / Formulir Baru'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'journal',
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.book_fill,
                    size: 16,
                    color: AppTheme.primaryBrown,
                  ),
                  SizedBox(width: 8),
                  Text('Buka Brew Journal'),
                ],
              ),
            ),
          ],
        ),
      ],
      bottom: bottom,
    );
  }
}
