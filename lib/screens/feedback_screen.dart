import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/feedback_item.dart';
import '../services/feedback_service.dart';
import '../services/profile_service.dart';

class FeedbackScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialFeature;

  const FeedbackScreen({
    super.key,
    this.initialCategory,
    this.initialFeature,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late String _selectedCategory;
  late String _selectedFeature;
  int _selectedRating = 5;

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? FeedbackCategory.all.first.key;
    _selectedFeature = widget.initialFeature ?? FeedbackService.commonFeatures.first;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String _getTitleHint() {
    switch (_selectedCategory) {
      case 'bug_report':
        return 'Contoh: Timer berhenti saat lock screen';
      case 'feature_request':
        return 'Contoh: Tambahkan timer water flow rate / bluetooth scale';
      case 'recipe_feedback':
        return 'Contoh: Saran suhu seduh untuk biji Anaerobic Honey';
      case 'ui_ux':
        return 'Contoh: Perbesar ukuran teks deskripsi cupping';
      default:
        return 'Contoh: Kesan atau saran Anda';
    }
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Sangat Perlu Perbaikan';
      case 2:
        return 'Kurang Memuaskan';
      case 3:
        return 'Cukup Baik';
      case 4:
        return 'Sangat Bagus!';
      case 5:
        return 'Luar Biasa & Sempurna! ☕';
      default:
        return '';
    }
  }

  Future<void> _handleSubmit() async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (title.isEmpty) {
      setState(() => _errorMessage = 'Harap isi judul masukan.');
      return;
    }
    if (desc.isEmpty) {
      setState(() => _errorMessage = 'Harap isi deskripsi masukan secara singkat.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final userName = await ProfileService.getUserName();

    final success = await FeedbackService.submitFeedback(
      category: _selectedCategory,
      featureAffected: _selectedFeature,
      title: title,
      description: desc,
      rating: _selectedRating,
      guestName: userName.isNotEmpty ? userName : 'Barista Tamu',
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      _showSuccessDialog();
    } else {
      setState(() {
        _errorMessage = 'Gagal mengirim feedback. Pastikan perangkat terhubung ke internet atau coba sesaat lagi.';
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.checkmark_seal_fill, color: Colors.green, size: 40),
              ),
              const SizedBox(height: 18),
              const Text(
                'Feedback Terkirim!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Terima kasih banyak atas masukan Anda. Tim kami dan Admin Rusdi akan meninjau saran ini untuk pembaruan fitur berikutnya.',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context); // Return to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Kembali', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Beri Masukan & Feedback'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBrown, const Color(0xFF4A2F18)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBrown.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
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
                    child: const Icon(CupertinoIcons.chat_bubble_2_fill, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suara Anda Membangun Coffee Labs',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Laporkan bug, usulkan fitur impian, atau beri saran resep langsung ke tim pengembang.',
                          style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Error banner if any
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.exclamationmark_circle_fill, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Section 1: Kategori Feedback
            _buildSectionTitle('1. Jenis Masukan (Kategori)', CupertinoIcons.square_grid_2x2_fill),
            const SizedBox(height: 10),
            _buildCategorySelector(),

            const SizedBox(height: 22),

            // Section 2: Fitur yang Terkait
            _buildSectionTitle('2. Fitur Terkait', CupertinoIcons.wrench_fill),
            const SizedBox(height: 10),
            _buildFeatureSelector(),

            const SizedBox(height: 22),

            // Section 3: Rating Kepuasan
            _buildSectionTitle('3. Tingkat Kepuasan Anda', CupertinoIcons.star_fill),
            const SizedBox(height: 10),
            _buildRatingSelector(),

            const SizedBox(height: 22),

            // Section 4: Judul Masukan
            _buildSectionTitle('4. Judul Masukan / Masalah', CupertinoIcons.pencil_ellipsis_rectangle),
            const SizedBox(height: 10),
            TextField(
              controller: _titleCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: _getTitleHint(),
                hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.surfaceWhite,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),

            const SizedBox(height: 22),

            // Section 5: Deskripsi Lengkap
            _buildSectionTitle('5. Detail Masukan & Harapan Anda', CupertinoIcons.text_alignleft),
            const SizedBox(height: 10),
            TextField(
              controller: _descCtrl,
              maxLines: 5,
              maxLength: 1000,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Jelaskan sedetail mungkin apa yang terjadi atau bagaimana fitur yang Anda usulkan dapat membantu proses menyeduh kopi Anda...',
                hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
                filled: true,
                fillColor: AppTheme.surfaceWhite,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 26),

            // Tombol Kirim
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(CupertinoIcons.paperplane_fill, size: 20),
              label: Text(
                _isSubmitting ? 'Mengirim Masukan...' : 'Kirim Feedback Sekarang',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryBrown),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      children: FeedbackCategory.all.map((cat) {
        final isSelected = _selectedCategory == cat.key;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            onTap: () => setState(() => _selectedCategory = cat.key),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? cat.color.withValues(alpha: 0.1) : AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? cat.color : AppTheme.primaryBrown.withValues(alpha: 0.1),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? cat.color : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cat.description,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(CupertinoIcons.checkmark_circle_fill, color: cat.color, size: 20),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: FeedbackService.commonFeatures.map((feat) {
        final isSelected = _selectedFeature == feat;
        return ChoiceChip(
          label: Text(feat),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedFeature = feat),
          selectedColor: AppTheme.primaryBrown,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
          backgroundColor: AppTheme.surfaceWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppTheme.primaryBrown : AppTheme.primaryBrown.withValues(alpha: 0.15),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRatingSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starNumber = index + 1;
              final isFilled = starNumber <= _selectedRating;
              return GestureDetector(
                onTap: () => setState(() => _selectedRating = starNumber),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    isFilled ? CupertinoIcons.star_fill : CupertinoIcons.star,
                    color: isFilled ? Colors.amber : Colors.grey.shade300,
                    size: 36,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _getRatingText(_selectedRating),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
          ),
        ],
      ),
    );
  }
}
