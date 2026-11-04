with open('lib/screens/recipe_feed_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Update imports
new_imports = '''import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/trial_service.dart';
import '../services/language_service.dart';
import '../services/coffee_translator.dart';
import '../theme/app_theme.dart';
import '../utils/barista_utils.dart';
import '../data/brew_visual_catalog.dart';
import 'add_recipe_screen.dart';
import 'barista_profile_screen.dart';
import 'recipe_detail_screen.dart';
import 'brew_calculator_screen.dart';
import 'smart_scale_screen.dart';
import '../features/recipe_feed/models/note_category_item.dart';
import '../features/recipe_feed/widgets/recipe_filter_modal.dart';
import '../features/recipe_feed/widgets/recipe_feed_grid_card.dart';
import '../features/recipe_feed/widgets/trial_lock_dialog.dart';
import '../shared/design_system/atoms/coffee_bean_icon.dart';
'''

# Find class RecipeFeedScreen
class_pos = text.find('class RecipeFeedScreen extends StatefulWidget {')

# Find _openFilterModal
filter_start = text.find('  void _openFilterModal() {')
filter_end = text.find('  void _confirmDelete(int id, String title) {')

# Find _showTrialLockDialog
trial_start = text.find('  void _showTrialLockDialog() {')
trial_end = text.find('  void _openDetail(dynamic recipe, {int? index}) {')

# Find _buildGridCard
grid_start = text.find('  Widget _buildGridCard(BuildContext context, dynamic rawRecipe, int index) {')
grid_end = text.find('class CoffeeBeanIcon extends StatelessWidget {')

# Construct middle 1: class definition up to _openFilterModal
part_class = text[class_pos:filter_start]

# Replace _noteCategories references in part_class
part_class = part_class.replace('_noteCategories', 'noteCategories')
part_class = part_class.replace('_NoteCategoryItem', 'NoteCategoryItem')

new_filter_method = '''  void _openFilterModal() {
    RecipeFilterModal.show(
      context: context,
      selectedPourFilter: _selectedPourFilter,
      selectedDripperFilter: _selectedDripperFilter,
      selectedBaristaFilter: _selectedBaristaFilter,
      selectedCategory: _selectedCategory,
      selectedOriginFilter: _selectedOriginFilter,
      selectedNoteFilter: _selectedNoteFilter,
      selectedNoteCategoryTab: _selectedNoteCategoryTab,
      uniqueBaristas: _uniqueBaristas,
      categories: _categories,
      pourFilterOptions: _pourFilterOptions,
      originFilterOptions: _originFilterOptions,
      activeFilterCount: _activeFilterCount,
      onUpdateFilter: (fn) => setState(fn),
      onResetAll: _resetAllFilters,
      onTabChanged: (tab) => setState(() => _selectedNoteCategoryTab = tab),
    );
  }

'''

part_between_filter_and_trial = text[filter_end:trial_start]

new_trial_method = '''  void _showTrialLockDialog() {
    RecipeTrialLockDialog.show(context);
  }

'''

part_between_trial_and_grid = text[trial_end:grid_start]

new_grid_method = '''  Widget _buildGridCard(BuildContext context, dynamic rawRecipe, int index) {
    final recipe = rawRecipe is Map ? ApiService.sanitizeRecipe(rawRecipe) : <String, dynamic>{};
    return RecipeFeedGridCard(
      rawRecipe: rawRecipe,
      index: index,
      isTrial: _isTrial,
      onTap: () => _openDetail(recipe, index: index),
      onLongPress: recipe['isCustom'] == true
          ? () => _confirmDelete(recipe['id'] as int, CoffeeTranslator.translateTitle(recipe['title'] as String))
          : null,
      onBaristaTap: () => _openBarista(recipe),
      onTrialLocked: _showTrialLockDialog,
    );
  }
}
'''

full_code = (
    new_imports +
    part_class +
    new_filter_method +
    part_between_filter_and_trial +
    new_trial_method +
    part_between_trial_and_grid +
    new_grid_method
)

with open('lib/screens/recipe_feed_screen.dart', 'w', encoding='utf-8') as f:
    f.write(full_code)

print("Refactored recipe_feed_screen.dart successfully!")
