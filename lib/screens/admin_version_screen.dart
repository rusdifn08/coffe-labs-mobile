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
  bool _isSyncingGitHub = false;

  // Controllers
  final _minBaseVersionCtrl = TextEditingController();
  final _latestBaseVersionCtrl = TextEditingController();
  final _minBuildNumberCtrl = TextEditingController();
  final _latestBuildNumberCtrl = TextEditingController();
  final _latestPatchNumberCtrl = TextEditingController();
  final _contentManifestCtrl = TextEditingController();
  final _releaseNotesCtrl = TextEditingController();
  final _downloadUrlCtrl = TextEditingController();
  final _iosDownloadUrlCtrl = TextEditingController();

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
    _contentManifestCtrl.dispose();
    _releaseNotesCtrl.dispose();
    _downloadUrlCtrl.dispose();
    _iosDownloadUrlCtrl.dispose();
    super.dispose();
  }

  void _populateFromConfig(Map<String, dynamic> config) {
    _minBaseVersionCtrl.text = config['min_base_version']?.toString() ?? '2.0.0';
    _latestBaseVersionCtrl.text = config['latest_base_version']?.toString() ?? '2.5.1';
    _minBuildNumberCtrl.text = config['min_build_number']?.toString() ?? '2';
    _latestBuildNumberCtrl.text = config['latest_build_number']?.toString() ?? '9';
    _latestPatchNumberCtrl.text = config['latest_patch_number']?.toString() ?? '0';
    _contentManifestCtrl.text = config['content_manifest_version']?.toString() ?? '1';
    _releaseNotesCtrl.text = config['release_notes']?.toString() ?? '';
    _downloadUrlCtrl.text = config['download_url']?.toString() ??
        AppUpdateService.officialAndroidApkUrl;
    _iosDownloadUrlCtrl.text = config['ios_download_url']?.toString() ??
        AppUpdateService.officialIosIpaUrl;
    _isForceUpdate = config['is_force_update'] == true;
    _isPatchRequired = config['is_patch_required'] == true;
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    final client = await AppUpdateService.getAppVersionInfo();
    final config = await AppUpdateService.adminGetConfig();

    if (!mounted) return;
    if (config != null) {
      _populateFromConfig(config);
    }

    setState(() {
      _clientInfo = client;
      _isLoading = false;
    });
  }

  Future<void> _syncFromGitHub() async {
    setState(() => _isSyncingGitHub = true);
    final synced = await AppUpdateService.adminSyncFromGitHub();
    if (!mounted) return;
    setState(() => _isSyncingGitHub = false);

    if (synced != null) {
      setState(() => _populateFromConfig(synced));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Berhasil sinkron dari GitHub Release v${synced['latest_base_version']}!',
          ),
          backgroundColor: const Color(0xFF15803D),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Gagal menyinkronkan dari GitHub Releases. Cek koneksi backend.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);

    final payload = {
      'min_base_version': _minBaseVersionCtrl.text.trim(),
      'latest_base_version': _latestBaseVersionCtrl.text.trim(),
      'min_build_number': int.tryParse(_minBuildNumberCtrl.text.trim()) ?? 2,
      'latest_build_number': int.tryParse(_latestBuildNumberCtrl.text.trim()) ?? 9,
      'latest_patch_number': int.tryParse(_latestPatchNumberCtrl.text.trim()) ?? 0,
      'content_manifest_version': int.tryParse(_contentManifestCtrl.text.trim()) ?? 1,
      'is_force_update': _isForceUpdate,
      'is_patch_required': _isPatchRequired,
      'release_notes': _releaseNotesCtrl.text.trim(),
      'download_url': _downloadUrlCtrl.text.trim(),
      'ios_download_url': _iosDownloadUrlCtrl.text.trim(),
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
    required String latestVersion,
    required int latestBuild,
    required int minBuild,
    required int latestPatch,
    required int contentManifestVersion,
    required bool forceUpdate,
    required bool patchRequired,
    required String notes,
  }) {
    setState(() {
      _latestBaseVersionCtrl.text = latestVersion;
      _latestBuildNumberCtrl.text = latestBuild.toString();
      _minBuildNumberCtrl.text = minBuild.toString();
      _latestPatchNumberCtrl.text = latestPatch.toString();
      _contentManifestCtrl.text = contentManifestVersion.toString();
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
    final currentVersion = _clientInfo['version']?.toString() ?? '2.5.1';
    final currentBuild = (_clientInfo['buildNumber'] as num?)?.toInt() ?? 9;
    final currentPatch = (_clientInfo['patchNumber'] as num?)?.toInt() ?? 0;
    final currentManifest = int.tryParse(_contentManifestCtrl.text.trim()) ?? 1;

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
                  AdminVersionClientCard(
                    isShorebird: isShorebird,
                    clientInfo: _clientInfo,
                  ),
                  const SizedBox(height: 14),

                  OutlinedButton.icon(
                    onPressed: _isSyncingGitHub ? null : _syncFromGitHub,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBrown,
                      backgroundColor: AppTheme.surfaceWhite,
                      side: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.35)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: _isSyncingGitHub
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBrown),
                          )
                        : const Icon(CupertinoIcons.cloud_download, size: 18),
                    label: Text(
                      _isSyncingGitHub
                          ? 'Menyinkronkan GitHub Release...'
                          : 'Sinkronkan Otomatis dari GitHub Release Terbaru',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 18),

                  AdminVersionPresets(
                    currentVersion: currentVersion,
                    currentBuild: currentBuild,
                    currentPatch: currentPatch,
                    currentManifestVersion: currentManifest,
                    onApplyPreset: _applyPreset,
                  ),
                  const SizedBox(height: 20),

                  AdminVersionFormCard(
                    latestBuildNumberCtrl: _latestBuildNumberCtrl,
                    minBuildNumberCtrl: _minBuildNumberCtrl,
                    latestBaseVersionCtrl: _latestBaseVersionCtrl,
                    minBaseVersionCtrl: _minBaseVersionCtrl,
                    latestPatchNumberCtrl: _latestPatchNumberCtrl,
                    contentManifestCtrl: _contentManifestCtrl,
                    releaseNotesCtrl: _releaseNotesCtrl,
                    downloadUrlCtrl: _downloadUrlCtrl,
                    iosDownloadUrlCtrl: _iosDownloadUrlCtrl,
                    isForceUpdate: _isForceUpdate,
                    onForceUpdateChanged: (val) => setState(() => _isForceUpdate = val),
                    isPatchRequired: _isPatchRequired,
                    onPatchRequiredChanged: (val) => setState(() => _isPatchRequired = val),
                  ),
                  const SizedBox(height: 24),

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
