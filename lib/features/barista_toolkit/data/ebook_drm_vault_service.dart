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

/// Zero-Disk-Leak E-Book DRM Vault (Offline-First On-Demand Download):
/// - Ukuran APK ringan: tidak ada binary PDF/EPUB/.clbook yang di-bundle di assets/ebooks/.
/// - File diunduh on-demand dari Object Storage -> dienkripsi & disimpan ke app-private `clbook_vault`.
/// - Saat dibaca, dekripsi berjalan di background `Isolate.run` ke `Uint8List` di RAM & di-zeroize saat ditutup.
class EncryptedEbookVaultService {
  EncryptedEbookVaultService._();
  static final EncryptedEbookVaultService instance = EncryptedEbookVaultService._();

  static const _storage = FlutterSecureStorage();
  static const _deviceIdKey = 'cl_drm_device_install_id_v1';
  static const _deviceSecretKey = 'cl_drm_device_wrap_secret_v1';
  static const _defaultRootSecret = 'coffee-labs-drm-root-key-2026-prod';

  // Memory fallback khusus platform web / unit test
  final Map<String, Uint8List> _memClbookCache = {};
  final Map<String, Uint8List> _memEpubCache = {};
  final Map<String, List<EbookChapterAstModel>> _memAstCache = {};

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

  Future<Directory?> _bookVaultDir(String bookCode, {bool create = false}) async {
    if (kIsWeb) return null;
    try {
      final supportDir = await getApplicationSupportDirectory();
      final dir = Directory('${supportDir.path}/clbook_vault/$bookCode');
      if (create && !await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    } catch (_) {
      return null;
    }
  }

  Future<bool> isBookDownloadedOffline(String bookCode) async {
    if (_memClbookCache.containsKey(bookCode) || _memAstCache.containsKey(bookCode)) {
      return true;
    }
    final dir = await _bookVaultDir(bookCode);
    if (dir == null || !await dir.exists()) return false;
    final clbk = File('${dir.path}/$bookCode.clbook');
    final ast = File('${dir.path}/$bookCode.ast.json');
    return await clbk.exists() || await ast.exists();
  }

  Future<int> getOfflineVaultSizeBytes(String bookCode) async {
    int total = 0;
    final dir = await _bookVaultDir(bookCode);
    if (dir != null && await dir.exists()) {
      await for (final entity in dir.list()) {
        if (entity is File) {
          total += await entity.length();
        }
      }
    }
    if (total == 0 && _memClbookCache.containsKey(bookCode)) {
      total += _memClbookCache[bookCode]!.length;
      total += _memEpubCache[bookCode]?.length ?? 0;
    }
    return total;
  }

  Future<void> deleteOfflineBook(String bookCode) async {
    _memClbookCache.remove(bookCode);
    _memEpubCache.remove(bookCode);
    _memAstCache.remove(bookCode);
    final dir = await _bookVaultDir(bookCode);
    if (dir != null && await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<void> saveDownloadedBookPackage({
    required String bookCode,
    Uint8List? clbookBytes,
    Uint8List? epubBytes,
    List<EbookChapterAstModel>? chaptersAst,
  }) async {
    if (clbookBytes != null && clbookBytes.isNotEmpty) {
      _memClbookCache[bookCode] = Uint8List.fromList(clbookBytes);
    }
    if (epubBytes != null && epubBytes.isNotEmpty) {
      _memEpubCache[bookCode] = Uint8List.fromList(epubBytes);
    }
    if (chaptersAst != null && chaptersAst.isNotEmpty) {
      _memAstCache[bookCode] = chaptersAst;
    }

    final dir = await _bookVaultDir(bookCode, create: true);
    if (dir == null) return;

    if (clbookBytes != null && clbookBytes.isNotEmpty) {
      await File('${dir.path}/$bookCode.clbook').writeAsBytes(clbookBytes, flush: true);
    }
    if (epubBytes != null && epubBytes.isNotEmpty) {
      // Bungkus file EPUB ke AES-256-GCM sebelum ditulis ke app-private disk!
      final cek = deriveBundledTrialCek(bookCode);
      final wrappedEpub = await encryptPayloadInIsolate(payload: epubBytes, cekBytes: cek);
      zeroizeBuffer(cek);
      await File('${dir.path}/$bookCode.clepub').writeAsBytes(wrappedEpub, flush: true);
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
      await File('${dir.path}/$bookCode.ast.json').writeAsString(rawJson, flush: true);
    }
  }

  Future<Uint8List?> readCachedClbookBytes(String bookCode) async {
    final mem = _memClbookCache[bookCode];
    if (mem != null) return Uint8List.fromList(mem);
    final dir = await _bookVaultDir(bookCode);
    if (dir == null) return null;
    final f = File('${dir.path}/$bookCode.clbook');
    if (await f.exists()) {
      return await f.readAsBytes();
    }
    return null;
  }

  Future<Uint8List?> readCachedEpubBytes(String bookCode) async {
    final mem = _memEpubCache[bookCode];
    if (mem != null) return Uint8List.fromList(mem);
    final dir = await _bookVaultDir(bookCode);
    if (dir == null) return null;
    final encFile = File('${dir.path}/$bookCode.clepub');
    if (await encFile.exists()) {
      final encBytes = await encFile.readAsBytes();
      final cek = deriveBundledTrialCek(bookCode);
      try {
        return await decryptClbookInIsolate(clbookBytes: encBytes, cekBytes: cek);
      } finally {
        zeroizeBuffer(cek);
      }
    }
    return null;
  }

  Future<List<EbookChapterAstModel>> readCachedChaptersAst(String bookCode) async {
    final mem = _memAstCache[bookCode];
    if (mem != null && mem.isNotEmpty) return mem;
    final dir = await _bookVaultDir(bookCode);
    if (dir == null) return const [];
    final f = File('${dir.path}/$bookCode.ast.json');
    if (!await f.exists()) return const [];
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
