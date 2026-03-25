import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/adm_theme.dart';
import '../../theme/adm_tokens.dart';

/// Validation status styling for [AdmOtpInput].
enum AdmOtpInputStatus { none, error, warning }

/// OTP / verification-code input — renders [length] individual cells that
/// auto-advance focus and support paste distribution.
///
/// ### Standalone with validator
/// ```dart
/// AdmOtpInput(
///   length: 6,
///   validator: (v) => (v?.length ?? 0) < 6 ? 'Enter all 6 digits' : null,
///   onComplete: (code) => verify(code),
/// )
/// ```
///
/// ### Inside AdmFormItem (recommended)
/// Put validation rules on [AdmFormItem] and use [onChange] to feed the
/// [AdmFormController]. The form item owns the error display.
///
/// ```dart
/// final _ctrl = AdmFormController();
///
/// AdmForm(
///   controller: _ctrl,
///   child: AdmFormItem(
///     name: 'otp',
///     label: const Text('Verification code'),
///     required: true,
///     rules: [
///       (v) => AdmValidators.notEmpty(v, msg: 'Code is required'),
///       (v) => AdmValidators.length(v, 6, msg: 'Enter all 6 digits'),
///     ],
///     child: AdmOtpInput(
///       length: 6,
///       onChange: (v) => _ctrl.setField('otp', v),
///       onComplete: (v) => _ctrl.setField('otp', v),
///     ),
///   ),
/// )
/// ```
class AdmOtpInput extends StatefulWidget {
  /// Number of cells. Defaults to 6.
  final int length;

  /// Called with the current (partial or complete) value on every keystroke.
  final ValueChanged<String>? onChange;

  /// Called once when all [length] cells are filled and validation passes.
  final ValueChanged<String>? onComplete;

  /// Controlled value — at most [length] characters.
  final String? value;

  /// Initial value for uncontrolled usage.
  final String? defaultValue;

  final bool disabled;

  /// Render each cell as a bullet (password-style).
  final bool masked;

  /// Allow only digit input (0–9). Defaults to `true`.
  final bool digitsOnly;

  final AdmOtpInputStatus status;

  /// Error message for standalone use. When inside [AdmFormItem], use
  /// [AdmFormItem.rules] instead — the form item owns the error display.
  final String? errorMessage;

  /// Validator for standalone use. Called when all cells are filled and on
  /// [AdmOtpInputState.validate]. Returns `null` when valid.
  ///
  /// For form integration prefer [AdmFormItem.rules].
  final String? Function(String? value)? validator;

  /// Size (width = height) of each cell in logical pixels.
  /// Defaults to the theme's `buttonDefaultHeight` (44).
  final double? cellSize;

  /// Gap between cells. Defaults to `spaceXs` (4).
  final double? gap;

  const AdmOtpInput({
    super.key,
    this.length = 6,
    this.onChange,
    this.onComplete,
    this.value,
    this.defaultValue,
    this.disabled = false,
    this.masked = false,
    this.digitsOnly = true,
    this.status = AdmOtpInputStatus.none,
    this.errorMessage,
    this.validator,
    this.cellSize,
    this.gap,
  });

  @override
  AdmOtpInputState createState() => AdmOtpInputState();
}

/// Public state — access via `GlobalKey<AdmOtpInputState>`.
class AdmOtpInputState extends State<AdmOtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  String? _validationError;

  String get currentValue => _controllers.map((c) => c.text).join();

  String? get _displayError => _validationError ?? widget.errorMessage;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    final initial = widget.value ?? widget.defaultValue ?? '';
    if (initial.isNotEmpty) _applyValue(initial);
  }

  @override
  void didUpdateWidget(AdmOtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && widget.value != oldWidget.value) {
      _applyValue(widget.value!);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  // ── Value helpers ──────────────────────────────────────────────────────────

  void _applyValue(String value) {
    for (var i = 0; i < widget.length; i++) {
      _controllers[i].text = i < value.length ? value[i] : '';
    }
  }

  String _sanitize(String raw) => widget.digitsOnly
      ? raw.replaceAll(RegExp(r'[^\d]'), '')
      : raw;

  // ── Event handlers ─────────────────────────────────────────────────────────

  void _onCellChanged(int index, String rawValue) {
    final value = _sanitize(rawValue);

    if (value.isEmpty) {
      // User deleted in this cell
      _controllers[index].clear();
      _notifyChange();
      return;
    }

    // Distribute chars (handles paste / SMS autofill)
    for (var j = 0; j < value.length && index + j < widget.length; j++) {
      _controllers[index + j].text = value[j];
    }


    // Keep only the first char in the current cell
    if (_controllers[index].text.length > 1) {
      _controllers[index].text = value[0];
      _controllers[index].selection =
          const TextSelection.collapsed(offset: 1);
    }

    // Advance focus
    final nextIndex = index + value.length;
    if (nextIndex < widget.length) {
      _focusNodes[nextIndex].requestFocus();
    } else {
      _focusNodes.last.unfocus();
    }

    _notifyChange();
  }

  KeyEventResult _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      _notifyChange();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _notifyChange() {
    final full = currentValue;
    widget.onChange?.call(full);

    if (full.length == widget.length) {
      final error = widget.validator?.call(full);
      if (error != _validationError) setState(() => _validationError = error);
      if (error == null) widget.onComplete?.call(full);
    } else if (_validationError != null) {
      setState(() => _validationError = null);
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Runs the [validator] immediately. Returns `true` if valid.
  bool validate() {
    if (widget.validator == null) return true;
    final v = currentValue;
    final error = widget.validator!(v.isEmpty ? null : v);
    setState(() => _validationError = error);
    return error == null;
  }

  /// Clears all cells and resets validation state.
  void clear() {
    for (final c in _controllers) { c.clear(); }
    setState(() => _validationError = null);
    widget.onChange?.call('');
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final size = widget.cellSize ?? tokens.buttonDefaultHeight;
    final gap = widget.gap ?? tokens.spaceXs;
    final hasError = _displayError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.length, (i) {
            return Padding(
              padding:
                  EdgeInsets.only(right: i < widget.length - 1 ? gap : 0),
              child: _OtpCell(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                size: size,
                disabled: widget.disabled,
                masked: widget.masked,
                digitsOnly: widget.digitsOnly,
                hasError: hasError,
                status: widget.status,
                tokens: tokens,
                onChanged: (v) => _onCellChanged(i, v),
                onKeyEvent: (e) => _onKeyEvent(i, e),
              ),
            );
          }),
        ),
        // Error row — only shown in standalone mode.
        // When inside AdmFormItem, the form item owns the error display.
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
                      Text(
                        _displayError!,
                        style: TextStyle(
                          fontSize: tokens.fontSizeSm,
                          color: tokens.colorDanger,
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

// ── _OtpCell ───────────────────────────────────────────────────────────────

class _OtpCell extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final double size;
  final bool disabled;
  final bool masked;
  final bool digitsOnly;
  final bool hasError;
  final AdmOtpInputStatus status;
  final AdmTokens tokens;
  final ValueChanged<String> onChanged;
  final KeyEventResult Function(KeyEvent) onKeyEvent;

  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.size,
    required this.disabled,
    required this.masked,
    required this.digitsOnly,
    required this.hasError,
    required this.status,
    required this.tokens,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  State<_OtpCell> createState() => _OtpCellState();
}

class _OtpCellState extends State<_OtpCell> {
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() =>
      setState(() => _hasFocus = widget.focusNode.hasFocus);

  Color _resolveBorderColor() {
    final t = widget.tokens;
    if (widget.disabled) return t.colorBorder;
    if (widget.hasError || widget.status == AdmOtpInputStatus.error) {
      return t.colorDanger;
    }
    if (widget.status == AdmOtpInputStatus.warning) return t.colorWarning;
    if (_hasFocus) return t.colorPrimary;
    return t.colorBorder;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final borderColor = _resolveBorderColor();

    return AnimatedContainer(
      duration: t.animationDurationFast,
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.disabled ? t.colorFill : t.colorBackground,
        border: Border.all(
          color: borderColor,
          width: _hasFocus ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(t.radiusSm),
      ),
      child: Focus(
        onKeyEvent: (_, event) => widget.onKeyEvent(event),
        child: TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: !widget.disabled,
          obscureText: widget.masked,
          obscuringCharacter: '●',
          textAlign: TextAlign.center,
          keyboardType:
              widget.digitsOnly ? TextInputType.number : TextInputType.text,
          inputFormatters: [
            if (widget.digitsOnly) FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: widget.onChanged,
          // Validator is managed by AdmOtpInputState / AdmFormItem.
          // Suppress built-in error display — the parent widget owns the UI.
          style: TextStyle(
            fontSize: t.fontSizeLg,
            fontWeight: t.fontWeightMedium,
            color: widget.disabled ? t.colorTextDisabled : t.colorTextBase,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
            isDense: true,
            errorStyle: TextStyle(height: 0, fontSize: 0),
          ),
        ),
      ),
    );
  }
}
