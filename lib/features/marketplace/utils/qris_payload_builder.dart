/// Generator string QRIS Dinamis standar EMVCo Indonesia (NMID Coffee Labs)
/// dengan checksum CRC-16/CCITT-FALSE (polynomial 0x1021, init 0xFFFF).
class MarketplaceQrisPayloadBuilder {
  static const String nmid = 'ID1026049882714';
  static const String merchantName = 'COFFEE LABS ROASTERY';
  static const String merchantCity = 'JAKARTA';

  static String _tlv(String tag, String value) {
    final len = value.length.toString().padLeft(2, '0');
    return '$tag$len$value';
  }

  static String computeCrc16(String input) {
    var crc = 0xFFFF;
    for (final byte in input.codeUnits) {
      crc ^= (byte & 0xFF) << 8;
      for (var i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }

  static String buildDynamicPayload({
    required String orderCode,
    required int totalIdr,
  }) {
    final safeTotal = (totalIdr < 0 ? 0 : totalIdr).toString();
    final safeRef = orderCode.length > 25 ? orderCode.substring(0, 25) : orderCode;
    final merchantAcct = '${_tlv('00', 'ID.CO.QRIS.WWW')}${_tlv('02', nmid)}';
    final addData = _tlv('01', safeRef);

    final body = [
      _tlv('00', '01'),
      _tlv('01', '12'),
      _tlv('26', merchantAcct),
      _tlv('52', '5499'),
      _tlv('53', '360'),
      _tlv('54', safeTotal),
      _tlv('58', 'ID'),
      _tlv('59', merchantName),
      _tlv('60', merchantCity),
      _tlv('62', addData),
      '6304',
    ].join();

    return '$body${computeCrc16(body)}';
  }
}
