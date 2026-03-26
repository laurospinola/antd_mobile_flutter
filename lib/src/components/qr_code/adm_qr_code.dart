import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

import '../../theme/adm_theme.dart';

/// Error correction level for QR codes.
///
/// | Level | Recovery |
/// |-------|----------|
/// | low   | ~7%      |
/// | medium| ~15%     |
/// | quartile | ~25%  |
/// | high  | ~30%     |
enum AdmQrCodeErrorCorrectLevel { low, medium, quartile, high }

/// [AdmQrCode] — renders a QR code from a string value.
///
/// Uses the `qr` package to generate the module matrix and paints it
/// via a [CustomPainter].
///
/// ```dart
/// AdmQrCode(
///   value: 'https://example.com',
///   size: 200,
/// )
///
/// AdmQrCode(
///   value: 'Hello World',
///   size: 160,
///   color: Colors.blue,
///   errorCorrectLevel: AdmQrCodeErrorCorrectLevel.high,
/// )
/// ```
class AdmQrCode extends StatelessWidget {
  /// The data to encode in the QR code.
  final String value;

  /// The width and height of the QR code widget.
  final double size;

  /// The color of the dark modules. Defaults to the theme's base text color.
  final Color? color;

  /// The color of the light modules / background. Defaults to transparent.
  final Color? backgroundColor;

  /// Padding around the QR code (quiet zone). Defaults to 0.
  final double padding;

  /// The border radius applied to the widget. Defaults to `tokens.radiusMd`.
  final BorderRadius? borderRadius;

  /// Error correction level. Defaults to [AdmQrCodeErrorCorrectLevel.medium].
  final AdmQrCodeErrorCorrectLevel errorCorrectLevel;

  /// An optional widget centered over the QR code (e.g. a logo or icon).
  /// When provided, use a high [errorCorrectLevel] so the code remains scannable.
  final Widget? embeddedImage;

  /// The size of the embedded image as a fraction of [size]. Defaults to 0.25.
  final double embeddedImageSizeFraction;

  const AdmQrCode({
    super.key,
    required this.value,
    this.size = 160,
    this.color,
    this.backgroundColor,
    this.padding = 0,
    this.borderRadius,
    this.errorCorrectLevel = AdmQrCodeErrorCorrectLevel.medium,
    this.embeddedImage,
    this.embeddedImageSizeFraction = 0.25,
  });

  QrErrorCorrectLevel get _qrErrorLevel => switch (errorCorrectLevel) {
        AdmQrCodeErrorCorrectLevel.low => QrErrorCorrectLevel.low,
        AdmQrCodeErrorCorrectLevel.medium => QrErrorCorrectLevel.medium,
        AdmQrCodeErrorCorrectLevel.quartile => QrErrorCorrectLevel.quartile,
        AdmQrCodeErrorCorrectLevel.high => QrErrorCorrectLevel.high,
      };

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final moduleColor = color ?? tokens.colorTextBase;
    final bgColor = backgroundColor ?? Colors.transparent;
    final radius = borderRadius ?? BorderRadius.circular(tokens.radiusMd);

    final qrCode = QrCode.fromData(
      data: value,
      errorCorrectLevel: _qrErrorLevel,
    );
    final qrImage = QrImage(qrCode);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(padding),
        color: bgColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(size - padding * 2),
              painter: _QrCodePainter(
                qrImage: qrImage,
                moduleColor: moduleColor,
              ),
            ),
            if (embeddedImage != null)
              SizedBox.square(
                dimension: (size - padding * 2) * embeddedImageSizeFraction,
                child: embeddedImage!,
              ),
          ],
        ),
      ),
    );
  }
}

class _QrCodePainter extends CustomPainter {
  final QrImage qrImage;
  final Color moduleColor;

  _QrCodePainter({
    required this.qrImage,
    required this.moduleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final moduleCount = qrImage.moduleCount;
    final moduleSize = size.width / moduleCount;

    final paint = Paint()
      ..color = moduleColor
      ..style = PaintingStyle.fill;

    for (var row = 0; row < moduleCount; row++) {
      for (var col = 0; col < moduleCount; col++) {
        if (qrImage.isDark(row, col)) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * moduleSize,
              row * moduleSize,
              moduleSize,
              moduleSize,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_QrCodePainter oldDelegate) =>
      oldDelegate.moduleColor != moduleColor || oldDelegate.qrImage != qrImage;
}
