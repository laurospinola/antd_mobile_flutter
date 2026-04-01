import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

enum AdmToastType { success, fail, error, warning, loading, info }

class _AdmMessageData {
  static int _nextId = 0;
  final int id = _nextId++;
  final String content;
  final AdmToastType type;

  _AdmMessageData({required this.content, required this.type});
}

/// [AdmToast] — Ant Design-style top-center message notifications.
///
/// Appears at the top-center of the screen, stacks up to 3 messages,
/// and auto-dismisses after [duration].
///
/// ```dart
/// AdmToast.show(context, content: 'Saved!', type: AdmToastType.success);
/// AdmToast.show(context, content: 'Warning!', type: AdmToastType.warning);
/// AdmToast.show(context, content: 'Loading…', type: AdmToastType.loading);
/// AdmToast.hide(context); // clear all
/// ```
class AdmToast {
  static final _hostKey = GlobalKey<_AdmMessageHostState>();
  static OverlayEntry? _entry;
  static const _maxCount = 3;

  static void show(
    BuildContext context, {
    required String content,
    AdmToastType type = AdmToastType.info,
    Duration duration = const Duration(milliseconds: 3000),
    bool maskClosable = false, // kept for API compatibility
  }) {
    if (_entry == null) {
      _entry = OverlayEntry(
        builder: (_) => _AdmMessageHost(key: _hostKey),
      );
      Overlay.of(context).insert(_entry!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = _hostKey.currentState;
      if (state == null) return;
      final msg = _AdmMessageData(content: content, type: type);
      state.add(msg);
      if (type != AdmToastType.loading) {
        Future.delayed(duration, () => state.remove(msg.id));
      }
    });
  }

  static void hide(BuildContext context) {
    _hostKey.currentState?.clear();
  }
}

// ── Host Widget ──────────────────────────────────────────────────────────────

class _AdmMessageHost extends StatefulWidget {
  const _AdmMessageHost({super.key});

  @override
  State<_AdmMessageHost> createState() => _AdmMessageHostState();
}

class _AdmMessageHostState extends State<_AdmMessageHost> {
  final _messages = <_AdmMessageData>[];
  final _listKey = GlobalKey<AnimatedListState>();

  void add(_AdmMessageData msg) {
    while (_messages.length >= AdmToast._maxCount) {
      _removeAt(0);
    }
    _messages.add(msg);
    _listKey.currentState?.insertItem(
      _messages.length - 1,
      duration: const Duration(milliseconds: 300),
    );
  }

  void remove(int id) {
    final idx = _messages.indexWhere((m) => m.id == id);
    if (idx != -1) _removeAt(idx);
  }

  void _removeAt(int idx) {
    final msg = _messages.removeAt(idx);
    _listKey.currentState?.removeItem(
      idx,
      (ctx, anim) => _MessageItem(msg: msg, animation: anim),
      duration: const Duration(milliseconds: 200),
    );
  }

  void clear() {
    for (int i = _messages.length - 1; i >= 0; i--) {
      _removeAt(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.topCenter,
              child: AnimatedList(
                key: _listKey,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                initialItemCount: 0,
                itemBuilder: (ctx, idx, anim) =>
                    _MessageItem(msg: _messages[idx], animation: anim),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Message Item ─────────────────────────────────────────────────────────────

class _MessageItem extends StatelessWidget {
  final _AdmMessageData msg;
  final Animation<double> animation;

  const _MessageItem({required this.msg, required this.animation});

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    Color iconColor;
    IconData? iconData;
    switch (msg.type) {
      case AdmToastType.success:
        iconColor = tokens.colorSuccess;
        iconData = Icons.check_circle;
        break;
      case AdmToastType.fail:
      case AdmToastType.error:
        iconColor = tokens.colorDanger;
        iconData = Icons.cancel;
        break;
      case AdmToastType.warning:
        iconColor = tokens.colorWarning;
        iconData = Icons.warning_rounded;
        break;
      case AdmToastType.loading:
        iconColor = tokens.colorPrimary;
        iconData = null;
        break;
      case AdmToastType.info:
        iconColor = tokens.colorPrimary;
        iconData = Icons.info;
        break;
    }

    final slideAnim = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: tokens.colorBackground,
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Color(0x1E000000),
                    blurRadius: 6,
                    spreadRadius: -4,
                    offset: Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 28,
                    spreadRadius: 8,
                    offset: Offset(0, 9),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (msg.type == AdmToastType.loading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: iconColor,
                      ),
                    )
                  else
                    Icon(iconData, color: iconColor, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      msg.content,
                      style: TextStyle(
                        color: tokens.colorTextBase,
                        fontSize: tokens.fontSizeMd,
                        fontWeight: tokens.fontWeightNormal,
                        decoration: TextDecoration.none,
                      ),
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
