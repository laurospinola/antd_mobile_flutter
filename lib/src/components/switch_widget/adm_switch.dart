import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

/// [AdmSwitch] — equivalent to ant-design-mobile's `<Switch>`.
///
/// ```dart
/// AdmSwitch(
///   checked: _on,
///   onChange: (v) => setState(() => _on = v),
/// )
/// ```
class AdmSwitch extends StatefulWidget {
  final bool checked;
  final bool disabled;
  final bool loading;
  final ValueChanged<bool>? onChange;
  final Color? checkedColor;
  final Color? uncheckedColor;

  const AdmSwitch({
    super.key,
    required this.checked,
    this.disabled = false,
    this.loading = false,
    this.onChange,
    this.checkedColor,
    this.uncheckedColor,
  });

  @override
  State<AdmSwitch> createState() => _AdmSwitchState();
}

class _AdmSwitchState extends State<AdmSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.checked ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(AdmSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.checked != widget.checked) {
      widget.checked ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    const width = 51.0;
    const height = 31.0;
    const thumbSize = 27.0;
    const padding = 2.0;

    final trackOnColor = widget.checkedColor ?? tokens.colorPrimary;
    final trackOffColor = widget.uncheckedColor ?? const Color(0xFFE5E5EA);
    final isDisabled = widget.disabled || widget.loading;

    return GestureDetector(
      onTap: isDisabled ? null : () => widget.onChange?.call(!widget.checked),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final trackColor =
              Color.lerp(trackOffColor, trackOnColor, _animation.value)!;
          final thumbLeft =
              padding + _animation.value * (width - thumbSize - padding * 2);

          return Opacity(
            opacity: isDisabled ? 0.4 : 1.0,
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: [
                  // Track
                  Container(
                    decoration: BoxDecoration(
                      color: trackColor,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                  // Thumb
                  Positioned(
                    top: padding,
                    left: thumbLeft,
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: widget.loading
                          ? Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                      trackOnColor),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
