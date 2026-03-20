import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdmLoading
// ─────────────────────────────────────────────────────────────────────────────

/// [AdmLoading] — equivalent to ant-design-mobile's `<SpinLoading>` / `<DotLoading>`.
///
/// ```dart
/// AdmLoading()             // spinning circle
/// AdmLoading.dots()        // three bouncing dots
/// ```
class AdmLoading extends StatelessWidget {
  final Color? color;
  final double size;

  const AdmLoading({super.key, this.color, this.size = 32});

  factory AdmLoading.dots({Color? color, double size = 8}) =>
      _DotLoading(color: color, dotSize: size);

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor:
            AlwaysStoppedAnimation(color ?? tokens.colorPrimary),
      ),
    );
  }
}

class _DotLoading extends AdmLoading {
  final double dotSize;
  const _DotLoading({super.color, required this.dotSize}) : super(size: dotSize);

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final c = color ?? tokens.colorPrimary;
    return _BouncingDots(color: c, dotSize: dotSize);
  }
}

class _BouncingDots extends StatefulWidget {
  final Color color;
  final double dotSize;
  const _BouncingDots({required this.color, required this.dotSize});

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _animations = _controllers
        .map((c) =>
            Tween(begin: 0.0, end: -widget.dotSize)
                .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (_, child) => Transform.translate(
            offset: Offset(0, _animations[i].value),
            child: child,
          ),
          child: Container(
            width: widget.dotSize,
            height: widget.dotSize,
            margin: EdgeInsets.symmetric(horizontal: widget.dotSize * 0.3),
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
