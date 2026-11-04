import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class RadarCityPickerSheet {
  static void show({
    required BuildContext context,
    required Map<String, List<double>> cityPresets,
    required String currentLocationName,
    required Function(String name, double lat, double lng) onSelectCity,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Lokasi Pencarian Beans Radar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: cityPresets.entries.map((e) {
                    final isSel = currentLocationName == e.key;
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        isSel ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.location,
                        color: isSel ? AppTheme.primaryBrown : Colors.grey,
                      ),
                      title: Text(
                        e.key,
                        style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                      ),
                      onTap: () {
                        onSelectCity(e.key, e.value[0], e.value[1]);
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
