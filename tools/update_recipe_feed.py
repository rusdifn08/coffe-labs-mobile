with open('coffe-labs-mobile/lib/screens/recipe_feed_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# 1. Update Class declaration
old_class = """class RecipeFeedScreen extends StatefulWidget {
  const RecipeFeedScreen({super.key});

  @override
  State<RecipeFeedScreen> createState() => _RecipeFeedScreenState();
}

class _RecipeFeedScreenState extends State<RecipeFeedScreen> {
  List<dynamic> _allRecipes = [];
  List<Map<String, dynamic>> _uniqueBaristas = [];
  bool _isLoading = true;
  bool _isTrial = false;

  // Filter States
  String _searchQuery = '';
  String _selectedCategory = 'All';"""

new_class = """class RecipeFeedScreen extends StatefulWidget {
  final String? initialMethodFilter;
  final String? initialMethodTitle;

  const RecipeFeedScreen({
    super.key,
    this.initialMethodFilter,
    this.initialMethodTitle,
  });

  @override
  State<RecipeFeedScreen> createState() => _RecipeFeedScreenState();
}

class _RecipeFeedScreenState extends State<RecipeFeedScreen> {
  List<dynamic> _allRecipes = [];
  List<Map<String, dynamic>> _uniqueBaristas = [];
  bool _isLoading = true;
  bool _isTrial = false;

  // Filter States
  String _searchQuery = '';
  String _selectedMethodFilter = 'All';
  String _selectedCategory = 'All';"""

c = c.replace(old_class, new_class)

# 2. Update initState
old_init = """  @override
  void initState() {
    super.initState();
    _loadData();"""

new_init = """  @override
  void initState() {
    super.initState();
    if (widget.initialMethodFilter != null && widget.initialMethodFilter!.isNotEmpty) {
      _selectedMethodFilter = widget.initialMethodFilter!;
    }
    _loadData();"""

c = c.replace(old_init, new_init)

# 3. Update _activeFilterCount
old_count = """  int get _activeFilterCount {
    int c = 0;
    if (_selectedCategory != 'All') c++;"""

new_count = """  int get _activeFilterCount {
    int c = 0;
    if (_selectedMethodFilter != 'All') c++;
    if (_selectedCategory != 'All') c++;"""

c = c.replace(old_count, new_count)

# 4. Update _resetAllFilters
old_reset = """  void _resetAllFilters() {
    setState(() {
      _selectedCategory = 'All';"""

new_reset = """  void _resetAllFilters() {
    setState(() {
      _selectedMethodFilter = 'All';
      _selectedCategory = 'All';"""

c = c.replace(old_reset, new_reset)

# 5. Update filter predicate
old_filter = """      return matchesCategory &&
          matchesBarista &&
          matchesOrigin &&"""

new_filter = """      final mfLower = _selectedMethodFilter.toLowerCase();
      bool matchesMethod = _selectedMethodFilter == 'All' ||
          (r['method'] ?? '').toString().toLowerCase().contains(mfLower) ||
          (r['category'] ?? '').toString().toLowerCase().contains(mfLower);

      return matchesCategory &&
          matchesMethod &&
          matchesBarista &&
          matchesOrigin &&"""

c = c.replace(old_filter, new_filter)

# 6. Update AppBar leading to support Back button when popped
old_appbar = """      appBar: AppBar(
        leadingWidth: 72,
        leading: Padding("""

new_appbar = """      appBar: AppBar(
        leadingWidth: Navigator.canPop(context) ? 48 : 72,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(CupertinoIcons.chevron_back),
                onPressed: () => Navigator.pop(context),
              )
            : Padding("""

c = c.replace(old_appbar, new_appbar)

with open('coffe-labs-mobile/lib/screens/recipe_feed_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)

lines = len(c.splitlines())
print(f"recipe_feed_screen.dart updated! Total lines: {lines}")
