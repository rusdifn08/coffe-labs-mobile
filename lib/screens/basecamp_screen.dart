import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class BasecampScreen extends StatefulWidget {
  const BasecampScreen({super.key});

  @override
  State<BasecampScreen> createState() => _BasecampScreenState();
}

class _BasecampScreenState extends State<BasecampScreen> {
  late Future<List<dynamic>> _basecampsFuture;

  @override
  void initState() {
    super.initState();
    _loadBasecamps();
  }

  void _loadBasecamps() {
    setState(() {
      _basecampsFuture = ApiService.getBasecamps();
    });
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    bool isPrivate = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Create Basecamp'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Basecamp Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descCtrl,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Private Group'),
                    value: isPrivate,
                    activeThumbColor: AppTheme.primaryBrown,
                    onChanged: (val) {
                      setModalState(() => isPrivate = val);
                    },
                  )
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty) return;
                    Navigator.pop(ctx);
                    try {
                      await ApiService.createBasecamp({
                        "name": nameCtrl.text,
                        "description": descCtrl.text,
                        "isPrivate": isPrivate
                      });
                      _loadBasecamps();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  child: const Text('Create', style: TextStyle(color: Colors.white)),
                )
              ],
            );
          }
        );
      },
    ).whenComplete(() {
      nameCtrl.dispose();
      descCtrl.dispose();
    });
  }

  void _confirmDelete(int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Basecamp?'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiService.deleteBasecamp(id);
                _loadBasecamps();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basecamp Komunitas'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryBrown,
                          AppTheme.primaryBrown.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBrown.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(CupertinoIcons.person_3_fill, color: AppTheme.accentGold, size: 26),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BASECAMP KOMUNITAS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: AppTheme.accentGold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Ruang Kumpul Barista',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Wadah grup seduh, diskusi resep, dan sharing tips kopi antar barista.',
                                style: TextStyle(fontSize: 11, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Daftar Grup Basecamp', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: _showCreateDialog,
                        icon: const Icon(CupertinoIcons.plus_circle_fill, size: 16, color: AppTheme.primaryBrown),
                        label: const Text('Buat Grup', style: TextStyle(color: AppTheme.primaryBrown, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder<List<dynamic>>(
            future: _basecampsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown)),
                  ),
                );
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.person_3, size: 54, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum Ada Basecamp Komunitas',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Jadilah yang pertama membuat ruang kumpul dan berdiskusi seduhan!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBrown,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _showCreateDialog,
                            icon: const Icon(CupertinoIcons.add, size: 16),
                            label: const Text('Buat Basecamp Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              List<dynamic> basecamps = snapshot.data!;
              
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var bc = basecamps[index];
                    String name = bc['name'] ?? 'Unknown';
                    String desc = bc['description'] ?? 'No description';
                    bool isPrivate = bc['isPrivate'] ?? false;
                    int id = bc['id'];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      leading: Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: AppTheme.accentAmber,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: AppTheme.accentAmber.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                          ]
                        ),
                        child: Center(
                          child: Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                          if (isPrivate) const Icon(CupertinoIcons.lock_fill, size: 14, color: AppTheme.textMuted),
                        ],
                      ),
                      subtitle: Text(desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textMuted)),
                      trailing: IconButton(
                        icon: const Icon(CupertinoIcons.trash, color: Colors.red, size: 20),
                        onPressed: () => _confirmDelete(id, name),
                      ),
                      onTap: () {},
                    );
                  },
                  childCount: basecamps.length,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'basecamp_create_fab',
        backgroundColor: AppTheme.primaryBrown,
        foregroundColor: Colors.white,
        onPressed: _showCreateDialog,
        icon: const Icon(CupertinoIcons.add, color: Colors.white, size: 18),
        label: const Text('Buat Basecamp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}
