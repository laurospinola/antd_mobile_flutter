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
/// Horizontal tab bar with animated indicator and scrollable overflow.
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
///   child: IndexedStack(index: _index, children: [...]),
/// )
/// ```
class AdmTabs extends StatefulWidget {
  final List<AdmTabItem> tabs;
  final int activeIndex;
  final ValueChanged<int>? onChange;
  final Widget? child;
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
    this.scrollable = false,
    this.tabWidth,
    this.activeColor,
    this.inactiveColor,
    this.indicatorColor,
    this.indicatorHeight = 2.0,
  });

  @override
  State<AdmTabs> createState() => _AdmTabsState();
}

class _AdmTabsState extends State<AdmTabs>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.activeIndex,
    );
  }

  @override
  void didUpdateWidget(AdmTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndex != widget.activeIndex) {
      _controller.animateTo(widget.activeIndex);
    }
    if (oldWidget.tabs.length != widget.tabs.length) {
      _controller.dispose();
      _controller = TabController(
        length: widget.tabs.length,
        vsync: this,
        initialIndex: widget.activeIndex,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final activeColor = widget.activeColor ?? tokens.colorPrimary;
    final inactiveColor =
        widget.inactiveColor ?? tokens.colorTextSecondary;
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
        tabAlignment: widget.scrollable || widget.tabs.length > 4
            ? TabAlignment.start
            : TabAlignment.fill,
        onTap: (i) {
          if (!widget.tabs[i].disabled) {
            widget.onChange?.call(i);
          }
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
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

    if (widget.child == null) return tabBar;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [tabBar, widget.child!],
    );
  }
}
