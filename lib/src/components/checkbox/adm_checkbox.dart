import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdmCheckbox
// ─────────────────────────────────────────────────────────────────────────────

/// [AdmCheckbox] — equivalent to ant-design-mobile's `<CheckBox>`.
///
/// ```dart
/// AdmCheckbox(
///   checked: _checked,
///   onChange: (v) => setState(() => _checked = v),
///   child: const Text('I agree to terms'),
/// )
/// ```
class AdmCheckbox extends StatelessWidget {
  final bool checked;
  final bool indeterminate;
  final bool disabled;
  final Widget? child;
  final ValueChanged<bool>? onChange;
  final Color? activeColor;

  const AdmCheckbox({
    super.key,
    required this.checked,
    this.indeterminate = false,
    this.disabled = false,
    this.child,
    this.onChange,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final color = activeColor ?? tokens.colorPrimary;

    return GestureDetector(
      onTap: disabled ? null : () => onChange?.call(!checked),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: tokens.animationDurationFast,
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: checked || indeterminate
                  ? (disabled ? tokens.colorTextDisabled : color)
                  : Colors.transparent,
              border: Border.all(
                color: checked || indeterminate
                    ? (disabled ? tokens.colorTextDisabled : color)
                    : (disabled ? tokens.colorTextDisabled : tokens.colorBorder),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(tokens.radiusSm),
            ),
            child: checked || indeterminate
                ? Icon(
                    indeterminate ? Icons.remove : Icons.check,
                    size: 12,
                    color: tokens.colorTextWhite,
                  )
                : null,
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

// ─────────────────────────────────────────────────────────────────────────────
// AdmCheckboxGroup
// ─────────────────────────────────────────────────────────────────────────────

class AdmCheckboxOption<T> {
  final T value;
  final Widget label;
  final bool disabled;
  const AdmCheckboxOption(
      {required this.value, required this.label, this.disabled = false});
}

class AdmCheckboxGroup<T> extends StatelessWidget {
  final List<AdmCheckboxOption<T>> options;
  final List<T> value;
  final ValueChanged<List<T>>? onChange;
  final Axis direction;

  const AdmCheckboxGroup({
    super.key,
    required this.options,
    required this.value,
    this.onChange,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final items = options.map((opt) {
      return AdmCheckbox(
        checked: value.contains(opt.value),
        disabled: opt.disabled,
        child: opt.label,
        onChange: (checked) {
          final newValue = List<T>.from(value);
          if (checked) {
            newValue.add(opt.value);
          } else {
            newValue.remove(opt.value);
          }
          onChange?.call(newValue);
        },
      );
    }).toList();

    if (direction == Axis.horizontal) {
      return Wrap(
        spacing: tokens.spaceLg,
        runSpacing: tokens.spaceSm,
        children: items,
      );
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
