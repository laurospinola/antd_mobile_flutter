import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

/// [AdmGrid] — equivalent to ant-design-mobile's `<Grid>`.
///
/// Creates a uniform grid of items with configurable columns and gaps.
///
/// ```dart
/// AdmGrid(
///   columns: 3,
///   gap: 8,
///   children: List.generate(6, (i) => AdmGridItem(child: Text('$i'))),
/// )
/// ```
class AdmGrid extends StatelessWidget {
  final List<Widget> children;
  final int columns;
  final double? gap;
  final double? horizontalGap;
  final double? verticalGap;

  const AdmGrid({
    super.key,
    required this.children,
    this.columns = 3,
    this.gap,
    this.horizontalGap,
    this.verticalGap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final hGap = horizontalGap ?? gap ?? tokens.spaceXs;
    final vGap = verticalGap ?? gap ?? tokens.spaceXs;

    return LayoutBuilder(builder: (context, constraints) {
      final itemWidth =
          (constraints.maxWidth - hGap * (columns - 1)) / columns;

      return Wrap(
        spacing: hGap,
        runSpacing: vGap,
        children: children.map((child) {
          return SizedBox(width: itemWidth, child: child);
        }).toList(),
      );
    });
  }
}

/// A cell inside [AdmGrid]. Wraps content with centered alignment.
class AdmGridItem extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const AdmGridItem({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    return Padding(
      padding: padding ?? EdgeInsets.all(tokens.spaceXs),
      child: child,
    );
  }
}
