import 'package:flutter/material.dart';
import 'adm_theme_data.dart';
import 'adm_tokens.dart';

/// [AdmTheme] is the Flutter equivalent of ant-design-mobile's `ConfigProvider`.
///
/// Wrap your app (or any subtree) with [AdmTheme] to inject design tokens.
///
/// ```dart
/// AdmTheme(
///   data: AdmThemeData(
///     tokens: AdmTokens(colorPrimary: Color(0xFF06C755)),
///   ),
///   child: MaterialApp(...)
/// )
/// ```
class AdmTheme extends InheritedWidget {
  final AdmThemeData data;

  const AdmTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// Retrieve the nearest [AdmThemeData] from the widget tree.
  /// Falls back to a default light theme if none found.
  static AdmThemeData of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<AdmTheme>();
    return inherited?.data ?? const AdmThemeData();
  }

  /// Quick access to design tokens.
  static AdmTokens tokensOf(BuildContext context) => of(context).tokens;

  @override
  bool updateShouldNotify(AdmTheme oldWidget) => data != oldWidget.data;
}

/// Convenience widget that wraps [AdmTheme] + [MaterialApp].
///
/// ```dart
/// AdmApp(
///   themeData: AdmThemeData(),
///   home: MyHomePage(),
/// )
/// ```
class AdmApp extends StatelessWidget {
  final AdmThemeData themeData;
  final Widget home;
  final String title;
  final GlobalKey<NavigatorState>? navigatorKey;

  const AdmApp({
    super.key,
    this.themeData = const AdmThemeData(),
    required this.home,
    this.title = '',
    this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return AdmTheme(
      data: themeData,
      child: MaterialApp(
        title: title,
        navigatorKey: navigatorKey,
        theme: themeData.toMaterialTheme(),
        home: home,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
