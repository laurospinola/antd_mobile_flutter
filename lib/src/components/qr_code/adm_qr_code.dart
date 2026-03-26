import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
/// Wraps `qr_flutter`'s [QrImageView] with theme integration and an
/// optional embedded widget overlay.
///
/// ```dart
/// AdmQrCode(
///   value: 'https://example.com',
///   size: 200,
/// )
///
/// AdmQrCode(
///   value: 'https://example.com',
///   size: 200,
///   errorCorrectLevel: AdmQrCodeErrorCorrectLevel.high,
///   embeddedImage: FlutterLogo(size: 40),
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

  /// Padding around the QR code (quiet zone). Defaults to `EdgeInsets.all(10)`.
  final EdgeInsets padding;

  /// The border radius applied to the widget. Defaults to `tokens.radiusMd`.
  final BorderRadius? borderRadius;

  /// Error correction level. Defaults to [AdmQrCodeErrorCorrectLevel.medium].
  final AdmQrCodeErrorCorrectLevel errorCorrectLevel;

  /// An optional widget centered over the QR code (e.g. a logo or icon).
  /// When provided, use a high [errorCorrectLevel] so the code remains scannable.
  final Widget? embeddedImage;

  /// The size of the embedded image as a fraction of [size]. Defaults to 0.25.
  final double embeddedImageSizeFraction;

  /// The shape of the data modules. Defaults to [QrDataModuleShape.square].
  final QrDataModuleShape dataModuleShape;

  /// The shape of the eye (finder pattern). Defaults to [QrEyeShape.square].
  final QrEyeShape eyeShape;

  const AdmQrCode({
    super.key,
    required this.value,
    this.size = 160,
    this.color,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(10),
    this.borderRadius,
    this.errorCorrectLevel = AdmQrCodeErrorCorrectLevel.medium,
    this.embeddedImage,
    this.embeddedImageSizeFraction = 0.25,
    this.dataModuleShape = QrDataModuleShape.square,
    this.eyeShape = QrEyeShape.square,
  });

  int get _qrErrorLevel => switch (errorCorrectLevel) {
        AdmQrCodeErrorCorrectLevel.low => QrErrorCorrectLevel.L,
        AdmQrCodeErrorCorrectLevel.medium => QrErrorCorrectLevel.M,
        AdmQrCodeErrorCorrectLevel.quartile => QrErrorCorrectLevel.Q,
        AdmQrCodeErrorCorrectLevel.high => QrErrorCorrectLevel.H,
      };

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final moduleColor = color ?? tokens.colorTextBase;
    final bgColor = backgroundColor ?? Colors.transparent;
    final radius = borderRadius ?? BorderRadius.circular(tokens.radiusMd);

    final qrWidget = QrImageView(
      data: value,
      size: size,
      padding: padding,
      backgroundColor: bgColor,
      errorCorrectionLevel: _qrErrorLevel,
      eyeStyle: QrEyeStyle(eyeShape: eyeShape, color: moduleColor),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: dataModuleShape,
        color: moduleColor,
      ),
    );

    return ClipRRect(
      borderRadius: radius,
      child: embeddedImage == null
          ? qrWidget
          : Stack(
              alignment: Alignment.center,
              children: [
                qrWidget,
                SizedBox.square(
                  dimension: size * embeddedImageSizeFraction,
                  child: embeddedImage!,
                ),
              ],
            ),
    );
  }
}
