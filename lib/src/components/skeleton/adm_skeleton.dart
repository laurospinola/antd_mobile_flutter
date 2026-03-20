import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

/// [AdmSkeleton] — equivalent to ant-design-mobile's `<Skeleton>`.
///
/// Shows animated shimmer placeholder blocks while content loads.
///
/// ```dart
/// // Inline usage
/// AdmSkeleton(animated: true)
/// AdmSkeleton.title()
/// AdmSkeleton.paragraph(rows: 3)
///
/// // Wrap real content
/// AdmSkeleton.wrap(
///   loading: isLoading,
///   child: MyRealContent(),
/// )
/// ```
class AdmSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool animated;

  const AdmSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.animated = true,
  });

  /// A skeleton that looks like a title line.
  factory AdmSkeleton.title({bool animated = true}) => AdmSkeleton(
        width: 200,
        height: 20,
        borderRadius: BorderRadius.circular(4),
        animated: animated,
      );

  /// Multiple paragraph lines.
  static Widget paragraph({int rows = 3, bool animated = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        rows,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AdmSkeleton(
            width: i == rows - 1 ? 200 : double.infinity,
            height: 16,
            borderRadius: BorderRadius.circular(4),
            animated: animated,
          ),
        ),
      ),
    );
  }

  /// A circular avatar skeleton.
  factory AdmSkeleton.avatar({double size = 40, bool animated = true}) =>
      AdmSkeleton(
        width: size,
        height: size,
        borderRadius: BorderRadius.circular(size / 2),
        animated: animated,
      );

  /// Wrap loading state around real content.
  static Widget wrap({
    required bool loading,
    required Widget child,
    Widget? placeholder,
    int paragraphRows = 3,
    bool animated = true,
  }) {
    if (!loading) return child;
    return placeholder ??
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              AdmSkeleton.avatar(animated: animated),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    AdmSkeleton(
                        height: 18,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(4),
                        animated: animated),
                    const SizedBox(height: 6),
                    AdmSkeleton(
                        height: 14,
                        width: 140,
                        borderRadius: BorderRadius.circular(4),
                        animated: animated),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 16),
            AdmSkeleton.paragraph(rows: paragraphRows, animated: animated),
          ],
        );
  }

  @override
  State<AdmSkeleton> createState() => _AdmSkeletonState();
}

class _AdmSkeletonState extends State<AdmSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _animation =
        Tween(begin: -1.5, end: 2.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    if (widget.animated) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    return LayoutBuilder(builder: (context, constraints) {
      final w = widget.width == double.infinity
          ? constraints.maxWidth
          : (widget.width ?? constraints.maxWidth);
      final h = widget.height ?? 16.0;

      if (!widget.animated) {
        return Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: tokens.colorFill,
            borderRadius: widget.borderRadius,
          ),
        );
      }

      return AnimatedBuilder(
        animation: _animation,
        builder: (_, __) {
          return Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [
                  (_animation.value - 1.0).clamp(0.0, 1.0),
                  _animation.value.clamp(0.0, 1.0),
                  (_animation.value + 1.0).clamp(0.0, 1.0),
                ],
                colors: [
                  tokens.colorFill,
                  tokens.colorFillTertiary,
                  tokens.colorFill,
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
