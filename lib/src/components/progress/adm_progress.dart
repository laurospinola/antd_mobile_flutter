import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

enum AdmProgressStatus { active, success, error }

/// [AdmProgress] — equivalent to ant-design-mobile's `<ProgressBar>` / `<ProgressCircle>`.
///
/// ```dart
/// AdmProgress(percent: 0.6)
/// AdmProgress(percent: 1.0, status: AdmProgressStatus.success)
/// AdmProgress.circle(percent: 0.75, size: 80)
/// ```
class AdmProgress extends StatelessWidget {
  final double percent; // 0.0 – 1.0
  final AdmProgressStatus status;
  final bool showInfo;
  final double strokeWidth;
  final Color? color;
  final Color? trailColor;
  final Widget? info;

  const AdmProgress({
    super.key,
    required this.percent,
    this.status = AdmProgressStatus.active,
    this.showInfo = true,
    this.strokeWidth = 8,
    this.color,
    this.trailColor,
    this.info,
  });

  factory AdmProgress.circle({
    Key? key,
    required double percent,
    double size = 60,
    AdmProgressStatus status = AdmProgressStatus.active,
    double strokeWidth = 6,
    Color? color,
    Color? trailColor,
    Widget? info,
  }) =>
      _AdmProgressCircle(
        key: key,
        percent: percent,
        size: size,
        status: status,
        strokeWidth: strokeWidth,
        color: color,
        trailColor: trailColor,
        info: info,
      );

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final barColor = color ??
        (status == AdmProgressStatus.success
            ? tokens.colorSuccess
            : status == AdmProgressStatus.error
                ? tokens.colorDanger
                : tokens.colorPrimary);
    final trail = trailColor ?? tokens.colorFill;
    final clampedPercent = percent.clamp(0.0, 1.0);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(strokeWidth / 2),
            child: LinearProgressIndicator(
              value: clampedPercent,
              minHeight: strokeWidth,
              backgroundColor: trail,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
        ),
        if (showInfo) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: info ??
                (status == AdmProgressStatus.success
                    ? Icon(Icons.check_circle,
                        size: 16, color: tokens.colorSuccess)
                    : status == AdmProgressStatus.error
                        ? Icon(Icons.cancel,
                            size: 16, color: tokens.colorDanger)
                        : Text(
                            '${(clampedPercent * 100).round()}%',
                            style: TextStyle(
                              fontSize: tokens.fontSizeSm,
                              color: tokens.colorTextSecondary,
                            ),
                          )),
          ),
        ],
      ],
    );
  }
}

class _AdmProgressCircle extends AdmProgress {
  final double size;

  const _AdmProgressCircle({
    super.key,
    required super.percent,
    required this.size,
    super.status,
    super.strokeWidth,
    super.color,
    super.trailColor,
    super.info,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final barColor = color ??
        (status == AdmProgressStatus.success
            ? tokens.colorSuccess
            : status == AdmProgressStatus.error
                ? tokens.colorDanger
                : tokens.colorPrimary);
    final trail = trailColor ?? tokens.colorFill;
    final clampedPercent = percent.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _CirclePainter(
              percent: clampedPercent,
              color: barColor,
              trailColor: trail,
              strokeWidth: strokeWidth,
            ),
          ),
          info ??
              Text(
                '${(clampedPercent * 100).round()}%',
                style: TextStyle(
                  fontSize: size * 0.18,
                  color: tokens.colorTextBase,
                  fontWeight: FontWeight.w600,
                ),
              ),
        ],
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double percent;
  final Color color;
  final Color trailColor;
  final double strokeWidth;

  _CirclePainter({
    required this.percent,
    required this.color,
    required this.trailColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Trail
    canvas.drawArc(
      rect,
      0,
      2 * 3.14159,
      false,
      Paint()
        ..color = trailColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress
    canvas.drawArc(
      rect,
      -3.14159 / 2,
      2 * 3.14159 * percent,
      false,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CirclePainter old) =>
      old.percent != percent || old.color != color;
}
