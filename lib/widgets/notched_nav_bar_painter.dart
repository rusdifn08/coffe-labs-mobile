import 'dart:math' as math;
import 'package:flutter/material.dart';

/// CustomPainter untuk menggambar navbar profesional dengan notch cradle melengkung
/// sempurna (tangential fillets) yang membungkus tombol floating circular Brew
/// secara simetris, presisi, bersih, dan mewah sesuai desain referensi modern.
class NotchedNavBarPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final double buttonCenterY;
  final double buttonRadius;
  final double gap;
  final double filletRadius;
  final double cornerRadius;
  final double? scoopWidth;
  final double? scoopDepth;

  const NotchedNavBarPainter({
    required this.backgroundColor,
    this.borderColor = const Color(0xFFEDE5DE),
    this.buttonCenterY = 3.0,
    this.buttonRadius = 27.0,
    this.gap = 5.0,
    this.filletRadius = 14.0,
    this.cornerRadius = 20.0,
    this.scoopWidth,
    this.scoopDepth,
  });

  Path createPath(Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final rCradle = buttonRadius + gap; // 32.0
    final rf = filletRadius; // 14.0
    final rSum = rCradle + rf; // 46.0
    final dy = rf - buttonCenterY; // 11.0
    final dxSquared = math.max(0.0, rSum * rSum - dy * dy);
    final dx = math.sqrt(dxSquared);

    final contactLeftX = cx - (rCradle * dx / rSum);
    final contactLeftY = buttonCenterY + (rCradle * dy / rSum);
    final contactRightX = cx + (rCradle * dx / rSum);
    final contactRightY = contactLeftY;

    final startNotchX = cx - dx;
    final endNotchX = cx + dx;

    final path = Path();
    // 1. Sudut kiri atas membulat
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    // 2. Garis horizontal datar sisi kiri
    path.lineTo(startNotchX, 0);

    // 3. Fillet lengkung kiri masuk ke notch secara tangensial (menukik ke bawah secara halus)
    path.arcToPoint(
      Offset(contactLeftX, contactLeftY),
      radius: Radius.circular(rf),
      clockwise: true,
    );

    // 4. Cradle notch melingkar sempurna mengitari tombol floating tengah
    path.arcToPoint(
      Offset(contactRightX, contactRightY),
      radius: Radius.circular(rCradle),
      clockwise: false,
    );

    // 5. Fillet lengkung kanan keluar notch kembali ke horizontal
    path.arcToPoint(
      Offset(endNotchX, 0),
      radius: Radius.circular(rf),
      clockwise: true,
    );

    // 6. Garis horizontal datar sisi kanan
    path.lineTo(w - cornerRadius, 0);
    path.quadraticBezierTo(w, 0, w, cornerRadius);

    // 7. Menutup path ke sudut kanan bawah dan kiri bawah
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    return path;
  }

  Path createTopBorderPath(Size size) {
    final w = size.width;
    final cx = w / 2;

    final rCradle = buttonRadius + gap;
    final rf = filletRadius;
    final rSum = rCradle + rf;
    final dy = rf - buttonCenterY;
    final dxSquared = math.max(0.0, rSum * rSum - dy * dy);
    final dx = math.sqrt(dxSquared);

    final contactLeftX = cx - (rCradle * dx / rSum);
    final contactLeftY = buttonCenterY + (rCradle * dy / rSum);
    final contactRightX = cx + (rCradle * dx / rSum);
    final contactRightY = contactLeftY;

    final startNotchX = cx - dx;
    final endNotchX = cx + dx;

    final path = Path();
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    path.lineTo(startNotchX, 0);

    path.arcToPoint(
      Offset(contactLeftX, contactLeftY),
      radius: Radius.circular(rf),
      clockwise: true,
    );

    path.arcToPoint(
      Offset(contactRightX, contactRightY),
      radius: Radius.circular(rCradle),
      clockwise: false,
    );

    path.arcToPoint(
      Offset(endNotchX, 0),
      radius: Radius.circular(rf),
      clockwise: true,
    );

    path.lineTo(w - cornerRadius, 0);
    path.quadraticBezierTo(w, 0, w, cornerRadius);

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = createPath(size);

    // 1. Ambient Elevation Shadow halus & mewah
    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.06),
      14.0,
      false,
    );

    // 2. Background Fill putih bersih
    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 3. Hairline border atas yang halus, rapi, dan elegan
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(createTopBorderPath(size), borderPaint);
  }

  @override
  bool shouldRepaint(covariant NotchedNavBarPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.buttonCenterY != buttonCenterY ||
        oldDelegate.buttonRadius != buttonRadius ||
        oldDelegate.gap != gap ||
        oldDelegate.filletRadius != filletRadius ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}
