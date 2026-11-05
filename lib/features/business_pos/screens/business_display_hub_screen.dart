import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/business_pos_models.dart';
import '../../../providers/workspace_mode_provider.dart';
import '../../../services/business_pos_api_service.dart';
import '../../../theme/business_theme.dart';
import '../widgets/business_menu_asset_image.dart';
import '../widgets/menu_grid_configurator_modal.dart';
import '../widgets/oled_compatibility_dialog.dart';
import '../widgets/kiosk_setup_checklist_modal.dart';
import 'oled_diagnostic_screen.dart';

class BusinessDisplayHubScreen extends ConsumerStatefulWidget {
  const BusinessDisplayHubScreen({super.key});

  @override
  ConsumerState<BusinessDisplayHubScreen> createState() =>
      _BusinessDisplayHubScreenState();
}

class _BusinessDisplayHubScreenState
    extends ConsumerState<BusinessDisplayHubScreen> {
  BusinessStoreConfig _config = BusinessStoreConfig.defaultBarConfig();
  List<BusinessMenuItem> _menuItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final conf = await BusinessPosApiService.fetchStoreConfig();
    final items = await BusinessPosApiService.fetchMenuList();
    if (mounted) {
      setState(() {
        if (conf != null) _config = conf;
        _menuItems = items;
        _isLoading = false;
      });
    }
  }

  void _launchFullScreenKiosk() {
    OledCompatibilityDialog.checkAndShowIfNeeded(
      context,
      onProceed: () {
        ref
            .read(workspaceModeProvider.notifier)
            .forceSetMode(WorkspaceMode.customerAodDisplay);
        KioskSetupChecklistModal.show(
          context,
          config: _config,
          menuItems: _menuItems,
        );
      },
      onOpenDiagnostic: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OledDiagnosticScreen()),
        );
      },
    );
  }

  void _openGridConfigurator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MenuGridConfiguratorModal(
        config: _config,
        onConfigUpdated: _loadData,
      ),
    );
  }

  Future<void> _toggleItemAodVisibility(BusinessMenuItem item, bool value) async {
    final updated = item.copyWith(showInAod: value);
    setState(() {
      final index = _menuItems.indexWhere((m) => m.id == item.id);
      if (index != -1) _menuItems[index] = updated;
    });

    await BusinessPosApiService.updateMenuItem(item.id, {'show_in_aod': value});
  }

  @override
  Widget build(BuildContext context) {
    final aodItems = _menuItems.where((i) => i.showInAod && i.isAvailable).toList();

    return Scaffold(
      backgroundColor: BusinessTheme.bgDark,
      appBar: AppBar(
        backgroundColor: BusinessTheme.bgSurface,
        elevation: 0,
        title: const Row(
          children: [
            Icon(CupertinoIcons.device_laptop, color: BusinessTheme.goldAccent, size: 20),
            SizedBox(width: 8),
            Text(
              'Display AOD & Kiosk Pelanggan',
              style: TextStyle(
                color: BusinessTheme.textLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.slider_horizontal_3, color: BusinessTheme.goldAccent),
            tooltip: 'Konfigurasi Grid & OLED',
            onPressed: _openGridConfigurator,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.waveform_path_ecg, color: Colors.white70),
            tooltip: 'Diagnostik OLED & Anti Burn-in',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OledDiagnosticScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: BusinessTheme.goldAccent),
            )
          : RefreshIndicator(
              color: BusinessTheme.goldAccent,
              backgroundColor: BusinessTheme.cardBg,
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Big Launch Fullscreen Kiosk Hero Card
                    _buildKioskLauncherCard(aodItems.length),
                    const SizedBox(height: 20),

                    // 2. Mini Kiosk Display Preview Simulator
                    _buildLiveDisplayPreview(aodItems),
                    const SizedBox(height: 20),

                    // 3. Grid & Brightness Settings Card
                    _buildConfigSummaryCard(),
                    const SizedBox(height: 20),

                    // 4. Menu Items Visibility Toggles
                    _buildMenuItemsList(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildKioskLauncherCard(int totalAodItems) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B2215), Color(0xFF171513)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: BusinessTheme.goldAccent.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: BusinessTheme.goldAccent.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: BusinessTheme.goldAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: BusinessTheme.goldAccent, width: 1.0),
                ),
                child: const Icon(
                  CupertinoIcons.tv_fill,
                  color: BusinessTheme.goldAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mode Pajangan Kiosk (AOD)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalAodItems Menu aktif tampil untuk pelanggan bar',
                      style: const TextStyle(
                        color: BusinessTheme.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Layar Always-On Display dengan latar True Pitch-Black OLED (#000000), proteksi anti burn-in pixel shift, dan kunci PIN Kiosk.',
            style: TextStyle(
              color: BusinessTheme.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _launchFullScreenKiosk,
              icon: const Icon(CupertinoIcons.play_circle_fill, size: 20),
              label: const Text(
                'Luncurkan Layar Penuh Kiosk AOD',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: BusinessTheme.goldAccent,
                foregroundColor: Colors.black,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveDisplayPreview(List<BusinessMenuItem> aodItems) {
    return Container(
      decoration: BusinessTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(CupertinoIcons.eye_fill, color: BusinessTheme.goldAccent, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'SIMULASI TAMPILAN PELANGGAN',
                    style: TextStyle(
                      color: BusinessTheme.goldAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: BusinessTheme.borderSubtle),
                ),
                child: const Text(
                  'True Black #000000',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Frame Kiosk Mini Screen
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF333333), width: 2),
            ),
            padding: const EdgeInsets.all(12),
            child: aodItems.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada menu yang diaktifkan untuk Display AOD',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  )
                : Row(
                    children: aodItems.take(3).map((item) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF262626),
                              width: 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: BusinessMenuAssetImage(
                                  assetUrl: item.assetUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.formattedPrice,
                                style: const TextStyle(
                                  color: BusinessTheme.goldAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSummaryCard() {
    return Container(
      decoration: BusinessTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PENGATURAN DISPLAY & PERFORMA',
                style: TextStyle(
                  color: BusinessTheme.goldAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              InkWell(
                onTap: _openGridConfigurator,
                child: const Text(
                  'Ubah Grid',
                  style: TextStyle(
                    color: BusinessTheme.goldAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildConfigItem(
            label: 'Matriks Layout Grid',
            value: '${_config.aodGridColumns} Kolom × ${_config.aodGridRows} Baris',
            icon: CupertinoIcons.rectangle_grid_2x2,
          ),
          const Divider(height: 16, color: BusinessTheme.borderSubtle),
          _buildConfigItem(
            label: 'Proteksi Layar Anti Burn-In',
            value: _config.pixelShiftEnabled ? 'Aktif (Pixel-Shifting 45s)' : 'Nonaktif',
            icon: CupertinoIcons.shield_lefthalf_fill,
          ),
          const Divider(height: 16, color: BusinessTheme.borderSubtle),
          _buildConfigItem(
            label: 'Tingkat Kecerahan Otomatis',
            value: 'Aktif: ${(_config.aodActiveBrightness * 100).toInt()}% • Redup: ${(_config.aodIdleBrightness * 100).toInt()}%',
            icon: CupertinoIcons.sun_max_fill,
          ),
          const Divider(height: 16, color: BusinessTheme.borderSubtle),
          _buildConfigItem(
            label: 'Keamanan PIN Keluar Kiosk',
            value: 'Default: 1234 (Tekan lama logo toko)',
            icon: CupertinoIcons.lock_shield,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: BusinessTheme.textMuted, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: BusinessTheme.textMuted, fontSize: 12),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: BusinessTheme.textLight,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItemsList() {
    return Container(
      decoration: BusinessTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'VISIBILITAS MENU DISPLAY AOD',
                style: TextStyle(
                  color: BusinessTheme.goldAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${_menuItems.where((i) => i.showInAod).length}/${_menuItems.length} Aktif',
                style: const TextStyle(color: BusinessTheme.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._menuItems.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: BusinessTheme.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BusinessTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  BusinessMenuAssetImage(
                    assetUrl: item.assetUrl,
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: BusinessTheme.textLight,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.category} • ${item.formattedPrice}',
                          style: const TextStyle(
                            color: BusinessTheme.textMuted,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    value: item.showInAod,
                    activeTrackColor: BusinessTheme.goldAccent,
                    onChanged: (val) => _toggleItemAodVisibility(item, val),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
