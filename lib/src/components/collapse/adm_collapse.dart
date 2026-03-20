import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdmNoticeBar
// ─────────────────────────────────────────────────────────────────────────────

/// [AdmNoticeBar] — equivalent to ant-design-mobile's `<NoticeBar>`.
///
/// ```dart
/// AdmNoticeBar(content: const Text('System maintenance tonight at 10 PM.'))
/// AdmNoticeBar(
///   icon: Icon(Icons.info_outline),
///   content: const Text('Important notice'),
///   closeable: true,
/// )
/// ```
class AdmNoticeBar extends StatefulWidget {
  final Widget content;
  final Widget? icon;
  final Widget? extra;
  final bool closeable;
  final bool marquee;
  final Color? color;
  final Color? background;
  final VoidCallback? onClose;

  const AdmNoticeBar({
    super.key,
    required this.content,
    this.icon,
    this.extra,
    this.closeable = false,
    this.marquee = false,
    this.color,
    this.background,
    this.onClose,
  });

  @override
  State<AdmNoticeBar> createState() => _AdmNoticeBarState();
}

class _AdmNoticeBarState extends State<AdmNoticeBar> {
  bool _closed = false;

  @override
  Widget build(BuildContext context) {
    if (_closed) return const SizedBox.shrink();

    final tokens = AdmTheme.tokensOf(context);
    final textColor = widget.color ?? tokens.colorWarning;
    final bgColor =
        widget.background ?? tokens.colorWarning.withOpacity(0.08);

    return Container(
      color: bgColor,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spaceLg,
        vertical: tokens.spaceSm + 2,
      ),
      child: Row(
        children: [
          if (widget.icon != null) ...[
            IconTheme(
              data: IconThemeData(color: textColor, size: 16),
              child: widget.icon!,
            ),
            SizedBox(width: tokens.spaceSm),
          ] else ...[
            Icon(Icons.volume_up_outlined, size: 16, color: textColor),
            SizedBox(width: tokens.spaceSm),
          ],
          Expanded(
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: tokens.fontSizeSm,
                color: textColor,
              ),
              maxLines: widget.marquee ? 1 : null,
              overflow: widget.marquee
                  ? TextOverflow.ellipsis
                  : TextOverflow.visible,
              child: widget.content,
            ),
          ),
          if (widget.extra != null) ...[
            SizedBox(width: tokens.spaceSm),
            widget.extra!,
          ],
          if (widget.closeable) ...[
            SizedBox(width: tokens.spaceSm),
            GestureDetector(
              onTap: () {
                setState(() => _closed = true);
                widget.onClose?.call();
              },
              child: Icon(Icons.close, size: 14, color: textColor),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AdmCollapse
// ─────────────────────────────────────────────────────────────────────────────

class AdmCollapsePanel {
  final String key;
  final Widget title;
  final Widget content;
  final Widget? extra;
  final bool disabled;
  final bool arrowPlacementRight;

  const AdmCollapsePanel({
    required this.key,
    required this.title,
    required this.content,
    this.extra,
    this.disabled = false,
    this.arrowPlacementRight = true,
  });
}

/// [AdmCollapse] — equivalent to ant-design-mobile's `<Collapse>`.
///
/// ```dart
/// AdmCollapse(
///   panels: [
///     AdmCollapsePanel(
///       key: 'faq1',
///       title: const Text('What is Ant Design?'),
///       content: const Text('An enterprise-class UI design language.'),
///     ),
///   ],
/// )
/// ```
class AdmCollapse extends StatefulWidget {
  final List<AdmCollapsePanel> panels;
  final List<String>? defaultActiveKeys;
  final bool accordion;
  final ValueChanged<List<String>>? onChange;

  const AdmCollapse({
    super.key,
    required this.panels,
    this.defaultActiveKeys,
    this.accordion = false,
    this.onChange,
  });

  @override
  State<AdmCollapse> createState() => _AdmCollapseState();
}

class _AdmCollapseState extends State<AdmCollapse> {
  late Set<String> _activeKeys;

  @override
  void initState() {
    super.initState();
    _activeKeys = Set.from(widget.defaultActiveKeys ?? []);
  }

  void _toggle(String key) {
    setState(() {
      if (widget.accordion) {
        _activeKeys = _activeKeys.contains(key) ? {} : {key};
      } else {
        if (_activeKeys.contains(key)) {
          _activeKeys.remove(key);
        } else {
          _activeKeys.add(key);
        }
      }
    });
    widget.onChange?.call(_activeKeys.toList());
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.panels.length, (i) {
        final panel = widget.panels[i];
        final isOpen = _activeKeys.contains(panel.key);
        final isFirst = i == 0;
        final isLast = i == widget.panels.length - 1;

        return Container(
          decoration: BoxDecoration(
            color: tokens.colorBackground,
            border: Border(
              top: isFirst
                  ? BorderSide(color: tokens.colorBorder, width: 0.5)
                  : BorderSide.none,
              bottom: BorderSide(color: tokens.colorBorder, width: 0.5),
            ),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: panel.disabled ? null : () => _toggle(panel.key),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: panel.disabled
                      ? tokens.colorFillSecondary
                      : Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spaceLg,
                    vertical: tokens.spaceMd,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DefaultTextStyle(
                          style: TextStyle(
                            fontSize: tokens.fontSizeMd,
                            color: panel.disabled
                                ? tokens.colorTextDisabled
                                : tokens.colorTextBase,
                            fontWeight: tokens.fontWeightMedium,
                          ),
                          child: panel.title,
                        ),
                      ),
                      if (panel.extra != null) ...[
                        SizedBox(width: tokens.spaceSm),
                        panel.extra!,
                      ],
                      SizedBox(width: tokens.spaceXs),
                      AnimatedRotation(
                        turns: isOpen ? 0.5 : 0.0,
                        duration: tokens.animationDurationMid,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: panel.disabled
                              ? tokens.colorTextDisabled
                              : tokens.colorTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: tokens.animationDurationMid,
                curve: tokens.animationCurveDefault,
                child: isOpen
                    ? Container(
                        width: double.infinity,
                        color: tokens.colorFillSecondary,
                        padding: EdgeInsets.fromLTRB(
                          tokens.spaceLg,
                          tokens.spaceSm,
                          tokens.spaceLg,
                          tokens.spaceMd,
                        ),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            fontSize: tokens.fontSizeMd,
                            color: tokens.colorTextSecondary,
                            height: 1.5,
                          ),
                          child: panel.content,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      }),
    );
  }
}
