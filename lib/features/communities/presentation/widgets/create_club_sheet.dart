import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../controllers/communities_controllers.dart';

class CreateClubSheet extends ConsumerStatefulWidget {
  const CreateClubSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateClubSheet(),
    );
  }

  @override
  ConsumerState<CreateClubSheet> createState() => _CreateClubSheetState();
}

class _CreateClubSheetState extends ConsumerState<CreateClubSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _privacyLevel = 'PUBLIC';
  final Set<String> _selectedTags = {'V60'};
  bool _submitting = false;
  String? _error;

  static const _tagChoices = [
    'V60',
    'Espresso',
    'Ethiopia',
    'Colombia',
    'Gayo',
    'Natural',
    'Washed',
    'Light Roast',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.length < 3) {
      setState(() => _error = 'Nama Coffee Club minimal 3 karakter.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final workspace = await ref.read(communitiesApiProvider).createCommunity(
            name: name,
            description: _descController.text.trim(),
            privacyLevel: _privacyLevel,
            focusTags: _selectedTags.toList(),
          );
      ref.invalidate(exploreCommunitiesControllerProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      context.push('/social/clubs/${workspace.community.id}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.bgCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderWarm,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Dirikan Coffee Club Baru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Otomatis hadir dengan #general-lounge, #klinik-seduh-v60, Recipe Vault, dan Secret ID.',
                  style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Club',
                    hintText: 'Contoh: Nusantara V60 Lab',
                    filled: true,
                    fillColor: AppTheme.surfaceWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi Singkat',
                    hintText: 'Fokus seduhan, kalibrasi air, dan diskusi beans...',
                    filled: true,
                    fillColor: AppTheme.surfaceWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Tingkat Privasi Club',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'PUBLIC',
                      label: Text('Publik'),
                      icon: Icon(CupertinoIcons.globe, size: 16),
                    ),
                    ButtonSegment(
                      value: 'RESTRICTED',
                      label: Text('Privat'),
                      icon: Icon(CupertinoIcons.lock, size: 16),
                    ),
                    ButtonSegment(
                      value: 'SECRET_VAULT',
                      label: Text('Vault'),
                      icon: Icon(CupertinoIcons.eye_slash, size: 16),
                    ),
                  ],
                  selected: {_privacyLevel},
                  onSelectionChanged: (s) =>
                      setState(() => _privacyLevel = s.first),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Karakteristik & Fokus Seduh',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _tagChoices.map((tag) {
                    final selected = _selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: selected,
                      selectedColor: AppTheme.accentAmber.withValues(alpha: 0.25),
                      onSelected: (val) => setState(() {
                        if (val) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      }),
                    );
                  }).toList(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12.5),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _submitting ? 'Membuat Workspace...' : 'Buat Coffee Club',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
