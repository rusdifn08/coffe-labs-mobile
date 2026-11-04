import 'package:flutter/foundation.dart';

/// Global service for managing bottom tab navigation and cross-tab filtering
/// ensuring the BottomNavigationBar remains visible at all times.
class MainNavigationService {
  static final ValueNotifier<int> currentTabNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<String?> methodFilterNotifier = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> methodTitleNotifier = ValueNotifier<String?>(null);

  /// Switch to Recipes tab (index 1) with an active brew method filter.
  static void openRecipesWithMethod(String filterKey, {String? methodTitle}) {
    methodTitleNotifier.value = methodTitle ?? filterKey;
    methodFilterNotifier.value = filterKey;
    currentTabNotifier.value = 1;
  }

  /// Switch bottom navigation tab directly.
  static void switchTab(int index) {
    currentTabNotifier.value = index;
  }

  /// Clear the active method filter.
  static void clearMethodFilter() {
    methodFilterNotifier.value = null;
    methodTitleNotifier.value = null;
  }
}
