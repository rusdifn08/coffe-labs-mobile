import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../models/beans_radar_models.dart';
import '../controllers/radar_gps_controller.dart';

class RadarFloatingControls extends StatelessWidget {
  final TextEditingController searchController;
  final RadarGpsState state;
  final VoidCallback onBack;
  final VoidCallback onRecenterGps;
  final VoidCallback onOpenCityPicker;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<RadarAppMode> onRadarModeChanged;
  final ValueChanged<CoffeePlaceCategory> onCategoryChanged;
  final VoidCallback onToggleOpenNow;
  final VoidCallback onToggleMinRating;
  final ValueChanged<double> onRadiusChanged;
  final VoidCallback onSearchThisArea;

  const RadarFloatingControls({
    super.key,
    required this.searchController,
    required this.state,
    required this.onBack,
    required this.onRecenterGps,
    required this.onOpenCityPicker,
    required this.onSearchChanged,
    required this.onRadarModeChanged,
    required this.onCategoryChanged,
    required this.onToggleOpenNow,
    required this.onToggleMinRating,
    required this.onRadiusChanged,
    required this.onSearchThisArea,
  });

  static const List<double> _radiusChoices = [3.0, 10.0, 15.0, 25.0, 50.0, 150.0];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: Row(
              children: [
                _CircleIconBtn(
                  icon: CupertinoIcons.back,
                  tooltip: 'Kembali',
                  onTap: onBack,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(
                          CupertinoIcons.search,
                          size: 16,
                          color: AppTheme.primaryBrown,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            onChanged: onSearchChanged,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: state.radarMode.searchHint,
                              hintStyle: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 9,
                              ),
                            ),
                          ),
                        ),
                        if (state.searchQuery.isNotEmpty)
                          IconButton(
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                            icon: const Icon(
                              CupertinoIcons.clear_circled_solid,
                              size: 16,
                              color: AppTheme.textMuted,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 30),
                          ),
                        InkWell(
                          onTap: onOpenCityPicker,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(
                              CupertinoIcons.map_pin_ellipse,
                              size: 17,
                              color: state.hasRealGpsFix
                                  ? Colors.green.shade700
                                  : AppTheme.primaryBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _CircleIconBtn(
                  icon: CupertinoIcons.location_fill,
                  tooltip: 'Lokasi GPS Real-Time',
                  isBusy: state.isLocating,
                  highlight: state.hasRealGpsFix,
                  onTap: onRecenterGps,
                ),
              ],
            ),
          ),

          // Dual-Scope Segmented Radar Mode Toggle (Semua | Cafe Radar | Beans Radar)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _RadarScopeTab(
                    label: 'Semua',
                    icon: CupertinoIcons.compass_fill,
                    selected: state.radarMode == RadarAppMode.all,
                    onTap: () => onRadarModeChanged(RadarAppMode.all),
                  ),
                  _RadarScopeTab(
                    label: 'Cafe Radar',
                    icon: Icons.coffee_rounded,
                    selected: state.radarMode == RadarAppMode.cafe,
                    onTap: () => onRadarModeChanged(RadarAppMode.cafe),
                  ),
                  _RadarScopeTab(
                    label: 'Beans Radar',
                    icon: CupertinoIcons.flame_fill,
                    selected: state.radarMode == RadarAppMode.beans,
                    onTap: () => onRadarModeChanged(RadarAppMode.beans),
                  ),
                ],
              ),
            ),
          ),

          // Horizontal Filter Chips Row
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterPill(
                  label: 'Semua',
                  selected: state.selectedCategory == CoffeePlaceCategory.all,
                  onTap: () => onCategoryChanged(CoffeePlaceCategory.all),
                ),
                _FilterPill(
                  label: 'Roastery',
                  icon: CupertinoIcons.flame_fill,
                  selected:
                      state.selectedCategory == CoffeePlaceCategory.roastery,
                  onTap: () => onCategoryChanged(CoffeePlaceCategory.roastery),
                ),
                _FilterPill(
                  label: 'Cafe',
                  icon: Icons.coffee_rounded,
                  selected:
                      state.selectedCategory == CoffeePlaceCategory.coffeeShop,
                  onTap: () =>
                      onCategoryChanged(CoffeePlaceCategory.coffeeShop),
                ),
                _FilterPill(
                  label: 'Resto Kopi',
                  icon: Icons.restaurant_rounded,
                  selected:
                      state.selectedCategory == CoffeePlaceCategory.cafeResto,
                  onTap: () => onCategoryChanged(CoffeePlaceCategory.cafeResto),
                ),
                _FilterPill(
                  label: 'Specialty',
                  icon: Icons.coffee_maker_rounded,
                  selected: state.selectedCategory ==
                      CoffeePlaceCategory.specialtyCafe,
                  onTap: () =>
                      onCategoryChanged(CoffeePlaceCategory.specialtyCafe),
                ),
                _FilterPill(
                  label: 'Jual Biji',
                  icon: CupertinoIcons.bag_fill,
                  selected:
                      state.selectedCategory == CoffeePlaceCategory.beanSeller,
                  onTap: () =>
                      onCategoryChanged(CoffeePlaceCategory.beanSeller),
                ),
                _FilterPill(
                  label: 'Buka',
                  dotColor: const Color(0xFF16A34A),
                  selected: state.openNowOnly,
                  onTap: onToggleOpenNow,
                ),
                _FilterPill(
                  label: '4.5+',
                  icon: CupertinoIcons.star_fill,
                  selected: state.minRating >= 4.5,
                  onTap: onToggleMinRating,
                ),
                _RadiusDropdownPill(
                  selectedRadiusKm: state.selectedRadiusKm,
                  choices: _radiusChoices,
                  onSelected: onRadiusChanged,
                ),
              ],
            ),
          ),

          if (state.showSearchAreaButton && state.activeRoute == null) ...[
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: onSearchThisArea,
              icon: const Icon(CupertinoIcons.refresh_bold, size: 14),
              label: const Text(
                'Cari di Area Peta Ini',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryBrown,
                elevation: 4,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: AppTheme.primaryBrown.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RadarScopeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RadarScopeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryBrown : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: selected ? AppTheme.accentGold : AppTheme.primaryBrown,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isBusy;
  final bool highlight;

  const _CircleIconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isBusy = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 40,
            height: 40,
            child: isBusy
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppTheme.primaryBrown,
                    ),
                  )
                : Icon(
                    icon,
                    size: 18,
                    color: highlight ? Colors.green.shade700 : AppTheme.textDark,
                  ),
          ),
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? dotColor;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: selected ? AppTheme.primaryBrown : Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dotColor != null) ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: selected ? Colors.lightGreenAccent : dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    size: 12.5,
                    color: selected ? AppTheme.accentGold : AppTheme.primaryBrown,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadiusDropdownPill extends StatelessWidget {
  final double selectedRadiusKm;
  final List<double> choices;
  final ValueChanged<double> onSelected;

  const _RadiusDropdownPill({
    required this.selectedRadiusKm,
    required this.choices,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      child: PopupMenuButton<double>(
        initialValue: selectedRadiusKm,
        onSelected: onSelected,
        itemBuilder: (_) => choices
            .map(
              (r) => PopupMenuItem<double>(
                value: r,
                child: Text('Radius ${r.toInt()} km'),
              ),
            )
            .toList(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.circle_grid_3x3,
                size: 12.5,
                color: AppTheme.primaryBrown,
              ),
              const SizedBox(width: 4),
              Text(
                '${selectedRadiusKm.toInt()} km',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const Icon(Icons.arrow_drop_down_rounded, size: 15),
            ],
          ),
        ),
      ),
    );
  }
}
