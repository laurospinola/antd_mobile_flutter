import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/adm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdmFormController
// ─────────────────────────────────────────────────────────────────────────────

/// Manages field values and validation for [AdmForm].
class AdmFormController extends ChangeNotifier {
  final Map<String, dynamic> _values = {};
  final Map<String, String?> _errors = {};
  final Map<String, String? Function(dynamic)?> _validators = {};
  final Map<String, ValueChanged<dynamic>?> _submitters = {};

  T? getField<T>(String name) => _values[name] as T?;

  void setField(String name, dynamic value) {
    _values[name] = value;
    _errors.remove(name);
    notifyListeners();
  }

  void setValidator(String name, String? Function(dynamic value)? validator) {
    _validators[name] = validator;
  }

  void setSubmitter(String name, ValueChanged<dynamic>? onSubmit) {
    _submitters[name] = onSubmit;
  }

  /// Invokes the [AdmFormItem.onSubmit] handler registered for [name],
  /// passing the field's current value. No-op if no handler is registered.
  void submitField(String name) {
    _submitters[name]?.call(_values[name]);
  }

  /// Invokes every registered [AdmFormItem.onSubmit] handler with each
  /// field's current value.
  void submitAll() {
    for (final entry in _submitters.entries) {
      entry.value?.call(_values[entry.key]);
    }
  }

  String? getError(String name) => _errors[name];

  bool validate() {
    bool valid = true;
    for (final entry in _validators.entries) {
      final error = entry.value?.call(_values[entry.key]);
      _errors[entry.key] = error;
      if (error != null) valid = false;
    }
    notifyListeners();
    return valid;
  }

  void resetFields() {
    _values.clear();
    _errors.clear();
    notifyListeners();
  }

  Map<String, dynamic> getFieldsValue() => Map.from(_values);
}

// ─────────────────────────────────────────────────────────────────────────────
// AdmForm
// ─────────────────────────────────────────────────────────────────────────────

/// [AdmForm] — equivalent to ant-design-mobile's `<Form>`.
///
/// Wrap your form fields with [AdmForm] and use [AdmFormItem] for layout.
///
/// ```dart
/// final _ctrl = AdmFormController();
///
/// AdmForm(
///   controller: _ctrl,
///   child: Column(children: [
///     AdmFormItem(
///       name: 'username',
///       label: const Text('Username'),
///       rules: [(v) => v == null || v.isEmpty ? 'Required' : null],
///       child: AdmInput(placeholder: 'Enter username'),
///     ),
///   ]),
/// )
/// ```
class AdmForm extends InheritedNotifier<AdmFormController> {
  const AdmForm({
    super.key,
    required AdmFormController controller,
    required super.child,
  }) : super(notifier: controller);

  static AdmFormController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AdmForm>()?.notifier;
  }

  @override
  bool updateShouldNotify(AdmForm oldWidget) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// AdmFormItem
// ─────────────────────────────────────────────────────────────────────────────

/// A labeled field row inside [AdmForm].
class AdmFormItem extends StatelessWidget {
  final String? name;
  final Widget? label;
  final Widget child;
  final bool isRequired;
  final String? help;
  final List<String? Function(dynamic)>? rules;
  final bool noStyle;

  /// Fires when the field is submitted — either by pressing Enter while the
  /// child is focused (hardware keyboard) or imperatively via
  /// [AdmFormController.submitField] / [AdmFormController.submitAll].
  ///
  /// Receives the field's current value from the controller, or `null` if
  /// [name] is unset.
  final ValueChanged<dynamic>? onSubmit;

  const AdmFormItem({
    super.key,
    this.name,
    this.label,
    required this.child,
    this.isRequired = false,
    this.help,
    this.rules,
    this.noStyle = false,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final controller = AdmForm.of(context);

    if (name != null && rules != null && controller != null) {
      controller.setValidator(name!, (v) {
        for (final rule in rules!) {
          final err = rule(v);
          if (err != null) return err;
        }
        return null;
      });
    }

    if (name != null && controller != null) {
      controller.setSubmitter(name!, onSubmit);
    }

    Widget content = child;
    if (onSubmit != null) {
      content = Focus(
        canRequestFocus: false,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
            final value = (name != null && controller != null) ? controller.getField(name!) : null;
            onSubmit!(value);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: child,
      );
    }

    if (noStyle) return content;

    final error = (name != null && controller != null) ? controller.getError(name!) : null;

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Row(
              children: [
                if (isRequired)
                  Text(
                    '* ',
                    style: TextStyle(color: tokens.colorDanger, fontSize: tokens.fontSizeMd),
                  ),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: tokens.fontSizeMd,
                    color: tokens.colorTextBase,
                    fontWeight: tokens.fontWeightMedium,
                  ),
                  child: label!,
                ),
              ],
            ),
            SizedBox(height: tokens.spaceXs),
          ],
          content,
          if (error != null) ...[
            SizedBox(height: tokens.spaceXs),
            Text(
              error,
              style: TextStyle(fontSize: tokens.fontSizeSm, color: tokens.colorDanger),
            ),
          ],
          if (help != null && error == null) ...[
            SizedBox(height: tokens.spaceXs),
            Text(
              help!,
              style: TextStyle(fontSize: tokens.fontSizeSm, color: tokens.colorTextTertiary),
            ),
          ],
        ],
      ),
    );
  }
}
