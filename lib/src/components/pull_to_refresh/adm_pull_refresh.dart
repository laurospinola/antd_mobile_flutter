import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';
import '../loading/adm_loading.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdmPullToRefresh
// ─────────────────────────────────────────────────────────────────────────────

/// [AdmPullToRefresh] — equivalent to ant-design-mobile's `<PullToRefresh>`.
///
/// Wraps a scrollable child and triggers [onRefresh] when pulled down.
///
/// ```dart
/// AdmPullToRefresh(
///   onRefresh: () async {
///     await fetchData();
///   },
///   child: ListView(...),
/// )
/// ```
class AdmPullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String pullingText;
  final String releaseText;
  final String refreshingText;
  final String completeText;
  final Color? indicatorColor;

  const AdmPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.pullingText = 'Pull down to refresh',
    this.releaseText = 'Release to refresh',
    this.refreshingText = 'Loading...',
    this.completeText = 'Done',
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    final color = indicatorColor ?? tokens.colorPrimary;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color,
      backgroundColor: tokens.colorBackground,
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AdmInfiniteScroll
// ─────────────────────────────────────────────────────────────────────────────

enum _InfiniteScrollState { idle, loading, error, noMore }

/// [AdmInfiniteScroll] — equivalent to ant-design-mobile's `<InfiniteScroll>`.
///
/// A footer widget that auto-triggers [loadMore] when scrolled near the bottom.
///
/// ```dart
/// ListView.builder(
///   itemCount: items.length + 1,
///   itemBuilder: (ctx, i) {
///     if (i == items.length) {
///       return AdmInfiniteScroll(
///         hasMore: hasMore,
///         loadMore: () async => await fetchMore(),
///       );
///     }
///     return ListTile(title: Text(items[i]));
///   },
/// )
/// ```
class AdmInfiniteScroll extends StatefulWidget {
  final bool hasMore;
  final Future<void> Function() loadMore;
  final Widget? loadingWidget;
  final Widget? noMoreWidget;
  final Widget? errorWidget;
  final double threshold;

  const AdmInfiniteScroll({
    super.key,
    required this.hasMore,
    required this.loadMore,
    this.loadingWidget,
    this.noMoreWidget,
    this.errorWidget,
    this.threshold = 100,
  });

  @override
  State<AdmInfiniteScroll> createState() => _AdmInfiniteScrollState();
}

class _AdmInfiniteScrollState extends State<AdmInfiniteScroll> {
  _InfiniteScrollState _state = _InfiniteScrollState.idle;

  @override
  void initState() {
    super.initState();
    _trigger();
  }

  @override
  void didUpdateWidget(AdmInfiniteScroll old) {
    super.didUpdateWidget(old);
    if (old.hasMore != widget.hasMore || old.loadMore != widget.loadMore) {
      if (widget.hasMore && _state != _InfiniteScrollState.loading) {
        _trigger();
      }
    }
  }

  Future<void> _trigger() async {
    if (!widget.hasMore || _state == _InfiniteScrollState.loading) return;
    setState(() => _state = _InfiniteScrollState.loading);
    try {
      await widget.loadMore();
      if (mounted) {
        setState(() => _state = widget.hasMore
            ? _InfiniteScrollState.idle
            : _InfiniteScrollState.noMore);
      }
    } catch (_) {
      if (mounted) setState(() => _state = _InfiniteScrollState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    if (!widget.hasMore && _state == _InfiniteScrollState.noMore) {
      return widget.noMoreWidget ??
          Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.spaceLg),
            child: Center(
              child: Text(
                '— No more data —',
                style: TextStyle(
                  fontSize: tokens.fontSizeSm,
                  color: tokens.colorTextTertiary,
                ),
              ),
            ),
          );
    }

    if (_state == _InfiniteScrollState.error) {
      return widget.errorWidget ??
          GestureDetector(
            onTap: _trigger,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.spaceLg),
              child: Center(
                child: Text(
                  'Failed to load. Tap to retry.',
                  style: TextStyle(
                    fontSize: tokens.fontSizeSm,
                    color: tokens.colorDanger,
                  ),
                ),
              ),
            ),
          );
    }

    return widget.loadingWidget ??
        Padding(
          padding: EdgeInsets.symmetric(vertical: tokens.spaceLg),
          child: Center(
            child: AdmLoading(color: tokens.colorPrimary, size: 24),
          ),
        );
  }
}
