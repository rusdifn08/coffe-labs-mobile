import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class ParsedEpubChapter {
  final String title;
  final List<String> paragraphs;
  final List<String> imageRefs;

  const ParsedEpubChapter({
    required this.title,
    required this.paragraphs,
    required this.imageRefs,
  });
}

class ParsedEpubPackage {
  final String title;
  final List<ParsedEpubChapter> chapters;
  final Map<String, List<int>> imagesByPath;

  const ParsedEpubPackage({
    required this.title,
    required this.chapters,
    required this.imagesByPath,
  });
}

/// Mengurai kontainer `.epub` langsung di RAM menggunakan `Isolate.run` tanpa pernah menulis file sementara ke disk.
Future<ParsedEpubPackage> parseEpubInRamIsolate(List<int> epubBytes) {
  return Isolate.run<ParsedEpubPackage>(() {
    final archive = ZipDecoder().decodeBytes(epubBytes);
    final files = <String, ArchiveFile>{};
    for (final f in archive.files) {
      if (f.isFile) {
        files[f.name.replaceAll('\\', '/')] = f;
      }
    }

    String opfPath = '';
    final containerFile = files['META-INF/container.xml'];
    if (containerFile != null) {
      try {
        final doc = XmlDocument.parse(String.fromCharCodes(containerFile.content as List<int>));
        final rf = doc.findAllElements('rootfile').firstOrNull;
        opfPath = rf?.getAttribute('full-path') ?? '';
      } catch (_) {}
    }

    final opfDir = opfPath.contains('/')
        ? opfPath.substring(0, opfPath.lastIndexOf('/') + 1)
        : '';

    final spineHrefs = <String>[];
    String bookTitle = 'EPUB3 Reader';
    final opfFile = files[opfPath];
    if (opfFile != null) {
      try {
        final opfXml = XmlDocument.parse(String.fromCharCodes(opfFile.content as List<int>));
        bookTitle = opfXml.findAllElements('dc:title').firstOrNull?.innerText ??
            opfXml.findAllElements('title').firstOrNull?.innerText ??
            bookTitle;
        final idToHref = <String, String>{};
        for (final item in opfXml.findAllElements('item')) {
          final id = item.getAttribute('id');
          final href = item.getAttribute('href');
          if (id != null && href != null) idToHref[id] = '$opfDir$href';
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
      for (final name in files.keys) {
        if (name.endsWith('.xhtml') || name.endsWith('.html')) {
          spineHrefs.add(name);
        }
      }
    }

    final images = <String, List<int>>{};
    for (final entry in files.entries) {
      final low = entry.key.toLowerCase();
      if (low.endsWith('.png') || low.endsWith('.jpg') || low.endsWith('.jpeg') || low.endsWith('.webp')) {
        images[entry.key] = List<int>.from(entry.value.content as List<int>);
      }
    }

    final chapters = <ParsedEpubChapter>[];
    final htmlTagStrip = RegExp(r'<[^>]+>');
    for (final href in spineHrefs) {
      if (href.endsWith('nav.xhtml')) continue;
      final f = files[href];
      if (f == null) continue;
      final rawHtml = String.fromCharCodes(f.content as List<int>);
      String chTitle = 'Bab ${chapters.length + 1}';
      final hMatch = RegExp(r'<h[12][^>]*>(.*?)</h[12]>', dotAll: true).firstMatch(rawHtml);
      if (hMatch != null) {
        chTitle = hMatch.group(1)!.replaceAll(htmlTagStrip, '').trim();
      }
      final paras = <String>[];
      for (final m in RegExp(r'<(p|h[1-3]|li|div[^>]*formula[^>]*)[^>]*>(.*?)</\1>', dotAll: true).allMatches(rawHtml)) {
        final clean = m.group(2)!.replaceAll(htmlTagStrip, ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
        if (clean.isNotEmpty) paras.add(clean);
      }
      final imgRefs = <String>[];
      for (final im in RegExp(r'''<img[^>]+src=['"]([^'"]+)['"]''').allMatches(rawHtml)) {
        final src = im.group(1)!;
        final resolved = opfDir.isNotEmpty && !src.startsWith(opfDir) ? '$opfDir$src' : src;
        imgRefs.add(resolved.replaceFirst('../', opfDir));
      }
      if (paras.isNotEmpty || imgRefs.isNotEmpty) {
        chapters.add(ParsedEpubChapter(title: chTitle, paragraphs: paras, imageRefs: imgRefs));
      }
    }

    return ParsedEpubPackage(title: bookTitle, chapters: chapters, imagesByPath: images);
  });
}

class NativeEpubRamView extends StatelessWidget {
  final ParsedEpubPackage epub;
  final int activeChapterIdx;
  final ValueChanged<int> onChapterChanged;
  final Color bgColor;
  final Color textColor;
  final double fontSize;
  final double lineHeight;
  final String fontFamily;

  const NativeEpubRamView({
    super.key,
    required this.epub,
    required this.activeChapterIdx,
    required this.onChapterChanged,
    required this.bgColor,
    required this.textColor,
    required this.fontSize,
    required this.lineHeight,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    if (epub.chapters.isEmpty) {
      return Center(
        child: Text(
          'Bab EPUB kosong.',
          style: TextStyle(color: textColor),
        ),
      );
    }
    final safeIdx = activeChapterIdx.clamp(0, epub.chapters.length - 1);
    final ch = epub.chapters[safeIdx];

    return Column(
      children: [
        if (epub.chapters.length > 1)
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              itemCount: epub.chapters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, idx) {
                final sel = idx == safeIdx;
                return ChoiceChip(
                  label: Text('Bab ${idx + 1}'),
                  selected: sel,
                  onSelected: (_) => onChapterChanged(idx),
                );
              },
            ),
          ),
        Expanded(
          child: Container(
            color: bgColor,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                Text(
                  ch.title,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: fontSize + 5,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                ...ch.paragraphs.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      p,
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: fontSize,
                        height: lineHeight,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                ...ch.imageRefs.map((refPath) {
                  final bytes = epub.imagesByPath[refPath] ??
                      epub.imagesByPath.entries
                          .where((e) => e.key.endsWith(refPath.split('/').last))
                          .map((e) => e.value)
                          .firstOrNull;
                  if (bytes == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        // Decoded directly from RAM
                        Uint8List.fromList(bytes),
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
