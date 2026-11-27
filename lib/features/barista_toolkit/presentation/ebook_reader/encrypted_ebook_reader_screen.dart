import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../theme/app_theme.dart';
import '../../data/barista_toolkit_api_service.dart';
import '../../data/barista_toolkit_seed_data.dart';
import '../../data/ebook_drm_vault_service.dart';
import '../../domain/barista_toolkit_models.dart';
import 'coffee_dictionary_az_screen.dart';
import 'embedded_book_lab_widgets.dart';
import 'native_epub_ram_view.dart';

typedef EncryptedEbookReaderScreen = UnifiedCoffeeBookReaderScreen;

enum _ReaderMode { pdf, epub, ast }

enum _PaperTheme {
  cream('Alabaster', Color(0xFFF9F5EE), Color(0xFFFFFCF7), Color(0xFF2C1D14), Color(0xFF795548)),
  sepia('Sepia', Color(0xFFF3E9D2), Color(0xFFFAF2DF), Color(0xFF3A2419), Color(0xFF6D4C41)),
  dark('Roast Dark', Color(0xFF181310), Color(0xFF241C16), Color(0xFFF3EAE0), Color(0xFFB5A495)),
  amoled('AMOLED', Color(0xFF000000), Color(0xFF121212), Color(0xFFEAEAEA), Color(0xFFA0A0A0));

  final String label;
  final Color bg;
  final Color cardBg;
  final Color text;
  final Color muted;

  const _PaperTheme(this.label, this.bg, this.cardBg, this.text, this.muted);

  bool get isDark => this == dark || this == amoled;
}

enum _ReaderFont {
  serif('Literata'),
  sans('Jakarta'),
  mono('Mono');

  final String label;
  const _ReaderFont(this.label);
}

class UnifiedCoffeeBookReaderScreen extends ConsumerStatefulWidget {
  final EbookCatalogItem ebook;
  final int? initialChapterNumber;
  final String? initialReaderMode;

  const UnifiedCoffeeBookReaderScreen({
    super.key,
    required this.ebook,
    this.initialChapterNumber,
    this.initialReaderMode,
  });

  @override
  ConsumerState<UnifiedCoffeeBookReaderScreen> createState() =>
      _UnifiedCoffeeBookReaderScreenState();
}

class _UnifiedCoffeeBookReaderScreenState
    extends ConsumerState<UnifiedCoffeeBookReaderScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PdfViewerController _pdfController = PdfViewerController();

  _ReaderMode _mode = _ReaderMode.pdf;
  _PaperTheme _theme = _PaperTheme.cream;
  _ReaderFont _font = _ReaderFont.serif;
  double _fontSize = 16.5;
  double _lineHeight = 1.68;
  bool _justified = true;
  bool _bilingualEn = false;
  bool _immersiveMode = false;

  List<EbookChapterAstModel> _astChapters = const [];
  List<CoffeeDictionaryEntryModel> _dictionary = const [];
  int _activeChapterIdx = 0;

  ParsedEpubPackage? _parsedEpub;
  bool _loadingEpub = false;
  int _activeEpubChapterIdx = 0;

  Uint8List? _pdfBytes;
  bool _loadingPdf = false;
  int _currentPdfPage = 1;
  int _realPdfTotalPages = 1;

  bool _initializing = true;
  String? _statusMessage;
  final Set<int> _bookmarkedChapters = {};
  final Set<int> _bookmarkedPages = {};

  bool get _isDesktopOrTest =>
      kIsWeb ||
      (!Platform.isAndroid && !Platform.isIOS) ||
      Platform.environment.containsKey('FLUTTER_TEST');

  bool get _isPaidProtectedTier {
    final t = widget.ebook.requiredTier.trim().toLowerCase();
    return t == 'pro' || t == 'business';
  }

  @override
  void initState() {
    super.initState();
    _realPdfTotalPages = widget.ebook.totalPages.clamp(1, 5000);
    _currentPdfPage = widget.ebook.currentPage.clamp(1, _realPdfTotalPages);
    if (_isPaidProtectedTier) {
      _enableDrmProtection();
    }
    _bootstrapOfflineContent();
  }

  Future<void> _enableDrmProtection() async {
    if (_isDesktopOrTest) return;
    try {
      await ScreenProtector.protectDataLeakageOn();
      await ScreenProtector.preventScreenshotOn();
    } catch (_) {}
  }

  Future<void> _disableDrmProtection() async {
    if (_isDesktopOrTest) return;
    try {
      await ScreenProtector.protectDataLeakageOff();
      await ScreenProtector.preventScreenshotOff();
    } catch (_) {}
  }

  Future<void> _bootstrapOfflineContent() async {
    final vault = EncryptedEbookVaultService.instance;
    final api = ref.read(baristaToolkitApiProvider);

    // 1. Muat preferensi tipografi & posisi terakhir buku dari perangkat (instan offline)
    final typo = await vault.loadTypographyPrefs();
    final savedState = await vault.loadLocalReadingState(
      widget.ebook.bookCode,
      fallbackPdfPage: widget.ebook.currentPage,
      fallbackAstChapter: widget.ebook.currentChapterNumber,
    );
    final formats = await vault.getOfflineFormats(widget.ebook.bookCode);
    final dict = await BaristaToolkitFallbackSeed.offlineDictionary();
    final chapters = await vault.readCachedChaptersAst(widget.ebook.bookCode);

    _ReaderMode resolveInitialMode() {
      final explicit = widget.initialReaderMode;
      if (explicit != null && explicit.isNotEmpty) {
        return switch (explicit) {
          'EPUB3' => _ReaderMode.epub,
          'EDITORIAL_AST' => _ReaderMode.ast,
          _ => _ReaderMode.pdf,
        };
      }
      if (widget.initialChapterNumber != null && chapters.isNotEmpty) {
        return _ReaderMode.ast;
      }
      // Pulihkan mode terakhir bila formatnya tersedia offline
      if (savedState.readerMode == 'EPUB3' && formats.hasEpub) {
        return _ReaderMode.epub;
      }
      if (savedState.readerMode == 'EDITORIAL_AST' && formats.hasAst) {
        return _ReaderMode.ast;
      }
      if (formats.hasPdf) return _ReaderMode.pdf;
      if (formats.hasEpub) return _ReaderMode.epub;
      return _ReaderMode.ast;
    }

    int resolveChapterIdx(List<EbookChapterAstModel> list) {
      if (list.isEmpty) return 0;
      final desired = widget.initialChapterNumber ?? savedState.astChapterNumber;
      final found = list.indexWhere((c) => c.chapterNumber == desired);
      return found >= 0 ? found : 0;
    }

    if (!mounted) return;
    setState(() {
      if (typo != null) {
        _theme = _PaperTheme.values.firstWhere(
          (t) => t.name == typo['theme'],
          orElse: () => _PaperTheme.cream,
        );
        _font = _ReaderFont.values.firstWhere(
          (f) => f.name == typo['font'],
          orElse: () => _ReaderFont.serif,
        );
        _fontSize = ((typo['size'] as num?)?.toDouble() ?? 16.5).clamp(13.0, 26.0);
        _lineHeight = ((typo['lh'] as num?)?.toDouble() ?? 1.68).clamp(1.35, 2.0);
        _justified = typo['just'] != false;
      }
      _mode = resolveInitialMode();
      _currentPdfPage = savedState.pdfPage.clamp(1, _realPdfTotalPages);
      _activeEpubChapterIdx = savedState.epubChapterIdx;
      _bookmarkedPages
        ..clear()
        ..addAll(savedState.bookmarkedPages);
      _bookmarkedChapters
        ..clear()
        ..addAll(savedState.bookmarkedChapters);
      _dictionary = dict;
      _astChapters = chapters;
      _activeChapterIdx = resolveChapterIdx(chapters);
      _initializing = false;
    });

    if (_mode == _ReaderMode.pdf) {
      unawaited(_ensurePdfLoaded());
    } else if (_mode == _ReaderMode.epub) {
      unawaited(_ensureEpubLoaded());
    }

    // Ambil AST bab secara senyap bila belum tersimpan lokal
    if (chapters.isEmpty) {
      try {
        final remote = await api.fetchEbookChaptersAst(
          widget.ebook.id,
          bookCode: widget.ebook.bookCode,
        );
        if (mounted && remote.isNotEmpty) {
          await vault.saveDownloadedBookPackage(
            bookCode: widget.ebook.bookCode,
            chaptersAst: remote,
          );
          if (!mounted) return;
          setState(() {
            _astChapters = remote;
            _activeChapterIdx = resolveChapterIdx(remote);
            _statusMessage = null;
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _ensureEpubLoaded() async {
    if (_parsedEpub != null || _loadingEpub) return;
    setState(() {
      _loadingEpub = true;
      _statusMessage = null;
    });
    try {
      final bytes = await EncryptedEbookVaultService.instance
          .readCachedEpubBytes(widget.ebook.bookCode);
      if (bytes == null || bytes.isEmpty) {
        if (!mounted) return;
        setState(() {
          _loadingEpub = false;
          _statusMessage = 'Berkas EPUB3 belum tersimpan di perangkat untuk buku ini.';
        });
        return;
      }
      final parsed = await parseEpubInRamIsolate(bytes);
      if (!mounted) return;
      setState(() {
        _parsedEpub = parsed;
        if (parsed.chapters.isNotEmpty) {
          _activeEpubChapterIdx =
              _activeEpubChapterIdx.clamp(0, parsed.chapters.length - 1);
        }
        _loadingEpub = false;
        _statusMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingEpub = false;
        _statusMessage = 'Gagal mengurai kontainer EPUB3 ($e).';
      });
    }
  }

  Future<void> _ensurePdfLoaded() async {
    if (_pdfBytes != null || _loadingPdf) return;
    setState(() {
      _loadingPdf = true;
      _statusMessage = null;
    });
    try {
      final bytes = await EncryptedEbookVaultService.instance
          .readCachedPdfBytes(widget.ebook.bookCode);
      if (bytes == null || bytes.isEmpty) {
        if (!mounted) return;
        setState(() {
          _loadingPdf = false;
          _statusMessage =
              'Berkas PDF asli belum tersimpan di perangkat. Silakan unduh dari Pustaka E-Book.';
        });
        return;
      }
      if (!mounted) return;
      setState(() {
        _pdfBytes = bytes;
        _loadingPdf = false;
        _statusMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingPdf = false;
        _statusMessage = 'Gagal membuka dokumen PDF ($e).';
      });
    }
  }

  void _releasePdfRam() {
    if (_pdfBytes != null) {
      if (_isPaidProtectedTier) {
        EncryptedEbookVaultService.zeroizeBuffer(_pdfBytes);
      }
      _pdfBytes = null;
    }
  }

  void _switchMode(_ReaderMode next) {
    if (_mode == next) return;
    if (_mode == _ReaderMode.pdf && next != _ReaderMode.pdf) {
      _releasePdfRam();
    }
    setState(() {
      _mode = next;
      _statusMessage = null;
    });
    if (next == _ReaderMode.epub) {
      unawaited(_ensureEpubLoaded());
    } else if (next == _ReaderMode.pdf) {
      unawaited(_ensurePdfLoaded());
    }
    _persistAndSyncProgress();
  }

  void _persistAndSyncProgress() {
    final chapterNum = _astChapters.isNotEmpty
        ? _astChapters[_activeChapterIdx.clamp(0, _astChapters.length - 1)].chapterNumber
        : 1;
    final modeStr = switch (_mode) {
      _ReaderMode.pdf => 'PDF_DRM',
      _ReaderMode.epub => 'EPUB3',
      _ReaderMode.ast => 'EDITORIAL_AST',
    };
    unawaited(
      EncryptedEbookVaultService.instance.saveLocalReadingState(
        widget.ebook.bookCode,
        LocalEbookReadingState(
          readerMode: modeStr,
          pdfPage: _currentPdfPage,
          epubChapterIdx: _activeEpubChapterIdx,
          astChapterNumber: chapterNum,
          bookmarkedPages: _bookmarkedPages,
          bookmarkedChapters: _bookmarkedChapters,
        ),
      ),
    );
    unawaited(
      ref.read(baristaToolkitApiProvider).syncEbookProgress(
            ebookId: widget.ebook.id,
            currentPage: _currentPdfPage,
            currentChapterNumber: chapterNum,
            preferredReaderMode: modeStr,
          ),
    );
  }

  Future<void> _exportPdfToDevice() async {
    try {
      final file = await EncryptedEbookVaultService.instance
          .getOrMaterializeLocalPdfFile(widget.ebook.bookCode);
      if (file == null || !await file.exists()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File PDF belum tersedia di penyimpanan perangkat.')),
        );
        return;
      }
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/pdf')],
          subject: widget.ebook.title,
          text: '${widget.ebook.title} — ${widget.ebook.author} (Coffee Labs Library)',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat mengekspor PDF ($e).')),
      );
    }
  }

  @override
  void dispose() {
    _releasePdfRam();
    if (_isPaidProtectedTier) {
      _disableDrmProtection();
    }
    super.dispose();
  }

  String _resolvedFontFamily() {
    return switch (_font) {
      _ReaderFont.serif => GoogleFonts.literata().fontFamily ?? 'serif',
      _ReaderFont.sans => GoogleFonts.plusJakartaSans().fontFamily ?? 'sans-serif',
      _ReaderFont.mono => GoogleFonts.jetBrainsMono().fontFamily ?? 'monospace',
    };
  }

  TextStyle _bodyTextStyle({bool isBold = false, bool isItalic = false, double deltaSize = 0}) {
    final base = TextStyle(
      fontSize: _fontSize + deltaSize,
      height: _lineHeight,
      color: isItalic ? _theme.muted : _theme.text,
      fontWeight: isBold ? FontWeight.w800 : FontWeight.w400,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
    );
    return switch (_font) {
      _ReaderFont.serif => GoogleFonts.literata(textStyle: base),
      _ReaderFont.sans => GoogleFonts.plusJakartaSans(textStyle: base),
      _ReaderFont.mono => GoogleFonts.jetBrainsMono(textStyle: base),
    };
  }

  List<CoffeeDictionaryEntryModel> _matchingTerms(String text) {
    if (text.length < 18 || _dictionary.isEmpty) return const [];
    final lower = text.toLowerCase();
    final hits = <CoffeeDictionaryEntryModel>[];
    for (final entry in _dictionary) {
      final keyword = entry.termTitle.split('(').first.trim().toLowerCase();
      if (keyword.length >= 4 && lower.contains(keyword)) {
        hits.add(entry);
        if (hits.length >= 3) break;
      }
    }
    return hits;
  }

  void _saveTypo() {
    unawaited(
      EncryptedEbookVaultService.instance.saveTypographyPrefs(
        themeName: _theme.name,
        fontName: _font.name,
        fontSize: _fontSize,
        lineHeight: _lineHeight,
        justified: _justified,
      ),
    );
  }

  void _openTypographySheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _theme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _theme.muted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tampilan Kertas & Tipografi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _theme.text,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _PaperTheme.values.map((t) {
                  final sel = _theme == t;
                  return ChoiceChip(
                    label: Text(t.label),
                    selected: sel,
                    onSelected: (_) {
                      setState(() => _theme = t);
                      setModalState(() {});
                      _saveTypo();
                    },
                    selectedColor: AppTheme.primaryBrown,
                    backgroundColor: t.bg,
                    side: BorderSide(
                      color: sel ? AppTheme.primaryBrown : t.muted.withValues(alpha: 0.35),
                    ),
                    labelStyle: TextStyle(
                      color: sel ? Colors.white : t.text,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: _ReaderFont.values.map((f) {
                        final sel = _font == f;
                        return ChoiceChip(
                          label: Text(f.label),
                          selected: sel,
                          selectedColor: AppTheme.primaryBrown,
                          labelStyle: TextStyle(
                            color: sel ? Colors.white : _theme.text,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) {
                            setState(() => _font = f);
                            setModalState(() {});
                            _saveTypo();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  IconButton(
                    tooltip: _justified ? 'Rata Kanan-Kiri' : 'Rata Kiri',
                    icon: Icon(
                      _justified
                          ? Icons.article_rounded
                          : Icons.notes_rounded,
                      color: _theme.text,
                    ),
                    onPressed: () {
                      setState(() => _justified = !_justified);
                      setModalState(() {});
                      _saveTypo();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 118,
                    child: Text('Ukuran (${_fontSize.toStringAsFixed(0)} pt)',
                        style: TextStyle(color: _theme.text, fontSize: 12.5)),
                  ),
                  Expanded(
                    child: Slider(
                      value: _fontSize,
                      min: 13,
                      max: 26,
                      divisions: 13,
                      activeColor: AppTheme.primaryBrown,
                      onChanged: (v) {
                        setState(() => _fontSize = v);
                        setModalState(() {});
                        _saveTypo();
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 118,
                    child: Text('Spasi (${_lineHeight.toStringAsFixed(2)}x)',
                        style: TextStyle(color: _theme.text, fontSize: 12.5)),
                  ),
                  Expanded(
                    child: Slider(
                      value: _lineHeight,
                      min: 1.35,
                      max: 2.0,
                      divisions: 13,
                      activeColor: AppTheme.primaryBrown,
                      onChanged: (v) {
                        setState(() => _lineHeight = v);
                        setModalState(() {});
                        _saveTypo();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showJumpToPageDialog() async {
    final ctrl = TextEditingController(text: '$_currentPdfPage');
    final target = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lompat ke Halaman'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '1 – $_realPdfTotalPages',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBrown),
            onPressed: () {
              final n = int.tryParse(ctrl.text.trim());
              Navigator.of(ctx).pop(n);
            },
            child: const Text('Buka'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (target == null) return;
    final clamped = target.clamp(1, _realPdfTotalPages);
    setState(() => _currentPdfPage = clamped);
    if (_pdfController.isReady) {
      unawaited(_pdfController.goToPage(pageNumber: clamped));
    }
    _persistAndSyncProgress();
  }

  void _openHdFigureViewer(String imageUrl, String caption) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  errorWidget: (_, _, _) => const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: Colors.white24),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
            if (caption.isNotEmpty)
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    caption,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool get _isCurrentBookmarked => _mode == _ReaderMode.pdf
      ? _bookmarkedPages.contains(_currentPdfPage)
      : _bookmarkedChapters.contains(
          _mode == _ReaderMode.epub
              ? _activeEpubChapterIdx + 1
              : (_astChapters.isNotEmpty
                  ? _astChapters[_activeChapterIdx.clamp(0, _astChapters.length - 1)]
                      .chapterNumber
                  : 1),
        );

  void _toggleCurrentBookmark() {
    setState(() {
      if (_mode == _ReaderMode.pdf) {
        if (!_bookmarkedPages.remove(_currentPdfPage)) {
          _bookmarkedPages.add(_currentPdfPage);
        }
      } else {
        final key = _mode == _ReaderMode.epub
            ? _activeEpubChapterIdx + 1
            : (_astChapters.isNotEmpty
                ? _astChapters[_activeChapterIdx.clamp(0, _astChapters.length - 1)]
                    .chapterNumber
                : 1);
        if (!_bookmarkedChapters.remove(key)) {
          _bookmarkedChapters.add(key);
        }
      }
    });
    _persistAndSyncProgress();
  }

  @override
  Widget build(BuildContext context) {
    final activeChapter = _astChapters.isNotEmpty
        ? _astChapters[_activeChapterIdx.clamp(0, _astChapters.length - 1)]
        : null;
    final isBookmarked = _isCurrentBookmarked;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _theme.bg,
      appBar: _immersiveMode
          ? null
          : AppBar(
              backgroundColor: _theme.bg,
              foregroundColor: _theme.text,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                tooltip: 'Kembali',
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.ebook.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: _theme.text,
                    ),
                  ),
                  Text(
                    '${widget.ebook.author} • ${widget.ebook.bookCode}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10.5, color: _theme.muted),
                  ),
                ],
              ),
              actions: [
                if (widget.ebook.supportsBilingualToggle && _mode == _ReaderMode.ast)
                  IconButton(
                    tooltip: _bilingualEn ? 'Mode Indonesia Saja' : 'Mode Bilingual ID + EN',
                    icon: Icon(
                      Icons.translate_rounded,
                      color: _bilingualEn ? AppTheme.accentGold : _theme.text,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _bilingualEn = !_bilingualEn),
                  ),
                IconButton(
                  tooltip: 'Kertas & Tipografi',
                  icon: Text(
                    'Aa',
                    style: TextStyle(
                      color: _theme.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: _openTypographySheet,
                ),
                IconButton(
                  tooltip: 'Tandai Halaman/Bab',
                  icon: Icon(
                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isBookmarked ? AppTheme.accentGold : _theme.text,
                    size: 21,
                  ),
                  onPressed: _toggleCurrentBookmark,
                ),
                IconButton(
                  tooltip: 'Daftar Isi',
                  icon: const Icon(Icons.toc_rounded, size: 22),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                if (!_isPaidProtectedTier)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, color: _theme.text, size: 20),
                    onSelected: (v) {
                      if (v == 'export') unawaited(_exportPdfToDevice());
                      if (v == 'immersive') setState(() => _immersiveMode = true);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'immersive',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.visibility_off_rounded, size: 20),
                          title: Text('Mode Fokus Layar Penuh'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'export',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.share_rounded, size: 20),
                          title: Text('Simpan / Bagikan PDF'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
      drawer: _buildTocDrawer(),
      body: SafeArea(
        top: _immersiveMode,
        child: Stack(
          children: [
            Column(
              children: [
                if (!_immersiveMode) _buildModeSwitcherBar(),
                Expanded(
                  child: _initializing
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(color: AppTheme.primaryBrown),
                              const SizedBox(height: 12),
                              Text(
                                'Membuka E-Book dari Penyimpanan Offline...',
                                style: TextStyle(
                                    color: _theme.muted, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )
                      : switch (_mode) {
                          _ReaderMode.pdf => _buildPdfReaderBody(),
                          _ReaderMode.epub => _buildEpubReaderBody(),
                          _ReaderMode.ast => _buildAstReaderBody(activeChapter),
                        },
                ),
              ],
            ),
            if (_immersiveMode)
              Positioned(
                top: 10,
                right: 12,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setState(() => _immersiveMode = false),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text('Tampilkan Menu',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSwitcherBar() {
    Widget tab(_ReaderMode mode, IconData icon, String label) {
      final selected = _mode == mode;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _switchMode(mode),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 6),
            decoration: BoxDecoration(
              color: selected ? AppTheme.primaryBrown : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14.5,
                  color: selected ? Colors.white : _theme.muted,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : _theme.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 2, 14, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _theme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _theme.muted.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          tab(_ReaderMode.pdf, Icons.picture_as_pdf_rounded, 'PDF Asli'),
          tab(_ReaderMode.epub, Icons.auto_stories_rounded, 'EPUB3'),
          tab(_ReaderMode.ast, Icons.science_rounded, 'Ringkasan'),
        ],
      ),
    );
  }

  Widget _buildTocDrawer() {
    final epubChapters = _parsedEpub?.chapters ?? const [];
    final sortedBookmarks = _bookmarkedPages.toList()..sort();

    return Drawer(
      backgroundColor: _theme.cardBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daftar Isi',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: _theme.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.ebook.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _theme.text.withValues(alpha: 0.85),
                    ),
                  ),
                  Text(
                    '${widget.ebook.author} • $_realPdfTotalPages Halaman',
                    style: TextStyle(fontSize: 11.5, color: _theme.muted),
                  ),
                ],
              ),
            ),
            if (sortedBookmarks.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: sortedBookmarks
                      .map(
                        (pg) => ActionChip(
                          visualDensity: VisualDensity.compact,
                          avatar: const Icon(Icons.bookmark_rounded,
                              size: 14, color: AppTheme.accentGold),
                          label: Text('Hal $pg', style: const TextStyle(fontSize: 11)),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _switchMode(_ReaderMode.pdf);
                            setState(() => _currentPdfPage = pg);
                            if (_pdfController.isReady) {
                              unawaited(_pdfController.goToPage(pageNumber: pg));
                            }
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            Divider(color: _theme.muted.withValues(alpha: 0.25)),
            Expanded(
              child: _mode == _ReaderMode.epub && epubChapters.isNotEmpty
                  ? ListView.builder(
                      itemCount: epubChapters.length,
                      itemBuilder: (ctx, i) {
                        final ch = epubChapters[i];
                        final active = i == _activeEpubChapterIdx;
                        return ListTile(
                          selected: active,
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: active
                                ? AppTheme.primaryBrown
                                : AppTheme.accentGold.withValues(alpha: 0.2),
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: active ? Colors.white : _theme.text,
                              ),
                            ),
                          ),
                          title: Text(
                            ch.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                              color: _theme.text,
                            ),
                          ),
                          subtitle: Text(
                            '~${ch.estimatedMinutes} menit baca',
                            style: TextStyle(fontSize: 11, color: _theme.muted),
                          ),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            setState(() => _activeEpubChapterIdx = i);
                            _persistAndSyncProgress();
                          },
                        );
                      },
                    )
                  : _mode == _ReaderMode.ast && _astChapters.isNotEmpty
                      ? ListView.builder(
                          itemCount: _astChapters.length,
                          itemBuilder: (ctx, i) {
                            final ch = _astChapters[i];
                            final active = i == _activeChapterIdx;
                            return ListTile(
                              selected: active,
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: active
                                    ? AppTheme.primaryBrown
                                    : AppTheme.accentGold.withValues(alpha: 0.2),
                                child: Text(
                                  '${ch.chapterNumber}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: active ? Colors.white : _theme.text,
                                  ),
                                ),
                              ),
                              title: Text(
                                ch.titleId,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                                  color: _theme.text,
                                ),
                              ),
                              subtitle: Text(
                                '~${ch.estimatedReadTimeMin} mnt • Hal ${ch.startPdfPage}-${ch.endPdfPage}',
                                style: TextStyle(fontSize: 11, color: _theme.muted),
                              ),
                              onTap: () {
                                Navigator.of(ctx).pop();
                                setState(() {
                                  _activeChapterIdx = i;
                                  _mode = _ReaderMode.ast;
                                });
                                _persistAndSyncProgress();
                              },
                            );
                          },
                        )
                      : ListView.builder(
                          itemCount: widget.ebook.tocChapters.length,
                          itemBuilder: (ctx, i) {
                            final toc = widget.ebook.tocChapters[i];
                            final page = toc.startPage.clamp(1, _realPdfTotalPages);
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor:
                                    AppTheme.accentGold.withValues(alpha: 0.22),
                                child: Text(
                                  '${toc.chapterNumber}',
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: _theme.text),
                                ),
                              ),
                              title: Text(
                                toc.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _theme.text),
                              ),
                              subtitle: Text(
                                'Halaman $page',
                                style: TextStyle(fontSize: 11, color: _theme.muted),
                              ),
                              onTap: () {
                                Navigator.of(ctx).pop();
                                setState(() => _currentPdfPage = page);
                                if (_pdfController.isReady) {
                                  unawaited(_pdfController.goToPage(pageNumber: page));
                                }
                                _persistAndSyncProgress();
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAstReaderBody(EbookChapterAstModel? ch) {
    final api = ref.read(baristaToolkitApiProvider);
    if (ch == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_stories_outlined, size: 46, color: _theme.muted),
              const SizedBox(height: 10),
              Text(
                _statusMessage ?? 'Ringkasan Editorial belum tersedia offline.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _theme.text,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBrown),
                onPressed: () => _switchMode(_ReaderMode.pdf),
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                label: const Text('Baca PDF Asli'),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => setState(() => _immersiveMode = !_immersiveMode),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Bab ${ch.chapterNumber} / ${_astChapters.length}',
                          style: TextStyle(
                            color: _theme.text,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '~${ch.estimatedReadTimeMin} menit • PDF Hal ${ch.startPdfPage}–${ch.endPdfPage}',
                        style: TextStyle(fontSize: 11.5, color: _theme.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ch.titleId,
                    style: _bodyTextStyle(isBold: true, deltaSize: 6),
                  ),
                  if (_bilingualEn && (ch.titleEn ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      ch.titleEn!,
                      style: _bodyTextStyle(isItalic: true, deltaSize: -1),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Divider(color: _theme.muted.withValues(alpha: 0.2)),
                  const SizedBox(height: 10),
                  ...ch.blocks.map((b) => _buildAstBlock(b, api)),
                  if (ch.keySummaryPoints.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _theme.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.accentGold.withValues(alpha: 0.45)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Intisari Bab ${ch.chapterNumber}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: _theme.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...ch.keySummaryPoints.map(
                            (pt) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ',
                                      style: TextStyle(
                                          color: AppTheme.accentGold,
                                          fontWeight: FontWeight.w900)),
                                  Expanded(
                                    child: Text(pt,
                                        style: _bodyTextStyle(deltaSize: -1.5)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (_activeChapterIdx > 0)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() => _activeChapterIdx--);
                              _persistAndSyncProgress();
                            },
                            icon: const Icon(Icons.chevron_left_rounded),
                            label: const Text('Bab Sebelumnya'),
                          ),
                        ),
                      if (_activeChapterIdx > 0 &&
                          _activeChapterIdx < _astChapters.length - 1)
                        const SizedBox(width: 10),
                      if (_activeChapterIdx < _astChapters.length - 1)
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.primaryBrown),
                            onPressed: () {
                              setState(() => _activeChapterIdx++);
                              _persistAndSyncProgress();
                            },
                            icon: const Icon(Icons.chevron_right_rounded),
                            label: const Text('Bab Berikutnya'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAstBlock(EbookDocBlock b, BaristaToolkitApiService api) {
    final align = _justified ? TextAlign.justify : TextAlign.start;
    switch (b.blockType) {
      case 'heading':
      case 'heading_1':
      case 'heading_2':
      case 'subheading':
        return Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(b.textId, style: _bodyTextStyle(isBold: true, deltaSize: 2.5)),
              if (_bilingualEn && b.textEnOriginal.isNotEmpty)
                Text(b.textEnOriginal,
                    style: _bodyTextStyle(isItalic: true, deltaSize: -1.5)),
            ],
          ),
        );
      case 'formula':
      case 'formula_latex':
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF241811),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                b.latexExpression.isNotEmpty ? b.latexExpression : b.textId,
                style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.accentGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (b.textId.isNotEmpty && b.latexExpression.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  b.textId,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ],
          ),
        );
      case 'figure':
      case 'diagram':
        final url = api.resolveMediaUrl(b.figureSecureUrl ?? '');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (url.isNotEmpty)
                GestureDetector(
                  onTap: () => _openHdFigureViewer(url, b.figureCaptionId ?? ''),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: url,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Container(
                            height: 120,
                            color: _theme.cardBg,
                            child: Center(
                              child: Icon(Icons.image_outlined,
                                  color: _theme.muted, size: 36),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.zoom_in_rounded,
                                    color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text('Zoom HD',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10.5)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if ((b.figureCaptionId ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  b.figureCaptionId!,
                  style: _bodyTextStyle(isItalic: true, deltaSize: -2.5),
                ),
              ],
            ],
          ),
        );
      case 'interactive_widget':
      case 'lab_widget':
        return EmbeddedBookLabWidget(
          widgetKind:
              b.widgetKind.isNotEmpty ? b.widgetKind : 'DARCY_PERCOLATION_SLIDER',
          title: b.textId,
          textColor: _theme.text,
          cardBgColor: _theme.cardBg,
        );
      default:
        final terms = _matchingTerms(b.textId);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(b.textId, textAlign: align, style: _bodyTextStyle()),
              if (_bilingualEn && b.textEnOriginal.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                          color: AppTheme.accentGold.withValues(alpha: 0.6),
                          width: 2.5),
                    ),
                  ),
                  child: Text(
                    b.textEnOriginal,
                    textAlign: align,
                    style: _bodyTextStyle(isItalic: true, deltaSize: -1.5),
                  ),
                ),
              ],
              if (terms.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: terms
                      .map(
                        (t) => ActionChip(
                          visualDensity: VisualDensity.compact,
                          avatar: const Icon(Icons.menu_book_rounded,
                              size: 13, color: AppTheme.primaryBrown),
                          label: Text(t.termTitle,
                              style: const TextStyle(fontSize: 11)),
                          onPressed: () => showCoffeeDictionaryTermSheet(context, t),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        );
    }
  }

  Widget _buildEpubReaderBody() {
    if (_loadingEpub) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBrown),
      );
    }
    if (_parsedEpub == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_stories_outlined, size: 46, color: _theme.muted),
              const SizedBox(height: 10),
              Text(
                _statusMessage ?? 'EPUB3 belum tersimpan di perangkat.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _theme.text, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBrown),
                onPressed: () => _switchMode(_ReaderMode.pdf),
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                label: const Text('Buka Mode PDF Asli'),
              ),
            ],
          ),
        ),
      );
    }

    return NativeEpubRamView(
      epub: _parsedEpub!,
      activeChapterIdx: _activeEpubChapterIdx,
      onChapterChanged: (idx) {
        setState(() => _activeEpubChapterIdx = idx);
        _persistAndSyncProgress();
      },
      onTapToggleImmersive: () =>
          setState(() => _immersiveMode = !_immersiveMode),
      bgColor: _theme.bg,
      cardBgColor: _theme.cardBg,
      textColor: _theme.text,
      mutedColor: _theme.muted,
      accentColor: AppTheme.accentGold,
      fontSize: _fontSize,
      lineHeight: _lineHeight,
      fontFamily: _resolvedFontFamily(),
      justified: _justified,
    );
  }

  ColorFilter? _pdfPaperColorFilter() {
    switch (_theme) {
      case _PaperTheme.cream:
        return null;
      case _PaperTheme.sepia:
        // Filter kertas sepia hangat yang nyaman di mata
        return const ColorFilter.matrix(<double>[
          0.96, 0.0, 0.0, 0, 8,
          0.0, 0.91, 0.0, 0, 4,
          0.0, 0.0, 0.80, 0, -4,
          0, 0, 0, 1, 0,
        ]);
      case _PaperTheme.dark:
      case _PaperTheme.amoled:
        // Mode baca malam (invert halus kontras rendah agar tidak menyilaukan)
        return const ColorFilter.matrix(<double>[
          -0.88, 0, 0, 0, 238,
          0, -0.88, 0, 0, 232,
          0, 0, -0.86, 0, 224,
          0, 0, 0, 1, 0,
        ]);
    }
  }

  Widget _buildPdfReaderBody() {
    if (_loadingPdf) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBrown),
      );
    }
    if (_pdfBytes == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.picture_as_pdf_outlined, size: 48, color: _theme.muted),
              const SizedBox(height: 10),
              Text(
                _statusMessage ?? 'File PDF belum tersimpan di perangkat.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _theme.text, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBrown),
                onPressed: () => _switchMode(_ReaderMode.epub),
                icon: const Icon(Icons.auto_stories_rounded, size: 18),
                label: const Text('Buka Mode EPUB3'),
              ),
            ],
          ),
        ),
      );
    }

    final totalPages = _realPdfTotalPages.clamp(1, 5000);
    final safePage = _currentPdfPage.clamp(1, totalPages);
    final pct = ((safePage / totalPages) * 100).round();
    final filter = _pdfPaperColorFilter();

    Widget viewer = PdfViewer.data(
      _pdfBytes!,
      sourceName: 'offline://${widget.ebook.bookCode}.pdf',
      controller: _pdfController,
      initialPageNumber: safePage,
      params: PdfViewerParams(
        backgroundColor: _theme.bg,
        margin: 10,
        onDocumentChanged: (doc) {
          final count = doc?.pages.length ?? 0;
          if (count > 0 && count != _realPdfTotalPages && mounted) {
            setState(() {
              _realPdfTotalPages = count;
              _currentPdfPage = _currentPdfPage.clamp(1, count);
            });
          }
        },
        onPageChanged: (page) {
          if (page != null && page != _currentPdfPage && mounted) {
            setState(() => _currentPdfPage = page);
            _persistAndSyncProgress();
          }
        },
      ),
    );

    if (filter != null) {
      viewer = ColorFiltered(colorFilter: filter, child: viewer);
    }

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              viewer,
              if (_immersiveMode)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: IgnorePointer(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.52),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Hal $safePage / $totalPages ($pct%)',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (!_immersiveMode)
          Container(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            decoration: BoxDecoration(
              color: _theme.cardBg,
              border: Border(
                top: BorderSide(color: _theme.muted.withValues(alpha: 0.2)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Halaman Sebelumnya',
                      icon: Icon(Icons.chevron_left_rounded, color: _theme.text),
                      onPressed: safePage > 1
                          ? () {
                              final next = safePage - 1;
                              setState(() => _currentPdfPage = next);
                              if (_pdfController.isReady) {
                                unawaited(_pdfController.goToPage(pageNumber: next));
                              }
                            }
                          : null,
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 7),
                        ),
                        child: Slider(
                          value: safePage.toDouble(),
                          min: 1,
                          max: totalPages > 1 ? totalPages.toDouble() : 2,
                          activeColor: AppTheme.primaryBrown,
                          inactiveColor: _theme.muted.withValues(alpha: 0.25),
                          onChanged: totalPages > 1
                              ? (v) {
                                  final pg = v.round().clamp(1, totalPages);
                                  setState(() => _currentPdfPage = pg);
                                }
                              : null,
                          onChangeEnd: totalPages > 1
                              ? (v) {
                                  final pg = v.round().clamp(1, totalPages);
                                  if (_pdfController.isReady) {
                                    unawaited(_pdfController.goToPage(pageNumber: pg));
                                  }
                                  _persistAndSyncProgress();
                                }
                              : null,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Halaman Berikutnya',
                      icon: Icon(Icons.chevron_right_rounded, color: _theme.text),
                      onPressed: safePage < totalPages
                          ? () {
                              final next = safePage + 1;
                              setState(() => _currentPdfPage = next);
                              if (_pdfController.isReady) {
                                unawaited(_pdfController.goToPage(pageNumber: next));
                              }
                            }
                          : null,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _showJumpToPageDialog,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Hal $safePage / $totalPages',
                              style: TextStyle(
                                color: _theme.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.edit_rounded,
                                size: 12, color: _theme.muted),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      '$pct% selesai • Tersimpan Offline',
                      style: TextStyle(color: _theme.muted, fontSize: 11),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _immersiveMode = true),
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.visibility_off_rounded,
                                size: 15, color: _theme.muted),
                            const SizedBox(width: 3),
                            Text('Fokus',
                                style: TextStyle(
                                    color: _theme.muted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
