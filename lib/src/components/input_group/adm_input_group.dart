import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/adm_theme.dart';
import '../button/adm_button.dart';

/// Alignment of an [AdmInputGroupAddon] within an [AdmInputGroup].
///
/// Only inline (leading / trailing) addons are supported — the Flutter port of
/// shadcn's `inline-start` / `inline-end`.
enum AdmAddonAlign { inlineStart, inlineEnd }

/// [AdmInputGroup] — a bordered, focus-aware container that groups a borderless
/// [AdmInputGroupInput] with inline addons ([AdmInputGroupAddon],
/// [AdmInputGroupButton], plain text or icons).
///
/// It is the Flutter equivalent of shadcn's `InputGroup`: the group draws the
/// border, background, corner radius and focus ring, while the children inside
/// stay borderless. Wrap the input in an [Expanded] so it fills the remaining
/// space:
///
/// ```dart
/// AdmInputGroup(
///   borderRadius: 16,
///   children: [
///     const Expanded(
///       child: AdmInputGroupInput(placeholder: 'Enter search query'),
///     ),
///     AdmInputGroupAddon(
///       align: AdmAddonAlign.inlineEnd,
///       child: AdmInputGroupButton(
///         'Search In...',
///         icon: AdmIcons.chevron_down,
///         onPressed: () {},
///       ),
///     ),
///   ],
/// )
/// ```
class AdmInputGroup extends StatefulWidget {
  /// The row of children — typically an [Expanded] [AdmInputGroupInput] plus one
  /// or more [AdmInputGroupAddon]s.
  final List<Widget> children;

  /// Corner radius. Defaults to `tokens.radiusMd`.
  final double? borderRadius;

  /// Background fill. Defaults to `tokens.colorBackground`.
  final Color? backgroundColor;

  /// When `true` the group is dimmed and ignores pointer input.
  final bool disabled;

  const AdmInputGroup({
    super.key,
    required this.children,
    this.borderRadius,
    this.backgroundColor,
    this.disabled = false,
  });

  @override
  State<AdmInputGroup> createState() => _AdmInputGroupState();
}

class _AdmInputGroupState extends State<AdmInputGroup> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final borderColor = _hasFocus ? tokens.colorPrimary : tokens.colorBorder;

    Widget row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widget.children,
    );
    if (widget.disabled) {
      row = AbsorbPointer(child: row);
    }

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (hasFocus) => setState(() => _hasFocus = hasFocus),
      child: AnimatedContainer(
        duration: tokens.animationDurationFast,
        decoration: BoxDecoration(
          color: widget.disabled
              ? tokens.colorFill
              : (widget.backgroundColor ?? tokens.colorBackground),
          border: Border.all(color: borderColor, width: _hasFocus ? 1.5 : 1),
          borderRadius:
              BorderRadius.circular(widget.borderRadius ?? tokens.radiusMd),
        ),
        child: row,
      ),
    );
  }
}

/// [AdmInputGroupInput] — a borderless text field designed to live inside an
/// [AdmInputGroup]. It is a lean, frame-less counterpart to [AdmInput]: no
/// border, label, error row or form integration. Reach for [AdmInput] when you
/// need validation or [AdmForm] registration.
class AdmInputGroupInput extends StatefulWidget {
  final String? placeholder;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final TextAlign textAlign;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmit;
  final bool readOnly;
  final bool disabled;
  final bool obscureText;
  final int? maxLength;
  final int maxLines;
  final bool autofocus;

  const AdmInputGroupInput({
    super.key,
    this.placeholder,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.textAlign = TextAlign.start,
    this.onChanged,
    this.onSubmit,
    this.readOnly = false,
    this.disabled = false,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1,
    this.autofocus = false,
  });

  @override
  State<AdmInputGroupInput> createState() => _AdmInputGroupInputState();
}

class _AdmInputGroupInputState extends State<AdmInputGroupInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: !widget.disabled,
      readOnly: widget.readOnly,
      obscureText: widget.obscureText,
      maxLength: widget.maxLength,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      textInputAction: widget.textInputAction,
      textAlign: widget.textAlign,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmit,
      style: TextStyle(
        fontSize: tokens.fontSizeMd,
        color: widget.disabled ? tokens.colorTextDisabled : tokens.colorTextBase,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: false,
        counterText: '',
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: widget.placeholder,
        hintStyle: TextStyle(
          color: tokens.colorTextPlaceholder,
          fontSize: tokens.fontSizeMd,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.spaceMd,
          vertical: tokens.spaceSm,
        ),
      ),
    );
  }
}

/// [AdmInputGroupAddon] — an alignment + muted-styling wrapper for non-input
/// content (text, icons, an [AdmInputGroupButton]) inside an [AdmInputGroup].
class AdmInputGroupAddon extends StatelessWidget {
  final Widget child;
  final AdmAddonAlign align;

  const AdmInputGroupAddon({
    super.key,
    required this.child,
    this.align = AdmAddonAlign.inlineStart,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final padding = align == AdmAddonAlign.inlineStart
        ? EdgeInsets.only(left: tokens.spaceMd)
        : EdgeInsets.only(right: tokens.spaceSm);

    return Padding(
      padding: padding,
      child: IconTheme(
        data: IconThemeData(color: tokens.colorTextTertiary, size: 18),
        child: DefaultTextStyle(
          style: TextStyle(
            color: tokens.colorTextSecondary,
            fontSize: tokens.fontSizeMd,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// [AdmInputGroupButton] — a compact button tuned for use inside an
/// [AdmInputGroup]. Defaults to a borderless (ghost-like) look; set [filled] for
/// a solid primary variant. Internally composes [AdmButton].
class AdmInputGroupButton extends StatelessWidget {
  /// Convenience label. Ignored when [child] is provided.
  final String? label;

  /// Custom content. Overrides [label] / [icon] when set.
  final Widget? child;

  /// Optional trailing icon, rendered after [label].
  final IconData? icon;

  final VoidCallback? onPressed;

  /// When `true` renders a solid primary button instead of the ghost default.
  final bool filled;

  final bool disabled;

  const AdmInputGroupButton(
    this.label, {
    super.key,
    this.child,
    this.icon,
    this.onPressed,
    this.filled = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final foreground = filled ? tokens.colorTextWhite : tokens.colorTextBase;

    final content = child ??
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null)
              Text(
                label!,
                style: TextStyle(fontSize: tokens.fontSizeSm, color: foreground),
              ),
            if (icon != null) ...[
              if (label != null) SizedBox(width: tokens.spaceXs),
              Icon(icon, size: 14, color: foreground),
            ],
          ],
        );

    return AdmButton(
      onPressed: onPressed,
      disabled: disabled,
      size: AdmButtonSize.mini,
      fill: filled ? AdmButtonFill.solid : AdmButtonFill.none,
      color: filled ? AdmButtonColor.primary : AdmButtonColor.defaultColor,
      borderRadius: BorderRadius.circular(tokens.radiusSm),
      child: content,
    );
  }
}
