import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/adm_theme.dart';

/// [AdmInput] — equivalent to ant-design-mobile's `<Input>`.
///
/// ```dart
/// AdmInput(
///   label: const Text('Username'),
///   placeholder: 'Enter your name',
///   prefix: const Icon(Icons.person_outline),
///   clearable: true,
///   onChanged: (v) => print(v),
/// )
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
  final String? errorMessage;
  final Color? backgroundColor;

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
  });

  @override
  State<AdmInput> createState() => _AdmInputState();
}

class _AdmInputState extends State<AdmInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasFocus = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() => _hasFocus = _focusNode.hasFocus);
    });
    _controller.addListener(() => setState(() {}));
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
    final hasError = widget.errorMessage != null;
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
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  readOnly: widget.readOnly || widget.disabled,
                  obscureText: widget.password && _obscure,
                  maxLength: widget.maxLength,
                  maxLines: widget.password ? 1 : widget.maxLines,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  textInputAction: widget.textInputAction,
                  onChanged: widget.onChanged,
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
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: tokens.spaceSm),
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
                    padding: EdgeInsets.symmetric(horizontal: tokens.spaceSm),
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
        if (hasError) ...[
          SizedBox(height: tokens.spaceXs),
          Text(
            widget.errorMessage!,
            style: TextStyle(
              fontSize: tokens.fontSizeSm,
              color: tokens.colorDanger,
            ),
          ),
        ],
      ],
    );
  }
}
