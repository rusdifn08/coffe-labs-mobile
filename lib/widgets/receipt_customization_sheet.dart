import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../services/profile_service.dart';
import '../services/receipt_settings_service.dart';
import '../theme/app_theme.dart';

class ReceiptCustomizationSheet extends StatefulWidget {
  final VoidCallback? onSettingsSaved;

  const ReceiptCustomizationSheet({super.key, this.onSettingsSaved});

  static Future<void> show(BuildContext context, {VoidCallback? onSettingsSaved}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReceiptCustomizationSheet(onSettingsSaved: onSettingsSaved),
    );
  }

  @override
  State<ReceiptCustomizationSheet> createState() => _ReceiptCustomizationSheetState();
}

class _ReceiptCustomizationSheetState extends State<ReceiptCustomizationSheet> {
  late TextEditingController _storeNameController;
  late TextEditingController _taglineController;
  late TextEditingController _baristaController;
  late TextEditingController _footerController;
  late TextEditingController _socialController;
  String _selectedIcon = '☕';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController();
    _taglineController = TextEditingController();
    _baristaController = TextEditingController();
    _footerController = TextEditingController();
    _socialController = TextEditingController();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _taglineController.dispose();
    _baristaController.dispose();
    _footerController.dispose();
    _socialController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentSettings() async {
    final settings = await ReceiptSettingsService.getSettings();
    if (!mounted) return;
    setState(() {
      _storeNameController.text = settings.storeName;
      _taglineController.text = settings.tagline;
      _baristaController.text = settings.baristaName;
      _footerController.text = settings.footerNote;
      _socialController.text = settings.socialHandle;
      _selectedIcon = settings.icon;
      _isLoading = false;
    });
  }

  Future<void> _syncFromProfile() async {
    try {
      final userName = await ProfileService.getUserName();
      if (userName.isNotEmpty && userName.toLowerCase() != 'novice brewer') {
        setState(() {
          _storeNameController.text = userName.toUpperCase();
          _baristaController.text = userName;
          _socialController.text = '@${userName.toLowerCase().replaceAll(' ', '')}.specialty';
        });
      }
    } catch (_) {}
  }

  Future<void> _saveSettings() async {
    final storeName = _storeNameController.text.trim().isEmpty ? 'COFFEE LABS' : _storeNameController.text.trim();
    final tagline = _taglineController.text.trim().isEmpty ? 'SPECIALTY COFFEE HUB' : _taglineController.text.trim();
    final barista = _baristaController.text.trim().isEmpty ? 'Coffee Labs Barista' : _baristaController.text.trim();
    final footer = _footerController.text.trim().isEmpty ? 'SELAMAT MENIKMATI KOPI ANDA!' : _footerController.text.trim();
    final social = _socialController.text.trim().isEmpty ? '@coffeelabs.specialty' : _socialController.text.trim();

    final newSettings = ReceiptSettings(
      storeName: storeName,
      tagline: tagline,
      icon: _selectedIcon,
      baristaName: barista,
      footerNote: footer,
      subFooter: 'Diseduh Presisi & Penuh Rasa',
      socialHandle: social,
      paperWidthMm: 58,
    );

    await ReceiptSettingsService.saveSettings(newSettings);
    widget.onSettingsSaved?.call();

    if (mounted) {
      Navigator.pop(context);
      final isEn = LanguageService.isEnglish;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEn ? 'Receipt header configuration successfully saved!' : 'Pengaturan header struk berhasil disimpan!'),
          backgroundColor: AppTheme.primaryBrown,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown))
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(CupertinoIcons.slider_horizontal_3, color: AppTheme.primaryBrown, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? 'Customize Receipt Header' : 'Kustomisasi Header Struk',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                          Text(
                            isEn ? 'Change store name, slogan, barista and icon' : 'Ubah nama kedai, slogan, barista & ikon struk',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Scrollable Form
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Live Preview Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAF7),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '===========================',
                                style: TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: Colors.grey.shade600, letterSpacing: 1),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$_selectedIcon  ${_storeNameController.text.trim().isEmpty ? "COFFEE LABS" : _storeNameController.text.trim().toUpperCase()}  $_selectedIcon',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF222222),
                                ),
                              ),
                              Text(
                                _taglineController.text.trim().isEmpty ? "SPECIALTY COFFEE HUB" : _taglineController.text.trim().toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '===========================',
                                style: TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: Colors.grey.shade600, letterSpacing: 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // PILIHAN IKON STRUK
                        Text(
                          isEn ? 'Select Receipt Icon' : 'Pilih Ikon Header Struk:',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ReceiptSettingsService.iconPresets.map((icon) {
                            final isSelected = _selectedIcon == icon;
                            return InkWell(
                              onTap: () => setState(() => _selectedIcon = icon),
                              borderRadius: BorderRadius.circular(10),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.primaryBrown : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? AppTheme.primaryBrown : Colors.grey.shade300,
                                    width: isSelected ? 1.8 : 1,
                                  ),
                                ),
                                child: Text(icon, style: const TextStyle(fontSize: 16)),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // NAMA TOKO / KEDAI
                        Row(
                          children: [
                            Text(
                              isEn ? 'Store / Roastery Name' : 'Nama Kedai / Roastery:',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: _syncFromProfile,
                              icon: const Icon(CupertinoIcons.arrow_2_circlepath, size: 13, color: AppTheme.primaryBrown),
                              label: Text(
                                isEn ? 'Sync Profile' : 'Gunakan Akun Profil',
                                style: const TextStyle(fontSize: 11, color: AppTheme.primaryBrown, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _storeNameController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Misal: COFFEE LABS / ELIKA ROASTERS',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 1.5)),
                          ),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 14),

                        // DESKRIPSI / SLOGAN
                        Text(
                          isEn ? 'Tagline / Slogan' : 'Slogan / Deskripsi:',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _taglineController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Misal: SPECIALTY COFFEE HUB / ARTISAN SLOW BAR',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 1.5)),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 14),

                        // NAMA BARISTA
                        Text(
                          isEn ? 'Default Barista Name' : 'Nama Barista:',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _baristaController,
                          decoration: InputDecoration(
                            hintText: 'Misal: Rusdi Barista / Lead Brewer',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 1.5)),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 14),

                        // CATATAN KAKI & SOSIAL MEDIA
                        Text(
                          isEn ? 'Footer Note & Social Media' : 'Pesan Footer & Akun Instagram:',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _footerController,
                          decoration: InputDecoration(
                            hintText: 'Misal: SELAMAT MENIKMATI KOPI ANDA!',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 1.5)),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _socialController,
                          decoration: InputDecoration(
                            hintText: 'Misal: @coffeelabs.specialty',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 1.5)),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // TOMBOL SIMPAN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 1,
                    ),
                    onPressed: _saveSettings,
                    child: Text(
                      isEn ? 'Save Receipt Configuration' : 'Simpan Kustomisasi Struk',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
