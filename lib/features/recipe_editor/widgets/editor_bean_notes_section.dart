import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../data/brew_visual_catalog.dart';
import '../../../../theme/app_theme.dart';

class EditorBeanNotesSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController authorController;
  final TextEditingController beanController;
  final TextEditingController tastingController;
  final bool customBeanManual;
  final String selectedBeanName;
  final Set<String> selectedNoteLabels;
  final List<String> popularNotes;
  final List<BeanVisualItem> popularBeans;
  final VoidCallback onShowBeanModal;
  final VoidCallback onShowNotesModal;
  final ValueChanged<BeanVisualItem> onSelectPopularBean;
  final VoidCallback onToggleCustomBeanManual;
  final ValueChanged<String> onToggleNote;

  const EditorBeanNotesSection({
    super.key,
    required this.titleController,
    required this.authorController,
    required this.beanController,
    required this.tastingController,
    required this.customBeanManual,
    required this.selectedBeanName,
    required this.selectedNoteLabels,
    required this.popularNotes,
    required this.popularBeans,
    required this.onShowBeanModal,
    required this.onShowNotesModal,
    required this.onSelectPopularBean,
    required this.onToggleCustomBeanManual,
    required this.onToggleNote,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            '3. Biji Kopi, Varietas & Tasting Notes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(titleController, 'Judul Resep (contoh: Sweet Floral V60 Ryan)', CupertinoIcons.tag_fill),
              _field(authorController, 'Nama Pembuat Resep (Barista)', CupertinoIcons.person_fill),
              const Divider(height: 20),

              // BEAN SELECTION HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Biji Kopi / Origin:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  TextButton.icon(
                    onPressed: onShowBeanModal,
                    icon: const Icon(CupertinoIcons.square_grid_2x2_fill, size: 14, color: AppTheme.primaryBrown),
                    label: const Text(
                      'Lihat Semua',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                    ),
                  ),
                ],
              ),

              // TOP 5 BEANS HORIZONTAL
              SizedBox(
                height: 98,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...popularBeans.map((bean) {
                      final selected = !customBeanManual && selectedBeanName == bean.name;
                      return GestureDetector(
                        onTap: () => onSelectPopularBean(bean),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 154,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: selected ? bean.color.withValues(alpha: 0.12) : AppTheme.bgCream,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected ? bean.color : Colors.grey.shade300,
                              width: selected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: bean.color.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(bean.emoji, style: const TextStyle(fontSize: 20)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bean.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: selected ? bean.color : AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${bean.process} • ${bean.roast}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 9.5, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: onShowBeanModal,
                      child: Container(
                        width: 130,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCream,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.primaryBrown, width: 1.5),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.sparkles, color: AppTheme.primaryBrown, size: 24),
                            SizedBox(height: 4),
                            Text(
                              'Semua Biji',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                            ),
                            Text(
                              'Kustom Varietas',
                              style: TextStyle(fontSize: 9, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ACTIVE BEAN INFO BANNER
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.info_circle_fill, size: 16, color: AppTheme.primaryBrown),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          beanController.text.isEmpty ? 'Pilih biji di atas' : beanController.text,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.primaryBrown),
                        ),
                      ),
                      InkWell(
                        onTap: onToggleCustomBeanManual,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            customBeanManual ? 'Tutup Edit' : 'Edit Teks',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentAmber),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (customBeanManual) ...[
                const SizedBox(height: 6),
                _field(beanController, 'Ketik Kustom Teks Biji Kopi / Origin', CupertinoIcons.pencil, isRequired: false),
              ],

              const Divider(height: 22),

              // TASTING NOTES HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Tasting Notes:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  TextButton.icon(
                    onPressed: onShowNotesModal,
                    icon: const Icon(CupertinoIcons.sparkles, size: 14, color: AppTheme.primaryBrown),
                    label: const Text(
                      'Lihat Semua',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                    ),
                  ),
                ],
              ),

              // 5 POPULAR NOTES + CURRENTLY SELECTED NOTES
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...popularNotes.map((label) {
                    final isSelected = selectedNoteLabels.contains(label);
                    return FlavorNoteVisualBadge(
                      noteText: label,
                      selected: isSelected,
                      onTap: () => onToggleNote(label),
                    );
                  }),
                  ...selectedNoteLabels
                      .where((l) => !popularNotes.contains(l))
                      .map((label) {
                    return FlavorNoteVisualBadge(
                      noteText: label,
                      selected: true,
                      onTap: () => onToggleNote(label),
                    );
                  }),
                  GestureDetector(
                    onTap: onShowNotesModal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.primaryBrown, width: 1.2),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.plus_circle_fill, size: 14, color: AppTheme.primaryBrown),
                          SizedBox(width: 4),
                          Text(
                            'More Notes...',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              if (selectedNoteLabels.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Ringkasan Notes: ${tastingController.text}',
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textMuted),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          final trimmed = value?.trim() ?? '';
          if (!isRequired && trimmed.isEmpty) return null;
          if (trimmed.isEmpty) return 'Wajib diisi';
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          prefixIcon: Icon(icon, size: 18, color: AppTheme.primaryBrown),
          filled: true,
          fillColor: AppTheme.bgCream.withValues(alpha: 0.5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
          ),
        ),
      ),
    );
  }
}
