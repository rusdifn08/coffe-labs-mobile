import 'package:flutter/material.dart';
import '../../../../services/audio_service.dart';
import '../../../../services/smart_scale_service.dart';
import '../../../../theme/app_theme.dart';
import '../../../smart_scale/widgets/scale_device_sheet.dart';
import '../../tts/brewing_tts_service.dart';

/// Vertical column of 3 icon-only quick controls positioned to the right of
/// `CircularBrewTimer` (leaving the timer strictly centered):
/// 1. Music (Background brewing music ON/OFF)
/// 2. Speaks (Text-To-Speech voice guidance ON/OFF)
/// 3. Bluetooth (Real BLE Smart Scale connection)
///
/// Unified color semantics:
/// - Active / Really Connected => vibrant green (#16A34A) with white icon.
/// - Inactive / Disconnected   => default neutral white with warm border.
class BrewTimerSideControls extends StatelessWidget {
  final bool isEn;
  final bool isBrewingRunning;

  const BrewTimerSideControls({
    super.key,
    required this.isEn,
    required this.isBrewingRunning,
  });

  static const Color activeGreen = Color(0xFF16A34A);
  static const Color activeGreenBorder = Color(0xFF15803D);
  static const Color defaultBg = Colors.white;
  static const Color defaultIconColor = AppTheme.textMuted;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Music (BGM) Toggle
        ValueListenableBuilder<bool>(
          valueListenable: AudioService.bgmEnabledNotifier,
          builder: (context, isMusicOn, _) {
            return _SideIconCircleButton(
              buttonKey: const Key('brew_side_music_btn'),
              isActive: isMusicOn,
              icon: isMusicOn
                  ? Icons.music_note_rounded
                  : Icons.music_off_rounded,
              tooltip: isMusicOn
                  ? (isEn ? 'Disable Brew Music' : 'Nonaktifkan Musik Latar')
                  : (isEn ? 'Enable Brew Music' : 'Aktifkan Musik Latar'),
              onTap: () async {
                await AudioService.toggleBgmEnabled(
                  resumeIfBrewing: isBrewingRunning,
                );
                if (!context.mounted) return;
                final nowOn = AudioService.isBgmEnabled;
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      nowOn
                          ? (isEn
                              ? 'Background music enabled'
                              : 'Musik latar seduhan aktif')
                          : (isEn
                              ? 'Background music disabled'
                              : 'Musik latar seduhan nonaktif'),
                    ),
                    duration: const Duration(milliseconds: 900),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 10),

        // 2. Speaks (Text-To-Speech) Toggle
        ValueListenableBuilder<bool>(
          valueListenable: BrewingTTSService.instance.isEnabledNotifier,
          builder: (context, isSpeaksOn, _) {
            return _SideIconCircleButton(
              buttonKey: const Key('brew_side_speaks_btn'),
              isActive: isSpeaksOn,
              icon: isSpeaksOn
                  ? Icons.record_voice_over_rounded
                  : Icons.voice_over_off_rounded,
              tooltip: isSpeaksOn
                  ? (isEn ? 'Disable Voice Guide (TTS)' : 'Nonaktifkan Suara Panduan (TTS)')
                  : (isEn ? 'Enable Voice Guide (TTS)' : 'Aktifkan Suara Panduan (TTS)'),
              onTap: () {
                BrewingTTSService.instance.toggleEnabled();
                final nowOn = BrewingTTSService.instance.isEnabled;
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      nowOn
                          ? (isEn
                              ? 'Voice guidance (TTS) enabled'
                              : 'Panduan suara (TTS) aktif')
                          : (isEn
                              ? 'Voice guidance (TTS) disabled'
                              : 'Panduan suara (TTS) nonaktif'),
                    ),
                    duration: const Duration(milliseconds: 900),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 10),

        // 3. Bluetooth Real Smart Scale Button
        ListenableBuilder(
          listenable: SmartScaleService.instance,
          builder: (context, _) {
            final scale = SmartScaleService.instance;
            final isConnected = scale.isConnected;
            final isScanning = scale.isScanning;

            return _SideIconCircleButton(
              buttonKey: const Key('brew_side_bluetooth_btn'),
              isActive: isConnected,
              icon: isConnected
                  ? Icons.bluetooth_connected_rounded
                  : (isScanning
                      ? Icons.bluetooth_searching_rounded
                      : Icons.bluetooth_rounded),
              tooltip: isConnected
                  ? (isEn
                      ? 'Scale Connected: ${scale.activeDevice?.name ?? 'BLE Scale'}'
                      : 'Timbangan Terhubung: ${scale.activeDevice?.name ?? 'BLE Scale'}')
                  : (isEn
                      ? 'Connect Bluetooth Smart Scale'
                      : 'Hubungkan Timbangan Bluetooth'),
              onTap: () => ScaleDeviceSheet.show(context, scale),
            );
          },
        ),
      ],
    );
  }
}

class _SideIconCircleButton extends StatelessWidget {
  final Key buttonKey;
  final bool isActive;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _SideIconCircleButton({
    required this.buttonKey,
    required this.isActive,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          key: buttonKey,
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isActive
                  ? BrewTimerSideControls.activeGreen
                  : BrewTimerSideControls.defaultBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? BrewTimerSideControls.activeGreenBorder
                    : AppTheme.borderWarm,
                width: isActive ? 1.5 : 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isActive
                      ? BrewTimerSideControls.activeGreen.withValues(alpha: 0.28)
                      : AppTheme.primaryBrown.withValues(alpha: 0.08),
                  blurRadius: isActive ? 8 : 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: isActive
                  ? Colors.white
                  : BrewTimerSideControls.defaultIconColor,
            ),
          ),
        ),
      ),
    );
  }
}
