import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/moderation/content_moderation_guard.dart';
import '../../../../core/moderation/moderation_alert_banner.dart';
import '../../../../models/social_coffee.dart';
import '../../../../services/api_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/social_service.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/user_avatar_circle.dart';
import 'social_recipe_attachment_card.dart';
import 'social_recipe_picker_sheet.dart';

class SocialCreatePostSheet extends StatefulWidget {
  final VoidCallback onPostCreated;
  final SocialPost? editingPost;
  final ValueChanged<SocialPost>? onPostUpdated;

  const SocialCreatePostSheet({
    super.key,
    required this.onPostCreated,
    this.editingPost,
    this.onPostUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onPostCreated,
    SocialPost? editingPost,
    ValueChanged<SocialPost>? onPostUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SocialCreatePostSheet(
        onPostCreated: onPostCreated,
        editingPost: editingPost,
        onPostUpdated: onPostUpdated,
      ),
    );
  }

  @override
  State<SocialCreatePostSheet> createState() => _SocialCreatePostSheetState();
}

class _SocialCreatePostSheetState extends State<SocialCreatePostSheet> {
  static const int _maxLength = 4000;

  final TextEditingController _contentCtrl = TextEditingController();
  List<dynamic> _availableRecipes = [];
  Map<String, dynamic>? _selectedRecipe;
  AuthUser? _currentUser;
  bool _isSubmitting = false;
  String? _moderationWarning;

  final List<String> _suggestedTags = [
    'V60',
    'Aeropress',
    'Origami',
    'JapaneseIced',
    'GayoWine',
    'Kintamani',
    'Sweetness',
    'ManualBrew',
    'Espresso',
  ];
  final Set<String> _selectedTags = {};

  bool get _isEditing => widget.editingPost != null;

  @override
  void initState() {
    super.initState();
    final edit = widget.editingPost;
    if (edit != null) {
      _contentCtrl.text = edit.content;
      _selectedTags.addAll(edit.tags.map((t) => t.replaceFirst('#', '')));
      if (edit.recipeSnapshot != null) {
        _selectedRecipe = Map<String, dynamic>.from(edit.recipeSnapshot!);
      }
    }
    _loadData();
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final list = await ApiService.getRecipes();
    final user = await AuthService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _availableRecipes = list;
      _currentUser = user;
    });
  }

  Future<void> _openRecipePicker() async {
    final picked = await SocialRecipePickerSheet.show(
      context,
      allRecipes: _availableRecipes,
      selectedRecipeId: _selectedRecipe?['id'] as int?,
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedRecipe = picked;
      });
    }
  }

  Future<void> _submitPost() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Tulis isi postingan terlebih dahulu'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    // 1. Cek moderasi kata terlarang + status auto-ban 3x pelanggaran
    final verdict = await ContentModerationGuard.inspectAndEnforce({
      'Postingan': content,
      if (_selectedTags.isNotEmpty) 'Tagar': _selectedTags.join(' '),
    });
    if (!mounted) return;
    if (!verdict.isAllowed) {
      setState(() => _moderationWarning = verdict.userMessage);
      await ModerationAlertFeedback.showViolationDialog(
        context,
        verdict,
        banStatus: verdict.banStatus,
      );
      return;
    }

    setState(() {
      _moderationWarning = null;
      _isSubmitting = true;
    });

    Map<String, dynamic>? snap;
    if (_selectedRecipe != null) {
      snap = {
        'id': _selectedRecipe!['id'],
        'title': _selectedRecipe!['title'],
        'author': _selectedRecipe!['author'],
        'method': _selectedRecipe!['method'],
        'category': _selectedRecipe!['category'],
        'beanName': _selectedRecipe!['beanName'],
        'variety': _selectedRecipe!['variety'],
        'process': _selectedRecipe!['process'],
        'waterTempCelsius': _selectedRecipe!['waterTempCelsius'],
        'grindSize': _selectedRecipe!['grindSize'],
        'coffeeWeightGrams': _selectedRecipe!['coffeeWeightGrams'],
        'totalWaterWeightGrams': _selectedRecipe!['totalWaterWeightGrams'],
        'tastingNotes': _selectedRecipe!['tastingNotes'],
        'steps': _selectedRecipe!['steps'],
        'description': _selectedRecipe!['description'],
        'isCustom': _selectedRecipe!['isCustom'] == true,
      };
    }

    try {
      if (_isEditing) {
        final updated = await SocialService.updatePost(
          post: widget.editingPost!,
          content: content,
          recipeSnapshot: snap,
          tags: _selectedTags.toList(),
        );
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        if (updated != null) {
          Navigator.pop(context);
          widget.onPostUpdated?.call(updated);
          widget.onPostCreated();
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              const SnackBar(
                content: Text('Postingan berhasil diperbarui!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      } else {
        final post = await SocialService.createPost(
          content: content,
          recipeSnapshot: snap,
          tags: _selectedTags.toList(),
        );

        if (!mounted) return;
        setState(() => _isSubmitting = false);

        if (post != null) {
          Navigator.pop(context);
          widget.onPostCreated();
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              const SnackBar(
                content: Text('Postingan berhasil dibagikan ke Social Coffee!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      }
    } on ContentModerationException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _moderationWarning = e.verdict.userMessage;
      });
      await ModerationAlertFeedback.showViolationDialog(
        context,
        e.verdict,
        banStatus: e.banStatus ?? e.verdict.banStatus,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? 'Edit Postingan' : 'Buat Postingan Baru',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: AppTheme.textMuted,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),

          // User info header
          _buildUserHeader(),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                // Post text input
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCream.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _moderationWarning != null
                          ? const Color(0xFFDC2626)
                          : AppTheme.primaryBrown.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextField(
                        controller: _contentCtrl,
                        maxLength: _maxLength,
                        onChanged: (_) {
                          setState(() {
                            if (_moderationWarning != null) {
                              _moderationWarning = null;
                            }
                          });
                        },
                        decoration: const InputDecoration(
                          hintText:
                              'Bagikan pengalaman seduh, tips ekstraksi, racikan beans, atau diskusikan resep kopi Anda...',
                          hintStyle:
                              TextStyle(fontSize: 13, color: AppTheme.textMuted),
                          border: InputBorder.none,
                          counterText: '',
                          isDense: true,
                        ),
                        maxLines: 6,
                        minLines: 3,
                        style: const TextStyle(fontSize: 13.5, height: 1.38),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_contentCtrl.text.length}/$_maxLength',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_moderationWarning != null)
                  ModerationInlineWarningBanner(message: _moderationWarning!),
                const SizedBox(height: 16),

                // Interactive Recipe Attachment Section
                _buildRecipeAttachmentSection(),
                const SizedBox(height: 20),

                // Topic Tags
                const Text(
                  'Pilih Tag Topik:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _suggestedTags.map((tag) {
                    final selected = _selectedTags.contains(tag);
                    return ChoiceChip(
                      label: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal,
                          color: selected ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                      selected: selected,
                      selectedColor: AppTheme.primaryBrown,
                      backgroundColor: AppTheme.bgCream,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Icon(
                      CupertinoIcons.shield_fill,
                      size: 13,
                      color: AppTheme.textMuted,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Moderasi Bahasa Aktif: kata kasar, SARA, atau spam judi diblokir otomatis.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Submit Button
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset * 0.2),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _isEditing
                            ? CupertinoIcons.checkmark_alt_circle_fill
                            : CupertinoIcons.paperplane_fill,
                        size: 18,
                      ),
                label: Text(
                  _isEditing
                      ? 'Simpan Perubahan'
                      : 'Publikasikan ke Social Coffee',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    final username =
        _currentUser?.username ?? widget.editingPost?.authorName ?? 'Barista';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          UserAvatarCircle(
            avatarUrl:
                _currentUser?.avatarUrl ?? widget.editingPost?.authorAvatar,
            displayName: username,
            radius: 18,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isEditing
                        ? 'Mengedit postingan Social Coffee'
                        : 'Membagikan ke Social Coffee',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeAttachmentSection() {
    if (_selectedRecipe == null) {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCream.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryBrown.withValues(alpha: 0.15),
            width: 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _openRecipePicker,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.book_fill,
                      color: AppTheme.primaryBrown,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lampirkan Resep Seduh',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pilih dari 140+ World Recipe atau Resep Kustom Anda',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.plus, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Pilih Resep',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SocialRecipeAttachmentCard(
      recipe: _selectedRecipe!,
      onSelectOther: _openRecipePicker,
      onRemove: () => setState(() => _selectedRecipe = null),
    );
  }
}
