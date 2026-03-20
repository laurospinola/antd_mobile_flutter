import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

/// [AdmBadge] — equivalent to ant-design-mobile's `<Badge>`.
///
/// Wraps a child widget and overlays a badge in the top-right corner.
///
/// ```dart
/// AdmBadge(
///   content: AdmBadge.dot,           // red dot
///   child: Icon(Icons.notifications),
/// )
///
/// AdmBadge(
///   content: '99+',
///   child: Icon(Icons.shopping_cart),
/// )
/// ```
class AdmBadge extends StatelessWidget {
  /// Use [AdmBadge.dot] as content to show a small red circle.
  static const Widget dot = _DotBadge();

  final Widget? content;
  final Widget child;
  final Color? color;

  const AdmBadge({
    super.key,
    this.content,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (content == null) return child;

    final tokens = AdmTheme.tokensOf(context);
    final badgeColor = color ?? tokens.colorDanger;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -6,
          top: -6,
          child: content is _DotBadge
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: tokens.colorTextWhite,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    child: content!,
                  ),
                ),
        ),
      ],
    );
  }
}

class _DotBadge extends Widget {
  const _DotBadge();

  @override
  Element createElement() => throw UnimplementedError(
      '_DotBadge is a sentinel value, not a real widget');
}
