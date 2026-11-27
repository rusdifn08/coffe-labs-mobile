import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/auth_service.dart';
import '../../../../services/subscription_service.dart';
import '../../../../services/trial_service.dart';
import '../../../../theme/app_theme.dart';
import '../../data/barista_toolkit_api_service.dart';
import '../../data/barista_toolkit_seed_data.dart';
import '../../data/ebook_drm_vault_service.dart';
import '../../domain/barista_toolkit_models.dart';
import 'coffee_dictionary_az_screen.dart';
import 'encrypted_ebook_reader_screen.dart';

class _DownloadState {
  final double progress;
  final String label;

  const _DownloadState(this.progress, this.label);
}

class EbookLibraryScreen extends ConsumerStatefulWidget {
  const EbookLibraryScreen({super.key});

  @override
  ConsumerState<EbookLibraryScreen> createState() => _EbookLibraryScreenState();
}

class _EbookLibraryScreenState extends ConsumerState<EbookLibraryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  late List<EbookCatalogItem> _books =
      BaristaToolkitFallbackSeed.cachedEbooksSync();
  final Map<String, bool> _downloadedMap = {};
  final Map<String, int> _localBytesMap = {};
  final Map<String, _DownloadState> _downloadingMap = {};
  String _selectedFilter = 'ALL';
  bool _loading = true;
  bool _isLoadingCatalog = false;

  @override
  void initState() {
    super.initState();
    AuthService.changeNotifier.addListener(_onAccessChanged);
    SubscriptionService.changeNotifier.addListener(_onAccessChanged);
    TrialService.changeNotifier.addListener(_onAccessChanged);
    _loadCatalog();
  }

  @override
  void dispose() {
    AuthService.changeNotifier.removeListener(_onAccessChanged);
    SubscriptionService.changeNotifier.removeListener(_onAccessChanged);
    TrialService.changeNotifier.removeListener(_onAccessChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onAccessChanged() {
    if (!mounted) return;
    unawaited(_reconcileLocalBooksAccessOnly());
  }

  Future<void> _reconcileLocalBooksAccessOnly() async {
    final api = ref.read(baristaToolkitApiProvider);
    final updated = await api.reconcileEbooksAccess(_books);
    if (!mounted) return;
    setState(() {
      _books = updated;
    });
  }

  Future<void> _loadCatalog() async {
    if (_isLoadingCatalog) return;
    _isLoadingCatalog = true;
    try {
      final api = ref.read(baristaToolkitApiProvider);
      final vault = EncryptedEbookVaultService.instance;

      Future<void> applyBooks(List<EbookCatalogItem> books) async {
        final dlMap = <String, bool>{};
        final szMap = <String, int>{};
        for (final book in books) {
          final isDl = await vault.isBookDownloadedOffline(book.bookCode);
          dlMap[book.bookCode] = isDl;
          if (isDl) {
            szMap[book.bookCode] = await vault.getOfflineVaultSizeBytes(book.bookCode);
          }
        }
        if (!mounted) return;
        setState(() {
          _books = books;
          _downloadedMap
            ..clear()
            ..addAll(dlMap);
          _localBytesMap
            ..clear()
            ..addAll(szMap);
          _loading = false;
        });
      }

      final offlineRaw = await BaristaToolkitFallbackSeed.offlineEbooks();
      final offline = await api.reconcileEbooksAccess(offlineRaw);
      await applyBooks(offline);

      try {
        final remote = await api.fetchEbooks();
        if (remote.isNotEmpty) {
          await applyBooks(remote);
        }
      } catch (_) {}
    } finally {
      _isLoadingCatalog = false;
    }
  }

  Future<void> _refreshSingleBookStatus(String bookCode) async {
    final vault = EncryptedEbookVaultService.instance;
    final isDl = await vault.isBookDownloadedOffline(bookCode);
    final size = isDl ? await vault.getOfflineVaultSizeBytes(bookCode) : 0;
    if (!mounted) return;
    setState(() {
      _downloadedMap[bookCode] = isDl;
      if (isDl) {
        _localBytesMap[bookCode] = size;
      } else {
        _localBytesMap.remove(bookCode);
      }
    });
  }

  Future<void> _downloadBook(EbookCatalogItem book) async {
    if (_downloadingMap.containsKey(book.bookCode)) return;
    if (!book.isUnlocked) {
      _showTierLockDialog(book);
      return;
    }

    setState(() {
      _downloadingMap[book.bookCode] =
          const _DownloadState(0.03, 'Menghubungkan Object Storage...');
    });

    try {
      await ref.read(baristaToolkitApiProvider).downloadBookPackageFromObjectStorage(
            book: book,
            onProgress: (progress, label) {
              if (!mounted) return;
              setState(() {
                _downloadingMap[book.bookCode] = _DownloadState(progress, label);
              });
            },
          );
      await _refreshSingleBookStatus(book.bookCode);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          content: Text(
            '${book.title} berhasil disimpan ke perangkat & siap dibaca offline!',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          action: SnackBarAction(
            label: 'Baca',
            textColor: Colors.white,
            onPressed: () => _openBookOrPromptDownload(book),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final friendlyMsg = BaristaToolkitApiService.formatFriendlyDownloadError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFB71C1C),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          content: Text(friendlyMsg),
          action: SnackBarAction(
            label: 'Coba Lagi',
            textColor: Colors.white,
            onPressed: () => _downloadBook(book),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _downloadingMap.remove(book.bookCode);
        });
      }
    }
  }

  Future<void> _confirmDeleteOfflineBook(EbookCatalogItem book) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Cache Offline?'),
        content: Text(
          'Hapus salinan offline "${book.title}" (${_formatBytes(_localBytesMap[book.bookCode] ?? book.totalEstimatedDownloadBytes)}) dari perangkat untuk menghemat ruang? Anda dapat mengunduh ulang kapan saja dari Object Storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB71C1C)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus Cache'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await EncryptedEbookVaultService.instance.deleteOfflineBook(book.bookCode);
    await _refreshSingleBookStatus(book.bookCode);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cache offline ${book.bookCode} telah dihapus.')),
    );
  }

  void _openBookOrPromptDownload(EbookCatalogItem book) {
    if (!book.isUnlocked) {
      _showTierLockDialog(book);
      return;
    }
    final isDownloaded = _downloadedMap[book.bookCode] ?? false;
    if (!isDownloaded) {
      _showDownloadPromptDialog(book);
      return;
    }
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => EncryptedEbookReaderScreen(ebook: book),
          ),
        )
        .then((_) => _refreshSingleBookStatus(book.bookCode));
  }

  void _showTierLockDialog(EbookCatalogItem book) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('E-Book Tier ${book.requiredTier}'),
        content: Text(
          '"${book.title}" tersedia pada paket ${book.requiredTier}. Tingkatkan akun Anda untuk membuka lisensi Object Storage & baca offline.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showDownloadPromptDialog(EbookCatalogItem book) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unduh ke Vault Offline'),
        content: Text(
          'Agar ukuran APK Coffee Labs tetap ringan, "${book.title}" disimpan di Object Storage dan tidak dibundel di installer.\n\n'
          'Paket berisi PDF Terenkripsi (.clbook), EPUB3 Reflowable & Editorial AST (~${_formatBytes(book.totalEstimatedDownloadBytes)}). Setelah diunduh, buku bisa dibaca 100% tanpa internet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Nanti'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBrown),
            onPressed: () {
              Navigator.of(ctx).pop();
              _downloadBook(book);
            },
            icon: const Icon(Icons.cloud_download_rounded, size: 18),
            label: const Text('Unduh Sekarang'),
          ),
        ],
      ),
    );
  }

  List<EbookCatalogItem> get _filteredBooks {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _books.where((book) {
      final matchesFilter = switch (_selectedFilter) {
        'OFFLINE' => _downloadedMap[book.bookCode] ?? false,
        'SCIENCE' => const {
            'ORIGINS_AND_SCIENCE',
            'EXTRACTION_PHYSICS',
            'WATER_CHEMISTRY',
            'POPULAR_SCIENCE',
            'ACADEMIC_INDUSTRY',
            'ACADEMIC_OA',
          }.contains(book.category),
        'MANUAL_BREW' => const {
            'BREWING_MANUAL',
            'VISUAL_ATLAS_RECIPES',
          }.contains(book.category),
        'REFERENCE' => const {
            'FLAVOUR_AND_CRAFT',
            'ENCYCLOPEDIA_A_Z',
            'HISTORY_CLASSIC',
          }.contains(book.category),
        _ => true,
      };

      final matchesQuery = q.isEmpty ||
          book.title.toLowerCase().contains(q) ||
          (book.originalTitle ?? '').toLowerCase().contains(q) ||
          book.author.toLowerCase().contains(q) ||
          book.bookCode.toLowerCase().contains(q) ||
          book.synopsis.toLowerCase().contains(q);

      return matchesFilter && matchesQuery;
    }).toList();
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0.9 MB';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final api = ref.read(baristaToolkitApiProvider);
    final filtered = _filteredBooks;
    final downloadedCount =
        _books.where((b) => _downloadedMap[b.bookCode] ?? false).length;
    final totalCachedBytes =
        _localBytesMap.values.fold<int>(0, (sum, v) => sum + v);

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pustaka E-Book Kopi',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            Text(
              'Cloud Storage • $downloadedCount/${_books.length} Tersimpan di Perangkat',
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Kamus Kopi A–Z',
            icon: const Icon(Icons.menu_book_rounded, color: AppTheme.primaryBrown),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CoffeeDictionaryAzScreen(),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
              onRefresh: _loadCatalog,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  _buildVaultStatusBanner(downloadedCount, totalCachedBytes),
                  const SizedBox(height: 12),
                  _buildDictionaryShortcutCard(context),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari judul buku, penulis, atau kode CL-BOOK...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.borderWarm),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('ALL', 'Semua (${_books.length})'),
                        const SizedBox(width: 6),
                        _filterChip('OFFLINE', 'Tersimpan Offline ($downloadedCount)'),
                        const SizedBox(width: 6),
                        _filterChip('SCIENCE', 'Sains & Riset'),
                        const SizedBox(width: 6),
                        _filterChip('MANUAL_BREW', 'Panduan Seduh'),
                        const SizedBox(width: 6),
                        _filterChip('REFERENCE', 'Kamus & Klasik'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_loading && _books.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: Text(
                          'Menyiapkan Pustaka E-Book DRM...',
                          style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  else if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderWarm),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.library_books_outlined,
                              size: 40, color: AppTheme.textMuted),
                          SizedBox(height: 8),
                          Text(
                            'Belum ada buku yang sesuai filter ini.',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Unduh buku dari Object Storage terlebih dahulu agar muncul di tab Tersimpan Offline.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filtered.map(
                      (book) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _EbookLibraryCard(
                          book: book,
                          resolvedCoverUrl: api.resolveEbookCoverUrl(book),
                          isDownloaded: _downloadedMap[book.bookCode] ?? false,
                          localBytes: _localBytesMap[book.bookCode] ?? 0,
                          downloadState: _downloadingMap[book.bookCode],
                          formatBytes: _formatBytes,
                          onTapCard: () => _openBookOrPromptDownload(book),
                          onDownloadPressed: () => _downloadBook(book),
                          onDeletePressed: () => _confirmDeleteOfflineBook(book),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildVaultStatusBanner(int downloadedCount, int totalCachedBytes) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3E2723), Color(0xFF5D4037)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.cloud_sync_rounded,
              color: AppTheme.accentGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perpustakaan Cloud • Baca 100% Offline',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unduh E-Book edisi penuh (PDF Asli + EPUB3 + Ringkasan) langsung dari Cloud Storage ke penyimpanan perangkat Anda agar nyaman dibaca kapan saja tanpa internet.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 11.5,
                    height: 1.38,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _bannerPill('$downloadedCount/${_books.length} Siap Offline'),
                    _bannerPill(
                      totalCachedBytes > 0
                          ? 'Penyimpanan: ${_formatBytes(totalCachedBytes)}'
                          : 'Belum Ada Unduhan',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.accentGold,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDictionaryShortcutCard(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const CoffeeDictionaryAzScreen(),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
        ),
        child: const Row(
          children: [
            Icon(Icons.translate_rounded, color: AppTheme.primaryBrown, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kamus Sains & Manual Brew A–Z (Buku #8)',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    '120+ entri istilah Darcy, Bypass, GH/KH, Varietas & Defek',
                    style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.primaryBrown),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String id, String label) {
    final selected = _selectedFilter == id;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedFilter = id),
      selectedColor: AppTheme.primaryBrown,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppTheme.textDark,
        fontWeight: FontWeight.w700,
        fontSize: 11.5,
      ),
    );
  }
}

class _EbookLibraryCard extends StatelessWidget {
  final EbookCatalogItem book;
  final String resolvedCoverUrl;
  final bool isDownloaded;
  final int localBytes;
  final _DownloadState? downloadState;
  final String Function(int bytes) formatBytes;
  final VoidCallback onTapCard;
  final VoidCallback onDownloadPressed;
  final VoidCallback onDeletePressed;

  const _EbookLibraryCard({
    required this.book,
    required this.resolvedCoverUrl,
    required this.isDownloaded,
    required this.localBytes,
    required this.downloadState,
    required this.formatBytes,
    required this.onTapCard,
    required this.onDownloadPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final dl = downloadState;
    final sizeLabel = isDownloaded && localBytes > 0
        ? formatBytes(localBytes)
        : formatBytes(book.totalEstimatedDownloadBytes);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTapCard,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDownloaded
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.45)
                  : AppTheme.borderWarm,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCoverThumb(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _tagPill(
                              book.bookCode,
                              const Color(0xFFEFE6DC),
                              AppTheme.primaryBrown,
                            ),
                            if (!book.isUnlocked)
                              _tagPill(
                                'Tier ${book.requiredTier}',
                                const Color(0xFFFFEBEE),
                                const Color(0xFFC62828),
                              )
                            else if (isDownloaded)
                              _tagPill(
                                'Siap Offline',
                                const Color(0xFFE8F5E9),
                                const Color(0xFF2E7D32),
                              )
                            else
                              _tagPill(
                                'Object Storage',
                                const Color(0xFFFFF8E1),
                                const Color(0xFF9E6B00),
                              ),
                            if (book.supportsBilingualToggle)
                              _tagPill(
                                'ID / EN',
                                const Color(0xFFE3F2FD),
                                const Color(0xFF1565C0),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          book.synopsis,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF6D5D54),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 4,
                children: [
                  Text(
                    '${book.totalChaptersCount} Bab • ${book.totalPages} Hal PDF',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  Text(
                    'PDF + EPUB3 • $sizeLabel',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                ],
              ),
              if (dl != null) ...[
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: dl.progress.clamp(0.0, 1.0),
                  backgroundColor: AppTheme.borderWarm,
                  color: AppTheme.primaryBrown,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dl.label} (${(dl.progress * 100).round()}%)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: isDownloaded
                          ? FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.primaryBrown,
                                padding: const EdgeInsets.symmetric(vertical: 10.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: onTapCard,
                              icon: const Icon(Icons.auto_stories_rounded, size: 17),
                              label: const Text(
                                'Baca Sekarang (PDF / EPUB3)',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            )
                          : OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryBrown,
                                side: const BorderSide(color: AppTheme.primaryBrown),
                                padding: const EdgeInsets.symmetric(vertical: 10.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: onDownloadPressed,
                              icon: Icon(
                                book.isUnlocked
                                    ? Icons.cloud_download_rounded
                                    : Icons.lock_outline_rounded,
                                size: 17,
                              ),
                              label: Text(
                                book.isUnlocked
                                    ? 'Unduh ke Perangkat ($sizeLabel)'
                                    : 'Terkunci (${book.requiredTier})',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                    ),
                    if (isDownloaded) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Hapus Cache Offline',
                        onPressed: onDeletePressed,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFB71C1C),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverThumb() {
    Widget fallback() {
      return Container(
        width: 64,
        height: 90,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A2C1D), Color(0xFF2B1810)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.65)),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              book.bookCode.replaceFirst('CL-BOOK-', '#'),
              style: const TextStyle(
                color: AppTheme.accentGold,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Icon(Icons.auto_stories_rounded,
                color: AppTheme.accentGold, size: 24),
            Text(
              book.category.split('_').first,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 8.5),
            ),
          ],
        ),
      );
    }

    if (resolvedCoverUrl.isEmpty ||
        (!resolvedCoverUrl.startsWith('http://') &&
            !resolvedCoverUrl.startsWith('https://'))) {
      return fallback();
    }

    return Container(
      width: 72,
      height: 104,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: resolvedCoverUrl,
          width: 72,
          height: 104,
          fit: BoxFit.cover,
          placeholder: (_, _) => fallback(),
          errorWidget: (_, _, _) => fallback(),
        ),
      ),
    );
  }

  Widget _tagPill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}
