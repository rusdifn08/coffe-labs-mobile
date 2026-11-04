import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../services/language_service.dart';
import '../../../theme/app_theme.dart';

class LanguageSelectorDialog {
  static void show(
    BuildContext context, {
    required String selectedLanguage,
    required ValueChanged<String> onLanguageSelected,
  }) {
    final isEn = LanguageService.isEnglish;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(CupertinoIcons.globe, color: AppTheme.primaryBrown, size: 24),
            SizedBox(width: 10),
            Text('Pilih Bahasa / Language', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                await LanguageService.setLanguage('en');
                onLanguageSelected('en');
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Language set to English (Default).'), backgroundColor: AppTheme.primaryBrown),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: selectedLanguage == 'en' ? AppTheme.primaryBrown.withValues(alpha: 0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selectedLanguage == 'en' ? AppTheme.primaryBrown : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🇬🇧', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('English', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              SizedBox(width: 6),
                              Text('(Default)', style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 2),
                          Text('Interface stays in English', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                    if (selectedLanguage == 'en')
                      const Icon(CupertinoIcons.checkmark_circle_fill, color: AppTheme.primaryBrown, size: 20)
                    else
                      Icon(CupertinoIcons.circle, color: Colors.grey.shade400, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                await LanguageService.setLanguage('id');
                onLanguageSelected('id');
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bahasa diubah ke Bahasa Indonesia.'), backgroundColor: AppTheme.primaryBrown),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: selectedLanguage == 'id' ? AppTheme.primaryBrown.withValues(alpha: 0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selectedLanguage == 'id' ? AppTheme.primaryBrown : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🇮🇩', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bahasa Indonesia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(height: 2),
                          Text('Antarmuka dalam Bahasa Indonesia', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                    if (selectedLanguage == 'id')
                      const Icon(CupertinoIcons.checkmark_circle_fill, color: AppTheme.primaryBrown, size: 20)
                    else
                      Icon(CupertinoIcons.circle, color: Colors.grey.shade400, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isEn ? 'Close' : 'Tutup', style: const TextStyle(color: AppTheme.primaryBrown)),
          ),
        ],
      ),
    );
  }
}
