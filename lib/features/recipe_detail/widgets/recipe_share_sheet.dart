import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../services/recipe_share_service.dart';
import 'recipe_share_card.dart';

/// Bottom sheet profesional untuk membagikan resep ke WhatsApp, Instagram,
/// Threads, dan media sosial lain lengkap dengan visual card + link `brewingcoffee.vercel.app`.
class RecipeShareSheet extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeShareSheet({super.key, required this.recipe});

  static Future<void> show(BuildContext context, Map<String, dynamic> recipe) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecipeShareSheet(recipe: recipe),
    );
  }

  @override
  State<RecipeShareSheet> createState() => _RecipeShareSheetState();
}

class _RecipeShareSheetState extends State<RecipeShareSheet> {
  final GlobalKey _posterKey = GlobalKey();
  bool _busy = false;

  void _showFeedback(String message, {bool isSuccess = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppTheme.primaryBrown : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _runShareAction(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = RecipeShareService.summarize(widget.recipe);
    final maxH = MediaQuery.of(context).size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: const BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderWarm,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bagikan Resep Presisi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Poster visual + tautan langsung ke Coffee Labs',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Visual Poster Preview (FittedBox prevents overflow on 375px screens)
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RepaintBoundary(
                    key: _posterKey,
                    child: RecipeShareCard(recipe: widget.recipe),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Landing Page Link Copy Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderWarm),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentAmber.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        CupertinoIcons.link,
                        size: 14,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Link Landing Page Resep',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          Text(
                            summary.shareUrl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await RecipeShareService.copyShareLink(widget.recipe);
                        _showFeedback(
                          'Link brewingcoffee.vercel.app disalin!',
                        );
                      },
                      icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 14),
                      label: const Text('Salin', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryBrown,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Social Channels Title
              const Text(
                'Pilih Platform Sosial Media',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),

              // 2x2 Social Channel Cards
              Row(
                children: [
                  Expanded(
                    child: _buildChannelButton(
                      label: 'WhatsApp',
                      subtitle: 'Teks + Link Web',
                      icon: CupertinoIcons.chat_bubble_text_fill,
                      color: const Color(0xFF1FA855),
                      onTap: () => _runShareAction(() async {
                        await RecipeShareService.shareToWhatsApp(
                          widget.recipe,
                          posterKey: _posterKey,
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildChannelButton(
                      label: 'Instagram',
                      subtitle: 'Poster PNG + Caption',
                      icon: CupertinoIcons.camera_fill,
                      color: const Color(0xFFE1306C),
                      onTap: () => _runShareAction(() async {
                        await RecipeShareService.shareToInstagram(
                          widget.recipe,
                          posterKey: _posterKey,
                        );
                        _showFeedback(
                          'Caption IG disalin & poster siap dibagikan!',
                        );
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildChannelButton(
                      label: 'Threads',
                      subtitle: 'Utas + Hashtag',
                      icon: CupertinoIcons.at,
                      color: const Color(0xFF1F1F1F),
                      onTap: () => _runShareAction(() async {
                        await RecipeShareService.shareToThreads(
                          widget.recipe,
                          posterKey: _posterKey,
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildChannelButton(
                      label: 'Sosmed Lain',
                      subtitle: 'Poster + Teks Penuh',
                      icon: CupertinoIcons.share,
                      color: AppTheme.primaryBrown,
                      onTap: () => _runShareAction(() async {
                        await RecipeShareService.sharePosterAndLink(
                          widget.recipe,
                          posterKey: _posterKey,
                        );
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Full Copy Button
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () async {
                        await RecipeShareService.copyFormattedRecipe(
                          widget.recipe,
                        );
                        _showFeedback(
                          'Format resep lengkap + link Coffee Labs disalin!',
                        );
                      },
                icon: const Icon(CupertinoIcons.doc_on_doc, size: 16),
                label: const Text(
                  'Salin Format Teks & Link Coffee Labs',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryBrown,
                  side: const BorderSide(color: AppTheme.borderWarm),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _busy ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
