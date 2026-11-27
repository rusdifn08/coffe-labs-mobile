import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/data/barista_toolkit_api_service.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/data/ebook_drm_vault_service.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/presentation/ebook_reader/native_epub_ram_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Uint8List _buildSampleEpubBytes() {
  final archive = Archive();
  void addText(String path, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(path, bytes.length, bytes));
  }

  addText('mimetype', 'application/epub+zip');
  addText(
    'META-INF/container.xml',
    '<?xml version="1.0"?><container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">'
    '<rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles>'
    '</container>',
  );
  addText(
    'OEBPS/content.opf',
    '<?xml version="1.0" encoding="utf-8"?><package xmlns="http://www.idpf.org/2007/opf" version="3.0">'
    '<metadata xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:title>Sains Ekstraksi &amp; Kopi</dc:title><dc:creator>Coffee Labs</dc:creator></metadata>'
    '<manifest><item id="c1" href="ch1.xhtml" media-type="application/xhtml+xml"/></manifest>'
    '<spine><itemref idref="c1"/></spine></package>',
  );
  addText(
    'OEBPS/ch1.xhtml',
    '<html><body>'
    '<h1>Bab 1 &mdash; Suhu 93&deg;C &amp; Ekstraksi</h1>'
    '<p>Kopi spesialti memiliki karakter &ldquo;manis&rdquo; saat rasio 1:15 dan CO₂ keluar sempurna.</p>'
    '<blockquote>Kejernihan rasa lahir dari aliran laminar.</blockquote>'
    '<li>Target TDS: 1.25% &ndash; 1.38%</li>'
    '</body></html>',
  );
  final encoded = ZipEncoder().encode(archive);
  return Uint8List.fromList(encoded);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('E-Book System v4 Upgrade Tests', () {
    test('validates PDF, EPUB, and CLBK magic bytes and rejects HTML error pages', () {
      final htmlErr = Uint8List.fromList(
        utf8.encode('<!DOCTYPE html><html><body>401 Unauthorized</body></html>' * 20),
      );
      expect(EncryptedEbookVaultService.isValidPdfBytes(htmlErr), isFalse);
      expect(EncryptedEbookVaultService.isValidEpubBytes(htmlErr), isFalse);
      expect(EncryptedEbookVaultService.isValidClbookBytes(htmlErr), isFalse);

      final fakePdf = Uint8List(1024);
      fakePdf.setRange(0, 5, utf8.encode('%PDF-'));
      expect(EncryptedEbookVaultService.isValidPdfBytes(fakePdf), isTrue);

      final epub = _buildSampleEpubBytes();
      expect(EncryptedEbookVaultService.isValidEpubBytes(epub), isTrue);
    });

    test('parses EPUB3 in RAM with proper UTF-8, HTML entities, and structured blocks', () async {
      final epubBytes = _buildSampleEpubBytes();
      final pkg = await parseEpubInRamIsolate(epubBytes);

      expect(pkg.title, 'Sains Ekstraksi & Kopi');
      expect(pkg.author, 'Coffee Labs');
      expect(pkg.chapters, hasLength(1));

      final ch = pkg.chapters.first;
      expect(ch.title, contains('93°C & Ekstraksi'));
      expect(ch.title, contains('—'));
      expect(ch.blocks.any((b) => b.kind == EpubBlockKind.paragraph && b.text.contains('CO₂')), isTrue);
      expect(ch.blocks.any((b) => b.kind == EpubBlockKind.blockquote && b.text.contains('laminar')), isTrue);
      expect(ch.blocks.any((b) => b.kind == EpubBlockKind.listItem && b.text.contains('–')), isTrue);
    });

    test('formats Dio download errors into user-friendly Indonesian messages', () {
      final req = RequestOptions(path: '/api/v1/toolkit/ebooks/1/asset');
      final err401 = DioException(
        requestOptions: req,
        response: Response(requestOptions: req, statusCode: 401),
        type: DioExceptionType.badResponse,
      );
      final msg401 = BaristaToolkitApiService.formatFriendlyDownloadError(err401);
      expect(msg401, isNot(contains('DioException')));
      expect(msg401.toLowerCase(), contains('login'));

      final timeout = DioException(
        requestOptions: req,
        type: DioExceptionType.receiveTimeout,
      );
      final msgTimeout = BaristaToolkitApiService.formatFriendlyDownloadError(timeout);
      expect(msgTimeout.toLowerCase(), contains('timeout'));
    });

    test('persists and restores local reading state via SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final vault = EncryptedEbookVaultService.instance;
      await vault.saveLocalReadingState(
        'CL-BOOK-03',
        const LocalEbookReadingState(
          readerMode: 'EPUB3',
          pdfPage: 19,
          epubChapterIdx: 2,
          astChapterNumber: 3,
          bookmarkedPages: {5, 19},
          bookmarkedChapters: {2},
        ),
      );

      final loaded = await vault.loadLocalReadingState('CL-BOOK-03');
      expect(loaded.readerMode, 'EPUB3');
      expect(loaded.pdfPage, 19);
      expect(loaded.epubChapterIdx, 2);
      expect(loaded.astChapterNumber, 3);
      expect(loaded.bookmarkedPages, containsAll([5, 19]));
    });

    testWidgets('NativeEpubRamView renders structured EPUB blocks cleanly', (tester) async {
      final pkg = await tester.runAsync(() => parseEpubInRamIsolate(_buildSampleEpubBytes()));
      expect(pkg, isNotNull);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeEpubRamView(
              epub: pkg!,
              activeChapterIdx: 0,
              onChapterChanged: (_) {},
              bgColor: const Color(0xFFF9F5EE),
              textColor: const Color(0xFF2C1D14),
              fontSize: 16,
              lineHeight: 1.65,
              fontFamily: 'serif',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('93°C & Ekstraksi'), findsOneWidget);
      expect(find.textContaining('CO₂'), findsOneWidget);
      expect(find.textContaining('laminar'), findsOneWidget);
    });
  });
}
