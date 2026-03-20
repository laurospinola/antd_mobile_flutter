import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

enum AdmAvatarSize { xs, small, middle, large, xl }
enum AdmAvatarShape { circle, square }

/// [AdmAvatar] — equivalent to ant-design-mobile's `<Avatar>`.
///
/// ```dart
/// AdmAvatar(src: 'https://example.com/avatar.jpg')
/// AdmAvatar(text: 'AB')
/// AdmAvatar(icon: Icon(Icons.person))
/// ```
class AdmAvatar extends StatelessWidget {
  final String? src;
  final String? text;
  final Widget? icon;
  final AdmAvatarSize size;
  final AdmAvatarShape shape;
  final Color? backgroundColor;
  final Color? textColor;

  const AdmAvatar({
    super.key,
    this.src,
    this.text,
    this.icon,
    this.size = AdmAvatarSize.middle,
    this.shape = AdmAvatarShape.circle,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final dimension = _resolveSize(tokens);
    final radius = shape == AdmAvatarShape.circle
        ? dimension / 2
        : tokens.radiusSm;
    final bgColor = backgroundColor ?? tokens.colorPrimary;

    Widget content;
    if (src != null) {
      content = Image.network(
        src!,
        width: dimension,
        height: dimension,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(tokens, dimension, bgColor),
      );
    } else if (text != null) {
      content = _fallback(tokens, dimension, bgColor);
    } else if (icon != null) {
      content = Container(
        width: dimension,
        height: dimension,
        color: bgColor,
        child: Center(
          child: IconTheme(
            data: IconThemeData(
                color: textColor ?? tokens.colorTextWhite,
                size: dimension * 0.5),
            child: icon!,
          ),
        ),
      );
    } else {
      content = _fallback(tokens, dimension, bgColor);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: dimension, height: dimension, child: content),
    );
  }

  Widget _fallback(tokens, double dimension, Color bgColor) {
    return Container(
      width: dimension,
      height: dimension,
      color: bgColor,
      child: Center(
        child: Text(
          (text ?? '').isNotEmpty ? text![0].toUpperCase() : '?',
          style: TextStyle(
            color: textColor ?? tokens.colorTextWhite,
            fontSize: dimension * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  double _resolveSize(tokens) => switch (size) {
        AdmAvatarSize.xs => 24.0,
        AdmAvatarSize.small => 32.0,
        AdmAvatarSize.middle => 40.0,
        AdmAvatarSize.large => 48.0,
        AdmAvatarSize.xl => 64.0,
      };
}
