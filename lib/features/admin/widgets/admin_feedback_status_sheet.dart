import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/feedback_item.dart';
import '../../../services/feedback_service.dart';
import '../../../theme/app_theme.dart';

class AdminFeedbackStatusSheet {
  static Future<void> show(BuildContext context, FeedbackItem fb, VoidCallback onSuccess) async {
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
                    onSuccess();
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
}
