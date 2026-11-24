import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/network/backend_endpoint_manager.dart';
import '../../../theme/app_theme.dart';

class AdminVersionClientCard extends StatelessWidget {
  final bool isShorebird;
  final Map<String, dynamic> clientInfo;

  const AdminVersionClientCard({
    super.key,
    required this.isShorebird,
    required this.clientInfo,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: isShorebird ? Colors.purple.shade50 : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isShorebird ? Colors.purple.shade200 : Colors.amber.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isShorebird ? CupertinoIcons.bolt_fill : CupertinoIcons.bolt_slash,
                      size: 12,
                      color: isShorebird ? Colors.purple : Colors.amber.shade800,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isShorebird ? 'Delta OTA Aktif' : 'Non-Shorebird Build',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isShorebird ? Colors.purple : Colors.amber.shade900,
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
              _buildInfoPill('Base Version', 'v${clientInfo['version'] ?? '2.5.2'}'),
              const SizedBox(width: 10),
              _buildInfoPill(
                'Build (Norm)',
                clientInfo['rawBuildNumber'] != null &&
                        clientInfo['rawBuildNumber'] != clientInfo['buildNumber']
                    ? '#${clientInfo['buildNumber']} (${clientInfo['rawBuildNumber']})'
                    : '#${clientInfo['buildNumber'] ?? 10}',
              ),
              const SizedBox(width: 10),
              _buildInfoPill('OTA Patch', '#${clientInfo['patchNumber'] ?? 0}'),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.dividerColor),
          const SizedBox(height: 12),
          _buildDynamicEndpointSection(context),
        ],
      ),
    );
  }

  Widget _buildDynamicEndpointSection(BuildContext context) {
    final manager = BackendEndpointManager.instance;
    return ValueListenableBuilder<String>(
      valueListenable: manager.activeBaseUrlNotifier,
      builder: (context, activeUrl, _) {
        final host = Uri.tryParse(activeUrl)?.host ?? activeUrl;
        final rev = manager.currentManifestRevision;
        final source = manager.currentSourceLabel;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.bgCream,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.globe, size: 15, color: AppTheme.primaryBrown),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Dynamic Server Endpoint (Auto-Failover VPS)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Text(
                      'Rev v$rev',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                host,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBrown,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Sumber: $source • Multi-CDN: Vercel / jsDelivr / GitHub',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final report = await manager.syncManifestFromMirrors(force: true);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(report.message)),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBrown,
                        side: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(CupertinoIcons.refresh, size: 14),
                      label: const Text('Sync CDN', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showCustomVpsDialog(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textDark,
                        side: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.25)),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(CupertinoIcons.cloud_upload, size: 14),
                      label: const Text('Uji / Set VPS', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCustomVpsDialog(BuildContext context) async {
    final manager = BackendEndpointManager.instance;
    final ctrl = TextEditingController(text: manager.manualOverrideUrl ?? '');
    bool testing = false;
    String? feedback;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Uji / Override Server VPS',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan domain HTTPS VPS pribadi untuk uji lokal pada HP ini, atau kosongkan untuk kembali ke Auto-Discovery Multi-CDN.',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.35),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                decoration: InputDecoration(
                  hintText: 'https://api.vps-anda.com',
                  isDense: true,
                  filled: true,
                  fillColor: AppTheme.bgCream,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              if (feedback != null) ...[
                const SizedBox(height: 8),
                Text(
                  feedback!,
                  style: const TextStyle(fontSize: 11.5, color: AppTheme.primaryBrown, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: testing
                  ? null
                  : () async {
                      await manager.setManualOverrideUrl('');
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kembali ke mode Auto-Discovery Multi-CDN.')),
                        );
                      }
                    },
              child: const Text('Reset Auto-CDN'),
            ),
            ElevatedButton(
              onPressed: testing
                  ? null
                  : () async {
                      final raw = ctrl.text.trim();
                      if (raw.isEmpty) {
                        await manager.setManualOverrideUrl('');
                        if (ctx.mounted) Navigator.pop(ctx);
                        return;
                      }
                      setDialogState(() {
                        testing = true;
                        feedback = 'Menguji /api/health server VPS...';
                      });
                      final ok = await manager.verifyCoffeeLabsHealth(raw);
                      if (!ok) {
                        setDialogState(() {
                          testing = false;
                          feedback = 'Gagal: pastikan URL HTTPS valid & /api/health merespons Coffee Labs OK.';
                        });
                        return;
                      }
                      await manager.setManualOverrideUrl(raw);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Berhasil beralih ke VPS: $raw')),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                foregroundColor: Colors.white,
              ),
              child: Text(testing ? 'Menguji...' : 'Verifikasi & Pakai'),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
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
}
