import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:crypto/crypto.dart' as crypto_hash;
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/barista_toolkit_models.dart';

/// Ringkasan ketersediaan format E-Book di penyimpanan lokal perangkat pengguna.
class OfflineBookFormats {
  final bool hasPdf;
  final bool hasEpub;
  final bool hasAst;
  final int totalBytes;

  const OfflineBookFormats({
    required this.hasPdf,
    required this.hasEpub,
    required this.hasAst,
    required this.totalBytes,
  });

  bool get hasAny => hasPdf || hasEpub || hasAst;
}

/// Preferensi & posisi baca lokal (100% offline-first, otomatis sinkron saat online).
class LocalEbookReadingState {
  final String readerMode;
  final int pdfPage;
  final int epubChapterIdx;
  final int astChapterNumber;
  final Set<int> bookmarkedPages;
  final Set<int> bookmarkedChapters;

  const LocalEbookReadingState({
    this.readerMode = 'PDF_DRM',
    this.pdfPage = 1,
    this.epubChapterIdx = 0,
    this.astChapterNumber = 1,
    this.bookmarkedPages = const {},
    this.bookmarkedChapters = const {},
  });
}

/// Persistent Offline E-Book Storage & DRM Vault Service:
/// - Menyimpan E-Book lengkap (PDF asli, EPUB3 reflowable, Editorial AST, & .clbook)
///   secara permanen di penyimpanan dokumen perangkat (`coffee_labs_ebooks/{bookCode}/`)
///   dengan penulisan atomik (`.tmp` -> rename) agar file tidak pernah korup.
/// - Tetap mendukung migrasi & baca dari direktori legacy `clbook_vault/{bookCode}/`.
/// - Validasi magic-bytes (`%PDF-`, `PK`, `CLBK`) sebelum menyimpan agar halaman error HTML
///   tidak pernah tersimpan sebagai buku rusak.
class EncryptedEbookVaultService {
  EncryptedEbookVaultService._();
  static final EncryptedEbookVaultService instance = EncryptedEbookVaultService._();

  static const _storage = FlutterSecureStorage();
  static const _deviceIdKey = 'cl_drm_device_install_id_v1';
  static const _deviceSecretKey = 'cl_drm_device_wrap_secret_v1';
  static const _defaultRootSecret = 'coffee-labs-drm-root-key-2026-prod';

  // Memory cache khusus web / unit test / akses ulang cepat
  final Map<String, Uint8List> _memPdfCache = {};
  final Map<String, Uint8List> _memClbookCache = {};
  final Map<String, Uint8List> _memEpubCache = {};
  final Map<String, List<EbookChapterAstModel>> _memAstCache = {};

  static bool isValidPdfBytes(Uint8List bytes) {
    if (bytes.length < 512) return false;
    return bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46 &&
        bytes[4] == 0x2D;
  }

  static bool isValidEpubBytes(Uint8List bytes) {
    if (bytes.length < 256) return false;
    return bytes[0] == 0x50 && bytes[1] == 0x4B;
  }

  static bool isValidClbookBytes(Uint8List bytes) {
    if (bytes.length < 6 + 12 + 16) return false;
    return bytes[0] == 0x43 &&
        bytes[1] == 0x4C &&
        bytes[2] == 0x42 &&
        bytes[3] == 0x4B;
  }

  Future<(String deviceId, Uint8List deviceSecret)> ensureDeviceCredentials() async {
    String? deviceId;
    String? secretB64;
    try {
      deviceId = await _storage.read(key: _deviceIdKey);
      secretB64 = await _storage.read(key: _deviceSecretKey);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      deviceId = prefs.getString(_deviceIdKey);
      secretB64 = prefs.getString(_deviceSecretKey);
    }

    if (deviceId == null || deviceId.isEmpty) {
      deviceId = 'dev_${const Uuid().v4()}';
      try {
        await _storage.write(key: _deviceIdKey, value: deviceId);
      } catch (_) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_deviceIdKey, deviceId);
      }
    }

    Uint8List secretBytes;
    if (secretB64 == null || secretB64.isEmpty) {
      final rng = math.Random.secure();
      secretBytes = Uint8List.fromList(List<int>.generate(32, (_) => rng.nextInt(256)));
      final encoded = base64Encode(secretBytes);
      try {
        await _storage.write(key: _deviceSecretKey, value: encoded);
      } catch (_) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_deviceSecretKey, encoded);
      }
    } else {
      secretBytes = base64Decode(secretB64);
    }

    return (deviceId, secretBytes);
  }

  /// Direktori utama penyimpanan E-Book pengguna (persisten di Documents perangkat).
  Future<Directory?> _primaryBookDir(String bookCode, {bool create = false}) async {
    if (kIsWeb) return null;
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${docsDir.path}${Platform.pathSeparator}coffee_labs_ebooks${Platform.pathSeparator}$bookCode');
      if (create && !await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    } catch (_) {
      return _legacyBookVaultDir(bookCode, create: create);
    }
  }

  /// Direktori legacy `clbook_vault` agar unduhan versi sebelumnya tetap terbaca.
  Future<Directory?> _legacyBookVaultDir(String bookCode, {bool create = false}) async {
    if (kIsWeb) return null;
    try {
      final supportDir = await getApplicationSupportDirectory();
      final dir = Directory('${supportDir.path}${Platform.pathSeparator}clbook_vault${Platform.pathSeparator}$bookCode');
      if (create && !await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    } catch (_) {
      return null;
    }
  }

  Future<List<Directory>> _candidateDirs(String bookCode) async {
    final dirs = <Directory>[];
    final primary = await _primaryBookDir(bookCode);
    if (primary != null && await primary.exists()) {
      dirs.add(primary);
    }
    final legacy = await _legacyBookVaultDir(bookCode);
    if (legacy != null &&
        await legacy.exists() &&
        (primary == null || legacy.path != primary.path)) {
      dirs.add(legacy);
    }
    return dirs;
  }

  Future<File?> _findExistingFile(String bookCode, String filename) async {
    for (final dir in await _candidateDirs(bookCode)) {
      final f = File('${dir.path}${Platform.pathSeparator}$filename');
      if (await f.exists() && await f.length() > 0) {
        return f;
      }
    }
    return null;
  }

  Future<void> _atomicWriteBytes(File target, Uint8List bytes) async {
    final tmp = File('${target.path}.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    if (await target.exists()) {
      await target.delete();
    }
    await tmp.rename(target.path);
  }

  Future<void> _atomicWriteString(File target, String content) async {
    final tmp = File('${target.path}.tmp');
    await tmp.writeAsString(content, flush: true);
    if (await target.exists()) {
      await target.delete();
    }
    await tmp.rename(target.path);
  }

  Future<OfflineBookFormats> getOfflineFormats(String bookCode) async {
    bool hasPdf = _memPdfCache.containsKey(bookCode) ||
        _memClbookCache.containsKey(bookCode);
    bool hasEpub = _memEpubCache.containsKey(bookCode);
    bool hasAst = (_memAstCache[bookCode]?.isNotEmpty ?? false);

    if (!hasPdf) {
      hasPdf = (await _findExistingFile(bookCode, '$bookCode.pdf')) != null ||
          (await _findExistingFile(bookCode, '$bookCode.clbook')) != null;
    }
    if (!hasEpub) {
      hasEpub = (await _findExistingFile(bookCode, '$bookCode.epub')) != null ||
          (await _findExistingFile(bookCode, '$bookCode.clepub')) != null;
    }
    if (!hasAst) {
      hasAst = (await _findExistingFile(bookCode, '$bookCode.ast.json')) != null;
    }
    final size = await getOfflineVaultSizeBytes(bookCode);
    return OfflineBookFormats(
      hasPdf: hasPdf,
      hasEpub: hasEpub,
      hasAst: hasAst,
      totalBytes: size,
    );
  }

  Future<bool> isBookDownloadedOffline(String bookCode) async {
    if (_memPdfCache.containsKey(bookCode) ||
        _memClbookCache.containsKey(bookCode) ||
        _memEpubCache.containsKey(bookCode) ||
        (_memAstCache[bookCode]?.isNotEmpty ?? false)) {
      return true;
    }
    final formats = await getOfflineFormats(bookCode);
    return formats.hasAny;
  }

  Future<int> getOfflineVaultSizeBytes(String bookCode) async {
    int total = 0;
    for (final dir in await _candidateDirs(bookCode)) {
      await for (final entity in dir.list()) {
        if (entity is File && !entity.path.endsWith('.tmp')) {
          total += await entity.length();
        }
      }
    }
    if (total == 0) {
      total += _memPdfCache[bookCode]?.length ?? 0;
      total += _memClbookCache[bookCode]?.length ?? 0;
      total += _memEpubCache[bookCode]?.length ?? 0;
    }
    return total;
  }

  Future<void> deleteOfflineBook(String bookCode) async {
    _memPdfCache.remove(bookCode);
    _memClbookCache.remove(bookCode);
    _memEpubCache.remove(bookCode);
    _memAstCache.remove(bookCode);
    for (final dir in await _candidateDirs(bookCode)) {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    }
  }

  Future<void> saveDownloadedBookPackage({
    required String bookCode,
    Uint8List? pdfBytes,
    Uint8List? clbookBytes,
    Uint8List? epubBytes,
    List<EbookChapterAstModel>? chaptersAst,
  }) async {
    final validPdf =
        pdfBytes != null && isValidPdfBytes(pdfBytes) ? pdfBytes : null;
    final validClbk =
        clbookBytes != null && isValidClbookBytes(clbookBytes) ? clbookBytes : null;
    final validEpub =
        epubBytes != null && isValidEpubBytes(epubBytes) ? epubBytes : null;

    if (validPdf != null) {
      _memPdfCache[bookCode] = Uint8List.fromList(validPdf);
    }
    if (validClbk != null) {
      _memClbookCache[bookCode] = Uint8List.fromList(validClbk);
    }
    if (validEpub != null) {
      _memEpubCache[bookCode] = Uint8List.fromList(validEpub);
    }
    if (chaptersAst != null && chaptersAst.isNotEmpty) {
      _memAstCache[bookCode] = chaptersAst;
    }

    final dir = await _primaryBookDir(bookCode, create: true);
    if (dir == null) return;

    if (validPdf != null) {
      await _atomicWriteBytes(
        File('${dir.path}${Platform.pathSeparator}$bookCode.pdf'),
        validPdf,
      );
    }
    if (validClbk != null) {
      await _atomicWriteBytes(
        File('${dir.path}${Platform.pathSeparator}$bookCode.clbook'),
        validClbk,
      );
    }
    if (validEpub != null) {
      await _atomicWriteBytes(
        File('${dir.path}${Platform.pathSeparator}$bookCode.epub'),
        validEpub,
      );
    }
    if (chaptersAst != null && chaptersAst.isNotEmpty) {
      final rawJson = jsonEncode(
        chaptersAst
            .map((c) => {
                  'id': c.id,
                  'chapter_number': c.chapterNumber,
                  'title_id': c.titleId,
                  'title_en': c.titleEn,
                  'estimated_read_time_min': c.estimatedReadTimeMin,
                  'start_pdf_page': c.startPdfPage,
                  'end_pdf_page': c.endPdfPage,
                  'mobile_blocks_ast': c.blocks
                      .map((b) => {
                            'block_id': b.blockId,
                            'block_type': b.blockType,
                            'text_id': b.textId,
                            'text_en_original': b.textEnOriginal,
                            'latex_expression': b.latexExpression,
                            'widget_kind': b.widgetKind,
                            'figure_secure_url': b.figureSecureUrl,
                            'figure_caption_id': b.figureCaptionId,
                          })
                      .toList(),
                  'key_summary_points': c.keySummaryPoints,
                  'chapter_quiz_json': c.chapterQuiz
                      .map((q) => {
                            'q': q.question,
                            'options': q.options,
                            'answer_idx': q.answerIdx,
                          })
                      .toList(),
                })
            .toList(),
      );
      await _atomicWriteString(
        File('${dir.path}${Platform.pathSeparator}$bookCode.ast.json'),
        rawJson,
      );
    }
  }

  /// Membaca bytes PDF asli langsung dari penyimpanan lokal (atau dekripsi fallback dari `.clbook`).
  Future<Uint8List?> readCachedPdfBytes(String bookCode) async {
    final mem = _memPdfCache[bookCode];
    if (mem != null && isValidPdfBytes(mem)) {
      return Uint8List.fromList(mem);
    }
    final pdfFile = await _findExistingFile(bookCode, '$bookCode.pdf');
    if (pdfFile != null) {
      final bytes = await pdfFile.readAsBytes();
      if (isValidPdfBytes(bytes)) {
        return bytes;
      }
    }
    final clbkBytes = await readCachedClbookBytes(bookCode);
    if (clbkBytes != null && isValidClbookBytes(clbkBytes)) {
      final cek = deriveBundledTrialCek(bookCode);
      try {
        final plain = await decryptClbookInIsolate(
          clbookBytes: clbkBytes,
          cekBytes: cek,
        );
        if (isValidPdfBytes(plain)) {
          return plain;
        }
      } catch (_) {
        // Abaikan jika kunci lama tidak cocok
      } finally {
        zeroizeBuffer(cek);
      }
    }
    return null;
  }

  /// Mengembalikan file PDF lokal di penyimpanan perangkat untuk ekspor/buka di pembaca eksternal.
  Future<File?> getOrMaterializeLocalPdfFile(String bookCode) async {
    final existing = await _findExistingFile(bookCode, '$bookCode.pdf');
    if (existing != null) return existing;
    final bytes = await readCachedPdfBytes(bookCode);
    if (bytes == null) return null;
    final dir = await _primaryBookDir(bookCode, create: true);
    if (dir == null) return null;
    final out = File('${dir.path}${Platform.pathSeparator}$bookCode.pdf');
    await _atomicWriteBytes(out, bytes);
    return out;
  }

  Future<Uint8List?> readCachedClbookBytes(String bookCode) async {
    final mem = _memClbookCache[bookCode];
    if (mem != null) return Uint8List.fromList(mem);
    final f = await _findExistingFile(bookCode, '$bookCode.clbook');
    if (f != null) {
      return await f.readAsBytes();
    }
    return null;
  }

  Future<Uint8List?> readCachedEpubBytes(String bookCode) async {
    final mem = _memEpubCache[bookCode];
    if (mem != null && isValidEpubBytes(mem)) return Uint8List.fromList(mem);

    final plainFile = await _findExistingFile(bookCode, '$bookCode.epub');
    if (plainFile != null) {
      final bytes = await plainFile.readAsBytes();
      if (isValidEpubBytes(bytes)) return bytes;
    }

    final encFile = await _findExistingFile(bookCode, '$bookCode.clepub');
    if (encFile != null) {
      final encBytes = await encFile.readAsBytes();
      final cek = deriveBundledTrialCek(bookCode);
      try {
        final plain = await decryptClbookInIsolate(
          clbookBytes: encBytes,
          cekBytes: cek,
        );
        if (isValidEpubBytes(plain)) return plain;
      } catch (_) {
      } finally {
        zeroizeBuffer(cek);
      }
    }
    return null;
  }

  Future<List<EbookChapterAstModel>> readCachedChaptersAst(String bookCode) async {
    final mem = _memAstCache[bookCode];
    if (mem != null && mem.isNotEmpty) return mem;
    final f = await _findExistingFile(bookCode, '$bookCode.ast.json');
    if (f == null) return const [];
    try {
      final decoded = jsonDecode(await f.readAsString()) as List<dynamic>;
      final parsed = decoded
          .map((e) => EbookChapterAstModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      _memAstCache[bookCode] = parsed;
      return parsed;
    } catch (_) {
      return const [];
    }
  }

  /// Simpan posisi halaman & bookmark buku secara lokal agar instan saat dibuka kembali.
  Future<void> saveLocalReadingState(
    String bookCode,
    LocalEbookReadingState state,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonEncode({
        'mode': state.readerMode,
        'pdf_page': state.pdfPage,
        'epub_ch': state.epubChapterIdx,
        'ast_ch': state.astChapterNumber,
        'bm_pages': state.bookmarkedPages.toList(),
        'bm_chapters': state.bookmarkedChapters.toList(),
      });
      await prefs.setString('cl_ebook_state_v2_$bookCode', payload);
    } catch (_) {}
  }

  Future<LocalEbookReadingState> loadLocalReadingState(
    String bookCode, {
    int fallbackPdfPage = 1,
    int fallbackAstChapter = 1,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cl_ebook_state_v2_$bookCode');
      if (raw == null || raw.isEmpty) {
        return LocalEbookReadingState(
          pdfPage: fallbackPdfPage,
          astChapterNumber: fallbackAstChapter,
        );
      }
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return LocalEbookReadingState(
        readerMode: m['mode']?.toString() ?? 'PDF_DRM',
        pdfPage: (m['pdf_page'] as num?)?.toInt() ?? fallbackPdfPage,
        epubChapterIdx: (m['epub_ch'] as num?)?.toInt() ?? 0,
        astChapterNumber: (m['ast_ch'] as num?)?.toInt() ?? fallbackAstChapter,
        bookmarkedPages: (m['bm_pages'] as List? ?? [])
            .map((e) => (e as num).toInt())
            .toSet(),
        bookmarkedChapters: (m['bm_chapters'] as List? ?? [])
            .map((e) => (e as num).toInt())
            .toSet(),
      );
    } catch (_) {
      return LocalEbookReadingState(
        pdfPage: fallbackPdfPage,
        astChapterNumber: fallbackAstChapter,
      );
    }
  }

  Future<void> saveTypographyPrefs({
    required String themeName,
    required String fontName,
    required double fontSize,
    required double lineHeight,
    required bool justified,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'cl_ebook_typo_v2',
        jsonEncode({
          'theme': themeName,
          'font': fontName,
          'size': fontSize,
          'lh': lineHeight,
          'just': justified,
        }),
      );
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> loadTypographyPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cl_ebook_typo_v2');
      if (raw == null || raw.isEmpty) return null;
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List> unwrapDeviceCek({
    required String wrappedCekB64,
    required String wrapNonceB64,
    required String aadContext,
    required String deviceId,
    required Uint8List deviceSecret,
  }) async {
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final kWrap = await hkdf.deriveKey(
      secretKey: SecretKey(deviceSecret),
      nonce: utf8.encode(deviceId),
      info: utf8.encode(aadContext),
    );

    final encrypted = base64Decode(wrappedCekB64);
    if (encrypted.length < 16) {
      throw const FormatException('Wrapped CEK tidak valid.');
    }
    final ct = encrypted.sublist(0, encrypted.length - 16);
    final macBytes = encrypted.sublist(encrypted.length - 16);
    final aesGcm = AesGcm.with256bits();
    final plain = await aesGcm.decrypt(
      SecretBox(ct, nonce: base64Decode(wrapNonceB64), mac: Mac(macBytes)),
      secretKey: kWrap,
      aad: utf8.encode(aadContext),
    );
    return Uint8List.fromList(plain);
  }

  Uint8List deriveBundledTrialCek(String bookCode) {
    final digest = crypto_hash.sha256.convert(
      utf8.encode('CLBK-BOOK-CEK|$bookCode|$_defaultRootSecret'),
    );
    return Uint8List.fromList(digest.bytes);
  }

  Future<Uint8List> encryptPayloadInIsolate({
    required Uint8List payload,
    required Uint8List cekBytes,
  }) {
    final plainCopy = Uint8List.fromList(payload);
    final keyCopy = Uint8List.fromList(cekBytes);
    return Isolate.run<Uint8List>(() async {
      final header = Uint8List.fromList([0x43, 0x4C, 0x42, 0x4B, 0x00, 0x01]);
      final rng = math.Random.secure();
      final nonce = Uint8List.fromList(List<int>.generate(12, (_) => rng.nextInt(256)));
      final cipher = AesGcm.with256bits();
      final box = await cipher.encrypt(
        plainCopy,
        secretKey: SecretKey(keyCopy),
        nonce: nonce,
        aad: header,
      );
      keyCopy.fillRange(0, keyCopy.length, 0);
      final out = Uint8List(header.length + nonce.length + box.cipherText.length + box.mac.bytes.length);
      var offset = 0;
      out.setAll(offset, header);
      offset += header.length;
      out.setAll(offset, nonce);
      offset += nonce.length;
      out.setAll(offset, box.cipherText);
      offset += box.cipherText.length;
      out.setAll(offset, box.mac.bytes);
      return out;
    });
  }

  /// Mendekripsi paket `.clbook` (`[CLBK\x00\x01][12B Nonce][Ciphertext][16B GCM Tag]`) di `Isolate.run` RAM.
  Future<Uint8List> decryptClbookInIsolate({
    required Uint8List clbookBytes,
    required Uint8List cekBytes,
  }) {
    final copiedBlob = Uint8List.fromList(clbookBytes);
    final copiedKey = Uint8List.fromList(cekBytes);

    return Isolate.run<Uint8List>(() async {
      if (copiedBlob.length < 6 + 12 + 16) {
        throw const FormatException('Ukuran file .clbook korup atau tidak lengkap.');
      }
      if (copiedBlob[0] != 0x43 ||
          copiedBlob[1] != 0x4C ||
          copiedBlob[2] != 0x42 ||
          copiedBlob[3] != 0x4B) {
        throw const FormatException('Header magic CLBK tidak cocok.');
      }

      final headerAad = copiedBlob.sublist(0, 6);
      final nonce = copiedBlob.sublist(6, 18);
      final ct = copiedBlob.sublist(18, copiedBlob.length - 16);
      final tag = copiedBlob.sublist(copiedBlob.length - 16);

      final cipher = AesGcm.with256bits();
      final decrypted = await cipher.decrypt(
        SecretBox(ct, nonce: nonce, mac: Mac(tag)),
        secretKey: SecretKey(copiedKey),
        aad: headerAad,
      );
      copiedKey.fillRange(0, copiedKey.length, 0);
      return Uint8List.fromList(decrypted);
    });
  }

  static void zeroizeBuffer(Uint8List? buffer) {
    if (buffer != null && buffer.isNotEmpty) {
      buffer.fillRange(0, buffer.length, 0);
    }
  }
}
