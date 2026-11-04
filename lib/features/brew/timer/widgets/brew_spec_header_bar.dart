import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../services/audio_service.dart';
import '../../../../services/language_service.dart';
import '../../../../theme/app_theme.dart';

/// Specification header bar displayed beneath the AppBar in BrewTimerScreen.
/// Displays bean name, ratio, water temperature, grind size, and speaker sound toggle.
class BrewSpecHeaderBar extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback? onMuteToggled;

  const BrewSpecHeaderBar({
    super.key,
    required this.recipe,
    this.onMuteToggled,
  });

  static String _formatBeanName(Map<String, dynamic> recipe) {
    final bean = recipe['beanName']?.toString().trim();
    if (bean != null && bean.isNotEmpty && bean != 'Specialty Single Origin') {
      return bean;
    }
    final title = recipe['title']?.toString().trim();
    if (title != null && title.isNotEmpty) {
      return title;
    }
    return 'Kopi Excelsa';
  }

  static String _formatRatio(num coffee, int water) {
    if (coffee <= 0) return '1:15';
    final ratio = water / coffee;
    if (ratio == ratio.roundToDouble()) {
      return '1:${ratio.toInt()}';
    }
    return '1:${ratio.toStringAsFixed(1)}';
  }

  static String _formatGrind(String rawGrind) {
    final trimmed = rawGrind.trim();
    if (trimmed.isEmpty) return 'Medium 900 µm';
    if (trimmed == 'Medium (22 Klik Comandante)') return 'Medium 900 µm';
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final beanName = _formatBeanName(recipe);
    final num coffeeWeight = recipe['coffeeWeightGrams'] ?? 15;
    final int waterGrams = recipe['totalWaterWeightGrams'] ?? 225;
    final int waterTemp = recipe['waterTempCelsius'] ?? 91;
    final String rawGrind = (recipe['grindSize'] ?? 'Medium 900 µm').toString();
    final String grindText = _formatGrind(rawGrind);

    final String coffeeDoseStr = coffeeWeight == coffeeWeight.roundToDouble()
        ? '${coffeeWeight.toInt()} g'
        : '${coffeeWeight.toStringAsFixed(1)} g';
    final String waterStr = '$waterGrams ml';
    final String ratioStr = _formatRatio(coffeeWeight, waterGrams);
    final String specDetails = '$coffeeDoseStr : $waterStr ($ratioStr) · $waterTemp °C · $grindText';

    return ValueListenableBuilder<bool>(
      valueListenable: AudioService.isMutedNotifier,
      builder: (context, isMuted, _) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderWarm),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBrown.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Coffee Bean / Droplet Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.drop_fill,
                  size: 15,
                  color: AppTheme.primaryBrown,
                ),
              ),
              const SizedBox(width: 10),

              // Specifications Text (Bean Name & Brew Parameters)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      beanName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1.5),
                    Text(
                      specDetails,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Speaker Mute / Unmute Button on the far right
              Tooltip(
                message: isMuted
                    ? (isEn ? 'Unmute Sound' : 'Aktifkan Suara')
                    : (isEn ? 'Mute Sound' : 'Mute Suara'),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      AudioService.toggleMute();
                      onMuteToggled?.call();
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AudioService.isMuted
                                ? (isEn ? 'Brew audio muted 🔇' : 'Suara seduhan dimatikan 🔇')
                                : (isEn ? 'Brew audio enabled 🔊' : 'Suara seduhan diaktifkan 🔊'),
                          ),
                          duration: const Duration(milliseconds: 900),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isMuted
                            ? Colors.grey.shade100
                            : AppTheme.accentGold.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isMuted
                              ? Colors.grey.shade300
                              : AppTheme.accentGold.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        isMuted
                            ? CupertinoIcons.speaker_slash_fill
                            : CupertinoIcons.speaker_2_fill,
                        size: 16,
                        color: isMuted ? Colors.grey : AppTheme.primaryBrown,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
