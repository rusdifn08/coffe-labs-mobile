import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/kiosk_engine_service.dart';
import '../../../../models/business_pos_models.dart';
import 'customer_aod_menu_screen.dart';

/// Wrapper khusus untuk rute GoRouter `/business/aod-showcase`.
/// Mendukung instan hidrasi menu & konfigurasi dari Direct-Boot Device Protected Storage
/// saat tablet kasir dinyalakan ulang (cold-boot).
class AodKioskShowcaseRouteWrapper extends ConsumerStatefulWidget {
  final BusinessStoreConfig? passedConfig;
  final List<BusinessMenuItem>? passedMenuItems;

  const AodKioskShowcaseRouteWrapper({
    super.key,
    this.passedConfig,
    this.passedMenuItems,
  });

  @override
  ConsumerState<AodKioskShowcaseRouteWrapper> createState() =>
      _AodKioskShowcaseRouteWrapperState();
}

class _AodKioskShowcaseRouteWrapperState
    extends ConsumerState<AodKioskShowcaseRouteWrapper> {
  BusinessStoreConfig? _resolvedConfig;
  List<BusinessMenuItem>? _resolvedMenuItems;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _hydrateKioskState();
  }

  Future<void> _hydrateKioskState() async {
    if (widget.passedConfig != null) {
      setState(() {
        _resolvedConfig = widget.passedConfig;
        _resolvedMenuItems = widget.passedMenuItems ?? [];
        _isLoading = false;
      });
      return;
    }

    try {
      final payload = await KioskEngineService.getDirectBootPayload();
      BusinessStoreConfig config = BusinessStoreConfig.defaultBarConfig();
      List<BusinessMenuItem> items = [];

      if (payload['config_json'] != null &&
          payload['config_json'].toString().isNotEmpty) {
        final decodedConfig =
            json.decode(payload['config_json'].toString()) as Map<String, dynamic>;
        config = BusinessStoreConfig.fromJson(decodedConfig);
      }

      if (payload['menu_json'] != null &&
          payload['menu_json'].toString().isNotEmpty) {
        final decodedMenu = json.decode(payload['menu_json'].toString()) as List;
        items = decodedMenu
            .map((e) => BusinessMenuItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (mounted) {
        setState(() {
          _resolvedConfig = config;
          _resolvedMenuItems = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _resolvedConfig = BusinessStoreConfig.defaultBarConfig();
          _resolvedMenuItems = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CupertinoActivityIndicator(color: Color(0xFFD4AF37)),
        ),
      );
    }

    return CustomerAodMenuScreen(
      config: _resolvedConfig ?? BusinessStoreConfig.defaultBarConfig(),
      initialMenuItems: _resolvedMenuItems,
    );
  }
}
