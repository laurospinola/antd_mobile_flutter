import 'package:flutter/material.dart';

import '../../theme/adm_theme.dart';
import '../badge/adm_badge.dart';

class AdmTabItem {
  final Widget title;
  final Widget? badge;
  final bool dot;
  final bool disabled;

  /// Background color of this tab cell. Defaults to [Colors.transparent].
  final Color? backgroundColor;

  const AdmTabItem({
    required this.title,
    this.badge,
    this.dot = false,
    this.disabled = false,
    this.backgroundColor,
  });
}

/// [AdmTabs] — equivalent to ant-design-mobile's `<Tabs>`.
///
/// Horizontal tab bar with animated indicator, scrollable overflow, and
/// swipe-to-switch support via [children] + [TabBarView].
///
/// ```dart
/// AdmTabs(
///   tabs: const [
///     AdmTabItem(title: Text('Fruit')),
///     AdmTabItem(title: Text('Vegetables'), badge: Text('5')),
///     AdmTabItem(title: Text('Meat'), dot: true),
///   ],
///   activeIndex: _index,
///   onChange: (i) => setState(() => _index = i),
///   children: const [Text('Fruit content'), Text('Veg content'), Text('Meat content')],
/// )
/// ```
class AdmTabs extends StatefulWidget {
  final List<AdmTabItem> tabs;
  final int activeIndex;
  final ValueChanged<int>? onChange;

  /// Rendered below the tab bar in a [TabBarView] for swipe-to-switch.
  /// Must have the same length as [tabs].
  final List<Widget> children;

  /// Fixed height of the [TabBarView] area. When `null`, the tab view expands
  /// to fill available space (requires a bounded parent).
  final double? tabViewHeight;

  final bool scrollable;
  final double? tabWidth;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? indicatorColor;
  final double indicatorHeight;

  /// Background color of the tab bar strip. Defaults to [Colors.transparent].
  final Color? backgroundColor;

  const AdmTabs({
    super.key,
    required this.tabs,
    required this.activeIndex,
    this.onChange,
    required this.children,
    this.tabViewHeight,
    this.scrollable = false,
    this.tabWidth,
    this.activeColor,
    this.inactiveColor,
    this.indicatorColor,
    this.indicatorHeight = 2.0,
    this.backgroundColor,
  }) : assert(
          children.length == tabs.length,
          'children length must match tabs length',
        );

  @override
  State<AdmTabs> createState() => _AdmTabsState();
}

class _AdmTabsState extends State<AdmTabs> with SingleTickerProviderStateMixin {
  late TabController _controller;

  // Tracks the last index we reported via onChange to avoid double-firing
  // when both onTap and the controller listener would trigger.
  int _lastReportedIndex = -1;

  @override
  void initState() {
    super.initState();
    _lastReportedIndex = widget.activeIndex;
    _controller = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.activeIndex,
    );
    _controller.addListener(_onControllerChange);
  }

  /// Fires when the controller settles on a new index (covers swipe gestures).
  void _onControllerChange() {
    if (_controller.indexIsChanging) return;
    final newIndex = _controller.index;
    if (newIndex == _lastReportedIndex) return;
    if (widget.tabs[newIndex].disabled) {
      // Revert swipe to a disabled tab.
      _controller.animateTo(_lastReportedIndex);
      return;
    }
    _lastReportedIndex = newIndex;
    widget.onChange?.call(newIndex);
  }

  @override
  void didUpdateWidget(AdmTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndex != widget.activeIndex && widget.activeIndex != _controller.index) {
      _lastReportedIndex = widget.activeIndex;
      _controller.animateTo(widget.activeIndex);
    }
    if (oldWidget.tabs.length != widget.tabs.length) {
      _controller.removeListener(_onControllerChange);
      _controller.dispose();
      _lastReportedIndex = widget.activeIndex;
      _controller = TabController(
        length: widget.tabs.length,
        vsync: this,
        initialIndex: widget.activeIndex,
      );
      _controller.addListener(_onControllerChange);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final activeColor = widget.activeColor ?? tokens.colorPrimary;
    final inactiveColor = widget.inactiveColor ?? tokens.colorTextSecondary;
    final indicatorColor = widget.indicatorColor ?? tokens.colorPrimary;

    final tabBar = ColoredBox(
      color: widget.backgroundColor ?? Colors.transparent,
      child: TabBar(
        controller: _controller,
        isScrollable: widget.scrollable || widget.tabs.length > 4,
        labelColor: activeColor,
        unselectedLabelColor: inactiveColor,
        labelStyle: TextStyle(
          fontSize: tokens.fontSizeMd,
          fontWeight: tokens.fontWeightMedium,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: tokens.fontSizeMd,
          fontWeight: tokens.fontWeightNormal,
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: indicatorColor,
            width: widget.indicatorHeight,
          ),
          insets: const EdgeInsets.symmetric(horizontal: 12),
        ),
        dividerColor: tokens.colorBorder,
        tabAlignment: widget.scrollable || widget.tabs.length > 4 ? TabAlignment.start : TabAlignment.fill,
        onTap: (i) {
          if (widget.tabs[i].disabled) {
            // Revert to the current valid index.
            _controller.animateTo(_lastReportedIndex);
            return;
          }
          // Report immediately on tap; suppress the subsequent listener fire.
          _lastReportedIndex = i;
          widget.onChange?.call(i);
        },
        tabs: widget.tabs.map(_buildTab).toList(),
      ),
    );

    final tabView = TabBarView(
      controller: _controller,
      children: widget.children,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tabBar,
        widget.tabViewHeight != null
            ? SizedBox(height: widget.tabViewHeight, child: tabView)
            : Expanded(child: tabView),
      ],
    );
  }

  Widget _buildTab(AdmTabItem tab) {
    Widget content = tab.title;
    if (tab.dot) {
      content = AdmBadge(content: AdmBadge.dot, child: _padForBadge(content));
    } else if (tab.badge != null) {
      content = AdmBadge(content: tab.badge, child: _padForBadge(content));
    }
    if (tab.backgroundColor != null) {
      content = Container(
        color: tab.backgroundColor,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: content,
      );
    }
    return Tab(child: content);
  }

  /// Adds trailing padding so the overlaid badge doesn't clip past the Tab's
  /// hit area or get cropped by neighbors.
  Widget _padForBadge(Widget child) => Padding(
        padding: const EdgeInsets.only(right: 6, top: 2),
        child: child,
      );
}
