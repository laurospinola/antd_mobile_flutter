import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';
import '../skeleton/adm_skeleton.dart';

enum AdmImageFit {
  fill,
  contain,
  cover,
  fitWidth,
  fitHeight,
  none,
  scaleDown
}

/// [AdmImage] — equivalent to ant-design-mobile's `<Image>`.
///
/// Shows a placeholder skeleton while loading, and an error state on failure.
///
/// ```dart
/// AdmImage(
///   src: 'https://example.com/photo.jpg',
///   width: 120,
///   height: 80,
///   fit: AdmImageFit.cover,
///   radius: 8,
/// )
/// ```
class AdmImage extends StatelessWidget {
  final String src;
  final double? width;
  final double? height;
  final AdmImageFit fit;
  final double radius;
  final Widget? errorIcon;
  final Widget? placeholder;
  final BoxDecoration? decoration;

  const AdmImage({
    super.key,
    required this.src,
    this.width,
    this.height,
    this.fit = AdmImageFit.cover,
    this.radius = 0,
    this.errorIcon,
    this.placeholder,
    this.decoration,
  });

  BoxFit _toBoxFit() => switch (fit) {
        AdmImageFit.fill => BoxFit.fill,
        AdmImageFit.contain => BoxFit.contain,
        AdmImageFit.cover => BoxFit.cover,
        AdmImageFit.fitWidth => BoxFit.fitWidth,
        AdmImageFit.fitHeight => BoxFit.fitHeight,
        AdmImageFit.none => BoxFit.none,
        AdmImageFit.scaleDown => BoxFit.scaleDown,
      };

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final br = BorderRadius.circular(radius);

    return ClipRRect(
      borderRadius: br,
      child: Container(
        width: width,
        height: height,
        decoration: decoration,
        child: Image.network(
          src,
          width: width,
          height: height,
          fit: _toBoxFit(),
          loadingBuilder: (_, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return placeholder ??
                AdmSkeleton(
                  width: width ?? double.infinity,
                  height: height ?? 80,
                  animated: true,
                );
          },
          errorBuilder: (_, __, ___) {
            return Container(
              width: width,
              height: height ?? 80,
              color: tokens.colorFill,
              child: Center(
                child: errorIcon ??
                    Icon(
                      Icons.broken_image_outlined,
                      size: 28,
                      color: tokens.colorTextTertiary,
                    ),
              ),
            );
          },
        ),
      ),
    );
  }
}
