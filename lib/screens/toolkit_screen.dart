import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/barista_utils.dart';
import 'barista_profile_screen.dart';
import 'bean_radar_screen.dart';
import 'brew_journal_screen.dart';
import 'favorites_screen.dart';
import 'flavor_wheel_screen.dart';
import 'smart_scale_screen.dart';
import 'taste_match_screen.dart';

/// Menggantikan tab Market yang tutup — toolkit praktis untuk barista.
class ToolkitScreen extends StatefulWidget {
  const ToolkitScreen({super.key});

  @override
  State<ToolkitScreen> createState() => _ToolkitScreenState();
}

class _ToolkitScreenState extends State<ToolkitScreen> {
  List<Map<String, dynamic>> _baristas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ApiService.getUniqueBaristas();
    if (!mounted) return;
    setState(() {
      _baristas = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toolkit Barista'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryBrown,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              'Alat harian untuk latihan, pencatatan, dan eksplorasi rasa.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _toolCard(
                  context,
                  icon: CupertinoIcons.heart_fill,
                  title: 'Favorit',
                  subtitle: 'Resep tersimpan',
                  color: Colors.redAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  ),
                ),
                _toolCard(
                  context,
                  icon: CupertinoIcons.doc_text_fill,
                  title: 'Jurnal Brew',
                  subtitle: 'Catatan hasil seduh',
                  color: AppTheme.primaryBrown,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BrewJournalScreen()),
                  ),
                ),
                _toolCard(
                  context,
                  icon: CupertinoIcons.heart_circle_fill,
                  title: 'Taste Match',
                  subtitle: 'Cocokkan selera',
                  color: AppTheme.accentAmber,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TasteMatchScreen()),
                  ),
                ),
                _toolCard(
                  context,
                  icon: CupertinoIcons.circle_grid_hex_fill,
                  title: 'Flavor Wheel',
                  subtitle: 'Peta aroma kopi',
                  color: Colors.deepOrange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FlavorWheelScreen()),
                  ),
                ),
                _toolCard(
                  context,
                  icon: CupertinoIcons.graph_square_fill,
                  title: 'Bean Radar',
                  subtitle: 'Profil biji',
                  color: Colors.teal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BeanRadarScreen()),
                  ),
                ),
                _toolCard(
                  context,
                  icon: CupertinoIcons.device_phone_portrait,
                  title: 'Smart Scale',
                  subtitle: 'Simulasi timbangan',
                  color: Colors.indigo,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SmartScaleScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text('Spotlight Barista', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text(
              'Tap foto untuk melihat profil & semua resepnya.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 14),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown)),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _baristas.length,
                  itemBuilder: (context, index) {
                    final b = _baristas[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BaristaProfileScreen(
                              rawAuthor: b['author'] as String,
                              imageUrl: b['imageUrl'] as String?,
                              coverImageUrl: b['coverImageUrl'] as String?,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 88,
                        margin: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            BaristaAvatar(
                              imageUrl: b['imageUrl'] as String?,
                              radius: 32,
                              heroTag: 'barista_${BaristaUtils.slugFromAuthor(b['author'] as String)}',
                            ),
                            const SizedBox(height: 8),
                            Text(
                              b['name'] as String,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _toolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 52) / 2,
      child: Material(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
