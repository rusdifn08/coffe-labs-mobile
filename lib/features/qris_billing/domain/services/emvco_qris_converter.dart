import 'dart:convert';
import 'dart:math';

import '../qris_billing_models.dart';

/// Pure-Dart EMVCo TLV Dynamic QRIS Converter & CRC-16/CCITT-FALSE Engine.
/// Identik secara matematis bit-for-bit dengan Rust `src/modules/qris_billing/emvco_qris.rs`
/// sehingga QRIS Dinamis resmi Livin' Merchant `Coffeelabs` dapat digenerate 100% valid
/// dan dapat dipindai oleh GoPay/OVO/DANA/ShopeePay/BCA/Livin' bahkan saat server sedang deploy.
class EmvcoQrisConverter {
  EmvcoQrisConverter._();

  /// String QRIS Statis resmi Livin' Merchant Bank Mandiri (`Coffeelabs`, Acquirer `93600008`,
  /// NMID `ID1023277752888`, Bandung (Kab) `40382`, CRC-16 `2BD1`).
  static const String defaultCoffeelabsStaticQris =
      '00020101021126690021ID.CO.BANKMANDIRI.WWW01189360000802317152890211723171528980303UMI51440014ID.CO.QRIS.WWW0215ID10232777528880303UMI5204481453033605802ID5910Coffeelabs6013Bandung (Kab)61054038262070703A0163042BD1';

  /// Menghitung CRC-16/CCITT-FALSE standar EMVCo QRIS (Polinomial `0x1021`, Init `0xFFFF`).
  static int computeCrc16CcittFalse(List<int> bytes) {
    var crc = 0xFFFF;
    for (final byte in bytes) {
      crc ^= (byte & 0xFF) << 8;
      for (var i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return crc & 0xFFFF;
  }

  /// Memverifikasi checksum 4-digit HEX CRC-16 di akhir string QRIS (`...6304XXXX`).
  static bool verifyQrisCrc16(String rawQris) {
    final trimmed = rawQris.trim();
    if (trimmed.length < 12) return false;
    final splitIdx = trimmed.length - 4;
    final body = trimmed.substring(0, splitIdx);
    final provided = trimmed.substring(splitIdx);
    if (!body.endsWith('6304')) return false;
    final calc = computeCrc16CcittFalse(ascii.encode(body))
        .toRadixString(16)
        .toUpperCase()
        .padLeft(4, '0');
    return calc == provided.toUpperCase();
  }

  /// Byte-safe EMVCo TLV Parser — tidak pernah memakai `.replaceAll` / `.split('5802ID')` naif!
  static List<(String tag, String value)> parseEmvcoTlv(String rawQris) {
    final trimmed = rawQris.trim();
    final tags = <(String, String)>[];
    var cursor = 0;

    while (cursor + 4 <= trimmed.length) {
      final tag = trimmed.substring(cursor, cursor + 2);
      final lenStr = trimmed.substring(cursor + 2, cursor + 4);
      final len = int.tryParse(lenStr);
      if (len == null || len < 0) {
        throw FormatException('Panjang TLV EMVCo tidak valid pada tag $tag');
      }
      final valStart = cursor + 4;
      final valEnd = valStart + len;
      if (valEnd > trimmed.length) {
        throw FormatException('Nilai TLV EMVCo terpotong pada tag $tag');
      }
      final value = trimmed.substring(valStart, valEnd);
      if (tag != '63') {
        tags.add((tag, value));
      }
      cursor = valEnd;
    }

    if (cursor != trimmed.length) {
      throw const FormatException('Sisa byte TLV tidak valid di ekor QRIS.');
    }
    return tags;
  }

  /// Mengonversi QRIS Statis Livin' Merchant -> QRIS Dinamis ber-nominal terkunci (`Tag 01=12`, `Tag 54=amount`, `Tag 63=CRC16`).
  static String buildDynamicQris(
    int amountIdr, {
    String staticQris = defaultCoffeelabsStaticQris,
  }) {
    if (amountIdr <= 0 || amountIdr > 10000000) {
      throw RangeError('Nominal QRIS harus antara Rp 1 hingga Rp 10.000.000.');
    }
    if (!verifyQrisCrc16(staticQris)) {
      throw const FormatException('Checksum CRC-16 QRIS Statis master tidak valid.');
    }

    final parsed = parseEmvcoTlv(staticQris);
    final mutated = <(String, String)>[];
    var hasTag01 = false;

    for (final (tag, val) in parsed) {
      if (tag == '01') {
        mutated.add(('01', '12'));
        hasTag01 = true;
      } else if (tag != '54') {
        mutated.add((tag, val));
      }
    }

    if (!hasTag01) {
      mutated.insert(mutated.isNotEmpty ? 1 : 0, ('01', '12'));
    }

    final amountStr = amountIdr.toString();
    final idx58 = mutated.indexWhere((e) => e.$1 == '58');
    final insertAt = idx58 >= 0 ? idx58 : mutated.length;
    mutated.insert(insertAt, ('54', amountStr));

    final buffer = StringBuffer();
    for (final (tag, val) in mutated) {
      buffer.write(tag);
      buffer.write(val.length.toString().padLeft(2, '0'));
      buffer.write(val);
    }
    buffer.write('6304');

    final body = buffer.toString();
    final crcHex = computeCrc16CcittFalse(ascii.encode(body))
        .toRadixString(16)
        .toUpperCase()
        .padLeft(4, '0');
    final dynamicQris = '$body$crcHex';

    if (!verifyQrisCrc16(dynamicQris)) {
      throw const FormatException('Verifikasi CRC-16 QRIS Dinamis gagal.');
    }
    return dynamicQris;
  }

  /// Membangun invoice QRIS Dinamis yang 100% valid secara kriptografi EMVCo
  /// sebagai fallback tangguh saat backend sedang restart/deploy.
  static DynamicQrisInvoiceModel buildResilientLifetimeInvoice({
    required String planCode,
    int? explicitUniqueCode,
    String? appliedReferralCode,
    int discountIdr = 0,
    int? overrideBaseAmountIdr,
    int? overrideDurationDays,
  }) {
    const knownCodes = {
      'PRO_LIFETIME',
      'BUSINESS_LIFETIME',
      'PRO_MONTHLY',
      'PRO_YEARLY',
      'BUSINESS_MONTHLY',
      'BUSINESS_YEARLY',
    };
    final upper = planCode.trim().toUpperCase();
    final normalized = knownCodes.contains(upper)
        ? upper
        : (upper.contains('BUSINESS') ? 'BUSINESS_LIFETIME' : 'PRO_LIFETIME');
    final isBusiness = normalized.startsWith('BUSINESS');
    final defaultBase = isBusiness ? 249000 : 99000;
    final baseAmount =
        (overrideBaseAmountIdr != null && overrideBaseAmountIdr >= 1000)
            ? overrideBaseAmountIdr
            : defaultBase;
    final durationDays = (overrideDurationDays != null && overrideDurationDays > 0)
        ? overrideDurationDays
        : (normalized.endsWith('_MONTHLY')
            ? 30
            : (normalized.endsWith('_YEARLY') ? 365 : 36500));
    final cleanRef = appliedReferralCode?.trim().toUpperCase();
    final safeDiscount =
        (cleanRef != null && cleanRef.isNotEmpty) ? discountIdr.clamp(0, baseAmount - 1000) : 0;
    final discountedBase = baseAmount - safeDiscount;

    final rng = Random.secure();
    final uniqueCode = (explicitUniqueCode ?? (101 + rng.nextInt(889))).clamp(1, 999);
    final totalPayable = discountedBase + uniqueCode;
    final dynamicPayload = buildDynamicQris(totalPayable);

    final now = DateTime.now();
    final ymd =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final suffixHex = (10000 + rng.nextInt(89999)).toRadixString(16).toUpperCase();
    final invoiceNo = 'CL-LT-$ymd-$suffixHex';

    return DynamicQrisInvoiceModel(
      invoiceId: 'local-$ymd-$suffixHex-$uniqueCode',
      invoiceNumber: invoiceNo,
      planCode: normalized,
      targetTier: isBusiness ? 'business' : 'pro',
      durationDays: durationDays,
      baseAmountIdr: discountedBase,
      uniqueCodeIdr: uniqueCode,
      totalPayableIdr: totalPayable,
      dynamicQrisPayload: dynamicPayload,
      merchantName: 'Coffeelabs',
      acquirerCode: '93600008',
      nmid: 'ID1023277752888',
      status: 'PENDING',
      expiresAt: now.add(const Duration(minutes: 15)),
      isLocalResilientMode: true,
      appliedReferralCode: (cleanRef != null && cleanRef.isNotEmpty) ? cleanRef : null,
      buyerDiscountIdr: safeDiscount,
    );
  }
}
