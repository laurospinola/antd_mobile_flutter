import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

/// [AdmNavBar] — the Flutter equivalent of ant-design-mobile's `<NavBar>`.
///
/// ```dart
/// AdmNavBar(
///   title: const Text('Page Title'),
///   back: const Text('Back'),
///   onBack: () => Navigator.pop(context),
///   right: const Icon(Icons.more_horiz),
/// )
/// ```
class AdmNavBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? back;
  final VoidCallback? onBack;
  final Widget? right;
  final Widget? left;
  final Color? backgroundColor;

  const AdmNavBar({
    super.key,
    this.title,
    this.back,
    this.onBack,
    this.right,
    this.left,
    this.backgroundColor,
  });

  @override
  Size get preferredSize {
    // We can't access tokens here reliably, so use a reasonable default.
    return const Size.fromHeight(45.0);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final bgColor = backgroundColor ?? tokens.navBarBackground;

    final backWidget = onBack != null || back != null
        ? GestureDetector(
            onTap: onBack ?? () => Navigator.maybePop(context),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
              child: back ??
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: tokens.colorPrimary,
                      ),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: tokens.colorPrimary,
                          fontSize: tokens.fontSizeMd,
                        ),
                      ),
                    ],
                  ),
            ),
          )
        : null;

    return Container(
      color: bgColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: tokens.navBarHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Left — back button or custom left
              Positioned(
                left: 0,
                child: left ?? backWidget ?? const SizedBox.shrink(),
              ),
              // Center — title
              if (title != null)
                Center(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontSize: tokens.navBarFontSize,
                      fontWeight: tokens.navBarFontWeight,
                      color: tokens.navBarTextColor,
                    ),
                    child: title!,
                  ),
                ),
              // Right
              if (right != null)
                Positioned(
                  right: tokens.spaceLg,
                  child: right!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
