import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

/// [AdmDivider] — equivalent to ant-design-mobile's `<Divider>`.
///
/// ```dart
/// AdmDivider()
/// AdmDivider(direction: Axis.vertical)
/// AdmDivider(child: const Text('OR'))
/// ```
class AdmDivider extends StatelessWidget {
  final Axis direction;
  final Widget? child;
  final EdgeInsets? padding;
  final Color? color;

  const AdmDivider({
    super.key,
    this.direction = Axis.horizontal,
    this.child,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final lineColor = color ?? tokens.colorBorder;

    if (direction == Axis.vertical) {
      return Container(
        width: 0.5,
        height: double.infinity,
        color: lineColor,
        margin: padding ??
            EdgeInsets.symmetric(horizontal: tokens.spaceSm),
      );
    }

    if (child != null) {
      return Padding(
        padding: padding ??
            EdgeInsets.symmetric(vertical: tokens.spaceSm),
        child: Row(
          children: [
            Expanded(child: Divider(color: lineColor, thickness: 0.5)),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: tokens.spaceSm),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: tokens.fontSizeSm,
                  color: tokens.colorTextTertiary,
                ),
                child: child!,
              ),
            ),
            Expanded(child: Divider(color: lineColor, thickness: 0.5)),
          ],
        ),
      );
    }

    return Padding(
      padding: padding ??
          EdgeInsets.symmetric(vertical: tokens.spaceSm),
      child: Divider(color: lineColor, thickness: 0.5, height: 0.5),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// [AdmSpace] — equivalent to ant-design-mobile's `<Space>`.
///
/// Distributes children with uniform gaps.
///
/// ```dart
/// AdmSpace(
///   children: [
///     AdmButton.primary(child: const Text('A')),
///     AdmButton(child: const Text('B')),
///   ],
/// )
/// ```
class AdmSpace extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;
  final double? gap;
  final WrapAlignment alignment;
  final WrapAlignment runAlignment;
  final bool wrap;
  final bool block;

  const AdmSpace({
    super.key,
    this.children = const [],
    this.direction = Axis.horizontal,
    this.gap,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
    this.wrap = false,
    this.block = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final spacing = gap ?? tokens.spaceSm;

    if (wrap) {
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        alignment: alignment,
        runAlignment: runAlignment,
        direction: direction,
        children: children,
      );
    }

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(
          direction == Axis.horizontal
              ? SizedBox(width: spacing)
              : SizedBox(height: spacing),
        );
      }
    }

    if (direction == Axis.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
        children: spacedChildren,
      );
    }

    return Row(
      mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
      children: spacedChildren,
    );
  }
}
