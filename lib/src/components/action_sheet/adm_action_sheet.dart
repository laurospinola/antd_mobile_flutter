import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

/// A single action in an [AdmActionSheet].
class AdmAction {
  final Widget text;
  final Widget? description;
  final bool disabled;
  final bool danger;
  final VoidCallback? onPress;
  final Color? textColor;

  const AdmAction({
    required this.text,
    this.description,
    this.disabled = false,
    this.danger = false,
    this.onPress,
    this.textColor,
  });
}

/// [AdmActionSheet] — equivalent to ant-design-mobile's `<ActionSheet>`.
///
/// ```dart
/// AdmActionSheet.show(
///   context,
///   title: const Text('Options'),
///   actions: [
///     AdmAction(text: const Text('Edit'), onPress: () {}),
///     AdmAction(text: const Text('Delete'), danger: true, onPress: () {}),
///   ],
///   cancelText: const Text('Cancel'),
/// );
/// ```
class AdmActionSheet {
  static Future<void> show(
    BuildContext context, {
    Widget? title,
    Widget? description,
    required List<AdmAction> actions,
    Widget? cancelText,
    bool closeOnMaskClick = true,
    bool showCancelButton = true,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      enableDrag: true,
      builder: (ctx) => _AdmActionSheetWidget(
        title: title,
        description: description,
        actions: actions,
        cancelText: cancelText,
        showCancelButton: showCancelButton,
      ),
    );
  }
}

class _AdmActionSheetWidget extends StatelessWidget {
  final Widget? title;
  final Widget? description;
  final List<AdmAction> actions;
  final Widget? cancelText;
  final bool showCancelButton;

  const _AdmActionSheetWidget({
    this.title,
    this.description,
    required this.actions,
    this.cancelText,
    this.showCancelButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main container
            Container(
              decoration: BoxDecoration(
                color: tokens.colorBackground,
                borderRadius: BorderRadius.circular(tokens.radiusXl),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  if (title != null || description != null) ...[
                    Padding(
                      padding: EdgeInsets.all(tokens.spaceLg),
                      child: Column(
                        children: [
                          if (title != null)
                            DefaultTextStyle(
                              style: TextStyle(
                                fontSize: tokens.fontSizeSm,
                                color: tokens.colorTextSecondary,
                                fontWeight: tokens.fontWeightNormal,
                              ),
                              textAlign: TextAlign.center,
                              child: title!,
                            ),
                          if (description != null) ...[
                            SizedBox(height: tokens.spaceXs),
                            DefaultTextStyle(
                              style: TextStyle(
                                fontSize: tokens.fontSizeSm,
                                color: tokens.colorTextTertiary,
                              ),
                              textAlign: TextAlign.center,
                              child: description!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Divider(height: 0.5, thickness: 0.5, color: tokens.colorBorder),
                  ],
                  // Actions
                  ...List.generate(actions.length, (i) {
                    final action = actions[i];
                    return Column(
                      children: [
                        _ActionItem(action: action, tokens: tokens),
                        if (i < actions.length - 1)
                          Divider(
                              height: 0.5,
                              thickness: 0.5,
                              color: tokens.colorBorder),
                      ],
                    );
                  }),
                ],
              ),
            ),
            // Cancel button
            if (showCancelButton) ...[
              SizedBox(height: tokens.spaceXs),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: tokens.colorBackground,
                  borderRadius: BorderRadius.circular(tokens.radiusXl),
                ),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    height: 56,
                    child: Center(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: tokens.fontSizeLg,
                          color: tokens.colorTextBase,
                          fontWeight: tokens.fontWeightMedium,
                        ),
                        child: cancelText ?? const Text('Cancel'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatefulWidget {
  final AdmAction action;
  final dynamic tokens;

  const _ActionItem({required this.action, required this.tokens});

  @override
  State<_ActionItem> createState() => _ActionItemState();
}

class _ActionItemState extends State<_ActionItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final color = widget.action.textColor ??
        (widget.action.danger
            ? t.colorDanger
            : widget.action.disabled
                ? t.colorTextDisabled
                : t.colorTextBase);

    return GestureDetector(
      onTapDown: widget.action.disabled
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.action.disabled
          ? null
          : (_) => setState(() => _pressed = false),
      onTapCancel: widget.action.disabled
          ? null
          : () => setState(() => _pressed = false),
      onTap: widget.action.disabled
          ? null
          : () {
              Navigator.of(context).pop();
              widget.action.onPress?.call();
            },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: t.animationDurationFast,
        color: _pressed ? t.colorFill : Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: t.spaceMd),
        child: Column(
          children: [
            DefaultTextStyle(
              style: TextStyle(
                fontSize: t.fontSizeLg,
                color: color,
                fontWeight: t.fontWeightNormal,
              ),
              textAlign: TextAlign.center,
              child: widget.action.text,
            ),
            if (widget.action.description != null) ...[
              SizedBox(height: t.spaceXs),
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: t.fontSizeSm,
                  color: t.colorTextTertiary,
                ),
                textAlign: TextAlign.center,
                child: widget.action.description!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
