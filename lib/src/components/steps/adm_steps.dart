import 'package:flutter/material.dart';
import '../../theme/adm_theme.dart';

enum AdmStepStatus { wait, process, finish, error }
enum AdmStepsDirection { horizontal, vertical }

class AdmStepItem {
  final Widget title;
  final Widget? description;
  final Widget? icon;
  final AdmStepStatus status;

  const AdmStepItem({
    required this.title,
    this.description,
    this.icon,
    this.status = AdmStepStatus.wait,
  });
}

/// [AdmSteps] — equivalent to ant-design-mobile's `<Steps>`.
///
/// ```dart
/// AdmSteps(
///   current: 1,
///   items: const [
///     AdmStepItem(title: Text('Step 1'), description: Text('Done')),
///     AdmStepItem(title: Text('Step 2'), description: Text('In progress')),
///     AdmStepItem(title: Text('Step 3')),
///   ],
/// )
/// ```
class AdmSteps extends StatelessWidget {
  final List<AdmStepItem> items;
  final int current;
  final AdmStepsDirection direction;

  const AdmSteps({
    super.key,
    required this.items,
    this.current = 0,
    this.direction = AdmStepsDirection.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    if (direction == AdmStepsDirection.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(items.length, (i) {
          return _VerticalStep(
            item: items[i],
            index: i,
            current: current,
            isLast: i == items.length - 1,
            tokens: tokens,
          );
        }),
      );
    }

    return Row(
      children: List.generate(items.length, (i) {
        return Expanded(
          child: _HorizontalStep(
            item: items[i],
            index: i,
            current: current,
            isLast: i == items.length - 1,
            tokens: tokens,
          ),
        );
      }),
    );
  }
}

AdmStepStatus _resolveStatus(AdmStepItem item, int index, int current) {
  if (item.status != AdmStepStatus.wait) return item.status;
  if (index < current) return AdmStepStatus.finish;
  if (index == current) return AdmStepStatus.process;
  return AdmStepStatus.wait;
}

Color _statusColor(AdmStepStatus status, tokens) => switch (status) {
      AdmStepStatus.finish => tokens.colorPrimary,
      AdmStepStatus.process => tokens.colorPrimary,
      AdmStepStatus.error => tokens.colorDanger,
      AdmStepStatus.wait => tokens.colorTextDisabled,
    };

Widget _stepIcon(AdmStepItem item, int index, int current, tokens) {
  final status = _resolveStatus(item, index, current);
  final color = _statusColor(status, tokens);
  if (item.icon != null) {
    return IconTheme(data: IconThemeData(color: color, size: 20), child: item.icon!);
  }
  return Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: status == AdmStepStatus.process
          ? color
          : status == AdmStepStatus.finish
              ? color
              : Colors.transparent,
      border: Border.all(
        color: status == AdmStepStatus.wait ? tokens.colorBorder : color,
        width: 1.5,
      ),
    ),
    child: Center(
      child: status == AdmStepStatus.finish
          ? Icon(Icons.check, size: 13, color: tokens.colorTextWhite)
          : status == AdmStepStatus.error
              ? Icon(Icons.close, size: 13, color: color)
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    color: status == AdmStepStatus.process
                        ? tokens.colorTextWhite
                        : tokens.colorTextDisabled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
    ),
  );
}

class _HorizontalStep extends StatelessWidget {
  final AdmStepItem item;
  final int index, current;
  final bool isLast;
  final dynamic tokens;

  const _HorizontalStep({
    required this.item,
    required this.index,
    required this.current,
    required this.isLast,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final status = _resolveStatus(item, index, current);
    final textColor = status == AdmStepStatus.wait
        ? tokens.colorTextDisabled
        : status == AdmStepStatus.error
            ? tokens.colorDanger
            : tokens.colorTextBase;

    return Column(
      children: [
        Row(
          children: [
            if (index > 0)
              Expanded(
                child: Container(
                  height: 1,
                  color: index <= current
                      ? tokens.colorPrimary
                      : tokens.colorBorder,
                ),
              ),
            _stepIcon(item, index, current, tokens),
            if (!isLast)
              Expanded(
                child: Container(
                  height: 1,
                  color: index < current
                      ? tokens.colorPrimary
                      : tokens.colorBorder,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        DefaultTextStyle(
          style: TextStyle(
            fontSize: tokens.fontSizeXs,
            color: textColor,
            fontWeight: index == current
                ? tokens.fontWeightMedium
                : tokens.fontWeightNormal,
          ),
          textAlign: TextAlign.center,
          child: item.title,
        ),
        if (item.description != null)
          DefaultTextStyle(
            style: TextStyle(
                fontSize: tokens.fontSizeXs,
                color: tokens.colorTextTertiary),
            textAlign: TextAlign.center,
            child: item.description!,
          ),
      ],
    );
  }
}

class _VerticalStep extends StatelessWidget {
  final AdmStepItem item;
  final int index, current;
  final bool isLast;
  final dynamic tokens;

  const _VerticalStep({
    required this.item,
    required this.index,
    required this.current,
    required this.isLast,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final status = _resolveStatus(item, index, current);
    final textColor = status == AdmStepStatus.wait
        ? tokens.colorTextDisabled
        : status == AdmStepStatus.error
            ? tokens.colorDanger
            : tokens.colorTextBase;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _stepIcon(item, index, current, tokens),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: index < current
                        ? tokens.colorPrimary
                        : tokens.colorBorder,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: tokens.fontSizeMd,
                      color: textColor,
                      fontWeight: index == current
                          ? tokens.fontWeightMedium
                          : tokens.fontWeightNormal,
                    ),
                    child: item.title,
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 4),
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: tokens.fontSizeSm,
                        color: tokens.colorTextSecondary,
                      ),
                      child: item.description!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
