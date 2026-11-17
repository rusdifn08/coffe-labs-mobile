import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:screen_protector/screen_protector.dart';

import '../../../../theme/app_theme.dart';
import '../../data/barista_toolkit_api_service.dart';
import '../../data/barista_toolkit_seed_data.dart';
import '../../data/ebook_drm_vault_service.dart';
import '../../domain/barista_toolkit_models.dart';
import 'coffee_dictionary_az_screen.dart';
import 'embedded_book_lab_widgets.dart';
import 'native_epub_ram_view.dart';

typedef EncryptedEbookReaderScreen = UnifiedCoffeeBookReaderScreen;

enum _ReaderMode { ast, epub, pdf }

enum _PaperTheme {
  cream('Alabaster', Color(0xFFF9F5EE), Color(0xFFFFFCF7), Color(0xFF2C1D14), Color(0xFF795548)),
  sepia('Sepia', Color(0xFFF4ECD8), Color(0xFFFBF5E6), Color(0xFF3E2723), Color(0xFF6D4C41)),
  dark('Roast Dark', Color(0xFF181310), Color(0xFF251D17), Color(0xFFF3EAE0), Color(0xFFB5A495)),
  amoled('AMOLED', Color(0xFF000000), Color(0xFF121212), Color(0xFFEAEAEA), Color(0xFFA0A0A0));

  final String label;
  final Color bg;
  final Color cardBg;
  final Color text;
  final Color muted;

  const _PaperTheme(this.label, this.bg, this.cardBg, this.text, this.muted);
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
  final String initialReaderMode;

  const UnifiedCoffeeBookReaderScreen({
    super.key,
    required this.ebook,
    this.initialChapterNumber,
    this.initialReaderMode = 'EDITORIAL_AST',
  });

  @override
  ConsumerState<UnifiedCoffeeBookReaderScreen> createState() =>
      _UnifiedCoffeeBookReaderScreenState();
}

class _UnifiedCoffeeBookReaderScreenState
    extends ConsumerState<UnifiedCoffeeBookReaderScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PdfViewerController _pdfController = PdfViewerController();

  late _ReaderMode _mode;
  _PaperTheme _theme = _PaperTheme.cream;
  _ReaderFont _font = _ReaderFont.serif;
  double _fontSize = 16.5;
  double _lineHeight = 1.65;
  bool _bilingualEn = false;

  List<EbookChapterAstModel> _astChapters = const [];
  List<CoffeeDictionaryEntryModel> _dictionary = const [];
  int _activeChapterIdx = 0;

  ParsedEpubPackage? _parsedEpub;
  bool _loadingEpub = false;
  int _activeEpubChapterIdx = 0;

  Uint8List? _decryptedPdfBytes;
  bool _loadingPdf = false;
  int _currentPdfPage = 1;

  bool _initializing = true;
  String? _statusMessage;
  final Set<int> _bookmarkedChapters = {};

  bool get _isDesktopOrTest =>
      kIsWeb ||
      (!Platform.isAndroid && !Platform.isIOS) ||
      Platform.environment.containsKey('FLUTTER_TEST');

  @override
  void initState() {
    super.initState();
    _mode = switch (widget.initialReaderMode) {
      'EPUB3' => _ReaderMode.epub,
      'PDF_DRM' => _ReaderMode.pdf,
      _ => _ReaderMode.ast,
    };
    _currentPdfPage = widget.ebook.currentPage.clamp(1, widget.ebook.totalPages);
    _enableDrmProtection();
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
    final dict = await BaristaToolkitFallbackSeed.offlineDictionary();
    var chapters = await vault.readCachedChaptersAst(widget.ebook.bookCode);

    int resolveChapterIdx(List<EbookChapterAstModel> list) {
      if (list.isEmpty) return 0;
      final desiredChapter =
          widget.initialChapterNumber ?? widget.ebook.currentChapterNumber;
      final found = list.indexWhere((c) => c.chapterNumber == desiredChapter);
      return found >= 0 ? found : 0;
    }

    if (!mounted) return;
    setState(() {
      _dictionary = dict;
      _astChapters = chapters;
      _activeChapterIdx = resolveChapterIdx(chapters);
      _initializing = false;
      if (chapters.isEmpty) {
        _statusMessage =
            'Belum ada bab Editorial AST lokal untuk ${widget.ebook.bookCode}.';
      }
    });

    if (_mode == _ReaderMode.epub) {
      _ensureEpubLoaded();
    } else if (_mode == _ReaderMode.pdf) {
      _ensurePdfDecrypted();
    }

    if (chapters.isEmpty) {
      try {
        final remote = await api.fetchEbookChaptersAst(widget.ebook.id);
        if (mounted && remote.isNotEmpty) {
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
    setState(() => _loadingEpub = true);
    try {
      final bytes = await EncryptedEbookVaultService.instance
          .readCachedEpubBytes(widget.ebook.bookCode);
      if (bytes == null || bytes.isEmpty) {
        if (!mounted) return;
        setState(() {
          _loadingEpub = false;
          _statusMessage = 'Paket EPUB3 offline belum tersedia di vault.';
        });
        return;
      }
      final parsed = await parseEpubInRamIsolate(bytes);
      if (!mounted) return;
      setState(() {
        _parsedEpub = parsed;
        _loadingEpub = false;
        _statusMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingEpub = false;
        _statusMessage = 'Gagal mengurai EPUB3 di RAM ($e).';
      });
    }
  }

  Future<void> _ensurePdfDecrypted() async {
    if (_decryptedPdfBytes != null || _loadingPdf) return;
    setState(() => _loadingPdf = true);
    Uint8List? cek;
    try {
      final vault = EncryptedEbookVaultService.instance;
      final clbkBytes = await vault.readCachedClbookBytes(widget.ebook.bookCode);
      if (clbkBytes == null || clbkBytes.isEmpty) {
        if (!mounted) return;
        setState(() {
          _loadingPdf = false;
          _statusMessage =
              'Paket PDF terenkripsi (.clbook) belum diunduh ke vault offline.';
        });
        return;
      }
      cek = vault.deriveBundledTrialCek(widget.ebook.bookCode);
      final plain = await vault.decryptClbookInIsolate(
        clbookBytes: clbkBytes,
        cekBytes: cek,
      );
      final validMagic = plain.length >= 4 &&
          plain[0] == 0x25 &&
          plain[1] == 0x50 &&
          plain[2] == 0x44 &&
          plain[3] == 0x46;
      if (!validMagic) {
        EncryptedEbookVaultService.zeroizeBuffer(plain);
        throw const FormatException('Header PDF %PDF- tidak valid.');
      }
      if (!mounted) {
        EncryptedEbookVaultService.zeroizeBuffer(plain);
        return;
      }
      setState(() {
        _decryptedPdfBytes = plain;
        _loadingPdf = false;
        _statusMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingPdf = false;
        _statusMessage = 'Gagal dekripsi RAM AES-256-GCM ($e).';
      });
    } finally {
      EncryptedEbookVaultService.zeroizeBuffer(cek);
    }
  }

  void _zeroizePdfRam() {
    if (_decryptedPdfBytes != null) {
      EncryptedEbookVaultService.zeroizeBuffer(_decryptedPdfBytes);
      _decryptedPdfBytes = null;
    }
  }

  void _switchMode(_ReaderMode next) {
    if (_mode == next) return;
    if (_mode == _ReaderMode.pdf && next != _ReaderMode.pdf) {
      _zeroizePdfRam();
    }
    setState(() {
      _mode = next;
      _statusMessage = null;
    });
    if (next == _ReaderMode.epub) {
      _ensureEpubLoaded();
    } else if (next == _ReaderMode.pdf) {
      _ensurePdfDecrypted();
    }
    _syncCurrentProgress();
  }

  void _syncCurrentProgress() {
    final chapterNum = _astChapters.isNotEmpty
        ? _astChapters[_activeChapterIdx].chapterNumber
        : 1;
    final modeStr = switch (_mode) {
      _ReaderMode.ast => 'EDITORIAL_AST',
      _ReaderMode.epub => 'EPUB3',
      _ReaderMode.pdf => 'PDF_DRM',
    };
    ref.read(baristaToolkitApiProvider).syncEbookProgress(
          ebookId: widget.ebook.id,
          currentPage: _currentPdfPage,
          currentChapterNumber: chapterNum,
          preferredReaderMode: modeStr,
        );
  }

  @override
  void dispose() {
    _zeroizePdfRam();
    _disableDrmProtection();
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
                'Pengaturan Tipografi & Kertas',
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
                    },
                    selectedColor: AppTheme.primaryBrown,
                    backgroundColor: t.bg,
                    labelStyle: TextStyle(
                      color: sel ? Colors.white : t.text,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _ReaderFont.values.map((f) {
                  final sel = _font == f;
                  return ChoiceChip(
                    label: Text(f.label),
                    selected: sel,
                    onSelected: (_) {
                      setState(() => _font = f);
                      setModalState(() {});
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Ukuran Teks (${_fontSize.toStringAsFixed(0)} pt)',
                      style: TextStyle(color: _theme.text, fontSize: 12.5)),
                  Expanded(
                    child: Slider(
                      value: _fontSize,
                      min: 14,
                      max: 26,
                      divisions: 12,
                      onChanged: (v) {
                        setState(() => _fontSize = v);
                        setModalState(() {});
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Spasi Baris (${_lineHeight.toStringAsFixed(2)}x)',
                      style: TextStyle(color: _theme.text, fontSize: 12.5)),
                  Expanded(
                    child: Slider(
                      value: _lineHeight,
                      min: 1.35,
                      max: 2.0,
                      divisions: 13,
                      onChanged: (v) {
                        setState(() => _lineHeight = v);
                        setModalState(() {});
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

  @override
  Widget build(BuildContext context) {
    final activeChapter = _astChapters.isNotEmpty
        ? _astChapters[_activeChapterIdx.clamp(0, _astChapters.length - 1)]
        : null;
    final chapterNum = activeChapter?.chapterNumber ?? 1;
    final isBookmarked = _bookmarkedChapters.contains(chapterNum);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _theme.bg,
      appBar: AppBar(
        backgroundColor: _theme.bg,
        foregroundColor: _theme.text,
        elevation: 0,
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
              '${widget.ebook.bookCode} • DRM RAM Protected',
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
            tooltip: 'Tipografi & Tema',
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
            tooltip: 'Bookmark Bab Ini',
            icon: Icon(
              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isBookmarked ? AppTheme.accentGold : _theme.text,
              size: 21,
            ),
            onPressed: () {
              setState(() {
                if (isBookmarked) {
                  _bookmarkedChapters.remove(chapterNum);
                } else {
                  _bookmarkedChapters.add(chapterNum);
                }
              });
            },
          ),
          IconButton(
            tooltip: 'Daftar Isi',
            icon: const Icon(Icons.toc_rounded, size: 22),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
      drawer: _buildTocDrawer(),
      body: Column(
        children: [
          _buildModeSwitcherBar(),
          Expanded(
            child: _initializing
                ? Center(
                    child: Text(
                      'Menyiapkan Vault Reader...',
                      style: TextStyle(color: _theme.muted, fontWeight: FontWeight.w600),
                    ),
                  )
                : switch (_mode) {
                    _ReaderMode.ast => _buildAstReaderBody(activeChapter),
                    _ReaderMode.epub => _buildEpubReaderBody(),
                    _ReaderMode.pdf => _buildPdfReaderBody(),
                  },
          ),
        ],
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
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
            decoration: BoxDecoration(
              color: selected ? AppTheme.primaryBrown : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: selected ? Colors.white : _theme.muted,
                ),
                const SizedBox(width: 4),
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
          tab(_ReaderMode.ast, Icons.article_rounded, 'Editorial'),
          tab(_ReaderMode.epub, Icons.menu_book_rounded, 'EPUB3'),
          tab(_ReaderMode.pdf, Icons.picture_as_pdf_rounded, 'PDF 120Hz'),
        ],
      ),
    );
  }

  Widget _buildTocDrawer() {
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
                    'Daftar Isi (${widget.ebook.bookCode})',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: _theme.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.ebook.author,
                    style: TextStyle(fontSize: 12, color: _theme.muted),
                  ),
                ],
              ),
            ),
            Divider(color: _theme.muted.withValues(alpha: 0.25)),
            Expanded(
              child: _astChapters.isNotEmpty
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
                              fontWeight:
                                  active ? FontWeight.w800 : FontWeight.w600,
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
                            _syncCurrentProgress();
                          },
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: widget.ebook.tocChapters.length,
                      itemBuilder: (ctx, i) {
                        final toc = widget.ebook.tocChapters[i];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: AppTheme.accentGold.withValues(alpha: 0.2),
                            child: Text('${toc.chapterNumber}'),
                          ),
                          title: Text(
                            toc.title,
                            style: TextStyle(fontSize: 13, color: _theme.text),
                          ),
                          subtitle: Text('Mulai Hal ${toc.startPage}'),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            setState(() => _currentPdfPage = toc.startPage);
                            if (_pdfController.isReady) {
                              _pdfController.goToPage(pageNumber: toc.startPage);
                            }
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
              Icon(Icons.cloud_download_outlined, size: 46, color: _theme.muted),
              const SizedBox(height: 10),
              Text(
                _statusMessage ?? 'Materi Editorial AST belum diunduh.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _theme.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Silakan kembali ke Pustaka E-Book untuk mengunduh paket offline dari Object Storage.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: _theme.muted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
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
              '~${ch.estimatedReadTimeMin} menit baca • PDF Hal ${ch.startPdfPage}–${ch.endPdfPage}',
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
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.45)),
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
                        const Text('• ', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w900)),
                        Expanded(
                          child: Text(pt, style: _bodyTextStyle(deltaSize: -1.5)),
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
                    _syncCurrentProgress();
                  },
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: const Text('Bab Sebelumnya'),
                ),
              ),
            if (_activeChapterIdx > 0 && _activeChapterIdx < _astChapters.length - 1)
              const SizedBox(width: 10),
            if (_activeChapterIdx < _astChapters.length - 1)
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBrown),
                  onPressed: () {
                    setState(() => _activeChapterIdx++);
                    _syncCurrentProgress();
                  },
                  icon: const Icon(Icons.chevron_right_rounded),
                  label: const Text('Bab Berikutnya'),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAstBlock(EbookDocBlock b, BaristaToolkitApiService api) {
    switch (b.blockType) {
      case 'heading':
      case 'subheading':
        return Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(b.textId, style: _bodyTextStyle(isBold: true, deltaSize: 2.5)),
              if (_bilingualEn && b.textEnOriginal.isNotEmpty)
                Text(b.textEnOriginal, style: _bodyTextStyle(isItalic: true, deltaSize: -1.5)),
            ],
          ),
        );
      case 'formula':
        return Container(
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
                              child: Icon(Icons.image_outlined, color: _theme.muted, size: 36),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text('Zoom HD', style: TextStyle(color: Colors.white, fontSize: 10.5)),
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
          widgetKind: b.widgetKind.isNotEmpty ? b.widgetKind : 'DARCY_PERCOLATION_SLIDER',
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
              Text(b.textId, style: _bodyTextStyle()),
              if (_bilingualEn && b.textEnOriginal.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: AppTheme.accentGold.withValues(alpha: 0.6), width: 2.5),
                    ),
                  ),
                  child: Text(
                    b.textEnOriginal,
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
                          avatar: const Icon(Icons.menu_book_rounded, size: 13, color: AppTheme.primaryBrown),
                          label: Text(t.termTitle, style: const TextStyle(fontSize: 11)),
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
      return const Center(child: CircularProgressIndicator());
    }
    if (_parsedEpub == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_outlined, size: 46, color: _theme.muted),
              const SizedBox(height: 10),
              Text(
                _statusMessage ?? 'EPUB3 belum diunduh ke vault offline.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _theme.text, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBrown),
                onPressed: () => _switchMode(_ReaderMode.ast),
                child: const Text('Buka Mode Editorial AST'),
              ),
            ],
          ),
        ),
      );
    }

    return NativeEpubRamView(
      epub: _parsedEpub!,
      activeChapterIdx: _activeEpubChapterIdx,
      onChapterChanged: (idx) => setState(() => _activeEpubChapterIdx = idx),
      bgColor: _theme.bg,
      textColor: _theme.text,
      fontSize: _fontSize,
      lineHeight: _lineHeight,
      fontFamily: _resolvedFontFamily(),
    );
  }

  Widget _buildPdfReaderBody() {
    if (_loadingPdf) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_decryptedPdfBytes == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline_rounded, size: 46, color: _theme.muted),
              const SizedBox(height: 10),
              Text(
                _statusMessage ?? 'File .clbook belum diunduh dari Object Storage.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _theme.text, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        PdfViewer.data(
          _decryptedPdfBytes!,
          sourceName: 'mem://${widget.ebook.bookCode}.pdf',
          controller: _pdfController,
          initialPageNumber: _currentPdfPage,
          params: PdfViewerParams(
            backgroundColor: _theme.bg,
            onPageChanged: (page) {
              if (page != null && page != _currentPdfPage && mounted) {
                setState(() => _currentPdfPage = page);
                _syncCurrentProgress();
              }
            },
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Coffee Labs Encrypted Vault • ${widget.ebook.bookCode} • Hal $_currentPdfPage/${widget.ebook.totalPages}',
                style: const TextStyle(color: Colors.white, fontSize: 10.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
