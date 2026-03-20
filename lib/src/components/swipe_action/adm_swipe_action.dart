import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

class AdmSwipeActionButton {
  final Widget text;
  final Color? color;
  final VoidCallback? onPress;

  const AdmSwipeActionButton({
    required this.text,
    this.color,
    this.onPress,
  });
}

/// [AdmSwipeAction] — equivalent to ant-design-mobile's `<SwipeAction>`.
///
/// Wraps any widget with swipeable action buttons revealed on drag.
///
/// ```dart
/// AdmSwipeAction(
///   rightActions: [
///     AdmSwipeActionButton(
///       text: const Text('Delete'),
///       color: Colors.red,
///       onPress: () => deleteItem(),
///     ),
///   ],
///   child: AdmListItem(title: const Text('Swipe me left')),
/// )
/// ```
class AdmSwipeAction extends StatefulWidget {
  final Widget child;
  final List<AdmSwipeActionButton> leftActions;
  final List<AdmSwipeActionButton> rightActions;
  final double actionWidth;

  const AdmSwipeAction({
    super.key,
    required this.child,
    this.leftActions = const [],
    this.rightActions = const [],
    this.actionWidth = 80,
  });

  @override
  State<AdmSwipeAction> createState() => _AdmSwipeActionState();
}

class _AdmSwipeActionState extends State<AdmSwipeAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  double _dragX = 0;
  double _startX = 0;
  bool _dragging = false;

  double get _maxRight =>
      widget.rightActions.length * widget.actionWidth;
  double get _maxLeft =>
      widget.leftActions.length * widget.actionWidth;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails d) {
    _startX = _dragX;
    _dragging = true;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!_dragging) return;
    setState(() {
      _dragX = (_startX + d.localPosition.dx - d.globalPosition.dx + _startX)
          .clamp(-_maxRight, _maxLeft);
      _dragX = (_dragX + d.delta.dx).clamp(-_maxRight, _maxLeft);
    });
  }

  void _onPanEnd(DragEndDetails d) {
    _dragging = false;
    final threshold = widget.actionWidth * 0.4;
    double target = 0;
    if (_dragX < -threshold && widget.rightActions.isNotEmpty) {
      target = -_maxRight;
    } else if (_dragX > threshold && widget.leftActions.isNotEmpty) {
      target = _maxLeft;
    }
    final from = _dragX;
    _ctrl.reset();
    _ctrl.forward().whenComplete(() {});
    final anim = Tween<double>(begin: from, end: target)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    anim.addListener(() => setState(() => _dragX = anim.value));
  }

  void _close() {
    final from = _dragX;
    _ctrl.reset();
    _ctrl.forward();
    final anim = Tween<double>(begin: from, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    anim.addListener(() => setState(() => _dragX = anim.value));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    return GestureDetector(
      onHorizontalDragStart: _onPanStart,
      onHorizontalDragUpdate: _onPanUpdate,
      onHorizontalDragEnd: _onPanEnd,
      child: Stack(
        children: [
          // Right actions (revealed on swipe left)
          if (widget.rightActions.isNotEmpty)
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: widget.rightActions.map((btn) {
                  return GestureDetector(
                    onTap: () {
                      _close();
                      btn.onPress?.call();
                    },
                    child: Container(
                      width: widget.actionWidth,
                      color: btn.color ?? tokens.colorDanger,
                      alignment: Alignment.center,
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: tokens.colorTextWhite,
                          fontSize: tokens.fontSizeSm,
                          fontWeight: tokens.fontWeightMedium,
                        ),
                        child: btn.text,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          // Left actions (revealed on swipe right)
          if (widget.leftActions.isNotEmpty)
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: widget.leftActions.map((btn) {
                  return GestureDetector(
                    onTap: () {
                      _close();
                      btn.onPress?.call();
                    },
                    child: Container(
                      width: widget.actionWidth,
                      color: btn.color ?? tokens.colorSuccess,
                      alignment: Alignment.center,
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: tokens.colorTextWhite,
                          fontSize: tokens.fontSizeSm,
                          fontWeight: tokens.fontWeightMedium,
                        ),
                        child: btn.text,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          // Main content, shifted
          Transform.translate(
            offset: Offset(_dragX, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
