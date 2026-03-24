import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

enum AdmToastType { success, fail, loading, info }

/// [AdmToast] — equivalent to ant-design-mobile's `<Toast>`.
///
/// Shows a lightweight, auto-dismissing overlay message.
///
/// ```dart
/// // Show helpers
/// AdmToast.show(context, content: 'Saved!');
/// AdmToast.show(context, content: 'Error!', type: AdmToastType.fail);
/// AdmToast.show(context, content: 'Loading', type: AdmToastType.loading);
///
/// // Dismiss manually
/// AdmToast.hide(context);
/// ```
class AdmToast {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String content,
    AdmToastType type = AdmToastType.info,
    Duration duration = const Duration(milliseconds: 2000),
    bool maskClosable = false,
  }) {
    hide(context);

    final overlay = Overlay.of(context);
    _currentEntry = OverlayEntry(
      builder: (ctx) => _AdmToastWidget(
        content: content,
        type: type,
        maskClosable: maskClosable,
        onDismiss: () => hide(context),
      ),
    );
    overlay.insert(_currentEntry!);

    if (type != AdmToastType.loading) {
      Future.delayed(duration, () {
        if (context.mounted) {
          hide(context);
        }
      });
    }
  }

  static void hide(BuildContext context) {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _AdmToastWidget extends StatefulWidget {
  final String content;
  final AdmToastType type;
  final bool maskClosable;
  final VoidCallback onDismiss;

  const _AdmToastWidget({
    required this.content,
    required this.type,
    required this.maskClosable,
    required this.onDismiss,
  });

  @override
  State<_AdmToastWidget> createState() => _AdmToastWidgetState();
}

class _AdmToastWidgetState extends State<_AdmToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    Widget? icon;
    switch (widget.type) {
      case AdmToastType.success:
        icon = Icon(Icons.check_circle_outline,
            color: tokens.colorTextWhite, size: 36);
        break;
      case AdmToastType.fail:
        icon =
            Icon(Icons.cancel_outlined, color: tokens.colorTextWhite, size: 36);
        break;
      case AdmToastType.loading:
        icon = SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(tokens.colorTextWhite),
          ),
        );
        break;
      case AdmToastType.info:
        icon = null;
    }

    final hasIcon = icon != null;

    return GestureDetector(
      onTap: widget.maskClosable ? widget.onDismiss : null,
      behavior: HitTestBehavior.translucent,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: Container(
              constraints: BoxConstraints(maxWidth: hasIcon ? 120 : 200),
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spaceLg,
                vertical: tokens.spaceMd,
              ),
              decoration: BoxDecoration(
                color: const Color(0xCC1A1A1A),
                borderRadius: BorderRadius.circular(tokens.radiusLg),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon,
                    SizedBox(height: tokens.spaceSm),
                  ],
                  Text(
                    widget.content,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tokens.colorTextWhite,
                      fontSize: tokens.fontSizeMd,
                      fontWeight: tokens.fontWeightNormal,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
