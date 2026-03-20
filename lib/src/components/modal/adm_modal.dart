import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

/// An action button definition for [AdmModal].
class AdmModalAction {
  final Widget key;
  final VoidCallback? onPress;
  final bool primary;
  final bool danger;
  final bool disabled;
  final bool bold;

  const AdmModalAction({
    required this.key,
    this.onPress,
    this.primary = false,
    this.danger = false,
    this.disabled = false,
    this.bold = false,
  });
}

/// [AdmModal] — equivalent to ant-design-mobile's `<Modal>` / `<Dialog>`.
///
/// Static helpers mirror the JS API:
/// ```dart
/// // Simple alert
/// AdmModal.alert(
///   context,
///   title: const Text('Notice'),
///   content: const Text('Are you sure?'),
///   onConfirm: () => print('confirmed'),
/// );
///
/// // Confirm dialog
/// final confirmed = await AdmModal.confirm(
///   context,
///   title: const Text('Delete'),
///   content: const Text('This cannot be undone.'),
/// );
///
/// // Custom
/// AdmModal.show(
///   context,
///   title: const Text('Custom'),
///   content: myWidget,
///   actions: [...],
/// );
/// ```
class AdmModal {
  // ── Static show helpers ──────────────────────────────────────────────────

  static Future<void> alert(
    BuildContext context, {
    Widget? title,
    Widget? content,
    String confirmText = 'OK',
    VoidCallback? onConfirm,
    bool closeOnMaskClick = false,
  }) {
    return show(
      context,
      title: title,
      content: content,
      closeOnMaskClick: closeOnMaskClick,
      actions: [
        AdmModalAction(
          key: Text(confirmText),
          primary: true,
          onPress: () {
            Navigator.of(context, rootNavigator: true).pop();
            onConfirm?.call();
          },
        ),
      ],
    );
  }

  static Future<bool> confirm(
    BuildContext context, {
    Widget? title,
    Widget? content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool closeOnMaskClick = false,
  }) async {
    bool result = false;
    await show(
      context,
      title: title,
      content: content,
      closeOnMaskClick: closeOnMaskClick,
      actions: [
        AdmModalAction(
          key: Text(cancelText),
          onPress: () => Navigator.of(context, rootNavigator: true).pop(false),
        ),
        AdmModalAction(
          key: Text(confirmText),
          primary: true,
          onPress: () {
            result = true;
            Navigator.of(context, rootNavigator: true).pop(true);
          },
        ),
      ],
    );
    return result;
  }

  static Future<void> show(
    BuildContext context, {
    Widget? title,
    Widget? content,
    List<AdmModalAction> actions = const [],
    bool closeOnMaskClick = false,
    bool showCloseButton = false,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: closeOnMaskClick,
      builder: (ctx) => _AdmModalWidget(
        title: title,
        content: content,
        actions: actions,
        showCloseButton: showCloseButton,
      ),
    );
  }
}

class _AdmModalWidget extends StatelessWidget {
  final Widget? title;
  final Widget? content;
  final List<AdmModalAction> actions;
  final bool showCloseButton;

  const _AdmModalWidget({
    this.title,
    this.content,
    required this.actions,
    this.showCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusXl),
      ),
      backgroundColor: tokens.colorBackground,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.spaceXl,
              tokens.spaceXl,
              tokens.spaceXl,
              content != null ? tokens.spaceSm : tokens.spaceXl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: tokens.fontSizeLg,
                      fontWeight: tokens.fontWeightBold,
                      color: tokens.colorTextBase,
                    ),
                    textAlign: TextAlign.center,
                    child: title!,
                  ),
                if (content != null) ...[
                  SizedBox(height: tokens.spaceMd),
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: tokens.fontSizeMd,
                      color: tokens.colorTextSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    child: content!,
                  ),
                ],
              ],
            ),
          ),
          // Actions
          if (actions.isNotEmpty) ...[
            Divider(height: 1, thickness: 0.5, color: tokens.colorBorder),
            if (actions.length <= 2)
              _HorizontalActions(actions: actions, tokens: tokens)
            else
              _VerticalActions(actions: actions, tokens: tokens),
          ],
        ],
      ),
    );
  }
}

class _HorizontalActions extends StatelessWidget {
  final List<AdmModalAction> actions;
  final dynamic tokens;

  const _HorizontalActions(
      {required this.actions, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: List.generate(actions.length, (i) {
          final action = actions[i];
          return Expanded(
            child: Row(
              children: [
                Expanded(child: _ActionButton(action: action, tokens: tokens)),
                if (i < actions.length - 1)
                  Container(
                    width: 0.5,
                    color: tokens.colorBorder,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _VerticalActions extends StatelessWidget {
  final List<AdmModalAction> actions;
  final dynamic tokens;

  const _VerticalActions(
      {required this.actions, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(actions.length, (i) {
        return Column(
          children: [
            _ActionButton(action: actions[i], tokens: tokens),
            if (i < actions.length - 1)
              Divider(height: 0.5, thickness: 0.5, color: tokens.colorBorder),
          ],
        );
      }),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final AdmModalAction action;
  final dynamic tokens;

  const _ActionButton({required this.action, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.disabled ? null : action.onPress,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: tokens.fontSizeLg,
            color: action.danger
                ? tokens.colorDanger
                : action.primary
                    ? tokens.colorPrimary
                    : tokens.colorTextBase,
            fontWeight: action.bold || action.primary
                ? tokens.fontWeightMedium
                : tokens.fontWeightNormal,
          ),
          child: action.key,
        ),
      ),
    );
  }
}
