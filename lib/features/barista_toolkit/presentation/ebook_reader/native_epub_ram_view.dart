import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

enum EpubBlockKind {
  heading1,
  heading2,
  heading3,
  paragraph,
  blockquote,
  listItem,
  formula,
  image,
  divider,
}

class ParsedEpubBlock {
  final EpubBlockKind kind;
  final String text;
  final String? imageRef;

  const ParsedEpubBlock({
    required this.kind,
    this.text = '',
    this.imageRef,
  });
}

class ParsedEpubChapter {
  final String title;
  final List<ParsedEpubBlock> blocks;
  final int wordCount;

  const ParsedEpubChapter({
    required this.title,
    required this.blocks,
    required this.wordCount,
  });

  /// Kompatibilitas mundur bagi pemanggil yang membaca daftar paragraf datar.
  List<String> get paragraphs => blocks
      .where((b) => b.kind != EpubBlockKind.image && b.kind != EpubBlockKind.divider && b.text.isNotEmpty)
      .map((b) => b.text)
      .toList();

  List<String> get imageRefs => blocks
      .where((b) => b.kind == EpubBlockKind.image && (b.imageRef?.isNotEmpty ?? false))
      .map((b) => b.imageRef!)
      .toList();

  int get estimatedMinutes => (wordCount / 210).ceil().clamp(1, 90);
}

class ParsedEpubPackage {
  final String title;
  final String author;
  final List<ParsedEpubChapter> chapters;
  final Map<String, List<int>> imagesByPath;

  const ParsedEpubPackage({
    required this.title,
    this.author = '',
    required this.chapters,
    required this.imagesByPath,
  });
}

String decodeHtmlEntities(String input) {
  if (!input.contains('&')) return input;
  const named = <String, String>{
    '&nbsp;': ' ',
    '&amp;': '&',
    '&lt;': '<',
    '&gt;': '>',
    '&quot;': '"',
    '&apos;': "'",
    '&mdash;': '—',
    '&ndash;': '–',
    '&rsquo;': '’',
    '&lsquo;': '‘',
    '&rdquo;': '”',
    '&ldquo;': '“',
    '&hellip;': '…',
    '&deg;': '°',
    '&times;': '×',
    '&plusmn;': '±',
    '&copy;': '©',
    '&reg;': '®',
    '&bull;': '•',
    '&middot;': '·',
    '&eacute;': 'é',
    '&egrave;': 'è',
    '&aacute;': 'á',
    '&iacute;': 'í',
    '&oacute;': 'ó',
    '&uacute;': 'ú',
    '&ntilde;': 'ñ',
    '&uuml;': 'ü',
  };
  var out = input;
  named.forEach((k, v) {
    if (out.contains(k)) out = out.replaceAll(k, v);
  });
  out = out.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (m) {
    final cp = int.tryParse(m.group(1)!, radix: 16);
    return cp != null ? String.fromCharCode(cp) : m.group(0)!;
  });
  out = out.replaceAllMapped(RegExp(r'&#([0-9]+);'), (m) {
    final cp = int.tryParse(m.group(1)!);
    return cp != null ? String.fromCharCode(cp) : m.group(0)!;
  });
  return out;
}

String _resolveRelativeEpubPath(String baseDir, String rawHref) {
  final cleanHref = Uri.decodeFull(rawHref.split('#').first.split('?').first)
      .replaceAll('\\', '/');
  if (cleanHref.startsWith('/')) return cleanHref.substring(1);
  final combined = '$baseDir$cleanHref';
  final parts = <String>[];
  for (final seg in combined.split('/')) {
    if (seg.isEmpty || seg == '.') continue;
    if (seg == '..') {
      if (parts.isNotEmpty) parts.removeLast();
    } else {
      parts.add(seg);
    }
  }
  return parts.join('/');
}

/// Mengurai kontainer `.epub` secara penuh di RAM via `Isolate.run` dengan dekode UTF-8 & struktur buku utuh.
Future<ParsedEpubPackage> parseEpubInRamIsolate(List<int> epubBytes) {
  return Isolate.run<ParsedEpubPackage>(() {
    final archive = ZipDecoder().decodeBytes(epubBytes);
    final files = <String, ArchiveFile>{};
    for (final f in archive.files) {
      if (f.isFile) {
        files[f.name.replaceAll('\\', '/')] = f;
      }
    }

    String readUtf8(ArchiveFile f) {
      return utf8.decode(f.content, allowMalformed: true);
    }

    String opfPath = '';
    final containerFile = files['META-INF/container.xml'];
    if (containerFile != null) {
      try {
        final doc = XmlDocument.parse(readUtf8(containerFile));
        final rf = doc.findAllElements('rootfile').firstOrNull;
        opfPath = rf?.getAttribute('full-path') ?? '';
      } catch (_) {}
    }

    final opfDir = opfPath.contains('/')
        ? opfPath.substring(0, opfPath.lastIndexOf('/') + 1)
        : '';

    final spineHrefs = <String>[];
    String bookTitle = 'EPUB3 Reader';
    String bookAuthor = '';
    final opfFile = files[opfPath];
    if (opfFile != null) {
      try {
        final opfXml = XmlDocument.parse(readUtf8(opfFile));
        bookTitle = opfXml.findAllElements('dc:title').firstOrNull?.innerText.trim() ??
            opfXml.findAllElements('title').firstOrNull?.innerText.trim() ??
            bookTitle;
        bookAuthor = opfXml.findAllElements('dc:creator').firstOrNull?.innerText.trim() ??
            opfXml.findAllElements('creator').firstOrNull?.innerText.trim() ??
            '';
        final idToHref = <String, String>{};
        for (final item in opfXml.findAllElements('item')) {
          final id = item.getAttribute('id');
          final href = item.getAttribute('href');
          if (id != null && href != null) {
            idToHref[id] = _resolveRelativeEpubPath(opfDir, href);
          }
        }
        for (final ref in opfXml.findAllElements('itemref')) {
          final idref = ref.getAttribute('idref');
          if (idref != null && idToHref.containsKey(idref)) {
            spineHrefs.add(idToHref[idref]!);
          }
        }
      } catch (_) {}
    }

    if (spineHrefs.isEmpty) {
      final sortedKeys = files.keys
          .where((name) =>
              name.endsWith('.xhtml') || name.endsWith('.html') || name.endsWith('.htm'))
          .toList()
        ..sort();
      spineHrefs.addAll(sortedKeys);
    }

    final images = <String, List<int>>{};
    for (final entry in files.entries) {
      final low = entry.key.toLowerCase();
      if (low.endsWith('.png') ||
          low.endsWith('.jpg') ||
          low.endsWith('.jpeg') ||
          low.endsWith('.webp') ||
          low.endsWith('.gif')) {
        images[entry.key] = List<int>.from(entry.value.content as List<int>);
      }
    }

    final chapters = <ParsedEpubChapter>[];
    final htmlTagStrip = RegExp(r'<[^>]+>');
    final scriptStyleStrip =
        RegExp(r'<(script|style)[^>]*>.*?</\1>', dotAll: true, caseSensitive: false);
    final bodyExtract =
        RegExp(r'<body[^>]*>(.*?)</body>', dotAll: true, caseSensitive: false);
    final tokenRegex = RegExp(
      r'<(h1|h2|h3|h4|p|li|blockquote|pre)[^>]*>(.*?)</\1>|<div[^>]*class=[\x27"][^\x27"]*formula[^\x27"]*[\x27"][^>]*>(.*?)</div>|<img[^>]+src=[\x27"]([^\x27"]+)[\x27"][^>]*/?>|<hr[^>]*/?>',
      dotAll: true,
      caseSensitive: false,
    );

    String cleanText(String raw) {
      final stripped = raw
          .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
          .replaceAll(htmlTagStrip, ' ');
      return decodeHtmlEntities(stripped)
          .replaceAll(RegExp(r'[ \t\r]+'), ' ')
          .replaceAll(RegExp(r'\n{3,}'), '\n\n')
          .trim();
    }

    for (final href in spineHrefs) {
      final lowHref = href.toLowerCase();
      if (lowHref.endsWith('nav.xhtml') || lowHref.contains('toc.xhtml')) continue;
      final f = files[href];
      if (f == null) continue;
      final rawHtml = readUtf8(f).replaceAll(scriptStyleStrip, '');
      final bodyMatch = bodyExtract.firstMatch(rawHtml);
      final bodyHtml = bodyMatch != null ? bodyMatch.group(1)! : rawHtml;
      final chapterDir = href.contains('/')
          ? href.substring(0, href.lastIndexOf('/') + 1)
          : '';

      String chTitle = '';
      final blocks = <ParsedEpubBlock>[];
      int words = 0;

      for (final m in tokenRegex.allMatches(bodyHtml)) {
        final fullMatch = m.group(0) ?? '';
        if (fullMatch.toLowerCase().startsWith('<hr')) {
          blocks.add(const ParsedEpubBlock(kind: EpubBlockKind.divider));
          continue;
        }
        final imgSrc = m.group(4);
        if (imgSrc != null && imgSrc.isNotEmpty) {
          final resolved = _resolveRelativeEpubPath(chapterDir, imgSrc);
          blocks.add(ParsedEpubBlock(kind: EpubBlockKind.image, imageRef: resolved));
          continue;
        }
        final formulaBody = m.group(3);
        if (formulaBody != null) {
          final txt = cleanText(formulaBody);
          if (txt.isNotEmpty) {
            blocks.add(ParsedEpubBlock(kind: EpubBlockKind.formula, text: txt));
            words += txt.split(RegExp(r'\s+')).length;
          }
          continue;
        }
        final tag = (m.group(1) ?? '').toLowerCase();
        final inner = m.group(2) ?? '';

        // Tangkap gambar yang berada di dalam tag <p> agar tampil inline pada posisi aslinya
        for (final im in RegExp(r'''<img[^>]+src=['"]([^'"]+)['"]''').allMatches(inner)) {
          final src = im.group(1);
          if (src != null && src.isNotEmpty) {
            final resolved = _resolveRelativeEpubPath(chapterDir, src);
            blocks.add(ParsedEpubBlock(kind: EpubBlockKind.image, imageRef: resolved));
          }
        }

        final txt = cleanText(inner);
        if (txt.isEmpty) continue;

        final kind = switch (tag) {
          'h1' => EpubBlockKind.heading1,
          'h2' => EpubBlockKind.heading2,
          'h3' || 'h4' => EpubBlockKind.heading3,
          'blockquote' => EpubBlockKind.blockquote,
          'li' => EpubBlockKind.listItem,
          'pre' => EpubBlockKind.formula,
          _ => EpubBlockKind.paragraph,
        };

        if (chTitle.isEmpty &&
            (kind == EpubBlockKind.heading1 || kind == EpubBlockKind.heading2)) {
          chTitle = txt;
          // Jangan duplikasi heading pertama sebagai blok jika identik dengan judul bab
          continue;
        }
        blocks.add(ParsedEpubBlock(kind: kind, text: txt));
        words += txt.split(RegExp(r'\s+')).length;
      }

      if (blocks.isEmpty) {
        final fallbackTxt = cleanText(bodyHtml);
        if (fallbackTxt.length > 20) {
          for (final para in fallbackTxt.split('\n\n')) {
            final trimmed = para.trim();
            if (trimmed.isNotEmpty) {
              blocks.add(ParsedEpubBlock(kind: EpubBlockKind.paragraph, text: trimmed));
              words += trimmed.split(RegExp(r'\s+')).length;
            }
          }
        }
      }

      if (blocks.isNotEmpty) {
        if (chTitle.isEmpty) {
          chTitle = 'Bagian ${chapters.length + 1}';
        }
        chapters.add(
          ParsedEpubChapter(
            title: chTitle,
            blocks: blocks,
            wordCount: words,
          ),
        );
      }
    }

    return ParsedEpubPackage(
      title: decodeHtmlEntities(bookTitle),
      author: decodeHtmlEntities(bookAuthor),
      chapters: chapters,
      imagesByPath: images,
    );
  });
}

class NativeEpubRamView extends StatefulWidget {
  final ParsedEpubPackage epub;
  final int activeChapterIdx;
  final ValueChanged<int> onChapterChanged;
  final VoidCallback? onTapToggleImmersive;
  final Color bgColor;
  final Color cardBgColor;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;
  final double fontSize;
  final double lineHeight;
  final String fontFamily;
  final bool justified;

  const NativeEpubRamView({
    super.key,
    required this.epub,
    required this.activeChapterIdx,
    required this.onChapterChanged,
    this.onTapToggleImmersive,
    required this.bgColor,
    this.cardBgColor = const Color(0xFFFFFCF7),
    required this.textColor,
    this.mutedColor = const Color(0xFF795548),
    this.accentColor = const Color(0xFFD4AF37),
    required this.fontSize,
    required this.lineHeight,
    required this.fontFamily,
    this.justified = true,
  });

  @override
  State<NativeEpubRamView> createState() => _NativeEpubRamViewState();
}

class _NativeEpubRamViewState extends State<NativeEpubRamView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant NativeEpubRamView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeChapterIdx != widget.activeChapterIdx &&
        _scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<int>? _resolveImageBytes(String refPath) {
    final exact = widget.epub.imagesByPath[refPath];
    if (exact != null) return exact;
    final tail = refPath.split('/').last.toLowerCase();
    for (final e in widget.epub.imagesByPath.entries) {
      if (e.key.toLowerCase().endsWith(tail)) return e.value;
    }
    return null;
  }

  void _openImageZoom(Uint8List bytes) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.5,
                child: Image.memory(bytes, fit: BoxFit.contain),
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.epub.chapters.isEmpty) {
      return Center(
        child: Text(
          'Bab EPUB kosong.',
          style: TextStyle(color: widget.textColor),
        ),
      );
    }
    final totalChapters = widget.epub.chapters.length;
    final safeIdx = widget.activeChapterIdx.clamp(0, totalChapters - 1);
    final ch = widget.epub.chapters[safeIdx];
    final progress = (safeIdx + 1) / totalChapters;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTapToggleImmersive,
      child: Container(
        color: widget.bgColor,
        child: Column(
          children: [
            // Garis progres baca tipis ala Kindle / Apple Books
            LinearProgressIndicator(
              value: progress,
              minHeight: 2.5,
              backgroundColor: widget.mutedColor.withValues(alpha: 0.14),
              color: widget.accentColor,
            ),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: false,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 48),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header ornament bab
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: widget.accentColor.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'BAB ${safeIdx + 1} / $totalChapters',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: widget.textColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '~${ch.estimatedMinutes} menit baca',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: widget.mutedColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              ch.title,
                              style: TextStyle(
                                fontFamily: widget.fontFamily,
                                fontSize: widget.fontSize + 7,
                                height: 1.25,
                                fontWeight: FontWeight.w800,
                                color: widget.textColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: widget.accentColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Divider(
                                    color: widget.mutedColor.withValues(alpha: 0.2),
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            ...ch.blocks.map(_buildBlock),
                            const SizedBox(height: 28),
                            Divider(color: widget.mutedColor.withValues(alpha: 0.22)),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                if (safeIdx > 0)
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: widget.textColor,
                                        side: BorderSide(
                                          color: widget.mutedColor.withValues(alpha: 0.4),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      onPressed: () =>
                                          widget.onChapterChanged(safeIdx - 1),
                                      icon: const Icon(Icons.chevron_left_rounded),
                                      label: const Text('Bab Sebelumnya'),
                                    ),
                                  ),
                                if (safeIdx > 0 && safeIdx < totalChapters - 1)
                                  const SizedBox(width: 10),
                                if (safeIdx < totalChapters - 1)
                                  Expanded(
                                    child: FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFF5D3A1A),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      onPressed: () =>
                                          widget.onChapterChanged(safeIdx + 1),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlock(ParsedEpubBlock block) {
    final align = widget.justified ? TextAlign.justify : TextAlign.start;

    switch (block.kind) {
      case EpubBlockKind.heading1:
        return Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 10),
          child: Text(
            block.text,
            style: TextStyle(
              fontFamily: widget.fontFamily,
              fontSize: widget.fontSize + 4.5,
              height: 1.3,
              fontWeight: FontWeight.w800,
              color: widget.textColor,
            ),
          ),
        );
      case EpubBlockKind.heading2:
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            block.text,
            style: TextStyle(
              fontFamily: widget.fontFamily,
              fontSize: widget.fontSize + 2.5,
              height: 1.35,
              fontWeight: FontWeight.w800,
              color: widget.textColor,
            ),
          ),
        );
      case EpubBlockKind.heading3:
        return Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            block.text,
            style: TextStyle(
              fontFamily: widget.fontFamily,
              fontSize: widget.fontSize + 1,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: widget.mutedColor,
            ),
          ),
        );
      case EpubBlockKind.blockquote:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            color: widget.cardBgColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            border: Border(
              left: BorderSide(color: widget.accentColor, width: 3.5),
            ),
          ),
          child: Text(
            block.text,
            style: TextStyle(
              fontFamily: widget.fontFamily,
              fontSize: widget.fontSize - 0.5,
              height: widget.lineHeight,
              fontStyle: FontStyle.italic,
              color: widget.mutedColor,
            ),
          ),
        );
      case EpubBlockKind.formula:
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF231710),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.accentColor.withValues(alpha: 0.45)),
          ),
          child: Text(
            block.text,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: (widget.fontSize - 2.5).clamp(11.5, 16.0),
              height: 1.5,
              color: widget.accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case EpubBlockKind.listItem:
        return Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 8),
                child: Text(
                  '•',
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w900,
                    color: widget.accentColor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  block.text,
                  textAlign: align,
                  style: TextStyle(
                    fontFamily: widget.fontFamily,
                    fontSize: widget.fontSize,
                    height: widget.lineHeight,
                    color: widget.textColor,
                  ),
                ),
              ),
            ],
          ),
        );
      case EpubBlockKind.image:
        final bytes = block.imageRef != null ? _resolveImageBytes(block.imageRef!) : null;
        if (bytes == null || bytes.isEmpty) return const SizedBox.shrink();
        final u8 = Uint8List.fromList(bytes);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: GestureDetector(
            onTap: () => _openImageZoom(u8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Center(
                    child: Image.memory(
                      u8,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
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
                          Icon(Icons.zoom_in_rounded, color: Colors.white, size: 13),
                          SizedBox(width: 4),
                          Text('Perbesar',
                              style: TextStyle(color: Colors.white, fontSize: 10.5)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case EpubBlockKind.divider:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              '•  •  •',
              style: TextStyle(
                color: widget.accentColor,
                fontSize: 14,
                letterSpacing: 4,
              ),
            ),
          ),
        );
      case EpubBlockKind.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 13),
          child: Text(
            block.text,
            textAlign: align,
            style: TextStyle(
              fontFamily: widget.fontFamily,
              fontSize: widget.fontSize,
              height: widget.lineHeight,
              color: widget.textColor,
            ),
          ),
        );
    }
  }
}
