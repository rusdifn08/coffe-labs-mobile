import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../services/api_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/social_service.dart';
import '../../../../theme/app_theme.dart';
import 'social_recipe_attachment_card.dart';
import 'social_recipe_picker_sheet.dart';

class SocialCreatePostSheet extends StatefulWidget {
  final VoidCallback onPostCreated;

  const SocialCreatePostSheet({super.key, required this.onPostCreated});

  static Future<void> show(BuildContext context, {required VoidCallback onPostCreated}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SocialCreatePostSheet(onPostCreated: onPostCreated),
    );
  }

  @override
  State<SocialCreatePostSheet> createState() => _SocialCreatePostSheetState();
}

class _SocialCreatePostSheetState extends State<SocialCreatePostSheet> {
  final TextEditingController _contentCtrl = TextEditingController();
  List<dynamic> _availableRecipes = [];
  Map<String, dynamic>? _selectedRecipe;
  AuthUser? _currentUser;
  bool _isSubmitting = false;

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

  @override
  void initState() {
    super.initState();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tulis isi postingan terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Postingan berhasil dibagikan ke Social Coffee!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'Buat Postingan Baru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
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
                    border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
                  ),
                  child: TextField(
                    controller: _contentCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Bagikan pengalaman seduh, tips ekstraksi, racikan beans, atau diskusikan resep kopi Anda...',
                      hintStyle: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    maxLines: 5,
                    minLines: 3,
                    style: const TextStyle(fontSize: 13.5, height: 1.35),
                  ),
                ),
                const SizedBox(height: 16),

                // Interactive Recipe Attachment Section
                _buildRecipeAttachmentSection(),
                const SizedBox(height: 20),

                // Topic Tags
                const Text('Pilih Tag Topik:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _suggestedTags.map((tag) {
                    final selected = _selectedTags.contains(tag);
                    return ChoiceChip(
                      label: Text('#$tag', style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? Colors.white : AppTheme.textDark)),
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
              ],
            ),
          ),

          // Submit Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(CupertinoIcons.paperplane_fill, size: 18),
                label: const Text('Publikasikan ke Social Coffee', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    final username = _currentUser?.username ?? 'Barista';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : 'B';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primaryBrown,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
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
                  const Text(
                    'Membagikan ke Social Coffee',
                    style: TextStyle(
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
                    child: const Icon(CupertinoIcons.book_fill, color: AppTheme.primaryBrown, size: 20),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
