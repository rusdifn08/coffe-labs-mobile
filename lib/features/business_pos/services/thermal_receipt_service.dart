import 'package:intl/intl.dart';
import '../../../models/business_pos_models.dart';

class ThermalReceiptData {
  final String storeName;
  final String storeAddress;
  final String orderNumber;
  final DateTime orderTime;
  final String cashierName;
  final String customerName;
  final List<PosCartItem> items;
  final int subtotal;
  final int discount;
  final int tax;
  final int grandTotal;
  final String paymentMethod;
  final String? footerNote;

  const ThermalReceiptData({
    required this.storeName,
    required this.storeAddress,
    required this.orderNumber,
    required this.orderTime,
    required this.cashierName,
    required this.customerName,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.grandTotal,
    required this.paymentMethod,
    this.footerNote,
  });
}

class ThermalReceiptService {
  ThermalReceiptService._();

  static String formatCurrency(int amount) {
    final s = amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return 'Rp $s';
  }

  /// Membuat teks struk standar 58mm (32 karakter per baris)
  static String generate58mmPlainText(ThermalReceiptData data) {
    final timeStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(data.orderTime);
    final buffer = StringBuffer();

    // 1. Header (Centered)
    buffer.writeln(_centerText(data.storeName.toUpperCase(), 32));
    buffer.writeln(_centerText(data.storeAddress, 32));
    buffer.writeln(_centerText('Coffee Labs Artisan Certified', 32));
    buffer.writeln(_divider('=', 32));

    // 2. Metadata Transaksi
    buffer.writeln(_twoColumn('No:', data.orderNumber, 32));
    buffer.writeln(_twoColumn('Waktu:', timeStr, 32));
    buffer.writeln(_twoColumn('Barista:', data.cashierName, 32));
    buffer.writeln(_twoColumn('Pelanggan:', data.customerName, 32));
    buffer.writeln(_divider('-', 32));

    // 3. Line Items
    for (final item in data.items) {
      final name = item.menuItem.name;
      final qtyPrice = '${item.quantity}x ${formatCurrency(item.menuItem.priceCents)}';
      final total = formatCurrency(item.totalPrice);

      buffer.writeln(name);
      buffer.writeln(_twoColumn('  $qtyPrice', total, 32));

      // Modifiers jika ada
      if (item.modifiers.isNotEmpty) {
        for (final entry in item.modifiers.entries) {
          buffer.writeln('   + ${entry.key}: ${entry.value}');
        }
      }
    }

    buffer.writeln(_divider('-', 32));

    // 4. Perhitungan Finansial
    buffer.writeln(_twoColumn('Subtotal:', formatCurrency(data.subtotal), 32));
    if (data.discount > 0) {
      buffer.writeln(_twoColumn('Diskon Barista:', '-${formatCurrency(data.discount)}', 32));
    }
    if (data.tax > 0) {
      buffer.writeln(_twoColumn('PB1 / Pajak (10%):', formatCurrency(data.tax), 32));
    }
    buffer.writeln(_divider('=', 32));
    buffer.writeln(_twoColumn('TOTAL BAYAR:', formatCurrency(data.grandTotal), 32));
    buffer.writeln(_twoColumn('Metode Bayar:', data.paymentMethod, 32));
    buffer.writeln(_divider('=', 32));

    // 5. Footer & Catatan Seduh Barista
    buffer.writeln();
    buffer.writeln(_centerText(data.footerNote ?? 'Terima Kasih Atas Kunjungan Anda', 32));
    buffer.writeln(_centerText('Diseduh dengan Rasio Presisi & Cinta', 32));
    buffer.writeln(_centerText('Powered by Coffee Labs POS', 32));
    buffer.writeln();
    buffer.writeln();

    return buffer.toString();
  }

  static String _centerText(String text, int width) {
    if (text.length >= width) return text.substring(0, width);
    final leftPadding = (width - text.length) ~/ 2;
    final rightPadding = width - text.length - leftPadding;
    return '${' ' * leftPadding}$text${' ' * rightPadding}';
  }

  static String _twoColumn(String left, String right, int width) {
    final availableSpace = width - left.length - right.length;
    if (availableSpace <= 0) {
      return '$left $right';
    }
    return '$left${' ' * availableSpace}$right';
  }

  static String _divider(String char, int width) {
    return char * width;
  }
}
