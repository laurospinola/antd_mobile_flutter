import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';
import '../../theme/adm_tokens.dart';

/// Button color variants matching ant-design-mobile.
enum AdmButtonColor { primary, success, warning, danger, defaultColor }

/// Button fill styles.
enum AdmButtonFill { solid, outline, none, ghost }

/// Button sizes matching ant-design-mobile (mini / small / middle / large).
enum AdmButtonSize { mini, small, middle, large }

/// [AdmButton] — the Flutter equivalent of ant-design-mobile's `<Button>`.
///
/// ```dart
/// AdmButton(
///   onPressed: () {},
///   child: const Text('Submit'),
/// )
///
/// AdmButton.primary(
///   onPressed: () {},
///   child: const Text('Primary'),
/// )
///
/// AdmButton(
///   color: AdmButtonColor.danger,
///   fill: AdmButtonFill.outline,
///   size: AdmButtonSize.small,
///   child: const Text('Delete'),
/// )
/// ```
class AdmButton extends StatefulWidget {
  final Widget? child;
  final VoidCallback? onPressed;
  final AdmButtonColor color;
  final AdmButtonFill fill;
  final AdmButtonSize size;
  final bool disabled;
  final bool loading;
  final bool block;
  final EdgeInsets? padding;
  final Widget? loadingIndicator;
  final BorderRadius? borderRadius;

  const AdmButton(
      {super.key,
      this.child,
      this.onPressed,
      this.color = AdmButtonColor.defaultColor,
      this.fill = AdmButtonFill.solid,
      this.size = AdmButtonSize.middle,
      this.disabled = false,
      this.loading = false,
      this.block = false,
      this.loadingIndicator,
      this.borderRadius,
      this.padding});

  // ── Named constructors ─────────────────────────────────────────────────────

  factory AdmButton.primary(
          {Key? key,
          Widget? child,
          VoidCallback? onPressed,
          AdmButtonSize size = AdmButtonSize.middle,
          bool disabled = false,
          bool loading = false,
          bool block = false,
          EdgeInsets? padding}) =>
      AdmButton(
        key: key,
        color: AdmButtonColor.primary,
        size: size,
        disabled: disabled,
        loading: loading,
        block: block,
        onPressed: onPressed,
        padding: padding,
        child: child,
      );

  factory AdmButton.ghost(
          {Key? key,
          Widget? child,
          VoidCallback? onPressed,
          AdmButtonColor color = AdmButtonColor.defaultColor,
          AdmButtonSize size = AdmButtonSize.middle,
          bool disabled = false,
          bool loading = false,
          bool block = false,
          EdgeInsets? padding}) =>
      AdmButton(
        key: key,
        fill: AdmButtonFill.ghost,
        color: color,
        size: size,
        disabled: disabled,
        loading: loading,
        block: block,
        onPressed: onPressed,
        padding: padding,
        child: child,
      );

  factory AdmButton.danger(
          {Key? key,
          Widget? child,
          VoidCallback? onPressed,
          AdmButtonSize size = AdmButtonSize.middle,
          bool disabled = false,
          bool loading = false,
          bool block = false,
          EdgeInsets? padding}) =>
      AdmButton(
        key: key,
        color: AdmButtonColor.danger,
        size: size,
        disabled: disabled,
        loading: loading,
        block: block,
        onPressed: onPressed,
        padding: padding,
        child: child,
      );

  @override
  State<AdmButton> createState() => _AdmButtonState();
}

class _AdmButtonState extends State<AdmButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final isDisabled = widget.disabled || widget.loading;

    final fgColor = _resolveForegroundColor(tokens);
    final bgColor = _resolveBackgroundColor(tokens);
    final borderColor = _resolveBorderColor(tokens);
    final height = _resolveHeight(tokens);
    final padding = _resolvePadding();
    final fontSize = _resolveFontSize(tokens);
    final br =
        widget.borderRadius ?? BorderRadius.circular(tokens.buttonBorderRadius);

    Widget content = widget.loading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.loadingIndicator ??
                  SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(fgColor),
                    ),
                  ),
              if (widget.child != null)
                Padding(
                  padding: widget.padding ?? const EdgeInsets.only(left: 8),
                  child: widget.child,
                ),
            ],
          )
        : widget.child ?? const SizedBox.shrink();

    Widget button = GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _pressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedOpacity(
        opacity: _pressed ? 0.7 : 1.0,
        duration: tokens.animationDurationFast,
        child: AnimatedContainer(
          duration: tokens.animationDurationFast,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: isDisabled ? _disabledBg(tokens) : bgColor,
            border: borderColor != null
                ? Border.all(
                    color: isDisabled ? tokens.colorBorder : borderColor,
                    width: 1,
                  )
                : null,
            borderRadius: br,
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: fontSize,
              color: isDisabled ? tokens.colorTextDisabled : fgColor,
              fontWeight: tokens.fontWeightMedium,
            ),
            child: Center(
              widthFactor: widget.block ? null : 1.0,
              child: content,
            ),
          ),
        ),
      ),
    );

    if (widget.block) return button;
    return IntrinsicWidth(child: button);
  }

  Color _resolveBackgroundColor(AdmTokens t) {
    if (widget.fill == AdmButtonFill.outline ||
        widget.fill == AdmButtonFill.none ||
        widget.fill == AdmButtonFill.ghost) {
      return Colors.transparent;
    }
    return switch (widget.color) {
      AdmButtonColor.primary => t.colorPrimary,
      AdmButtonColor.success => t.colorSuccess,
      AdmButtonColor.warning => t.colorWarning,
      AdmButtonColor.danger => t.colorDanger,
      AdmButtonColor.defaultColor => t.colorBackground,
    };
  }

  Color _resolveForegroundColor(AdmTokens t) {
    if (widget.fill == AdmButtonFill.ghost) return t.colorTextWhite;
    if (widget.fill == AdmButtonFill.solid &&
        widget.color != AdmButtonColor.defaultColor) {
      return t.colorTextWhite;
    }
    return switch (widget.color) {
      AdmButtonColor.primary => t.colorPrimary,
      AdmButtonColor.success => t.colorSuccess,
      AdmButtonColor.warning => t.colorWarning,
      AdmButtonColor.danger => t.colorDanger,
      AdmButtonColor.defaultColor => t.colorTextBase,
    };
  }

  Color? _resolveBorderColor(AdmTokens t) {
    if (widget.fill == AdmButtonFill.none) return null;
    if (widget.fill == AdmButtonFill.ghost) return t.colorTextWhite;
    return switch (widget.color) {
      AdmButtonColor.primary => t.colorPrimary,
      AdmButtonColor.success => t.colorSuccess,
      AdmButtonColor.warning => t.colorWarning,
      AdmButtonColor.danger => t.colorDanger,
      AdmButtonColor.defaultColor => t.colorBorder,
    };
  }

  Color _disabledBg(AdmTokens t) =>
      widget.fill == AdmButtonFill.solid ? t.colorFill : Colors.transparent;

  double _resolveHeight(AdmTokens t) => switch (widget.size) {
        AdmButtonSize.mini => t.buttonMiniHeight,
        AdmButtonSize.small => t.buttonSmallHeight,
        AdmButtonSize.middle => t.buttonDefaultHeight,
        AdmButtonSize.large => t.buttonLargeHeight,
      };

  EdgeInsets _resolvePadding() => switch (widget.size) {
        AdmButtonSize.mini => const EdgeInsets.symmetric(horizontal: 8),
        AdmButtonSize.small => const EdgeInsets.symmetric(horizontal: 12),
        AdmButtonSize.middle => const EdgeInsets.symmetric(horizontal: 16),
        AdmButtonSize.large => const EdgeInsets.symmetric(horizontal: 24),
      };

  double _resolveFontSize(AdmTokens t) => switch (widget.size) {
        AdmButtonSize.mini => t.fontSizeXs,
        AdmButtonSize.small => t.fontSizeSm,
        AdmButtonSize.middle => t.fontSizeMd,
        AdmButtonSize.large => t.fontSizeLg,
      };
}
