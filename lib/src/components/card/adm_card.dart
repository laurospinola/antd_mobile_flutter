import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

/// [AdmCard] — equivalent to ant-design-mobile's `<Card>`.
///
/// ```dart
/// AdmCard(
///   header: const Text('Title'),
///   headerExtra: const Text('More'),
///   footer: const Text('Footer info'),
///   child: const Text('Card body content'),
/// )
/// ```
class AdmCard extends StatelessWidget {
  final Widget? header;
  final Widget? headerExtra;
  final Widget? child;
  final Widget? footer;
  final Widget? footerExtra;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onHeaderClick;
  final VoidCallback? onBodyClick;
  final VoidCallback? onFooterClick;

  const AdmCard({
    super.key,
    this.header,
    this.headerExtra,
    this.child,
    this.footer,
    this.footerExtra,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.onHeaderClick,
    this.onBodyClick,
    this.onFooterClick,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final br = borderRadius ?? BorderRadius.circular(tokens.radiusLg);
    final bgColor = backgroundColor ?? tokens.colorBackground;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: br,
        boxShadow: [
          BoxShadow(
            color: tokens.colorBoxShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            if (header != null) ...[
              _CardSection(
                onTap: onHeaderClick,
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spaceLg,
                  vertical: tokens.spaceSm + 2,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: tokens.fontSizeLg,
                          fontWeight: tokens.fontWeightMedium,
                          color: tokens.colorTextBase,
                        ),
                        child: header!,
                      ),
                    ),
                    if (headerExtra != null)
                      DefaultTextStyle(
                        style: TextStyle(
                          fontSize: tokens.fontSizeSm,
                          color: tokens.colorTextSecondary,
                        ),
                        child: headerExtra!,
                      ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 0.5, color: tokens.colorBorder),
            ],
            // Body
            if (child != null)
              _CardSection(
                onTap: onBodyClick,
                padding: padding ??
                    EdgeInsets.all(tokens.spaceLg),
                child: child!,
              ),
            // Footer
            if (footer != null) ...[
              Divider(height: 1, thickness: 0.5, color: tokens.colorBorder),
              _CardSection(
                onTap: onFooterClick,
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spaceLg,
                  vertical: tokens.spaceSm + 2,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: tokens.fontSizeSm,
                          color: tokens.colorTextSecondary,
                        ),
                        child: footer!,
                      ),
                    ),
                    if (footerExtra != null)
                      DefaultTextStyle(
                        style: TextStyle(
                          fontSize: tokens.fontSizeSm,
                          color: tokens.colorTextSecondary,
                        ),
                        child: footerExtra!,
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const _CardSection({
    required this.child,
    required this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(padding: padding, child: child),
    );
  }
}
