import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

/// [AdmStepper] — equivalent to ant-design-mobile's `<Stepper>`.
///
/// ```dart
/// AdmStepper(
///   value: _qty,
///   min: 1,
///   max: 99,
///   onChange: (v) => setState(() => _qty = v),
/// )
/// ```
class AdmStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final int step;
  final bool disabled;
  final ValueChanged<int>? onChange;
  final double? inputWidth;

  const AdmStepper({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 999,
    this.step = 1,
    this.disabled = false,
    this.onChange,
    this.inputWidth,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final canMinus = !disabled && value > min;
    final canPlus = !disabled && value < max;

    Widget btn(IconData icon, bool active, VoidCallback? onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? tokens.colorBackground : tokens.colorFill,
            border: Border.all(color: tokens.colorBorder, width: 0.5),
            borderRadius: BorderRadius.circular(tokens.radiusSm),
          ),
          child: Icon(
            icon,
            size: 16,
            color: active ? tokens.colorTextBase : tokens.colorTextDisabled,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(
          Icons.remove,
          canMinus,
          canMinus ? () => onChange?.call(value - step) : null,
        ),
        Container(
          width: inputWidth ?? 48,
          height: 32,
          margin: EdgeInsets.symmetric(horizontal: tokens.spaceXs),
          decoration: BoxDecoration(
            border: Border.all(color: tokens.colorBorder, width: 0.5),
            borderRadius: BorderRadius.circular(tokens.radiusSm),
          ),
          child: Center(
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: tokens.fontSizeMd,
                color: disabled
                    ? tokens.colorTextDisabled
                    : tokens.colorTextBase,
              ),
            ),
          ),
        ),
        btn(
          Icons.add,
          canPlus,
          canPlus ? () => onChange?.call(value + step) : null,
        ),
      ],
    );
  }
}
