import 'package:flutter/services.dart';

/// Auto-masks Secret ID input into `CLB-XXXX-XXXXXX` and normalizes
/// visually ambiguous characters (`O->0`, `I/L->1`) on the client too.
class CrockfordSecretIdInputFormatter extends TextInputFormatter {
  static const String validAlphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

  static String normalizeCore(String raw) {
    final buffer = StringBuffer();
    var cleaned = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleaned.startsWith('CLB')) {
      cleaned = cleaned.substring(3);
    }
    for (var i = 0; i < cleaned.length && buffer.length < 10; i++) {
      var ch = cleaned[i];
      if (ch == 'O') ch = '0';
      if (ch == 'I' || ch == 'L') ch = '1';
      if (validAlphabet.contains(ch)) {
        buffer.write(ch);
      }
    }
    return buffer.toString();
  }

  static String formatDisplay(String core10) {
    if (core10.isEmpty) return '';
    if (core10.length <= 4) return 'CLB-$core10';
    return 'CLB-${core10.substring(0, 4)}-${core10.substring(4)}';
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final core = normalizeCore(newValue.text);
    final formatted = formatDisplay(core);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
