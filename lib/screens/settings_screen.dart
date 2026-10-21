import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/profile_service.dart';
import '../services/app_update_service.dart';
import 'feedback_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    ProfileService.changeNotifier.addListener(_loadProfile);
  }

  @override
  void dispose() {
    ProfileService.changeNotifier.removeListener(_loadProfile);
    _nameController.dispose();
    super.dispose();
  }

  void _loadProfile() async {
    String name = await ProfileService.getUserName();
    String? img = await ProfileService.getUserImagePath();
    if (!mounted) return;
    setState(() {
      _nameController.text = name;
      _imagePath = img;
    });
  }

  Future<void> _pickImage() async {
    await ProfileService.showAvatarPickerDialog(
      context: context,
      currentPath: _imagePath,
      onSelected: (newPath) async {
        setState(() {
          _imagePath = newPath;
        });
        await ProfileService.setUserImagePath(newPath);
      },
    );
  }

  void _saveName() async {
    String name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await ProfileService.setUserName(name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppTheme.primaryBrown),
        );
        if (Navigator.canPop(context)) {
          Navigator.pop(context, true); // return true only if pushed as a route
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Profile Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppTheme.surfaceWhite,
                      backgroundImage: ProfileService.getImageProvider(_imagePath),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBrown,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.bgCream, width: 3),
                        ),
                        child: const Icon(CupertinoIcons.camera_fill, color: Colors.white, size: 20),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryBrown,
                  side: const BorderSide(color: AppTheme.primaryBrown),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(CupertinoIcons.sparkles, size: 16),
                label: const Text("Ganti Karakter Avatar", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 36),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                labelStyle: const TextStyle(color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.surfaceWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 2),
                ),
                prefixIcon: const Icon(CupertinoIcons.person_fill, color: AppTheme.primaryBrown),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveName,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.teal,
                  side: const BorderSide(color: Colors.teal),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(CupertinoIcons.chat_bubble_2_fill, size: 18),
                label: const Text("Beri Masukan / Laporkan Bug", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  AppUpdateService.checkForUpdate(context: context, isManual: true);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple,
                  side: BorderSide(color: Colors.purple.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(CupertinoIcons.arrow_clockwise_circle_fill, size: 18),
                label: const Text("Periksa Pembaruan Sistem", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Coffee Labs v1.0.0\nPowered by Rust Axum & Shorebird Engine',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
