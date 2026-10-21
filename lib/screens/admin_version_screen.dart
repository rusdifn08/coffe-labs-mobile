import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_update_service.dart';

class AdminVersionScreen extends StatefulWidget {
  const AdminVersionScreen({super.key});

  @override
  State<AdminVersionScreen> createState() => _AdminVersionScreenState();
}

class _AdminVersionScreenState extends State<AdminVersionScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  // Controllers
  final _minBaseVersionCtrl = TextEditingController();
  final _latestBaseVersionCtrl = TextEditingController();
  final _minBuildNumberCtrl = TextEditingController();
  final _latestBuildNumberCtrl = TextEditingController();
  final _latestPatchNumberCtrl = TextEditingController();
  final _releaseNotesCtrl = TextEditingController();
  final _downloadUrlCtrl = TextEditingController();

  // Toggles
  bool _isForceUpdate = false;
  bool _isPatchRequired = false;

  // Current client info
  Map<String, dynamic> _clientInfo = {};

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _minBaseVersionCtrl.dispose();
    _latestBaseVersionCtrl.dispose();
    _minBuildNumberCtrl.dispose();
    _latestBuildNumberCtrl.dispose();
    _latestPatchNumberCtrl.dispose();
    _releaseNotesCtrl.dispose();
    _downloadUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    final client = await AppUpdateService.getAppVersionInfo();
    final config = await AppUpdateService.adminGetConfig();

    if (!mounted) return;

    if (config != null) {
      _minBaseVersionCtrl.text = config['min_base_version']?.toString() ?? '1.0.0';
      _latestBaseVersionCtrl.text = config['latest_base_version']?.toString() ?? '1.0.0';
      _minBuildNumberCtrl.text = config['min_build_number']?.toString() ?? '1';
      _latestBuildNumberCtrl.text = config['latest_build_number']?.toString() ?? '1';
      _latestPatchNumberCtrl.text = config['latest_patch_number']?.toString() ?? '0';
      _releaseNotesCtrl.text = config['release_notes']?.toString() ?? '';
      _downloadUrlCtrl.text = config['download_url']?.toString() ?? '';
      _isForceUpdate = config['is_force_update'] == true;
      _isPatchRequired = config['is_patch_required'] == true;
    }

    setState(() {
      _clientInfo = client;
      _isLoading = false;
    });
  }

  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);

    final payload = {
      'min_base_version': _minBaseVersionCtrl.text.trim(),
      'latest_base_version': _latestBaseVersionCtrl.text.trim(),
      'min_build_number': int.tryParse(_minBuildNumberCtrl.text.trim()) ?? 1,
      'latest_build_number': int.tryParse(_latestBuildNumberCtrl.text.trim()) ?? 1,
      'latest_patch_number': int.tryParse(_latestPatchNumberCtrl.text.trim()) ?? 0,
      'is_force_update': _isForceUpdate,
      'is_patch_required': _isPatchRequired,
      'release_notes': _releaseNotesCtrl.text.trim(),
      'download_url': _downloadUrlCtrl.text.trim(),
    };

    final success = await AppUpdateService.adminUpdateConfig(payload);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Konfigurasi Gatekeeper berhasil diperbarui & di-reload secara live!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Gagal menyimpan konfigurasi. Cek koneksi backend.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _applyPreset({
    required int latestBuild,
    required int minBuild,
    required int latestPatch,
    required bool forceUpdate,
    required bool patchRequired,
    required String notes,
  }) {
    setState(() {
      _latestBuildNumberCtrl.text = latestBuild.toString();
      _minBuildNumberCtrl.text = minBuild.toString();
      _latestPatchNumberCtrl.text = latestPatch.toString();
      _isForceUpdate = forceUpdate;
      _isPatchRequired = patchRequired;
      _releaseNotesCtrl.text = notes;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preset diterapkan ke form. Tekan "Simpan & Deploy" untuk mengaktifkan.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isShorebird = AppUpdateService.isShorebirdAvailable;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Version Gatekeeper Admin'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Segarkan Konfigurasi',
            icon: const Icon(CupertinoIcons.arrow_clockwise),
            onPressed: _loadConfig,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Client info card
                  _buildClientInfoCard(isShorebird),
                  const SizedBox(height: 20),

                  // Quick Simulation Presets
                  _buildPresetsSection(),
                  const SizedBox(height: 20),

                  // Main Config Card
                  _buildFormCard(),
                  const SizedBox(height: 24),

                  // Action Buttons
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveConfig,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBrown,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(CupertinoIcons.paperplane_fill, color: Colors.white, size: 20),
                    label: Text(
                      _isSaving ? 'Menyimpan ke Backend...' : 'Simpan & Deploy ke Axum Gatekeeper',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: () {
                      AppUpdateService.checkForUpdate(context: context, isManual: true);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple,
                      side: const BorderSide(color: Colors.purple),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(CupertinoIcons.play_circle_fill, size: 20),
                    label: const Text(
                      'Uji Coba Respon Gatekeeper Pada Device Ini',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildClientInfoCard(bool isShorebird) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(CupertinoIcons.device_phone_portrait, color: AppTheme.primaryBrown, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Klien Saat Ini',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    Text(
                      'Data build runtime device Anda',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isShorebird ? Colors.purple.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isShorebird ? Colors.purple.shade200 : Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isShorebird ? CupertinoIcons.bolt_fill : CupertinoIcons.bolt_slash,
                      size: 12,
                      color: isShorebird ? Colors.purple : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isShorebird ? 'Shorebird Aktif' : 'Shorebird Dev/Desktop',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isShorebird ? Colors.purple : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.dividerColor),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoPill('Base Version', 'v${_clientInfo['version'] ?? '1.0.0'}'),
              const SizedBox(width: 10),
              _buildInfoPill('Build Number', '#${_clientInfo['buildNumber'] ?? 1}'),
              const SizedBox(width: 10),
              _buildInfoPill('Current Patch', '#${_clientInfo['patchNumber'] ?? 0}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.bgCream,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Simulasi Cepat (Presets)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPresetChip(
                title: '🟢 Normal (Up-To-Date)',
                onTap: () => _applyPreset(
                  latestBuild: 1,
                  minBuild: 1,
                  latestPatch: 0,
                  forceUpdate: false,
                  patchRequired: false,
                  notes: 'Sistem aplikasi stabil dan mutakhir.',
                ),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                title: '⚡ Shorebird Patch (#2)',
                onTap: () => _applyPreset(
                  latestBuild: 1,
                  minBuild: 1,
                  latestPatch: 2,
                  forceUpdate: false,
                  patchRequired: true,
                  notes: 'Pembaruan Shorebird Patch #2: Perbaikan performa kalkulator rasio seduh dan optimasi cache.',
                ),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                title: '🚨 Force Native Update',
                onTap: () => _applyPreset(
                  latestBuild: 2,
                  minBuild: 2,
                  latestPatch: 0,
                  forceUpdate: true,
                  patchRequired: false,
                  notes: 'Pembaruan Besar v1.1.0 (Build #2): Upgrade native engine, sinkronisasi cloud real-time, dan perbaikan keamanan wajib.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip({required String title, required VoidCallback onTap}) {
    return ActionChip(
      label: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      backgroundColor: AppTheme.surfaceWhite,
      side: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: onTap,
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(CupertinoIcons.slider_horizontal_3, color: AppTheme.primaryBrown, size: 20),
              SizedBox(width: 8),
              Text(
                'Konfigurasi Kebijakan Versi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Build numbers row
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _latestBuildNumberCtrl,
                  label: 'Latest Build #',
                  hint: '1',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _minBuildNumberCtrl,
                  label: 'Min Build #',
                  hint: '1',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Versions row
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _latestBaseVersionCtrl,
                  label: 'Latest Version',
                  hint: '1.0.0',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _minBaseVersionCtrl,
                  label: 'Min Version',
                  hint: '1.0.0',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Shorebird Latest Patch Number
          _buildTextField(
            controller: _latestPatchNumberCtrl,
            label: 'Shorebird Target Patch #',
            hint: '0',
            keyboardType: TextInputType.number,
            helperText: 'Isi angka patch jika ada pembaruan kode Dart via Shorebird (0 = tidak ada patch)',
          ),
          const SizedBox(height: 16),

          // Toggles
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.bgCream,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppTheme.primaryBrown,
                  title: const Text(
                    'Wajibkan Pembaruan Native (Force Update)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  subtitle: const Text(
                    'Blokir layar aplikasi bagi pengguna dengan versi di bawah batas minimum.',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  value: _isForceUpdate,
                  onChanged: (val) => setState(() => _isForceUpdate = val),
                ),
                const Divider(height: 1, color: AppTheme.dividerColor),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: Colors.purple,
                  title: const Text(
                    'Wajibkan Shorebird Patch Segera',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  subtitle: const Text(
                    'Jika aktif: Tampilkan progress modal FORCE_OTA_PATCH. Jika nonaktif: unduh patch secara diam-diam (SILENT_OTA_PATCH).',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  value: _isPatchRequired,
                  onChanged: (val) => setState(() => _isPatchRequired = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Release Notes
          _buildTextField(
            controller: _releaseNotesCtrl,
            label: 'Catatan Rilis (Release Notes)',
            hint: 'Deskripsikan perbaikan fitur atau patch...',
            maxLines: 4,
          ),
          const SizedBox(height: 14),

          // Download URL
          _buildTextField(
            controller: _downloadUrlCtrl,
            label: 'URL Unduhan APK / Toko Aplikasi',
            hint: 'https://github.com/rusdi-labs/coffee-hub-mobile/releases/latest',
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            helperText: helperText,
            helperMaxLines: 2,
            helperStyle: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            filled: true,
            fillColor: AppTheme.bgCream,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
