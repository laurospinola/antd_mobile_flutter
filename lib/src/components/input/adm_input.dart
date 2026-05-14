import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/adm_theme.dart';

/// When validation is triggered automatically.
///
/// Pass one or both values to [AdmInput.validateTrigger].
enum AdmInputValidateTrigger {
  /// Validate every time the value changes.
  onChange,

  /// Validate when the field loses focus.
  onBlur,
}

/// [AdmInput] — equivalent to ant-design-mobile's `<Input>`.
///
/// ### Basic usage
/// ```dart
/// AdmInput(
///   label: const Text('Username'),
///   placeholder: 'Enter your name',
///   prefix: const Icon(Icons.person_outline),
///   clearable: true,
///   onChanged: (v) => print(v),
/// )
/// ```
///
/// ### With validation
/// ```dart
/// final _key = GlobalKey<AdmInputState>();
///
/// AdmInput(
///   key: _key,
///   label: const Text('Email'),
///   placeholder: 'you@example.com',
///   validator: (v) {
///     if (v == null || v.isEmpty) return 'Required';
///     if (!v.contains('@')) return 'Invalid email';
///     return null;
///   },
///   validateTrigger: const {AdmInputValidateTrigger.onBlur},
/// )
///
/// // Trigger validation imperatively (e.g. on form submit):
/// final isValid = _key.currentState?.validate() ?? false;
/// ```
class AdmInput extends StatefulWidget {
  final String? placeholder;
  final Widget? label;
  final Widget? prefix;
  final Widget? suffix;
  final bool clearable;
  final bool readOnly;
  final bool disabled;
  final bool password;
  final int? maxLength;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final TextAlign textAlign;

  /// Static error message shown unconditionally (no validator needed).
  final String? errorMessage;

  final Color? backgroundColor;

  /// Returns an error string to display, or `null` if the value is valid.
  final String? Function(String? value)? validator;

  /// When the [validator] runs automatically.
  ///
  /// Defaults to `{AdmInputValidateTrigger.onBlur}`.
  final Set<AdmInputValidateTrigger> validateTrigger;

  /// Controls when [TextFormField] auto-validates internally.
  ///
  /// Defaults to [AutovalidateMode.disabled] — validation is driven by
  /// [validateTrigger] and the imperative [AdmInputState.validate] method.
  /// Set to [AutovalidateMode.onUserInteraction] to also participate in
  /// [Form] auto-validation.
  final AutovalidateMode autovalidateMode;

  const AdmInput({
    super.key,
    this.placeholder,
    this.label,
    this.prefix,
    this.suffix,
    this.clearable = false,
    this.readOnly = false,
    this.disabled = false,
    this.password = false,
    this.maxLength,
    this.maxLines = 1,
    this.keyboardType,
    this.controller,
    this.onChanged,
    this.onClear,
    this.inputFormatters,
    this.textInputAction,
    this.focusNode,
    this.errorMessage,
    this.backgroundColor,
    this.validator,
    this.validateTrigger = const {AdmInputValidateTrigger.onBlur},
    this.autovalidateMode = AutovalidateMode.disabled,
    this.textAlign = TextAlign.start,
  });

  @override
  AdmInputState createState() => AdmInputState();
}

/// Public state — access via `GlobalKey<AdmInputState>` to call [validate].
class AdmInputState extends State<AdmInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late VoidCallback _controllerListener;
  bool _hasFocus = false;
  bool _obscure = true;

  /// Validation error set by [validator] runs. `null` means valid / not yet run.
  String? _validationError;

  /// The error string to display — validator result takes priority over the
  /// static [AdmInput.errorMessage].
  String? get _displayError => _validationError ?? widget.errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(_onFocusChange);
    _controllerListener = () { if (mounted) setState(() {}); };
    _controller.addListener(_controllerListener);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_controllerListener);
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    final hasFocus = _focusNode.hasFocus;
    setState(() => _hasFocus = hasFocus);
    if (!hasFocus &&
        widget.validator != null &&
        widget.validateTrigger.contains(AdmInputValidateTrigger.onBlur)) {
      _runValidator(_controller.text);
    }
  }

  void _onChanged(String value) {
    widget.onChanged?.call(value);
    if (widget.validator != null &&
        widget.validateTrigger.contains(AdmInputValidateTrigger.onChange)) {
      _runValidator(value);
    } else if (_validationError != null) {
      // Clear stale error as the user types, even when onChange isn't a trigger.
      setState(() => _validationError = null);
    }
  }

  void _runValidator(String value) {
    final error = widget.validator?.call(value.isEmpty ? null : value);
    setState(() => _validationError = error);
  }

  /// Runs the [validator] immediately and returns `true` if the field is valid.
  ///
  /// Call from a parent widget via `GlobalKey<AdmInputState>`:
  /// ```dart
  /// final isValid = _inputKey.currentState?.validate() ?? false;
  /// ```
  bool validate() {
    if (widget.validator == null) return true;
    _runValidator(_controller.text);
    return _validationError == null;
  }

  /// Clears any active validation error.
  void clearValidation() => setState(() => _validationError = null);

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final hasError = _displayError != null;
    final borderColor = hasError
        ? tokens.colorDanger
        : (_hasFocus ? tokens.colorPrimary : tokens.colorBorder);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          DefaultTextStyle(
            style: TextStyle(
              fontSize: tokens.fontSizeSm,
              color: tokens.colorTextSecondary,
              fontWeight: tokens.fontWeightMedium,
            ),
            child: widget.label!,
          ),
          SizedBox(height: tokens.spaceXs),
        ],
        AnimatedContainer(
          duration: tokens.animationDurationFast,
          decoration: BoxDecoration(
            color: widget.disabled
                ? tokens.colorFill
                : (widget.backgroundColor ?? tokens.colorBackground),
            border: Border.all(color: borderColor, width: _hasFocus ? 1.5 : 1),
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
          child: Row(
            children: [
              if (widget.prefix != null) ...[
                Padding(
                  padding: EdgeInsets.only(left: tokens.spaceMd),
                  child: IconTheme(
                    data: IconThemeData(
                        color: tokens.colorTextTertiary, size: 18),
                    child: widget.prefix!,
                  ),
                ),
              ],
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  readOnly: widget.readOnly || widget.disabled,
                  obscureText: widget.password && _obscure,
                  maxLength: widget.maxLength,
                  maxLines: widget.password ? 1 : widget.maxLines,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  textInputAction: widget.textInputAction,
                  onChanged: _onChanged,
                  validator: widget.validator,
                  autovalidateMode: widget.autovalidateMode,
                  textAlign: widget.textAlign,
                  style: TextStyle(
                    fontSize: tokens.fontSizeMd,
                    color: widget.disabled
                        ? tokens.colorTextDisabled
                        : tokens.colorTextBase,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: TextStyle(
                      color: tokens.colorTextPlaceholder,
                      fontSize: tokens.fontSizeMd,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    // Suppress the built-in error display — AdmInput owns
                    // the error UI via the row below the container.
                    errorStyle: const TextStyle(height: 0, fontSize: 0),
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: tokens.spaceMd,
                      vertical: tokens.spaceMd,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              // Clear button
              if (widget.clearable && _controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    widget.onClear?.call();
                    widget.onChanged?.call('');
                    if (widget.validator != null) _runValidator('');
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: tokens.spaceSm),
                    child: Icon(
                      Icons.cancel,
                      size: 16,
                      color: tokens.colorTextTertiary,
                    ),
                  ),
                ),
              // Password toggle
              if (widget.password)
                GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: tokens.spaceSm),
                    child: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: tokens.colorTextTertiary,
                    ),
                  ),
                ),
              // Custom suffix
              if (widget.suffix != null) ...[
                Padding(
                  padding: EdgeInsets.only(right: tokens.spaceMd),
                  child: widget.suffix!,
                ),
              ],
            ],
          ),
        ),
        // Error message
        AnimatedSize(
          duration: tokens.animationDurationFast,
          alignment: Alignment.topLeft,
          child: hasError
              ? Padding(
                  padding: EdgeInsets.only(top: tokens.spaceXs),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 12,
                        color: tokens.colorDanger,
                      ),
                      SizedBox(width: tokens.spaceXs),
                      Expanded(
                        child: Text(
                          _displayError!,
                          style: TextStyle(
                            fontSize: tokens.fontSizeSm,
                            color: tokens.colorDanger,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
