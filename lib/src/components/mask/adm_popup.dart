import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdmMask  (semi-transparent overlay)
// ─────────────────────────────────────────────────────────────────────────────

/// [AdmMask] — equivalent to ant-design-mobile's `<Mask>`.
///
/// A full-screen semi-transparent overlay that optionally dismisses on tap.
class AdmMask extends StatefulWidget {
  final bool visible;
  final VoidCallback? onMaskClick;
  final Widget? child;
  final Color? color;

  const AdmMask({
    super.key,
    required this.visible,
    this.onMaskClick,
    this.child,
    this.color,
  });

  @override
  State<AdmMask> createState() => _AdmMaskState();
}

class _AdmMaskState extends State<AdmMask>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: widget.visible ? 1 : 0,
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    if (widget.visible) _ctrl.forward();
  }

  @override
  void didUpdateWidget(AdmMask old) {
    super.didUpdateWidget(old);
    if (old.visible != widget.visible) {
      widget.visible ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: GestureDetector(
        onTap: widget.onMaskClick,
        child: Container(
          color: widget.color ?? Colors.black54,
          child: widget.child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AdmPopup  (bottom / top / left / right sheet)
// ─────────────────────────────────────────────────────────────────────────────

enum AdmPopupPosition { bottom, top, left, right, center }

/// [AdmPopup] — equivalent to ant-design-mobile's `<Popup>`.
///
/// ```dart
/// AdmPopup.show(
///   context,
///   position: AdmPopupPosition.bottom,
///   child: SizedBox(
///     height: 300,
///     child: MyPickerWidget(),
///   ),
/// );
/// ```
class AdmPopup {
  static Future<void> show(
    BuildContext context, {
    required Widget child,
    AdmPopupPosition position = AdmPopupPosition.bottom,
    bool closeOnMaskClick = true,
    bool showMask = true,
    double? maxHeight,
    Color? backgroundColor,
    BorderRadius? borderRadius,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: closeOnMaskClick,
      barrierLabel: '',
      barrierColor: showMask ? Colors.black54 : Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        return _AdmPopupSheet(
          animation: anim,
          position: position,
          maxHeight: maxHeight,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          child: child,
        );
      },
    );
  }
}

class _AdmPopupSheet extends StatelessWidget {
  final Animation<double> animation;
  final AdmPopupPosition position;
  final Widget child;
  final double? maxHeight;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const _AdmPopupSheet({
    required this.animation,
    required this.position,
    required this.child,
    this.maxHeight,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final bgColor = backgroundColor ?? tokens.colorBackground;

    final curved =
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);

    Alignment alignment;
    Offset beginOffset;

    switch (position) {
      case AdmPopupPosition.bottom:
        alignment = Alignment.bottomCenter;
        beginOffset = const Offset(0, 1);
        break;
      case AdmPopupPosition.top:
        alignment = Alignment.topCenter;
        beginOffset = const Offset(0, -1);
        break;
      case AdmPopupPosition.left:
        alignment = Alignment.centerLeft;
        beginOffset = const Offset(-1, 0);
        break;
      case AdmPopupPosition.right:
        alignment = Alignment.centerRight;
        beginOffset = const Offset(1, 0);
        break;
      case AdmPopupPosition.center:
        alignment = Alignment.center;
        beginOffset = Offset.zero;
        break;
    }

    if (position == AdmPopupPosition.center) {
      return FadeTransition(
        opacity: curved,
        child: Align(
          alignment: alignment,
          child: _decoratedChild(bgColor, tokens),
        ),
      );
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: beginOffset,
        end: Offset.zero,
      ).animate(curved),
      child: Align(
        alignment: alignment,
        child: _decoratedChild(bgColor, tokens),
      ),
    );
  }

  Widget _decoratedChild(Color bgColor, tokens) {
    BorderRadius br;
    if (borderRadius != null) {
      br = borderRadius!;
    } else {
      br = switch (position) {
        AdmPopupPosition.bottom => BorderRadius.vertical(
            top: Radius.circular(tokens.radiusXl)),
        AdmPopupPosition.top => BorderRadius.vertical(
            bottom: Radius.circular(tokens.radiusXl)),
        AdmPopupPosition.left => BorderRadius.horizontal(
            right: Radius.circular(tokens.radiusXl)),
        AdmPopupPosition.right => BorderRadius.horizontal(
            left: Radius.circular(tokens.radiusXl)),
        AdmPopupPosition.center => BorderRadius.circular(tokens.radiusXl),
      };
    }

    return Container(
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight!)
          : null,
      decoration: BoxDecoration(color: bgColor, borderRadius: br),
      child: SafeArea(
        top: position == AdmPopupPosition.top,
        bottom: position == AdmPopupPosition.bottom,
        child: child,
      ),
    );
  }
}
