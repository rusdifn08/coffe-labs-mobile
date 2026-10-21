import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/feedback_item.dart';
import '../services/feedback_service.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FeedbackItem> _feedbacks = [];
  FeedbackStatsData? _stats;
  bool _isLoading = true;
  String? _selectedCategoryFilter;

  final List<String> _statusTabs = ['all', 'pending', 'in_progress', 'resolved'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _loadData();
    FeedbackService.changeNotifier.addListener(_loadData);
  }

  @override
  void dispose() {
    FeedbackService.changeNotifier.removeListener(_loadData);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final stats = await FeedbackService.getFeedbackStats();
    final list = await FeedbackService.getAdminFeedbacks();

    if (!mounted) return;
    setState(() {
      _stats = stats;
      _feedbacks = list;
      _isLoading = false;
    });
  }

  Future<void> _showUpdateStatusSheet(FeedbackItem fb) async {
    String currentStatus = fb.status;
    final notesCtrl = TextEditingController(text: fb.adminNotes ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Perbarui Status Feedback',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.textDark),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Masukan: "${fb.title}"',
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 18),

              // Status Radios
              const Text('Pilih Status:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['pending', 'in_progress', 'resolved', 'dismissed'].map((st) {
                  final isSelected = currentStatus == st;
                  final color = FeedbackStatusHelper.getColor(st);
                  return ChoiceChip(
                    label: Text(FeedbackStatusHelper.getLabel(st)),
                    selected: isSelected,
                    onSelected: (_) => setSheetState(() => currentStatus = st),
                    selectedColor: color,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    backgroundColor: color.withValues(alpha: 0.1),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              const Text('Catatan Internal Admin (Opsional):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Misal: Sedang diperbaiki di v1.1.0 atau sudah diimplementasikan.',
                  filled: true,
                  fillColor: AppTheme.bgCream,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final success = await FeedbackService.updateFeedbackStatus(
                    fb.id,
                    currentStatus,
                    adminNotes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (success) {
                    _loadData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteFeedback(FeedbackItem fb) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Yakin ingin menghapus feedback '${fb.title}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await FeedbackService.deleteFeedback(fb.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback berhasil dihapus.'), backgroundColor: Colors.brown),
      );
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Pusat Feedback User'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.arrow_clockwise),
            tooltip: 'Segarkan',
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBrown,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primaryBrown,
          indicatorWeight: 3,
          isScrollable: true,
          tabs: [
            Tab(text: 'Semua (${_feedbacks.length})'),
            Tab(text: 'Pending (${_stats?.pending ?? 0})'),
            Tab(text: 'Diproses (${_stats?.inProgress ?? 0})'),
            Tab(text: 'Selesai (${_stats?.resolved ?? 0})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown))
          : RefreshIndicator(
              color: AppTheme.primaryBrown,
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Summary Stats Card
                    if (_stats != null) _buildStatsGrid(_stats!),
                    const SizedBox(height: 16),

                    // Category Filter Pills
                    _buildCategoryFilterRow(),
                    const SizedBox(height: 16),

                    // List Feedbacks
                    _buildFeedbacksList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsGrid(FeedbackStatsData stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.chat_bubble_2_fill,
                  iconColor: AppTheme.primaryBrown,
                  label: 'Total Masukan',
                  value: '${stats.total}',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.clock_fill,
                  iconColor: Colors.orange,
                  label: 'Belum Ditinjau',
                  value: '${stats.pending}',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.star_fill,
                  iconColor: Colors.amber,
                  label: 'Rata-rata Rating',
                  value: '⭐ ${stats.averageRating.toStringAsFixed(1)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.dividerColor),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text('🐛', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text('${stats.bugReports} Bug Report', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text('${stats.featureRequests} Ide Fitur', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.checkmark_seal_fill, size: 14, color: Colors.green),
                    const SizedBox(width: 6),
                    Text('${stats.resolved} Selesai', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _buildCategoryFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Semua Kategori'),
            selected: _selectedCategoryFilter == null,
            onSelected: (_) => setState(() => _selectedCategoryFilter = null),
            selectedColor: AppTheme.primaryBrown,
            labelStyle: TextStyle(
              color: _selectedCategoryFilter == null ? Colors.white : AppTheme.textDark,
              fontWeight: _selectedCategoryFilter == null ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          ...FeedbackCategory.all.map((cat) {
            final isSelected = _selectedCategoryFilter == cat.key;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text('${cat.emoji} ${cat.label}'),
                selected: isSelected,
                onSelected: (_) => setState(() {
                  _selectedCategoryFilter = isSelected ? null : cat.key;
                }),
                selectedColor: cat.color,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeedbacksList() {
    final activeTabStatus = _statusTabs[_tabController.index];

    List<FeedbackItem> filtered = _feedbacks;
    if (activeTabStatus != 'all') {
      filtered = filtered.where((f) => f.status.toLowerCase() == activeTabStatus).toList();
    }
    if (_selectedCategoryFilter != null) {
      filtered = filtered.where((f) => f.category.toLowerCase() == _selectedCategoryFilter).toList();
    }

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(CupertinoIcons.tray, size: 48, color: AppTheme.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text(
              'Tidak ada feedback pada filter ini.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final fb = filtered[index];
        final cat = fb.categoryInfo;
        final statusColor = FeedbackStatusHelper.getColor(fb.status);
        final statusLabel = FeedbackStatusHelper.getLabel(fb.status);

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          elevation: 1.5,
          color: AppTheme.surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Category badge + Status chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat.emoji, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            cat.label,
                            style: TextStyle(color: cat.color, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  fb.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                ),
                const SizedBox(height: 4),

                // Feature affected & Rating
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCream,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Fitur: ${fb.featureAffected}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.primaryBrown),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(5, (starIdx) {
                        return Icon(
                          starIdx < fb.rating ? CupertinoIcons.star_fill : CupertinoIcons.star,
                          size: 12,
                          color: Colors.amber,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Description
                Text(
                  fb.description,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
                ),

                // Admin notes if present
                if (fb.adminNotes != null && fb.adminNotes!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(CupertinoIcons.pencil_circle_fill, size: 14, color: Colors.purple),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Catatan Admin: ${fb.adminNotes}',
                            style: const TextStyle(fontSize: 11, color: Colors.purple, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1, color: AppTheme.dividerColor),
                const SizedBox(height: 10),

                // Sender Info & Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Oleh @${fb.username} (${fb.userRole}) · ${fb.deviceInfo}',
                      style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(CupertinoIcons.trash, size: 18, color: Colors.redAccent),
                          tooltip: 'Hapus',
                          onPressed: () => _deleteFeedback(fb),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showUpdateStatusSheet(fb),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBrown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(CupertinoIcons.pencil, size: 13),
                          label: const Text('Update Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
