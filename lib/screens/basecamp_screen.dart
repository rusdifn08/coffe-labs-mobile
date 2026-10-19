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
    );
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
        title: const Text('Basecamps'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Live Audio Rooms', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.1),
                                    child: const Icon(CupertinoIcons.mic_fill, color: AppTheme.primaryBrown, size: 30),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.green, 
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Text('24', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text('Q&A V60', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('Your Groups', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          FutureBuilder<List<dynamic>>(
            future: _basecampsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(child: Center(child: Text('Error: ${snapshot.error}')));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: Text('No Basecamps found. Create one!')),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryBrown,
        onPressed: _showCreateDialog,
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
    );
  }
}
