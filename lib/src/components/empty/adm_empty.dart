import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdmEmpty
// ─────────────────────────────────────────────────────────────────────────────

/// [AdmEmpty] — equivalent to ant-design-mobile's `<Empty>`.
///
/// ```dart
/// AdmEmpty(description: const Text('No data yet'))
/// AdmEmpty(
///   image: Image.asset('assets/empty.png'),
///   description: const Text('Nothing here'),
///   child: AdmButton.primary(child: const Text('Create')),
/// )
/// ```
class AdmEmpty extends StatelessWidget {
  final Widget? image;
  final Widget? description;
  final Widget? child;
  final double imageHeight;

  const AdmEmpty({
    super.key,
    this.image,
    this.description,
    this.child,
    this.imageHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.spaceXxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            image ??
                SizedBox(
                  height: imageHeight,
                  child: CustomPaint(
                    size: Size(imageHeight * 1.2, imageHeight),
                    painter: _EmptyPainter(
                      primaryColor: tokens.colorFill,
                      secondaryColor: tokens.colorBorder,
                    ),
                  ),
                ),
            SizedBox(height: tokens.spaceMd),
            if (description != null)
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: tokens.fontSizeMd,
                  color: tokens.colorTextTertiary,
                ),
                textAlign: TextAlign.center,
                child: description!,
              )
            else
              Text(
                'No data',
                style: TextStyle(
                  fontSize: tokens.fontSizeMd,
                  color: tokens.colorTextTertiary,
                ),
              ),
            if (child != null) ...[
              SizedBox(height: tokens.spaceLg),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _EmptyPainter({required this.primaryColor, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Outer ellipse (ground)
    final ellipsePaint = Paint()..color = primaryColor;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.85), width: w * 0.7, height: h * 0.1),
      ellipsePaint,
    );

    // Box body
    final boxPaint = Paint()..color = secondaryColor;
    final boxRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.2, h * 0.35, w * 0.6, h * 0.45),
      const Radius.circular(6),
    );
    canvas.drawRRect(boxRect, boxPaint);

    // Box fill
    final fillPaint = Paint()..color = primaryColor;
    final fillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.37, w * 0.56, h * 0.41),
      const Radius.circular(5),
    );
    canvas.drawRRect(fillRect, fillPaint);

    // Lid
    final lidPath = Path()
      ..moveTo(w * 0.15, h * 0.37)
      ..lineTo(w * 0.3, h * 0.2)
      ..lineTo(w * 0.7, h * 0.2)
      ..lineTo(w * 0.85, h * 0.37)
      ..close();
    canvas.drawPath(lidPath, boxPaint);

    final lidFillPath = Path()
      ..moveTo(w * 0.18, h * 0.37)
      ..lineTo(w * 0.32, h * 0.22)
      ..lineTo(w * 0.68, h * 0.22)
      ..lineTo(w * 0.82, h * 0.37)
      ..close();
    canvas.drawPath(lidFillPath, fillPaint);
  }

  @override
  bool shouldRepaint(_EmptyPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// AdmResult
// ─────────────────────────────────────────────────────────────────────────────

enum AdmResultStatus { success, error, info, waiting }

/// [AdmResult] — equivalent to ant-design-mobile's `<Result>`.
///
/// ```dart
/// AdmResult(
///   status: AdmResultStatus.success,
///   title: const Text('Payment Successful'),
///   description: const Text('Your order is confirmed.'),
///   child: AdmButton.primary(child: const Text('View Order')),
/// )
/// ```
class AdmResult extends StatelessWidget {
  final AdmResultStatus status;
  final Widget? icon;
  final Widget title;
  final Widget? description;
  final Widget? child;

  const AdmResult({
    super.key,
    this.status = AdmResultStatus.info,
    this.icon,
    required this.title,
    this.description,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    final (iconData, iconColor) = switch (status) {
      AdmResultStatus.success => (Icons.check_circle_outline, tokens.colorSuccess),
      AdmResultStatus.error => (Icons.cancel_outlined, tokens.colorDanger),
      AdmResultStatus.waiting => (Icons.hourglass_empty_outlined, tokens.colorWarning),
      AdmResultStatus.info => (Icons.info_outline, tokens.colorPrimary),
    };

    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.spaceXxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ??
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, size: 40, color: iconColor),
                ),
            SizedBox(height: tokens.spaceLg),
            DefaultTextStyle(
              style: TextStyle(
                fontSize: tokens.fontSizeXl,
                fontWeight: tokens.fontWeightBold,
                color: tokens.colorTextBase,
              ),
              textAlign: TextAlign.center,
              child: title,
            ),
            if (description != null) ...[
              SizedBox(height: tokens.spaceSm),
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: tokens.fontSizeMd,
                  color: tokens.colorTextSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                child: description!,
              ),
            ],
            if (child != null) ...[
              SizedBox(height: tokens.spaceXl),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}
