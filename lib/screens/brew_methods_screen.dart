import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/brew_methods/models/brew_method_item.dart';
import '../features/brew_methods/widgets/brew_method_card.dart';
import '../services/api_service.dart';
import '../services/language_service.dart';
import '../services/main_navigation_service.dart';
import '../services/user_brew_usage_service.dart';

/// Screen displaying 3-column grid of all coffee brew methods.
/// Supports both embedded mode (preserving bottom navbar) and push route mode.
class BrewMethodsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const BrewMethodsScreen({super.key, this.onBack});

  @override
  State<BrewMethodsScreen> createState() => _BrewMethodsScreenState();
}

class _BrewMethodsScreenState extends State<BrewMethodsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    ApiService.getBrewHistory().then((h) {
      if (mounted) setState(() => _history = h);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.maybePop(context);
    }
  }

  void _onMethodTapped(BrewMethodItem item) {
    if (widget.onBack != null) {
      widget.onBack!();
    }
    MainNavigationService.openRecipesWithMethod(
      item.filterKey,
      methodTitle: item.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final all = UserBrewUsageService.sortMethodsByUserUsage(BrewMethodItem.allMethods, _history);
    final filtered = _searchQuery.isEmpty
        ? all
        : all.where((m) {
            final q = _searchQuery.toLowerCase();
            return m.title.toLowerCase().contains(q) ||
                m.titleId.toLowerCase().contains(q) ||
                m.category.toLowerCase().contains(q) ||
                m.subtitle.toLowerCase().contains(q);
          }).toList();

    return PopScope(
      canPop: widget.onBack == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.onBack != null) {
          widget.onBack!();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: Column(
            children: [
              // Top App Bar matching competitor aesthetic
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    // Circular Back Button
                    _buildCircularButton(
                      icon: CupertinoIcons.chevron_back,
                      onTap: _handleBack,
                    ),
                    const SizedBox(width: 12),
                    // Title
                    Expanded(
                      child: _isSearching
                          ? TextField(
                              controller: _searchCtrl,
                              autofocus: true,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                hintText: isEn ? 'Search method...' : 'Cari metode seduh...',
                                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (val) => setState(() => _searchQuery = val.trim()),
                            )
                          : Text(
                              isEn ? 'Brew methods' : 'Metode Seduh',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF141414),
                                letterSpacing: -0.5,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    // Circular Search Toggle
                    _buildCircularButton(
                      icon: _isSearching ? CupertinoIcons.xmark : CupertinoIcons.search,
                      onTap: () {
                        setState(() {
                          if (_isSearching) {
                            _isSearching = false;
                            _searchCtrl.clear();
                            _searchQuery = '';
                          } else {
                            _isSearching = true;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),

              // 3-Column Grid of Brew Methods
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          isEn ? 'No brewing methods found' : 'Metode seduh tidak ditemukan',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                        itemCount: filtered.length,
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          mainAxisExtent: 175,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 16,
                        ),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return BrewMethodCard(
                            item: item,
                            isEn: isEn,
                            onTap: () => _onMethodTapped(item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: const Color(0xFF1E1E1E)),
        padding: EdgeInsets.zero,
        onPressed: onTap,
      ),
    );
  }
}
