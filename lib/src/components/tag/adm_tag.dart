import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

enum AdmTagColor { primary, success, warning, danger, defaultColor }
enum AdmTagFill { solid, outline }

/// [AdmTag] — equivalent to ant-design-mobile's `<Tag>`.
///
/// ```dart
/// AdmTag(child: const Text('New'))
/// AdmTag(color: AdmTagColor.success, child: const Text('Active'))
/// AdmTag(fill: AdmTagFill.outline, child: const Text('Label'))
/// AdmTag(closeable: true, onClose: () {}, child: const Text('Removable'))
/// ```
class AdmTag extends StatelessWidget {
  final Widget child;
  final AdmTagColor color;
  final AdmTagFill fill;
  final bool round;
  final bool closeable;
  final VoidCallback? onClose;
  final VoidCallback? onTap;

  const AdmTag({
    super.key,
    required this.child,
    this.color = AdmTagColor.defaultColor,
    this.fill = AdmTagFill.solid,
    this.round = false,
    this.closeable = false,
    this.onClose,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    final bgColor = _resolveBg(tokens);
    final fgColor = _resolveFg(tokens);
    final borderColor = _resolveBorder(tokens);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: fill == AdmTagFill.outline ? Colors.transparent : bgColor,
          borderRadius: BorderRadius.circular(
              round ? 999 : tokens.radiusSm),
          border: Border.all(
            color: borderColor,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DefaultTextStyle(
              style: TextStyle(
                fontSize: tokens.fontSizeSm,
                color: fgColor,
                height: 1.4,
              ),
              child: child,
            ),
            if (closeable) ...[
              const SizedBox(width: 2),
              GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close, size: 12, color: fgColor),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _resolveBg(t) => switch (color) {
        AdmTagColor.primary => t.colorPrimary.withOpacity(0.1),
        AdmTagColor.success => t.colorSuccess.withOpacity(0.1),
        AdmTagColor.warning => t.colorWarning.withOpacity(0.1),
        AdmTagColor.danger => t.colorDanger.withOpacity(0.1),
        AdmTagColor.defaultColor => t.colorFill,
      };

  Color _resolveFg(t) => switch (color) {
        AdmTagColor.primary => t.colorPrimary,
        AdmTagColor.success => t.colorSuccess,
        AdmTagColor.warning => t.colorWarning,
        AdmTagColor.danger => t.colorDanger,
        AdmTagColor.defaultColor => t.colorTextBase,
      };

  Color _resolveBorder(t) => switch (color) {
        AdmTagColor.primary => t.colorPrimary.withOpacity(0.3),
        AdmTagColor.success => t.colorSuccess.withOpacity(0.3),
        AdmTagColor.warning => t.colorWarning.withOpacity(0.3),
        AdmTagColor.danger => t.colorDanger.withOpacity(0.3),
        AdmTagColor.defaultColor => t.colorBorder,
      };
}
