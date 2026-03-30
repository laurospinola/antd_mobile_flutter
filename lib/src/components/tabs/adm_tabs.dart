import 'package:flutter/material.dart';

import '../../theme/adm_theme.dart';

class AdmTabItem {
  final Widget title;
  final Widget? badge;
  final bool dot;
  final bool disabled;

  const AdmTabItem({
    required this.title,
    this.badge,
    this.dot = false,
    this.disabled = false,
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
///     AdmTabItem(title: Text('Vegetables')),
///     AdmTabItem(title: Text('Meat')),
///   ],
///   activeIndex: _index,
///   onChange: (i) => setState(() => _index = i),
///   children: const [Text('Fruit content'), Text('Veg content'), Text('Meat content')],
///   tabViewHeight: 200,
/// )
/// ```
class AdmTabs extends StatefulWidget {
  final List<AdmTabItem> tabs;
  final int activeIndex;
  final ValueChanged<int>? onChange;

  /// Legacy single-child below the tab bar (no swipe support).
  final Widget? child;

  /// When provided, renders a [TabBarView] enabling swipe-to-switch.
  /// Must have the same length as [tabs].
  final List<Widget>? children;

  /// Height of the [TabBarView] area. Required when [children] is set and the
  /// widget lives inside a scroll view. Defaults to 200.
  final double tabViewHeight;

  final bool scrollable;
  final double? tabWidth;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? indicatorColor;
  final double indicatorHeight;

  const AdmTabs({
    super.key,
    required this.tabs,
    required this.activeIndex,
    this.onChange,
    this.child,
    this.children,
    this.tabViewHeight = 200,
    this.scrollable = false,
    this.tabWidth,
    this.activeColor,
    this.inactiveColor,
    this.indicatorColor,
    this.indicatorHeight = 2.0,
  }) : assert(
          children == null || children.length == tabs.length,
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

    final tabBar = Container(
      color: tokens.colorBackground,
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
        tabs: widget.tabs.map((tab) {
          Widget label = tab.title;
          if (tab.dot || tab.badge != null) {
            label = Stack(
              clipBehavior: Clip.none,
              children: [
                tab.title,
                Positioned(
                  right: -8,
                  top: 0,
                  child: tab.dot
                      ? Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: tokens.colorDanger,
                            shape: BoxShape.circle,
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: tokens.colorDanger,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: DefaultTextStyle(
                            style: TextStyle(
                              color: tokens.colorTextWhite,
                              fontSize: 10,
                            ),
                            child: tab.badge!,
                          ),
                        ),
                ),
              ],
            );
          }
          return Tab(child: label);
        }).toList(),
      ),
    );

    // --- TabBarView (swipe) mode ---
    if (widget.children != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tabBar,
          TabBarView(
            controller: _controller,
            children: widget.children!,
          ),
        ],
      );
    }

    // --- Legacy single-child mode ---
    if (widget.child == null) return tabBar;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [tabBar, widget.child!],
    );
  }
}
