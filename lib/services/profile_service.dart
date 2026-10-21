import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ProfileService {
  static const String _userNameKey = 'coffeehub_user_name';
  static const String _userImageKey = 'coffeehub_user_image';
  static const String _defaultAvatarKey = 'coffeehub_default_avatar_character';

  static const List<String> characterAvatars = [
    'assets/images/characters/avatar_1.png',
    'assets/images/characters/avatar_2.png',
    'assets/images/characters/avatar_3.png',
    'assets/images/characters/avatar_4.png',
    'assets/images/characters/avatar_5.png',
    'assets/images/characters/avatar_6.png',
    'assets/images/characters/avatar_7.png',
    'assets/images/characters/avatar_8.png',
    'assets/images/characters/avatar_9.png',
    'assets/images/characters/avatar_10.png',
    'assets/images/characters/avatar_11.png',
    'assets/images/characters/avatar_12.png',
  ];

  static final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);

  static Future<bool> isUserRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userNameKey);
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Barista';
  }

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    changeNotifier.value++;
  }

  static String getRandomAvatar() {
    final random = Random();
    return characterAvatars[random.nextInt(characterAvatars.length)];
  }

  static Future<String> getDefaultAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    String? assigned = prefs.getString(_defaultAvatarKey);
    if (assigned == null || !characterAvatars.contains(assigned)) {
      assigned = getRandomAvatar();
      await prefs.setString(_defaultAvatarKey, assigned);
    }
    return assigned;
  }

  static Future<String> getUserImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    final customPath = prefs.getString(_userImageKey);
    if (customPath != null &&
        customPath.isNotEmpty &&
        !customPath.contains('rusdi.png')) {
      return customPath;
    }
    final defaultAvatar = await getDefaultAvatar();
    await prefs.setString(_userImageKey, defaultAvatar);
    return defaultAvatar;
  }

  static Future<void> setUserImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userImageKey, path);
    changeNotifier.value++;
  }

  static ImageProvider getImageProvider(String? imagePath) {
    if (imagePath == null ||
        imagePath.isEmpty ||
        imagePath.contains('rusdi.png')) {
      return const AssetImage('assets/images/characters/avatar_1.png');
    }
    if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    }
    final file = File(imagePath);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return const AssetImage('assets/images/characters/avatar_1.png');
  }

  /// Menampilkan dialog / modal bottom sheet pemilihan avatar karakter atau galeri
  static Future<void> showAvatarPickerDialog({
    required BuildContext context,
    required String? currentPath,
    required Function(String newPath) onSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String selected = currentPath ?? characterAvatars.first;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pilih Avatar Profil",
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Pilih karakter barista favoritmu atau unggah foto",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryBrown,
                              side: const BorderSide(color: AppTheme.primaryBrown),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(CupertinoIcons.shuffle, size: 18),
                            label: const Text("Acak Avatar"),
                            onPressed: () {
                              final rand = getRandomAvatar();
                              setModalState(() {
                                selected = rand;
                              });
                              onSelected(rand);
                              Navigator.pop(ctx);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBrown,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(CupertinoIcons.photo_camera, size: 18),
                            label: const Text("Dari Galeri"),
                            onPressed: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 800,
                                maxHeight: 800,
                                imageQuality: 85,
                              );
                              if (pickedFile != null) {
                                onSelected(pickedFile.path);
                                if (ctx.mounted) Navigator.pop(ctx);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: characterAvatars.length,
                      itemBuilder: (context, index) {
                        final avatarPath = characterAvatars[index];
                        final isSelected = selected == avatarPath;

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selected = avatarPath;
                            });
                            onSelected(avatarPath);
                            Navigator.pop(ctx);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryBrown.withValues(alpha: 0.1)
                                  : AppTheme.bgCream.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryBrown
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryBrown.withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    avatarPath,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Avatar ${index + 1}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? AppTheme.primaryBrown : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
