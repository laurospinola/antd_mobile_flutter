import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

/// [AdmSearchBar] — equivalent to ant-design-mobile's `<SearchBar>`.
///
/// ```dart
/// AdmSearchBar(
///   placeholder: 'Search products...',
///   onSearch: (v) => performSearch(v),
///   showCancelButton: true,
/// )
/// ```
class AdmSearchBar extends StatefulWidget {
  final String? placeholder;
  final bool showCancelButton;
  final String cancelText;
  final TextEditingController? controller;
  final ValueChanged<String>? onSearch;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onCancel;
  final FocusNode? focusNode;

  const AdmSearchBar({
    super.key,
    this.placeholder = 'Search',
    this.showCancelButton = false,
    this.cancelText = 'Cancel',
    this.controller,
    this.onSearch,
    this.onChanged,
    this.onCancel,
    this.focusNode,
  });

  @override
  State<AdmSearchBar> createState() => _AdmSearchBarState();
}

class _AdmSearchBarState extends State<AdmSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
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

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: tokens.colorFill,
              borderRadius: BorderRadius.circular(tokens.radiusPill),
            ),
            child: Row(
              children: [
                SizedBox(width: tokens.spaceSm + 2),
                Icon(
                  Icons.search,
                  size: 16,
                  color: tokens.colorTextTertiary,
                ),
                SizedBox(width: tokens.spaceXs),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onSubmitted: widget.onSearch,
                    onChanged: widget.onChanged,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(
                      fontSize: tokens.fontSizeMd,
                      color: tokens.colorTextBase,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: TextStyle(
                        color: tokens.colorTextPlaceholder,
                        fontSize: tokens.fontSizeMd,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _controller.clear();
                      widget.onChanged?.call('');
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: tokens.spaceSm),
                      child: Icon(
                        Icons.cancel,
                        size: 15,
                        color: tokens.colorTextTertiary,
                      ),
                    ),
                  )
                else
                  SizedBox(width: tokens.spaceSm),
              ],
            ),
          ),
        ),
        // Cancel button
        if (widget.showCancelButton && _focused)
          GestureDetector(
            onTap: () {
              _controller.clear();
              _focusNode.unfocus();
              widget.onCancel?.call();
            },
            child: Padding(
              padding: EdgeInsets.only(left: tokens.spaceMd),
              child: Text(
                widget.cancelText,
                style: TextStyle(
                  fontSize: tokens.fontSizeMd,
                  color: tokens.colorPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
