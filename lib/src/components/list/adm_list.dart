import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

/// [AdmList] — equivalent to ant-design-mobile's `<List>`.
///
/// ```dart
/// AdmList(
///   header: const Text('Settings'),
///   children: [
///     AdmListItem(
///       prefix: Icon(Icons.person_outline),
///       title: const Text('Profile'),
///       extra: const Text('Edit'),
///       arrow: true,
///       onTap: () {},
///     ),
///   ],
/// )
/// ```
class AdmList extends StatelessWidget {
  final Widget? header;
  final Widget? footer;
  final List<Widget> children;
  final EdgeInsets? padding;

  /// Background color of the list body. Defaults to [Colors.transparent].
  final Color? backgroundColor;

  const AdmList({
    super.key,
    this.header,
    this.footer,
    this.children = const [],
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null)
          Padding(
            padding: EdgeInsets.only(
              left: tokens.listItemPaddingHorizontal,
              right: tokens.listItemPaddingHorizontal,
              top: tokens.spaceSm,
              bottom: tokens.spaceXs,
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: tokens.fontSizeSm,
                color: tokens.colorTextSecondary,
              ),
              child: header!,
            ),
          ),
        Container(
          color: backgroundColor ?? Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(children.length, (i) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  children[i],
                  if (i < children.length - 1)
                    Padding(
                      padding: EdgeInsets.only(
                          left: tokens.listItemPaddingHorizontal),
                      child: Divider(
                          height: 0.5,
                          thickness: 0.5,
                          color: tokens.listBorderColor),
                    ),
                ],
              );
            }),
          ),
        ),
        if (footer != null)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.listItemPaddingHorizontal,
              vertical: tokens.spaceXs,
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: tokens.fontSizeSm,
                color: tokens.colorTextTertiary,
              ),
              child: footer!,
            ),
          ),
      ],
    );
  }
}

/// A single row inside [AdmList].
class AdmListItem extends StatefulWidget {
  final Widget? prefix;
  final Widget title;
  final Widget? description;
  final Widget? extra;
  final bool arrow;
  final bool disabled;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Widget? children; // expandable inner content

  /// Idle background color. Defaults to [Colors.transparent]. The pressed and
  /// disabled overlays still take precedence over this color.
  final Color? backgroundColor;

  const AdmListItem({
    super.key,
    this.prefix,
    required this.title,
    this.description,
    this.extra,
    this.arrow = false,
    this.disabled = false,
    this.onTap,
    this.padding,
    this.children,
    this.backgroundColor,
  });

  @override
  State<AdmListItem> createState() => _AdmListItemState();
}

class _AdmListItemState extends State<AdmListItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final isInteractive = widget.onTap != null && !widget.disabled;

    return GestureDetector(
      onTapDown: isInteractive ? (_) => setState(() => _pressed = true) : null,
      onTapUp: isInteractive ? (_) => setState(() => _pressed = false) : null,
      onTapCancel:
          isInteractive ? () => setState(() => _pressed = false) : null,
      onTap: isInteractive ? widget.onTap : null,
      child: AnimatedContainer(
        duration: tokens.animationDurationFast,
        color: _pressed
            ? tokens.colorFill
            : (widget.disabled
                ? tokens.colorFillSecondary
                : (widget.backgroundColor ?? Colors.transparent)),
        constraints:
            BoxConstraints(minHeight: tokens.listItemMinHeight),
        padding: widget.padding ??
            EdgeInsets.symmetric(
              vertical: tokens.listItemPaddingVertical,
              horizontal: tokens.listItemPaddingHorizontal,
            ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Prefix
            if (widget.prefix != null) ...[
              IconTheme(
                data: IconThemeData(
                  color: widget.disabled
                      ? tokens.colorTextDisabled
                      : tokens.colorTextBase,
                  size: 20,
                ),
                child: widget.prefix!,
              ),
              SizedBox(width: tokens.spaceMd),
            ],
            // Title + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: tokens.fontSizeMd,
                      color: widget.disabled
                          ? tokens.colorTextDisabled
                          : tokens.colorTextBase,
                      fontWeight: tokens.fontWeightNormal,
                    ),
                    child: widget.title,
                  ),
                  if (widget.description != null) ...[
                    const SizedBox(height: 2),
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: tokens.fontSizeSm,
                        color: tokens.colorTextSecondary,
                      ),
                      child: widget.description!,
                    ),
                  ],
                ],
              ),
            ),
            // Extra content
            if (widget.extra != null) ...[
              SizedBox(width: tokens.spaceSm),
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: tokens.fontSizeMd,
                  color: tokens.colorTextSecondary,
                ),
                child: widget.extra!,
              ),
            ],
            // Arrow
            if (widget.arrow) ...[
              SizedBox(width: tokens.spaceXs),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: tokens.colorTextTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
