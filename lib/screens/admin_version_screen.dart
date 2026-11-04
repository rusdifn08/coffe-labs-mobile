import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/admin/widgets/admin_version_client_card.dart';
import '../features/admin/widgets/admin_version_form_card.dart';
import '../features/admin/widgets/admin_version_presets.dart';
import '../services/app_update_service.dart';
import '../theme/app_theme.dart';

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
                  AdminVersionClientCard(
                    isShorebird: isShorebird,
                    clientInfo: _clientInfo,
                  ),
                  const SizedBox(height: 20),

                  // Quick Simulation Presets
                  AdminVersionPresets(
                    onApplyPreset: _applyPreset,
                  ),
                  const SizedBox(height: 20),

                  // Main Config Card
                  AdminVersionFormCard(
                    latestBuildNumberCtrl: _latestBuildNumberCtrl,
                    minBuildNumberCtrl: _minBuildNumberCtrl,
                    latestBaseVersionCtrl: _latestBaseVersionCtrl,
                    minBaseVersionCtrl: _minBaseVersionCtrl,
                    latestPatchNumberCtrl: _latestPatchNumberCtrl,
                    releaseNotesCtrl: _releaseNotesCtrl,
                    downloadUrlCtrl: _downloadUrlCtrl,
                    isForceUpdate: _isForceUpdate,
                    onForceUpdateChanged: (val) => setState(() => _isForceUpdate = val),
                    isPatchRequired: _isPatchRequired,
                    onPatchRequiredChanged: (val) => setState(() => _isPatchRequired = val),
                  ),
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
}
