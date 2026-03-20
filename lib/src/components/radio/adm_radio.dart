import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

/// [AdmRadio] — single radio button, use with [AdmRadioGroup].
///
/// ```dart
/// AdmRadioGroup<String>(
///   value: _selected,
///   onChange: (v) => setState(() => _selected = v),
///   options: const [
///     AdmRadioOption(value: 'a', label: Text('Option A')),
///     AdmRadioOption(value: 'b', label: Text('Option B')),
///   ],
/// )
/// ```
class AdmRadio<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final bool disabled;
  final Widget? child;
  final ValueChanged<T>? onChange;
  final Color? activeColor;

  const AdmRadio({
    super.key,
    required this.value,
    this.groupValue,
    this.disabled = false,
    this.child,
    this.onChange,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final isSelected = value == groupValue;
    final color = activeColor ?? tokens.colorPrimary;
    final effectiveColor =
        disabled ? tokens.colorTextDisabled : color;

    return GestureDetector(
      onTap: disabled ? null : () => onChange?.call(value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: tokens.animationDurationFast,
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? effectiveColor : tokens.colorBorder,
                width: isSelected ? 5.5 : 1.5,
              ),
              color: tokens.colorBackground,
            ),
          ),
          if (child != null) ...[
            SizedBox(width: tokens.spaceSm),
            DefaultTextStyle(
              style: TextStyle(
                fontSize: tokens.fontSizeMd,
                color: disabled
                    ? tokens.colorTextDisabled
                    : tokens.colorTextBase,
              ),
              child: child!,
            ),
          ],
        ],
      ),
    );
  }
}

class AdmRadioOption<T> {
  final T value;
  final Widget label;
  final bool disabled;
  const AdmRadioOption(
      {required this.value, required this.label, this.disabled = false});
}

class AdmRadioGroup<T> extends StatelessWidget {
  final List<AdmRadioOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChange;
  final Axis direction;
  final Color? activeColor;

  const AdmRadioGroup({
    super.key,
    required this.options,
    this.value,
    this.onChange,
    this.direction = Axis.vertical,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final items = options.map((opt) {
      return AdmRadio<T>(
        value: opt.value,
        groupValue: value,
        disabled: opt.disabled,
        activeColor: activeColor,
        onChange: onChange,
        child: opt.label,
      );
    }).toList();

    if (direction == Axis.horizontal) {
      return Wrap(
          spacing: tokens.spaceLg,
          runSpacing: tokens.spaceSm,
          children: items);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((e) => Padding(
                padding: EdgeInsets.only(bottom: tokens.spaceSm),
                child: e,
              ))
          .toList(),
    );
  }
}
