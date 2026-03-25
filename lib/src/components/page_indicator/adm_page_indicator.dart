import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

/// Smooth page indicator with a worm morphing effect.
///
/// The active indicator stretches like a worm as the page transitions:
/// the head advances first, the tail catches up in the second half.
/// This works correctly for both forward and backward swipes.
///
/// ### Basic usage — attach to a [PageView]
/// ```dart
/// final _pageCtrl = PageController();
///
/// PageView(controller: _pageCtrl, children: [...])
///
/// AdmPageIndicator(count: 4, controller: _pageCtrl)
/// ```
///
/// ### Customised
/// ```dart
/// AdmPageIndicator(
///   count: 5,
///   controller: _pageCtrl,
///   dotSize: 10,
///   dotSpacing: 8,
///   activeColor: Colors.white,
///   inactiveColor: Colors.white38,
/// )
/// ```
class AdmPageIndicator extends StatelessWidget {
  /// Total number of pages / dots.
  final int count;

  /// The [PageController] driving the [PageView].
  final PageController controller;

  /// Diameter of each dot and the worm height. Defaults to `8`.
  final double dotSize;

  /// Gap between dots (not centre-to-centre). Defaults to `8`.
  final double dotSpacing;

  /// Colour of the active worm indicator. Defaults to `colorPrimary`.
  final Color? activeColor;

  /// Colour of the inactive dots. Defaults to a 25 % tint of `colorPrimary`.
  final Color? inactiveColor;

  /// Size ratio of inactive dots relative to [dotSize]. Defaults to `0.75`.
  final double inactiveScale;

  const AdmPageIndicator({
    super.key,
    required this.count,
    required this.controller,
    this.dotSize = 8,
    this.dotSpacing = 8,
    this.activeColor,
    this.inactiveColor,
    this.inactiveScale = 0.75,
  }) : assert(count > 0, 'count must be greater than 0');

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final active = activeColor ?? tokens.colorPrimary;
    final inactive =
        inactiveColor ?? tokens.colorPrimary.withValues(alpha: 0.25);

    // Total width = N dots + (N-1) gaps
    final totalWidth = count * dotSize + (count - 1) * dotSpacing;

    return SizedBox(
      width: totalWidth,
      height: dotSize,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final page = controller.hasClients
              ? (controller.page ?? controller.initialPage.toDouble())
              : controller.initialPage.toDouble();

          return CustomPaint(
            painter: _WormPainter(
              page: page.clamp(0.0, (count - 1).toDouble()),
              count: count,
              dotSize: dotSize,
              dotSpacing: dotSpacing,
              activeColor: active,
              inactiveColor: inactive,
              inactiveScale: inactiveScale,
            ),
          );
        },
      ),
    );
  }
}

// ── Painter ────────────────────────────────────────────────────────────────

class _WormPainter extends CustomPainter {
  final double page;
  final int count;
  final double dotSize;
  final double dotSpacing;
  final Color activeColor;
  final Color inactiveColor;
  final double inactiveScale;

  const _WormPainter({
    required this.page,
    required this.count,
    required this.dotSize,
    required this.dotSpacing,
    required this.activeColor,
    required this.inactiveColor,
    required this.inactiveScale,
  });

  /// X centre of dot at [index].
  double _cx(int index) => index * (dotSize + dotSpacing) + dotSize / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;

    // ── Inactive dots ────────────────────────────────────────────────────────
    final inactiveRadius = (dotSize * inactiveScale) / 2;
    final inactivePaint = Paint()..color = inactiveColor;

    for (var i = 0; i < count; i++) {
      canvas.drawCircle(Offset(_cx(i), cy), inactiveRadius, inactivePaint);
    }

    // ── Worm indicator ────────────────────────────────────────────────────────
    //
    // progress ∈ [0, 1) is the fractional part of page.
    //
    // Head advances using easeInOut over the full [0→1] range.
    // Tail is delayed: it only starts moving after the head is half-way,
    // producing the characteristic stretch-then-contract worm shape.
    // The algorithm is symmetric, so backward swipes look correct too.
    //
    final from = page.floor();
    final progress = page - from;
    final to = (from + 1).clamp(0, count - 1);

    final headT =
        Curves.easeInOut.transform(progress.clamp(0.0, 1.0));
    final tailT =
        Curves.easeInOut.transform(((progress - 0.5) * 2).clamp(0.0, 1.0));

    final fromCx = _cx(from);
    final toCx = _cx(to);

    final headCx = fromCx + headT * (toCx - fromCx);
    final tailCx = fromCx + tailT * (toCx - fromCx);

    final wormLeft = tailCx - dotSize / 2;
    final wormRight = headCx + dotSize / 2;
    final radius = Radius.circular(dotSize / 2);

    canvas.drawRRect(
      RRect.fromLTRBR(
        wormLeft,
        cy - dotSize / 2,
        wormRight,
        cy + dotSize / 2,
        radius,
      ),
      Paint()..color = activeColor,
    );
  }

  @override
  bool shouldRepaint(_WormPainter old) =>
      old.page != page ||
      old.count != count ||
      old.dotSize != dotSize ||
      old.dotSpacing != dotSpacing ||
      old.activeColor != activeColor ||
      old.inactiveColor != inactiveColor ||
      old.inactiveScale != inactiveScale;
}
