import 'package:flutter/material.dart';

import '../../theme/adm_theme.dart';
import '../../theme/adm_tokens.dart';

// ── Enums ──────────────────────────────────────────────────────────────────

/// Controls where the dropdown panel appears relative to the trigger.
enum AdmDropdownPlacement {
  bottomLeft,
  bottomCenter,
  bottomRight,
  topLeft,
  topCenter,
  topRight,
}

// ── Data Model ─────────────────────────────────────────────────────────────

/// A single action item in the dropdown menu.
class AdmDropdownItem {
  final String key;
  final String title;

  /// Optional subtitle rendered below [title].
  final String? brief;

  /// Optional leading icon.
  final Widget? icon;

  /// Renders title and icon in danger (red) color.
  final bool danger;
  final bool disabled;

  const AdmDropdownItem({
    required this.key,
    required this.title,
    this.brief,
    this.icon,
    this.danger = false,
    this.disabled = false,
  });
}

// ── AdmDropdown ────────────────────────────────────────────────────────────

/// Contextual action menu that wraps any trigger widget.
///
/// Unlike [AdmSelect], this is not a form input — it shows a list of
/// action items positioned relative to the trigger.
///
/// ```dart
/// AdmDropdown(
///   items: const [
///     AdmDropdownItem(key: 'edit',   title: 'Edit',   icon: Icon(Icons.edit_outlined)),
///     AdmDropdownItem(key: 'share',  title: 'Share',  icon: Icon(Icons.share_outlined)),
///     AdmDropdownItem(key: 'delete', title: 'Delete', icon: Icon(Icons.delete_outline), danger: true),
///   ],
///   onAction: (key) => print('tapped: $key'),
///   child: AdmButton(child: const Text('Options')),
/// )
/// ```
class AdmDropdown extends StatefulWidget {
  /// The widget that triggers the dropdown on tap.
  final Widget child;

  final List<AdmDropdownItem> items;

  /// Highlights the item with this key using primary color and a checkmark.
  final String? activeKey;

  /// Called with the tapped item's [AdmDropdownItem.key].
  final ValueChanged<String>? onAction;

  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  /// Automatically close the dropdown after an item is tapped (default true).
  final bool closeOnAction;

  /// Prevents opening the dropdown on tap.
  final bool disabled;

  final AdmDropdownPlacement placement;

  /// Explicit panel width. When null the panel matches the trigger width.
  final double? dropdownWidth;

  /// Maximum height of the scrollable item list.
  final double dropdownMaxHeight;

  const AdmDropdown({
    super.key,
    required this.child,
    required this.items,
    this.activeKey,
    this.onAction,
    this.onOpen,
    this.onClose,
    this.closeOnAction = true,
    this.disabled = false,
    this.placement = AdmDropdownPlacement.bottomLeft,
    this.dropdownWidth,
    this.dropdownMaxHeight = 320,
  });

  @override
  State<AdmDropdown> createState() => _AdmDropdownState();
}

class _AdmDropdownState extends State<AdmDropdown> {
  bool _isOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggle() {
    if (widget.disabled) return;
    _isOpen ? _close() : _open();
  }

  void _open() {
    final renderBox = context.findRenderObject() as RenderBox;
    final triggerWidth = renderBox.size.width;
    final tokens = AdmTheme.tokensOf(context);
    _overlayEntry = _buildOverlay(tokens, triggerWidth);
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    widget.onOpen?.call();
  }

  void _close() {
    _removeOverlay();
    if (mounted) setState(() => _isOpen = false);
    widget.onClose?.call();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleAction(String key) {
    widget.onAction?.call(key);
    if (widget.closeOnAction) _close();
  }

  ({Alignment target, Alignment follower}) get _anchors => switch (widget.placement) {
        AdmDropdownPlacement.bottomLeft => (target: Alignment.bottomLeft, follower: Alignment.topLeft),
        AdmDropdownPlacement.bottomCenter => (target: Alignment.bottomCenter, follower: Alignment.topCenter),
        AdmDropdownPlacement.bottomRight => (target: Alignment.bottomRight, follower: Alignment.topRight),
        AdmDropdownPlacement.topLeft => (target: Alignment.topLeft, follower: Alignment.bottomLeft),
        AdmDropdownPlacement.topCenter => (target: Alignment.topCenter, follower: Alignment.bottomCenter),
        AdmDropdownPlacement.topRight => (target: Alignment.topRight, follower: Alignment.bottomRight),
      };

  bool get _opensUpward => widget.placement.name.startsWith('top');

  OverlayEntry _buildOverlay(AdmTokens tokens, double triggerWidth) {
    final anchors = _anchors;
    return OverlayEntry(
      builder: (_) => _AdmDropdownPanel(
        layerLink: _layerLink,
        items: widget.items,
        activeKey: widget.activeKey,
        onAction: _handleAction,
        onClose: _close,
        tokens: tokens,
        targetAnchor: anchors.target,
        followerAnchor: anchors.follower,
        panelWidth: widget.dropdownWidth ?? triggerWidth,
        dropdownMaxHeight: widget.dropdownMaxHeight,
        opensUpward: _opensUpward,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.opaque,
        child: IgnorePointer(child: widget.child),
      ),
    );
  }
}

// ── _AdmDropdownPanel ──────────────────────────────────────────────────────

class _AdmDropdownPanel extends StatefulWidget {
  final LayerLink layerLink;
  final List<AdmDropdownItem> items;
  final String? activeKey;
  final ValueChanged<String> onAction;
  final VoidCallback onClose;
  final AdmTokens tokens;
  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final double panelWidth;
  final double dropdownMaxHeight;
  final bool opensUpward;

  const _AdmDropdownPanel({
    required this.layerLink,
    required this.items,
    this.activeKey,
    required this.onAction,
    required this.onClose,
    required this.tokens,
    required this.targetAnchor,
    required this.followerAnchor,
    required this.panelWidth,
    required this.dropdownMaxHeight,
    required this.opensUpward,
  });

  @override
  State<_AdmDropdownPanel> createState() => _AdmDropdownPanelState();
}

class _AdmDropdownPanelState extends State<_AdmDropdownPanel> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(  
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Widget _buildItem(AdmDropdownItem item, bool isLast) {
    final t = widget.tokens;
    final isActive = item.key == widget.activeKey;

    final textColor = item.disabled
        ? t.colorTextDisabled
        : item.danger
            ? t.colorDanger
            : isActive
                ? t.colorPrimary
                : t.colorTextBase;

    final iconColor = item.disabled
        ? t.colorTextDisabled
        : item.danger
            ? t.colorDanger
            : isActive
                ? t.colorPrimary
                : t.colorTextSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: item.disabled ? null : () => widget.onAction(item.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            color: isActive ? t.colorPrimary.withValues(alpha: 0.06) : Colors.transparent,
            padding: EdgeInsets.symmetric(
              horizontal: t.spaceLg,
              vertical: item.brief != null ? t.spaceMd : t.spaceMd,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (item.icon != null) ...[
                  IconTheme(
                    data: IconThemeData(size: 18, color: iconColor),
                    child: item.icon!,
                  ),
                  SizedBox(width: t.spaceMd),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: t.fontSizeMd,
                          color: textColor,
                          fontWeight: isActive ? t.fontWeightMedium : t.fontWeightNormal,
                        ),
                      ),
                      if (item.brief != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.brief!,
                          style: TextStyle(
                            fontSize: t.fontSizeSm,
                            color: item.disabled ? t.colorTextDisabled : t.colorTextTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isActive) ...[
                  SizedBox(width: t.spaceSm),
                  Icon(Icons.check_rounded, size: 16, color: t.colorPrimary),
                ],
              ],
            ),
          ),
        ),
        if (!isLast) Divider(height: 1, thickness: 0.5, color: t.colorBorder),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final scaleOrigin = widget.opensUpward ? Alignment.bottomCenter : Alignment.topCenter;

    return Stack(
      children: [
        // Tap-outside barrier
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            behavior: HitTestBehavior.translucent,
            child: const SizedBox.expand(),
          ),
        ),
        // Panel
        CompositedTransformFollower(
          link: widget.layerLink,
          targetAnchor: widget.targetAnchor,
          followerAnchor: widget.followerAnchor,
          offset: Offset(0, widget.opensUpward ? -4 : 4),
          child: SizedBox(
            width: widget.panelWidth,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                alignment: scaleOrigin,
                child: Material(
                  elevation: 6,
                  shadowColor: t.colorBoxShadow,
                  borderRadius: BorderRadius.circular(t.radiusMd),
                  color: t.colorBackground,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(t.radiusMd),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: widget.dropdownMaxHeight),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (int i = 0; i < widget.items.length; i++)
                              _buildItem(
                                widget.items[i],
                                i == widget.items.length - 1,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
