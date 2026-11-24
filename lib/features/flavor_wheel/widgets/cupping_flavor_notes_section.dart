import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// Compact SCA Flavor Wheel & Tasting Notes card that opens `FlavorNotesPickerModal`
/// instead of flooding the page with 25+ chips.
class CuppingFlavorNotesSection extends StatelessWidget {
  final Set<String> selectedNotes;
  final VoidCallback onOpenNotesPopup;
  final ValueChanged<String> onRemoveNote;

  const CuppingFlavorNotesSection({
    super.key,
    required this.selectedNotes,
    required this.onOpenNotesPopup,
    required this.onRemoveNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.sparkles,
                color: AppTheme.accentAmber,
                size: 18,
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'Flavor Wheel & Tasting Notes',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  '${selectedNotes.length} Notes',
                  style: const TextStyle(
                    fontSize: 10.8,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Pilih profil aroma & rasa dari SCA Flavor Wheel lewat pop-up pencarian.',
            style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 11),

          if (selectedNotes.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: selectedNotes.map((note) {
                return InkWell(
                  onTap: () => onRemoveNote(note),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.2,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          CupertinoIcons.xmark,
                          size: 11,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 11),
          ],

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onOpenNotesPopup,
              icon: const Icon(CupertinoIcons.plus, size: 15),
              label: Text(
                selectedNotes.isEmpty
                    ? 'Pilih Tasting Notes (SCA Wheel)'
                    : 'Tambah / Ubah Tasting Notes',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryBrown,
                backgroundColor: AppTheme.bgCream,
                side: const BorderSide(color: AppTheme.primaryBrown),
                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
