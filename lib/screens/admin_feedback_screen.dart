import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/admin/widgets/admin_feedback_card.dart';
import '../features/admin/widgets/admin_feedback_category_filter.dart';
import '../features/admin/widgets/admin_feedback_stats_card.dart';
import '../features/admin/widgets/admin_feedback_status_sheet.dart';
import '../models/feedback_item.dart';
import '../services/feedback_service.dart';
import '../theme/app_theme.dart';

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
                    if (_stats != null) AdminFeedbackStatsCard(stats: _stats!),
                    const SizedBox(height: 16),

                    // Category Filter Pills
                    AdminFeedbackCategoryFilter(
                      selectedCategoryFilter: _selectedCategoryFilter,
                      onSelectCategory: (c) => setState(() => _selectedCategoryFilter = c),
                    ),
                    const SizedBox(height: 16),

                    // List Feedbacks
                    _buildFeedbacksList(),
                  ],
                ),
              ),
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
        return AdminFeedbackCard(
          feedback: fb,
          onDelete: () => _deleteFeedback(fb),
          onUpdateStatus: () => AdminFeedbackStatusSheet.show(context, fb, _loadData),
        );
      },
    );
  }
}
