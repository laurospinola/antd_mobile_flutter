import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';
import '../../theme/adm_tokens.dart';

// ── Enums ──────────────────────────────────────────────────────────────────

/// Single value or multiple values selection.
enum AdmSelectMode { single, multiple }

/// Input size variants.
enum AdmSelectSize { small, middle, large }

/// Validation status styling.
enum AdmSelectStatus { none, error, warning }

// ── Data models ────────────────────────────────────────────────────────────

/// A single selectable option.
class AdmSelectOption<T> {
  final String label;
  final T value;
  final bool disabled;

  const AdmSelectOption({
    required this.label,
    required this.value,
    this.disabled = false,
  });
}

/// A labeled group of options.
class AdmSelectOptionGroup<T> {
  final String label;
  final List<AdmSelectOption<T>> options;

  const AdmSelectOptionGroup({
    required this.label,
    required this.options,
  });
}

// ── AdmSelect ──────────────────────────────────────────────────────────────

/// Dropdown select — Flutter equivalent of ant-design's `<Select>`.
///
/// ```dart
/// // Single select
/// AdmSelect<String>(
///   options: const [
///     AdmSelectOption(label: 'Apple', value: 'apple'),
///     AdmSelectOption(label: 'Banana', value: 'banana'),
///   ],
///   placeholder: 'Pick a fruit',
///   onChange: (vals) => print(vals.first),
/// )
///
/// // Multiple select with search
/// AdmSelect<int>(
///   mode: AdmSelectMode.multiple,
///   showSearch: true,
///   allowClear: true,
///   options: const [
///     AdmSelectOption(label: 'One', value: 1),
///     AdmSelectOption(label: 'Two', value: 2),
///     AdmSelectOption(label: 'Three', value: 3),
///   ],
///   onChange: (vals) => print(vals),
/// )
///
/// // Grouped options
/// AdmSelect<String>(
///   optionGroups: const [
///     AdmSelectOptionGroup(label: 'Fruits', options: [
///       AdmSelectOption(label: 'Apple', value: 'apple'),
///       AdmSelectOption(label: 'Mango', value: 'mango'),
///     ]),
///     AdmSelectOptionGroup(label: 'Veggies', options: [
///       AdmSelectOption(label: 'Carrot', value: 'carrot'),
///     ]),
///   ],
///   onChange: (vals) {},
/// )
/// ```
class AdmSelect<T> extends StatefulWidget {
  /// Controlled selected values. Pair with [onChange].
  final List<T>? value;

  /// Initial values for uncontrolled usage.
  final List<T>? defaultValue;

  /// Flat list of options. Mutually exclusive with [optionGroups].
  final List<AdmSelectOption<T>>? options;

  /// Grouped options. Mutually exclusive with [options].
  final List<AdmSelectOptionGroup<T>>? optionGroups;

  /// Called when selection changes.
  final ValueChanged<List<T>>? onChange;

  final AdmSelectMode mode;
  final AdmSelectSize size;
  final AdmSelectStatus status;
  final String? placeholder;
  final bool disabled;

  /// Shows a clear-all button when a value is selected.
  final bool allowClear;

  /// Replaces the dropdown arrow with a loading spinner.
  final bool loading;

  /// Shows a search/filter field inside the dropdown.
  final bool showSearch;

  /// Content shown when no options match the search query.
  final Widget? notFoundContent;

  /// Maximum pixel height of the dropdown list.
  final double dropdownMaxHeight;

  const AdmSelect({
    super.key,
    this.value,
    this.defaultValue,
    this.options,
    this.optionGroups,
    this.onChange,
    this.mode = AdmSelectMode.single,
    this.size = AdmSelectSize.middle,
    this.status = AdmSelectStatus.none,
    this.placeholder,
    this.disabled = false,
    this.allowClear = false,
    this.loading = false,
    this.showSearch = false,
    this.notFoundContent,
    this.dropdownMaxHeight = 256,
  }) : assert(
          options != null || optionGroups != null,
          'Provide either options or optionGroups',
        );

  @override
  State<AdmSelect<T>> createState() => _AdmSelectState<T>();
}

class _AdmSelectState<T> extends State<AdmSelect<T>>
    with SingleTickerProviderStateMixin {
  List<T> _selected = [];
  bool _isOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late AnimationController _arrowCtrl;
  late Animation<double> _arrowAnim;

  bool get _isControlled => widget.value != null;
  List<T> get _effectiveValue => _isControlled ? widget.value! : _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<T>.from(widget.defaultValue ?? []);
    _arrowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _arrowAnim = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _arrowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _arrowCtrl.dispose();
    super.dispose();
  }

  List<AdmSelectOption<T>> get _flatOptions {
    if (widget.options != null) return widget.options!;
    return widget.optionGroups!.expand((g) => g.options).toList();
  }

  void _toggleOpen() {
    if (widget.disabled || widget.loading) return;
    _isOpen ? _closeDropdown() : _openDropdown();
  }

  void _openDropdown() {
    final renderBox = context.findRenderObject() as RenderBox;
    final triggerWidth = renderBox.size.width;
    final tokens = AdmTheme.tokensOf(context);
    _overlayEntry = _buildOverlayEntry(tokens, triggerWidth);
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _arrowCtrl.forward();
  }

  void _closeDropdown() {
    _removeOverlay();
    if (mounted) setState(() => _isOpen = false);
    _arrowCtrl.reverse();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectOption(T val) {
    List<T> next;
    if (widget.mode == AdmSelectMode.single) {
      next = [val];
      if (!_isControlled) setState(() => _selected = next);
      widget.onChange?.call(next);
      _closeDropdown();
    } else {
      next = List<T>.from(_effectiveValue);
      next.contains(val) ? next.remove(val) : next.add(val);
      if (!_isControlled) setState(() => _selected = next);
      widget.onChange?.call(next);
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _clearValue() {
    if (!_isControlled) setState(() => _selected = []);
    widget.onChange?.call([]);
  }

  void _removeChip(T val) {
    final next = List<T>.from(_effectiveValue)..remove(val);
    if (!_isControlled) setState(() => _selected = next);
    widget.onChange?.call(next);
    if (_isOpen) _overlayEntry?.markNeedsBuild();
  }

  OverlayEntry _buildOverlayEntry(AdmTokens tokens, double width) {
    return OverlayEntry(
      builder: (_) => _SelectDropdown<T>(
        layerLink: _layerLink,
        width: width,
        options: widget.options,
        optionGroups: widget.optionGroups,
        selectedValues: _effectiveValue,
        mode: widget.mode,
        showSearch: widget.showSearch,
        notFoundContent: widget.notFoundContent,
        dropdownMaxHeight: widget.dropdownMaxHeight,
        onSelect: _selectOption,
        onClose: _closeDropdown,
        tokens: tokens,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AdmTheme.tokensOf(context);
    final selected = _effectiveValue;
    final hasValue = selected.isNotEmpty;
    final isMulti = widget.mode == AdmSelectMode.multiple;
    final isDisabled = widget.disabled;

    final minHeight = switch (widget.size) {
      AdmSelectSize.small => t.buttonSmallHeight,
      AdmSelectSize.middle => t.buttonDefaultHeight,
      AdmSelectSize.large => t.buttonLargeHeight,
    };
    final fontSize = switch (widget.size) {
      AdmSelectSize.small => t.fontSizeSm,
      AdmSelectSize.middle => t.fontSizeMd,
      AdmSelectSize.large => t.fontSizeLg,
    };
    final borderColor = isDisabled
        ? t.colorBorder
        : _isOpen
            ? t.colorPrimary
            : switch (widget.status) {
                AdmSelectStatus.error => t.colorDanger,
                AdmSelectStatus.warning => t.colorWarning,
                AdmSelectStatus.none => t.colorBorder,
              };

    // ── Display content ──────────────────────────────────────────────────────
    Widget displayContent;
    if (isMulti && hasValue) {
      displayContent = Wrap(
        spacing: 4,
        runSpacing: 4,
        children: selected.map((v) {
          final label = _flatOptions
              .firstWhere(
                (o) => o.value == v,
                orElse: () => AdmSelectOption(label: v.toString(), value: v),
              )
              .label;
          return _SelectChip(
            label: label,
            onRemove: isDisabled ? null : () => _removeChip(v),
            tokens: t,
          );
        }).toList(),
      );
    } else if (!isMulti && hasValue) {
      final label = _flatOptions
          .firstWhere(
            (o) => o.value == selected.first,
            orElse: () => AdmSelectOption(
              label: selected.first.toString(),
              value: selected.first,
            ),
          )
          .label;
      displayContent = Text(
        label,
        style: TextStyle(fontSize: fontSize, color: t.colorTextBase),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    } else {
      displayContent = Text(
        widget.placeholder ?? '',
        style: TextStyle(fontSize: fontSize, color: t.colorTextPlaceholder),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    final vertPad = isMulti && hasValue ? t.spaceXs : 0.0;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleOpen,
        child: AnimatedContainer(
          duration: t.animationDurationFast,
          constraints: BoxConstraints(minHeight: minHeight),
          padding: EdgeInsets.symmetric(
            horizontal: t.spaceMd,
            vertical: vertPad,
          ),
          decoration: BoxDecoration(
            color: isDisabled ? t.colorFill : t.colorBackground,
            border: Border.all(
              color: borderColor,
              width: _isOpen ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(t.radiusSm),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: isMulti && hasValue
                    ? displayContent
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: displayContent,
                      ),
              ),
              const SizedBox(width: 4),
              if (widget.loading)
                SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(t.colorTextTertiary),
                  ),
                )
              else ...[
                if (widget.allowClear && hasValue && !isDisabled)
                  GestureDetector(
                    onTap: _clearValue,
                    child: Icon(
                      Icons.cancel_rounded,
                      size: 14,
                      color: t.colorTextTertiary,
                    ),
                  ),
                const SizedBox(width: 2),
                RotationTransition(
                  turns: _arrowAnim,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color:
                        isDisabled ? t.colorTextDisabled : t.colorTextSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── _SelectDropdown ────────────────────────────────────────────────────────

class _SelectDropdown<T> extends StatefulWidget {
  final LayerLink layerLink;
  final double width;
  final List<AdmSelectOption<T>>? options;
  final List<AdmSelectOptionGroup<T>>? optionGroups;
  final List<T> selectedValues;
  final AdmSelectMode mode;
  final bool showSearch;
  final Widget? notFoundContent;
  final double dropdownMaxHeight;
  final ValueChanged<T> onSelect;
  final VoidCallback onClose;
  final AdmTokens tokens;

  const _SelectDropdown({
    required this.layerLink,
    required this.width,
    this.options,
    this.optionGroups,
    required this.selectedValues,
    required this.mode,
    required this.showSearch,
    this.notFoundContent,
    required this.dropdownMaxHeight,
    required this.onSelect,
    required this.onClose,
    required this.tokens,
  });

  @override
  State<_SelectDropdown<T>> createState() => _SelectDropdownState<T>();
}

class _SelectDropdownState<T> extends State<_SelectDropdown<T>>
    with SingleTickerProviderStateMixin {
  String _query = '';
  final _searchCtrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AdmSelectOption<T>> _filter(List<AdmSelectOption<T>> opts) {
    if (_query.isEmpty) return opts;
    final q = _query.toLowerCase();
    return opts.where((o) => o.label.toLowerCase().contains(q)).toList();
  }

  Widget _buildEmpty() {
    final t = widget.tokens;
    return widget.notFoundContent ??
        Padding(
          padding: EdgeInsets.symmetric(vertical: t.spaceLg),
          child: Center(
            child: Text(
              'No data',
              style: TextStyle(
                fontSize: t.fontSizeMd,
                color: t.colorTextTertiary,
              ),
            ),
          ),
        );
  }

  Widget _buildOptionTile(AdmSelectOption<T> opt) {
    final t = widget.tokens;
    final isSelected = widget.selectedValues.contains(opt.value);
    final isMulti = widget.mode == AdmSelectMode.multiple;

    return GestureDetector(
      onTap: opt.disabled ? null : () => widget.onSelect(opt.value),
      child: Container(
        color: isSelected
            ? t.colorPrimary.withValues(alpha: 0.08)
            : Colors.transparent,
        padding: EdgeInsets.symmetric(
          horizontal: t.spaceLg,
          vertical: t.spaceMd,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                opt.label,
                style: TextStyle(
                  fontSize: t.fontSizeMd,
                  color: opt.disabled
                      ? t.colorTextDisabled
                      : isSelected
                          ? t.colorPrimary
                          : t.colorTextBase,
                  fontWeight:
                      isSelected ? t.fontWeightMedium : t.fontWeightNormal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (isMulti)
              Icon(
                isSelected
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                size: 18,
                color: isSelected ? t.colorPrimary : t.colorBorder,
              )
            else if (isSelected)
              Icon(Icons.check, size: 16, color: t.colorPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupLabel(String label) {
    final t = widget.tokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(t.spaceLg, t.spaceMd, t.spaceLg, t.spaceXs),
      child: Text(
        label,
        style: TextStyle(
          fontSize: t.fontSizeSm,
          color: t.colorTextTertiary,
          fontWeight: t.fontWeightMedium,
        ),
      ),
    );
  }

  List<Widget> _buildItems() {
    final t = widget.tokens;

    if (widget.options != null) {
      final filtered = _filter(widget.options!);
      if (filtered.isEmpty) return [_buildEmpty()];
      return filtered.map(_buildOptionTile).toList();
    }

    // Grouped options
    final List<Widget> items = [];
    for (final group in widget.optionGroups!) {
      final filtered = _filter(group.options);
      if (filtered.isEmpty) continue;
      if (items.isNotEmpty) {
        items.add(Divider(height: 1, thickness: 0.5, color: t.colorBorder));
      }
      items.add(_buildGroupLabel(group.label));
      items.addAll(filtered.map(_buildOptionTile));
    }
    if (items.isEmpty) return [_buildEmpty()];
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;

    return Stack(
      children: [
        // Tap-outside-to-close barrier
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            behavior: HitTestBehavior.translucent,
            child: const SizedBox.expand(),
          ),
        ),
        // Dropdown panel
        CompositedTransformFollower(
          link: widget.layerLink,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 4),
          child: SizedBox(
            width: widget.width,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                alignment: Alignment.topCenter,
                child: Material(
                  elevation: 6,
                  shadowColor: t.colorBoxShadow,
                  borderRadius: BorderRadius.circular(t.radiusSm),
                  color: t.colorBackground,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(t.radiusSm),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.showSearch)
                          Padding(
                            padding: EdgeInsets.all(t.spaceSm),
                            child: TextField(
                              controller: _searchCtrl,
                              autofocus: true,
                              onChanged: (v) => setState(() => _query = v),
                              style: TextStyle(
                                fontSize: t.fontSizeMd,
                                color: t.colorTextBase,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                prefixIcon: Icon(
                                  Icons.search,
                                  size: 16,
                                  color: t.colorTextTertiary,
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 0,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: t.spaceSm,
                                  horizontal: t.spaceMd,
                                ),
                                hintText: 'Search...',
                                hintStyle: TextStyle(
                                  fontSize: t.fontSizeMd,
                                  color: t.colorTextPlaceholder,
                                ),
                                filled: true,
                                fillColor: t.colorFill,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(t.radiusXs),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(t.radiusXs),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(t.radiusXs),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: widget.dropdownMaxHeight,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _buildItems(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── _SelectChip ────────────────────────────────────────────────────────────

class _SelectChip extends StatelessWidget {
  final String label;
  final VoidCallback? onRemove;
  final AdmTokens tokens;

  const _SelectChip({
    required this.label,
    this.onRemove,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: t.colorFill,
        borderRadius: BorderRadius.circular(t.radiusXs),
        border: Border.all(color: t.colorBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: t.fontSizeXs, color: t.colorTextBase),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 3),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: 11,
                color: t.colorTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
