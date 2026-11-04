with open('lib/features/recipe_feed/widgets/recipe_filter_modal.dart', 'r', encoding='utf-8') as f:
    c = f.read()

import_stmt = "import 'flavor_notes_filter_section.dart';\n"
c = import_stmt + c

target_start = "                          // 5. FILTER BY TASTING NOTES"
target_end = "                          const SizedBox(height: 22),\n\n                          // 6. FILTER BY ASAL & DURASI"

start_idx = c.find(target_start)
end_idx = c.find(target_end)

if start_idx != -1 and end_idx != -1:
    replacement = '''                          FlavorNotesFilterSection(
                            activeNoteCategoryModal: activeNoteCategoryModal,
                            selectedNoteFilter: selectedNoteFilter,
                            onCategoryTabChanged: (tabId) {
                              setModalState(() {
                                activeNoteCategoryModal = tabId;
                              });
                              onTabChanged(tabId);
                            },
                            onNoteFilterChanged: (newFilter) {
                              updateFilter(() => selectedNoteFilter = newFilter);
                            },
                          ),\n'''
    c = c[:start_idx] + replacement + c[end_idx:]
    with open('lib/features/recipe_feed/widgets/recipe_filter_modal.dart', 'w', encoding='utf-8') as f:
        f.write(c)
    print("Successfully compacted recipe_filter_modal.dart!")
else:
    print(f"Indices not found: start={start_idx}, end={end_idx}")
