import 'package:antd_mobile_flutter/antd_mobile_flutter.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdmCascaderOption
// ─────────────────────────────────────────────────────────────────────────────

/// A single node in the cascader option tree.
class AdmCascaderOption {
  /// Unique identifier submitted to [AdmCascader.show]'s `onConfirm` callback.
  final String value;

  /// Human-readable text displayed in the list and the tab bar.
  final String label;

  /// Nested options shown in the next column when this node is selected.
  /// A `null` or empty list marks this node as a leaf (no further drilling).
  final List<AdmCascaderOption>? children;

  /// When `true` the option is shown but cannot be tapped.
  final bool disabled;

  const AdmCascaderOption({
    required this.value,
    required this.label,
    this.children,
    this.disabled = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// AdmCascader
// ─────────────────────────────────────────────────────────────────────────────

/// [AdmCascader] — equivalent to ant-design-mobile's `<Cascader>`.
///
/// Opens a bottom sheet with a tab bar showing the current selection path.
/// Each tab corresponds to a depth level; tapping a tab navigates back to
/// that level. Selecting an option that has children automatically opens
/// the next tab.
///
/// ```dart
/// AdmCascader.show(
///   context,
///   title: const Text('Select Category'),
///   options: const [
///     AdmCascaderOption(
///       value: 'electronics',
///       label: 'Electronics',
///       children: [
///         AdmCascaderOption(value: 'phones', label: 'Phones'),
///         AdmCascaderOption(value: 'computers', label: 'Computers'),
///       ],
///     ),
///   ],
///   onConfirm: (values, items) => print(values),
/// );
/// ```
class AdmCascader {
  /// Shows the cascader as a bottom sheet.
  ///
  /// Returns the confirmed [List<String>] of values, or `null` if cancelled.
  static Future<List<String>?> show(
    BuildContext context, {
    required List<AdmCascaderOption> options,
    List<String>? defaultValue,
    Widget? title,
    Widget? closeWidget,
    Widget? acceptWidget,
    void Function(List<String> values, List<AdmCascaderOption> items)? onConfirm,
    void Function(List<String> values, List<AdmCascaderOption> items)? onChange,
    VoidCallback? onClose,
  }) {
    return showGeneralDialog<List<String>>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeIn),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _AdmCascaderSheet(
                acceptWidget: acceptWidget,
                closetWidget: closeWidget,
                options: options,
                defaultValue: defaultValue,
                title: title,
                onConfirm: onConfirm,
                onChange: onChange,
                onClose: onClose,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AdmCascaderSheet
// ─────────────────────────────────────────────────────────────────────────────

class _AdmCascaderSheet extends StatefulWidget {
  final List<AdmCascaderOption> options;
  final List<String>? defaultValue;
  final Widget? title;
  final void Function(List<String>, List<AdmCascaderOption>)? onConfirm;
  final void Function(List<String>, List<AdmCascaderOption>)? onChange;
  final VoidCallback? onClose;
  final Widget? acceptWidget;
  final Widget? closetWidget;

  const _AdmCascaderSheet({
    required this.options,
    this.defaultValue,
    this.title,
    this.onConfirm,
    this.onChange,
    this.onClose,
    this.acceptWidget,
    this.closetWidget,
  });

  @override
  State<_AdmCascaderSheet> createState() => _AdmCascaderSheetState();
}

class _AdmCascaderSheetState extends State<_AdmCascaderSheet> {
  late List<String?> _selected;

  /// Which level/tab is currently visible.
  int _activeLevel = 0;

  /// Cached columns derived from the current selection.
  late List<List<AdmCascaderOption>> _columns;

  late final PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _selected = [];
    if (widget.defaultValue != null) _initDefaults(widget.defaultValue!);
    _columns = _computeColumns();
    _activeLevel = _selected.length.clamp(0, _columns.length - 1);
    _pageCtrl = PageController(initialPage: _activeLevel);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  // ── Init helpers ────────────────────────────────────────────────────────────

  void _initDefaults(List<String> defaults) {
    List<AdmCascaderOption> cur = widget.options;
    for (final val in defaults) {
      final match = cur.where((o) => o.value == val).firstOrNull;
      if (match == null) break;
      _selected.add(val);
      if (match.children != null && match.children!.isNotEmpty) {
        cur = match.children!;
      } else {
        break;
      }
    }
  }

  // ── Derived data ────────────────────────────────────────────────────────────

  List<List<AdmCascaderOption>> _computeColumns() {
    final cols = <List<AdmCascaderOption>>[widget.options];
    List<AdmCascaderOption> cur = widget.options;
    for (final val in _selected) {
      if (val == null) break;
      final match = cur.where((o) => o.value == val).firstOrNull;
      if (match == null || match.children == null || match.children!.isEmpty) {
        break;
      }
      cols.add(match.children!);
      cur = match.children!;
    }
    return cols;
  }

  List<AdmCascaderOption> _resolveItems() {
    final items = <AdmCascaderOption>[];
    List<AdmCascaderOption> cur = widget.options;
    for (final val in _selected) {
      if (val == null) break;
      final match = cur.where((o) => o.value == val).firstOrNull;
      if (match == null) break;
      items.add(match);
      if (match.children != null) cur = match.children!;
    }
    return items;
  }

  /// Label shown on tab [level].
  String _tabLabel(int level) {
    if (level >= _selected.length || _selected[level] == null) {
      return 'Select';
    }
    return _columns[level]
        .firstWhere(
          (o) => o.value == _selected[level],
          orElse: () => const AdmCascaderOption(value: '', label: '...'),
        )
        .label;
  }

  // ── Interaction ─────────────────────────────────────────────────────────────

  void _pick(String value) {
    final opts = _columns[_activeLevel];
    final opt = opts.firstWhere((o) => o.value == value);
    final hasChildren = opt.children != null && opt.children!.isNotEmpty;

    setState(() {
      _selected = [..._selected.take(_activeLevel), value];
      _columns = _computeColumns();
      if (hasChildren) _activeLevel++;
    });

    if (hasChildren) {
      // Defer navigation until after the rebuild so the new page is available.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageCtrl.hasClients) {
          _pageCtrl.animateToPage(
            _activeLevel,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }

    widget.onChange?.call(_selected.whereType<String>().toList(), _resolveItems());
  }

  void _goToTab(int level) {
    if (level == _activeLevel) return;
    setState(() => _activeLevel = level);
    _pageCtrl.animateToPage(
      level,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _confirm() {
    final values = _selected.whereType<String>().toList();
    widget.onConfirm?.call(values, _resolveItems());
    Navigator.of(context).pop(values);
  }

  void _cancel() {
    widget.onClose?.call();
    Navigator.of(context).pop();
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = AdmTheme.tokensOf(context);

    return Container(
      decoration: BoxDecoration(
        color: t.colorBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(t.radiusXl)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DragHandle(tokens: t),
            _buildHeader(t, acceptWidget: widget.acceptWidget, closeWidget: widget.closetWidget),
            Divider(height: 1, thickness: 0.5, color: t.colorBorder),
            _buildTabBar(t),
            Divider(height: 1, thickness: 0.5, color: t.colorBorder),
            SizedBox(
              height: 260,
              child: PageView.builder(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _columns.length,
                itemBuilder: (_, i) {
                  return _CascaderColumn(
                    // Key includes full parent path so the column is rebuilt
                    // (and auto-scrolls) whenever its content changes.
                    key: ValueKey('col_${i}_${_selected.take(i).join("/")}'),
                    options: _columns[i],
                    selectedVal: i < _selected.length ? _selected[i] : null,
                    onPick: _pick,
                    tokens: t,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AdmTokens t, {Widget? closeWidget, Widget? acceptWidget}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: t.spaceMd, vertical: t.spaceXs),
      child: Row(
        children: [
          _HeaderButton(
            label: closeWidget ?? const Icon(Icons.close),
            color: t.colorTextSecondary,
            fontSize: t.fontSizeMd,
            onTap: _cancel,
          ),
          Expanded(
            child: Center(
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: t.fontSizeLg,
                  fontWeight: t.fontWeightBold,
                  color: t.colorTextBase,
                ),
                child: widget.title ?? const Text('Select'),
              ),
            ),
          ),
          _HeaderButton(
            label: acceptWidget ?? const Icon(AdmIcons.check),
            color: t.colorPrimary,
            fontWeight: t.fontWeightMedium,
            fontSize: t.fontSizeMd,
            onTap: _confirm,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(AdmTokens t) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: t.spaceSm),
      child: Row(
        children: List.generate(_columns.length, (i) {
          final isActive = i == _activeLevel;
          final hasSelection = i < _selected.length && _selected[i] != null;
          return _CascaderTab(
            label: _tabLabel(i),
            isActive: isActive,
            hasSelection: hasSelection,
            onTap: () => _goToTab(i),
            tokens: t,
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CascaderTab — animated navigation tab
// ─────────────────────────────────────────────────────────────────────────────

class _CascaderTab extends StatefulWidget {
  final String label;
  final bool isActive;
  final bool hasSelection;
  final VoidCallback onTap;
  final AdmTokens tokens;

  const _CascaderTab({
    required this.label,
    required this.isActive,
    required this.hasSelection,
    required this.onTap,
    required this.tokens,
  });

  @override
  State<_CascaderTab> createState() => _CascaderTabState();
}

class _CascaderTabState extends State<_CascaderTab> with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      onTap: widget.onTap,
      child: FadeTransition(
        opacity: _pressAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: t.spaceLg,
            vertical: t.spaceMd,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.isActive ? t.colorPrimary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            style: TextStyle(
              fontSize: t.fontSizeMd,
              color: widget.isActive
                  ? t.colorPrimary
                  : widget.hasSelection
                      ? t.colorTextBase
                      : t.colorTextTertiary,
              fontWeight: widget.isActive ? t.fontWeightMedium : FontWeight.normal,
            ),
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CascaderColumn — single level list; auto-scrolls to selected item
// ─────────────────────────────────────────────────────────────────────────────

class _CascaderColumn extends StatefulWidget {
  final List<AdmCascaderOption> options;
  final String? selectedVal;
  final void Function(String) onPick;
  final AdmTokens tokens;

  const _CascaderColumn({
    required super.key,
    required this.options,
    required this.selectedVal,
    required this.onPick,
    required this.tokens,
  });

  @override
  State<_CascaderColumn> createState() => _CascaderColumnState();
}

class _CascaderColumnState extends State<_CascaderColumn> {
  final _scrollCtrl = ScrollController();

  static const _kItemHeight = 44.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  void _scrollToSelected() {
    if (widget.selectedVal == null || !_scrollCtrl.hasClients) return;
    final idx = widget.options.indexWhere((o) => o.value == widget.selectedVal);
    if (idx < 0) return;
    final maxExtent = _scrollCtrl.position.maxScrollExtent;
    if (maxExtent <= 0) return;
    final viewport = _scrollCtrl.position.viewportDimension;
    final target = (idx * _kItemHeight - viewport / 2 + _kItemHeight / 2).clamp(0.0, maxExtent);
    _scrollCtrl.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    return ListView.builder(
      controller: _scrollCtrl,
      itemCount: widget.options.length,
      padding: EdgeInsets.symmetric(vertical: t.spaceXs),
      itemBuilder: (_, i) {
        final opt = widget.options[i];
        final isSelected = opt.value == widget.selectedVal;
        final hasChildren = opt.children != null && opt.children!.isNotEmpty;
        return _CascaderItem(
          option: opt,
          isSelected: isSelected,
          hasChildren: hasChildren,
          onTap: opt.disabled ? null : () => widget.onPick(opt.value),
          tokens: t,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CascaderItem — individual option row with full animation suite
// ─────────────────────────────────────────────────────────────────────────────

class _CascaderItem extends StatelessWidget {
  final AdmCascaderOption option;
  final bool isSelected;
  final bool hasChildren;
  final VoidCallback? onTap;
  final AdmTokens tokens;

  const _CascaderItem({
    required this.option,
    required this.isSelected,
    required this.hasChildren,
    this.onTap,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final t = tokens;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      color: isSelected ? t.colorPrimary.withValues(alpha: 0.07) : Colors.transparent,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: t.colorPrimary.withValues(alpha: 0.14),
          highlightColor: t.colorPrimary.withValues(alpha: 0.06),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: t.spaceLg,
              vertical: t.spaceSm + 2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    style: TextStyle(
                      fontSize: t.fontSizeMd,
                      color: option.disabled
                          ? t.colorTextDisabled
                          : isSelected
                              ? t.colorPrimary
                              : t.colorTextBase,
                      fontWeight: isSelected ? t.fontWeightMedium : t.fontWeightNormal,
                    ),
                    child: Text(option.label),
                  ),
                ),
                const SizedBox(width: 4),
                // Check icon — elastic bounce in on selection
                AnimatedScale(
                  scale: isSelected ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 300),
                  curve: isSelected ? Curves.elasticOut : Curves.easeIn,
                  child: AnimatedOpacity(
                    opacity: isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: t.colorPrimary,
                    ),
                  ),
                ),
                // Chevron — fades out when selected (check takes its place)
                if (hasChildren) ...[
                  const SizedBox(width: 2),
                  AnimatedOpacity(
                    opacity: isSelected ? 0.0 : 0.45,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: t.colorTextTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DragHandle
// ─────────────────────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  final AdmTokens tokens;
  const _DragHandle({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: tokens.spaceMd,
        bottom: tokens.spaceXs,
      ),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: tokens.colorBorder,
            borderRadius: BorderRadius.circular(tokens.radiusPill),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HeaderButton
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderButton extends StatefulWidget {
  final Widget label;
  final Color color;
  final double fontSize;
  final FontWeight? fontWeight;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.label,
    required this.color,
    required this.fontSize,
    required this.onTap,
    this.fontWeight,
  });

  @override
  State<_HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<_HeaderButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedOpacity(
        opacity: _pressed ? 0.45 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: widget.label,
        ),
      ),
    );
  }
}
