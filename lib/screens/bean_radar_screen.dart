import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BeanRadarScreen extends StatelessWidget {
  const BeanRadarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bean Radar'), centerTitle: true),
      body: Column(
        children: [
          // Radar Animation Mockup
          Container(
            height: 300,
            width: double.infinity,
            color: AppTheme.bgCream,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(CupertinoIcons.waveform_path_badge_plus, size: 150, color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
                const Icon(CupertinoIcons.location_solid, size: 40, color: AppTheme.primaryBrown),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nearby Roasteries', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(backgroundColor: AppTheme.accentAmber, child: Icon(CupertinoIcons.building_2_fill, color: Colors.white)),
                          title: const Text('Blue Bottle Coffee', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('1.2 km away • Closes at 8PM'),
                          trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
