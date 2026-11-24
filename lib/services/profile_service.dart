import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/storage/user_scoped_storage.dart';
import '../theme/app_theme.dart';
import '../core/assets/cloud_asset_manager.dart';

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

  static Future<bool> isUserRegistered({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await UserScopedStorage.scopedKeyAsync(
      _userNameKey,
      userId: userId,
      prefs: prefs,
    );
    return prefs.containsKey(key);
  }

  static Future<String> getUserName({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = userId != null && userId.trim().isNotEmpty
        ? UserScopedStorage.normalizeUserId(userId)
        : await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    final key = UserScopedStorage.scopedKey(_userNameKey, userId: uid);
    final scopedVal = prefs.getString(key);
    if (scopedVal != null && scopedVal.isNotEmpty) return scopedVal;
    if (uid == UserScopedStorage.guestScope) {
      final legacyGuest = prefs.getString(_userNameKey);
      if (legacyGuest != null && legacyGuest.isNotEmpty) return legacyGuest;
    }
    return 'Barista';
  }

  static Future<void> setUserName(String name, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await UserScopedStorage.scopedKeyAsync(
      _userNameKey,
      userId: userId,
      prefs: prefs,
    );
    await prefs.setString(key, name);
    changeNotifier.value++;
  }

  static String getRandomAvatar() {
    final random = Random();
    return characterAvatars[random.nextInt(characterAvatars.length)];
  }

  static Future<String> getDefaultAvatar({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await UserScopedStorage.scopedKeyAsync(
      _defaultAvatarKey,
      userId: userId,
      prefs: prefs,
    );
    String? assigned = prefs.getString(key);
    if (assigned == null || !characterAvatars.contains(assigned)) {
      assigned = getRandomAvatar();
      await prefs.setString(key, assigned);
    }
    return assigned;
  }

  static Future<String> getUserImagePath({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await UserScopedStorage.scopedKeyAsync(
      _userImageKey,
      userId: userId,
      prefs: prefs,
    );
    final customPath = prefs.getString(key);
    if (customPath != null &&
        customPath.trim().isNotEmpty &&
        !customPath.contains('rusdi.png')) {
      return customPath.trim();
    }
    final defaultAvatar = await getDefaultAvatar(userId: userId);
    await prefs.setString(key, defaultAvatar);
    return defaultAvatar;
  }

  static Future<void> setUserImagePath(String path, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await UserScopedStorage.scopedKeyAsync(
      _userImageKey,
      userId: userId,
      prefs: prefs,
    );
    await prefs.setString(key, path.trim());
    changeNotifier.value++;
  }

  /// Menerapkan profil terverifikasi dari cloud/login ke partisi pengguna tertentu.
  static Future<void> applyCloudProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    bool changed = false;
    if (fullName != null && fullName.trim().isNotEmpty) {
      final nameKey = UserScopedStorage.scopedKey(_userNameKey, userId: userId);
      await prefs.setString(nameKey, fullName.trim());
      changed = true;
    }
    if (avatarUrl != null &&
        avatarUrl.trim().isNotEmpty &&
        !avatarUrl.contains('rusdi.png')) {
      final imgKey = UserScopedStorage.scopedKey(_userImageKey, userId: userId);
      await prefs.setString(imgKey, avatarUrl.trim());
      changed = true;
    }
    if (changed) {
      changeNotifier.value++;
    }
  }

  /// Memicu pembaruan UI saat sesi berganti akun / logout.
  static void notifySessionSwitched() {
    changeNotifier.value++;
  }

  /// Mengembalikan `ImageProvider` jika `imagePath` valid (URL HTTPS, asset lokal, atau file ada),
  /// atau `null` bila kosong/tidak valid.
  static ImageProvider? tryGetImageProvider(String? imagePath) {
    final raw = imagePath?.trim() ?? '';
    if (raw.isEmpty || raw.contains('rusdi.png')) {
      return null;
    }
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return CachedNetworkImageProvider(raw);
    }
    if (raw.startsWith('assets/')) {
      return CloudAssetManager.imageProvider(raw);
    }
    final file = File(raw);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
  }

  static ImageProvider getImageProvider(String? imagePath) {
    return tryGetImageProvider(imagePath) ??
        const AssetImage('assets/images/characters/avatar_1.png');
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
                                  child: CloudAssetImage(
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
