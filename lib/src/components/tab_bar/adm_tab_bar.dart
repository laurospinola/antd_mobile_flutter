import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

/// Model for a single bottom tab.
class AdmTabBarItem {
  final Widget icon;
  final Widget? activeIcon;
  final Widget title;
  final String? badge;
  final bool dot;

  const AdmTabBarItem({
    required this.icon,
    this.activeIcon,
    required this.title,
    this.badge,
    this.dot = false,
  });
}

/// [AdmTabBar] — bottom navigation bar, equivalent to ant-design-mobile `<TabBar>`.
///
/// ```dart
/// AdmTabBar(
///   items: const [
///     AdmTabBarItem(icon: Icon(Icons.home_outlined), title: Text('Home')),
///     AdmTabBarItem(icon: Icon(Icons.search_outlined), title: Text('Search')),
///   ],
///   activeIndex: _activeIndex,
///   onChange: (i) => setState(() => _activeIndex = i),
/// )
/// ```
class AdmTabBar extends StatelessWidget {
  final List<AdmTabBarItem> items;
  final int activeIndex;
  final ValueChanged<int>? onChange;
  final bool safeArea;

  const AdmTabBar({
    super.key,
    required this.items,
    required this.activeIndex,
    this.onChange,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    Widget bar = Container(
      height: tokens.tabBarHeight,
      color: tokens.tabBarBackground,
      child: Row(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isActive = i == activeIndex;
          final color = isActive
              ? tokens.tabBarActiveColor
              : tokens.tabBarInactiveColor;

          Widget iconWidget = isActive && item.activeIcon != null
              ? item.activeIcon!
              : item.icon;

          // Apply color to icon
          iconWidget = IconTheme(
            data: IconThemeData(color: color, size: 22),
            child: iconWidget,
          );

          // Badge / dot overlay
          if (item.dot || item.badge != null) {
            iconWidget = Stack(
              clipBehavior: Clip.none,
              children: [
                iconWidget,
                Positioned(
                  right: -4,
                  top: -4,
                  child: item.dot
                      ? Container(
                          width: 8,
                          height: 8,
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
                          child: Text(
                            item.badge!,
                            style: TextStyle(
                              color: tokens.colorTextWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ],
            );
          }

          return Expanded(
            child: GestureDetector(
              onTap: () => onChange?.call(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconWidget,
                  const SizedBox(height: 2),
                  DefaultTextStyle(
                    style: TextStyle(
                      color: color,
                      fontSize: tokens.tabBarFontSize,
                    ),
                    child: item.title,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );

    if (safeArea) {
      bar = SafeArea(top: false, child: bar);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, thickness: 0.5, color: tokens.colorBorder),
        bar,
      ],
    );
  }
}
